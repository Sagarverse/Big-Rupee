import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/categories.dart';
import '../models/ai_insight.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/recurring_template.dart';
import '../models/transaction_entry.dart';
import '../models/user_profile.dart';
import '../services/ai_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';

class AppState extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final Uuid _uuid = const Uuid();

  UserProfile? profile;
  List<TransactionEntry> transactions = [];
  Budget budget = Budget(monthlyLimit: 0, categoryLimits: {});
  List<Goal> goals = [];
  List<RecurringTemplate> recurringTemplates = [];
  AiInsight insight = AiInsight.empty();
  bool aiConsent = false;
  bool alertsEnabled = true;
  String lastSyncedAt = '';
  String? _authToken;

  bool get isProfileReady => profile != null;
  bool get isSignedIn => _authToken != null;

  String get monthLabel => DateFormat('MMMM yyyy').format(DateTime.now());

  double get totalIncome => _sumByType(TransactionType.income);
  double get totalExpenses => _sumByType(TransactionType.expense);
  double get remainingBalance => totalIncome - totalExpenses;
  double get effectiveMonthlyBudget => budget.monthlyLimit + budget.carryoverAmount;
  double get weeklySavingsTarget => profile == null ? 0 : profile!.savingsGoal / 4;

  Map<String, double> get expenseByCategory {
    final Map<String, double> totals = {};
    for (final entry in _currentMonthTransactions(TransactionType.expense)) {
      totals.update(entry.category, (value) => value + entry.amount, ifAbsent: () => entry.amount);
    }
    for (final category in expenseCategories) {
      totals.putIfAbsent(category, () => 0);
    }
    return totals;
  }

  Future<void> load() async {
    profile = _storage.loadProfile();
    transactions = _storage.loadTransactions();
    budget = _storage.loadBudget();
    goals = _storage.loadGoals();
    recurringTemplates = _storage.loadRecurringTemplates();
    aiConsent = _storage.loadConsent();
    alertsEnabled = _storage.loadAlertsEnabled();
    lastSyncedAt = _storage.loadLastSyncAt();
    await _applyRolloverIfNeeded();
    await _applyRecurringTransactionsIfNeeded();
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    profile = newProfile;
    await _storage.saveProfile(newProfile);
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required TransactionType type,
    DateTime? date,
    String? recurringId,
  }) async {
    final entry = TransactionEntry(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      type: type,
      recurringId: recurringId,
    );
    transactions = [entry, ...transactions];
    await _storage.saveTransactions(transactions);
    await _maybeNotifyBudgetAlert(entry);
    notifyListeners();
  }

  Future<void> updateBudget(Budget updated) async {
    budget = updated;
    await _storage.saveBudget(updated);
    notifyListeners();
  }

  Future<void> updateGoals(List<Goal> updated) async {
    goals = updated;
    await _storage.saveGoals(updated);
    notifyListeners();
  }

  Future<void> updateConsent(bool value) async {
    aiConsent = value;
    await _storage.saveConsent(value);
    notifyListeners();
  }

  Future<void> updateAlerts(bool value) async {
    alertsEnabled = value;
    await _storage.saveAlertsEnabled(value);
    notifyListeners();
  }

  Future<void> addRecurringTemplate(RecurringTemplate template) async {
    recurringTemplates = [template, ...recurringTemplates];
    await _storage.saveRecurringTemplates(recurringTemplates);
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final signIn = GoogleSignIn(scopes: ['email']);
    final account = await signIn.signIn();
    if (account == null) return;
    final auth = await account.authentication;
    _authToken = auth.idToken;
    notifyListeners();
  }

  Future<void> requestAiInsight() async {
    if (profile == null || !aiConsent) return;

    final aiService = AiService(
      baseUrl: 'http://localhost:8000',
      authToken: _authToken,
      consent: aiConsent,
    );

    final payload = {
      'user_age': profile!.age,
      'is_student': profile!.isStudent,
      'monthly_income': profile!.monthlyIncome,
      'expenses': expenseByCategory,
      'monthly_budget': budget.monthlyLimit,
      'savings_goal': profile!.savingsGoal,
      'historical_data': [],
    };

    insight = await aiService.fetchInsights(payload);
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_authToken == null) {
      throw Exception('Sign in required');
    }
    final service = SyncService(baseUrl: 'http://localhost:8000', authToken: _authToken);
    final payload = {
      'profile': profile?.toJson(),
      'budget': budget.toJson(),
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'transactions': transactions.map((item) => item.toJson()).toList(),
      'recurring_templates': recurringTemplates.map((item) => item.toJson()).toList(),
    };
    final data = await service.sync(payload);
    if (data['profile'] != null) {
      profile = UserProfile.fromJson(Map<String, dynamic>.from(data['profile']));
      await _storage.saveProfile(profile!);
    }
    if (data['budget'] != null) {
      budget = Budget.fromJson(Map<String, dynamic>.from(data['budget']));
      await _storage.saveBudget(budget);
    }
    if (data['goals'] != null) {
      goals = List<Map>.from(data['goals'] as List)
          .map((item) => Goal.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      await _storage.saveGoals(goals);
    }
    if (data['transactions'] != null) {
      transactions = List<Map>.from(data['transactions'] as List)
          .map((item) => TransactionEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      await _storage.saveTransactions(transactions);
    }
    if (data['recurring_templates'] != null) {
      recurringTemplates = List<Map>.from(data['recurring_templates'] as List)
          .map((item) => RecurringTemplate.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      await _storage.saveRecurringTemplates(recurringTemplates);
    }
    lastSyncedAt = DateTime.now().toIso8601String();
    await _storage.saveLastSyncAt(lastSyncedAt);
    notifyListeners();
  }

  double _sumByType(TransactionType type) {
    return _currentMonthTransactions(type)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
  }

  Iterable<TransactionEntry> _currentMonthTransactions(TransactionType type) {
    final now = DateTime.now();
    return transactions.where((entry) {
      return entry.type == type &&
          entry.date.year == now.year &&
          entry.date.month == now.month;
    });
  }

  Iterable<TransactionEntry> _previousMonthTransactions(TransactionType type) {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    return transactions.where((entry) {
      return entry.type == type &&
          entry.date.year == previousMonth.year &&
          entry.date.month == previousMonth.month;
    });
  }

  Future<void> _applyRolloverIfNeeded() async {
    if (!budget.rolloverEnabled) return;
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    if (budget.lastRolloverMonth == currentMonth) return;
    final prevSpent = _previousMonthTransactions(TransactionType.expense)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final carryover = (budget.monthlyLimit - prevSpent).clamp(0, double.infinity).toDouble();
    budget = Budget(
      monthlyLimit: budget.monthlyLimit,
      categoryLimits: budget.categoryLimits,
      rolloverEnabled: budget.rolloverEnabled,
      carryoverAmount: carryover,
      lastRolloverMonth: currentMonth,
    );
    await _storage.saveBudget(budget);
  }

  Future<void> _applyRecurringTransactionsIfNeeded() async {
    if (recurringTemplates.isEmpty) return;
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    var updatedTemplates = List<RecurringTemplate>.from(recurringTemplates);
    var updatedTransactions = List<TransactionEntry>.from(transactions);

    for (var i = 0; i < updatedTemplates.length; i += 1) {
      final template = updatedTemplates[i];
      if (template.lastAppliedMonth == currentMonth) continue;
      final date = DateTime(now.year, now.month, template.dayOfMonth);
      final exists = updatedTransactions.any((entry) {
        return entry.recurringId == template.id &&
            entry.date.year == now.year &&
            entry.date.month == now.month;
      });
      if (exists) continue;
      final entry = TransactionEntry(
        id: _uuid.v4(),
        title: template.title,
        amount: template.amount,
        category: template.category,
        date: date,
        type: template.type,
        recurringId: template.id,
      );
      updatedTransactions.insert(0, entry);
      updatedTemplates[i] = RecurringTemplate(
        id: template.id,
        title: template.title,
        amount: template.amount,
        category: template.category,
        type: template.type,
        dayOfMonth: template.dayOfMonth,
        lastAppliedMonth: currentMonth,
      );
    }

    transactions = updatedTransactions;
    recurringTemplates = updatedTemplates;
    await _storage.saveTransactions(transactions);
    await _storage.saveRecurringTemplates(recurringTemplates);
  }

  Future<void> _maybeNotifyBudgetAlert(TransactionEntry entry) async {
    if (!alertsEnabled || entry.type != TransactionType.expense) return;
    final categoryLimit = budget.categoryLimits[entry.category] ?? 0;
    final categorySpent = expenseByCategory[entry.category] ?? 0;
    if (categoryLimit > 0 && categorySpent >= categoryLimit) {
      await NotificationService.instance.showBudgetAlert(
        'Budget limit reached',
        'You have hit the ${entry.category} budget.',
      );
      return;
    }
    if (effectiveMonthlyBudget > 0 && totalExpenses >= effectiveMonthlyBudget) {
      await NotificationService.instance.showBudgetAlert(
        'Monthly budget alert',
        'You have used your monthly budget.',
      );
    }
  }
}
