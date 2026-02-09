import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/goal.dart';
import '../state/app_state.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const routeName = '/goals';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.profile!;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, appState),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Savings autoplan', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Save about ${appState.weeklySavingsTarget.toStringAsFixed(0)} '
                      '${profile.currency} each week to hit your goal.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (appState.goals.isEmpty)
              const Text('No goals yet. Add one to start saving.')
            else
              ...appState.goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GoalCard(
                    title: goal.title,
                    saved: goal.savedAmount,
                    target: goal.targetAmount,
                    progress: goal.progress,
                    currency: profile.currency,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddGoalDialog(BuildContext context, AppState appState) async {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final savedController = TextEditingController();

    final result = await showDialog<Goal>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Goal title'),
            ),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target amount'),
            ),
            TextField(
              controller: savedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Already saved'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final goal = Goal(
                id: const Uuid().v4(),
                title: titleController.text,
                targetAmount: double.tryParse(targetController.text) ?? 0,
                savedAmount: double.tryParse(savedController.text) ?? 0,
                targetDate: DateTime.now().add(const Duration(days: 150)),
              );
              Navigator.pop(context, goal);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final updated = [result, ...appState.goals];
      appState.updateGoals(updated);
    }
  }
}
