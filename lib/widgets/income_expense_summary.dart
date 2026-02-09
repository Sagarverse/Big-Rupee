import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeExpenseSummary extends StatelessWidget {
  const IncomeExpenseSummary({
    super.key,
    required this.currency,
    required this.income,
    required this.expenses,
  });

  final String currency;
  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: currency);
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Income',
            value: formatter.format(income),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: 'Expenses',
            value: formatter.format(expenses),
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
