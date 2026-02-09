import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceHeader extends StatelessWidget {
  const BalanceHeader({
    super.key,
    required this.currency,
    required this.balance,
    required this.monthLabel,
  });

  final String currency;
  final double balance;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: currency);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatter.format(balance)} remaining',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
