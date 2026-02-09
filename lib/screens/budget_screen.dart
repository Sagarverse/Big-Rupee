import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/categories.dart';
import '../models/budget.dart';
import '../state/app_state.dart';
import '../widgets/budget_category_tile.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  static const routeName = '/budget';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.profile!;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: ListTile(
                title: const Text('Monthly budget'),
                subtitle: Text(appState.effectiveMonthlyBudget.toStringAsFixed(2)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editMonthlyBudget(context, appState),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: appState.budget.rolloverEnabled,
              onChanged: (value) {
                appState.updateBudget(
                  Budget(
                    monthlyLimit: appState.budget.monthlyLimit,
                    categoryLimits: appState.budget.categoryLimits,
                    rolloverEnabled: value,
                    carryoverAmount: appState.budget.carryoverAmount,
                    lastRolloverMonth: appState.budget.lastRolloverMonth,
                  ),
                );
              },
              title: const Text('Enable rollover'),
              subtitle: Text(
                'Carry over unused budget (${profile.currency} '
                '${appState.budget.carryoverAmount.toStringAsFixed(0)})',
              ),
            ),
            const SizedBox(height: 16),
            Text('Category limits', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...expenseCategories.map((category) {
              final limit = appState.budget.categoryLimits[category] ?? 0;
              final spent = appState.expenseByCategory[category] ?? 0;
              return Column(
                children: [
                  BudgetCategoryTile(
                    category: category,
                    spent: spent,
                    limit: limit,
                    currency: profile.currency,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _editCategoryLimit(context, appState, category, limit),
                      child: const Text('Edit limit'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _editMonthlyBudget(BuildContext context, AppState appState) async {
    final controller = TextEditingController(text: appState.budget.monthlyLimit.toStringAsFixed(0));
    final value = await _showNumberDialog(context, 'Monthly budget', controller);
    if (value == null) return;
    final updated = Budget(
      monthlyLimit: value,
      categoryLimits: appState.budget.categoryLimits,
      rolloverEnabled: appState.budget.rolloverEnabled,
      carryoverAmount: appState.budget.carryoverAmount,
      lastRolloverMonth: appState.budget.lastRolloverMonth,
    );
    appState.updateBudget(updated);
  }

  Future<void> _editCategoryLimit(
    BuildContext context,
    AppState appState,
    String category,
    double current,
  ) async {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    final value = await _showNumberDialog(context, '$category limit', controller);
    if (value == null) return;
    final updatedLimits = Map<String, double>.from(appState.budget.categoryLimits);
    updatedLimits[category] = value;
    appState.updateBudget(
      Budget(
        monthlyLimit: appState.budget.monthlyLimit,
        categoryLimits: updatedLimits,
        rolloverEnabled: appState.budget.rolloverEnabled,
        carryoverAmount: appState.budget.carryoverAmount,
        lastRolloverMonth: appState.budget.lastRolloverMonth,
      ),
    );
  }

  Future<double?> _showNumberDialog(
    BuildContext context,
    String title,
    TextEditingController controller,
  ) async {
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text);
              Navigator.pop(context, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
