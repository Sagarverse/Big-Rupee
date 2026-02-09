import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.title,
    required this.saved,
    required this.target,
    required this.progress,
    required this.currency,
  });

  final String title;
  final double saved;
  final double target;
  final double progress;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: currency);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Text('${formatter.format(saved)} / ${formatter.format(target)}'),
          ],
        ),
      ),
    );
  }
}
