import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetCategoryTile extends StatelessWidget {
  const BudgetCategoryTile({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.currency,
  });

  final String category;
  final double spent;
  final double limit;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: currency);
    final progress = limit == 0 ? 0.0 : (spent / limit).clamp(0, 1).toDouble();
    final Color barColor;
    if (progress < 0.7) {
      barColor = Theme.of(context).colorScheme.secondary;
    } else if (progress < 1) {
      barColor = const Color(0xFFF59E0B);
    } else {
      barColor = Theme.of(context).colorScheme.error;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: barColor,
            ),
            const SizedBox(height: 8),
            Text('${formatter.format(spent)} / ${formatter.format(limit)}'),
          ],
        ),
      ),
    );
  }
}
