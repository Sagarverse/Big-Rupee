import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../services/report_service.dart';
import '../models/transaction_entry.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const routeName = '/reports';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.profile!;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share your progress', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Generate a weekly or monthly PDF summary to keep track or share with family.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _shareMonthly(context, appState),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Share monthly report'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _shareWeekly(context, appState),
                icon: const Icon(Icons.calendar_view_week_outlined),
                label: const Text('Share weekly report'),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Savings autoplan', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Aim to save about ${appState.weeklySavingsTarget.toStringAsFixed(0)} '
                        '${profile.currency} per week to hit your goal.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareMonthly(BuildContext context, AppState appState) async {
    final profile = appState.profile!;
    await ReportService().shareMonthlyReport(
      title: 'Monthly report - ${appState.monthLabel}',
      currency: profile.currency,
      income: appState.totalIncome,
      expenses: appState.totalExpenses,
      categoryTotals: appState.expenseByCategory,
      recent: appState.transactions.take(6).toList(),
    );
  }

  Future<void> _shareWeekly(BuildContext context, AppState appState) async {
    final profile = appState.profile!;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recent = appState.transactions
        .where((entry) => entry.date.isAfter(weekAgo))
        .toList();
    final weeklyIncome = recent
      .where((entry) => entry.type == TransactionType.income)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final weeklyExpenses = recent
      .where((entry) => entry.type == TransactionType.expense)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    await ReportService().shareMonthlyReport(
      title: 'Weekly report',
      currency: profile.currency,
      income: weeklyIncome,
      expenses: weeklyExpenses,
      categoryTotals: appState.expenseByCategory,
      recent: recent.take(6).toList(),
    );
  }
}
