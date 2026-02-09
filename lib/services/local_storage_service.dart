import 'package:hive_flutter/hive_flutter.dart';

import '../models/budget.dart';
import '../models/goal.dart';
import '../models/recurring_template.dart';
import '../models/transaction_entry.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  static const _profileKey = 'profile';
  static const _transactionsKey = 'transactions';
  static const _budgetKey = 'budget';
  static const _goalsKey = 'goals';
  static const _consentKey = 'ai_consent';
  static const _recurringKey = 'recurring_templates';
  static const _alertsKey = 'budget_alerts';
  static const _syncKey = 'last_sync';

  final Box<Map> _box = Hive.box<Map>('finflow');

  UserProfile? loadProfile() {
    final raw = _box.get(_profileKey);
    if (raw == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _box.put(_profileKey, profile.toJson());
  }

  List<TransactionEntry> loadTransactions() {
    final raw = _box.get(_transactionsKey);
    if (raw == null) return [];
    final list = List<Map>.from(raw['items'] as List? ?? []);
    return list
        .map((item) => TransactionEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveTransactions(List<TransactionEntry> items) async {
    await _box.put(_transactionsKey, {
      'items': items.map((item) => item.toJson()).toList(),
    });
  }

  Budget loadBudget() {
    final raw = _box.get(_budgetKey);
    if (raw == null) {
      return Budget(monthlyLimit: 0, categoryLimits: {});
    }
    return Budget.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> saveBudget(Budget budget) async {
    await _box.put(_budgetKey, budget.toJson());
  }

  List<Goal> loadGoals() {
    final raw = _box.get(_goalsKey);
    if (raw == null) return [];
    final list = List<Map>.from(raw['items'] as List? ?? []);
    return list.map((item) => Goal.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    await _box.put(_goalsKey, {
      'items': goals.map((goal) => goal.toJson()).toList(),
    });
  }

  List<RecurringTemplate> loadRecurringTemplates() {
    final raw = _box.get(_recurringKey);
    if (raw == null) return [];
    final list = List<Map>.from(raw['items'] as List? ?? []);
    return list
        .map((item) => RecurringTemplate.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveRecurringTemplates(List<RecurringTemplate> templates) async {
    await _box.put(_recurringKey, {
      'items': templates.map((item) => item.toJson()).toList(),
    });
  }

  bool loadConsent() => (_box.get(_consentKey)?['value'] as bool?) ?? false;

  Future<void> saveConsent(bool value) async {
    await _box.put(_consentKey, {'value': value});
  }

  bool loadAlertsEnabled() => (_box.get(_alertsKey)?['value'] as bool?) ?? true;

  Future<void> saveAlertsEnabled(bool value) async {
    await _box.put(_alertsKey, {'value': value});
  }

  String loadLastSyncAt() => (_box.get(_syncKey)?['value'] as String?) ?? '';

  Future<void> saveLastSyncAt(String value) async {
    await _box.put(_syncKey, {'value': value});
  }
}
