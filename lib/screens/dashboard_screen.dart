import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/transaction_entry.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/balance_header.dart';
import '../widgets/category_spend_chart.dart';
import '../widgets/income_expense_summary.dart';
import 'add_expense_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.profile!;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AddExpenseScreen.routeName),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            BalanceHeader(
              currency: profile.currency,
              balance: appState.remainingBalance,
              monthLabel: appState.monthLabel,
            ),
            const SizedBox(height: 16),
            IncomeExpenseSummary(
              currency: profile.currency,
              income: appState.totalIncome,
              expenses: appState.totalExpenses,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CategorySpendChart(data: appState.expenseByCategory),
              ),
            ),
            const SizedBox(height: 16),
            AiInsightCard(
              title: 'Quick insight',
              body: appState.insight.summary,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(ReportsScreen.routeName),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Open reports'),
            ),
            const SizedBox(height: 16),
            Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (appState.transactions.isEmpty)
              const Text('No transactions yet. Add your first one.')
            else
              ...appState.transactions.take(4).map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.title),
                      subtitle: Text(entry.category),
                      trailing: Text(
                        '${entry.type == TransactionType.expense ? '-' : '+'}${entry.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: entry.type == TransactionType.expense
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
