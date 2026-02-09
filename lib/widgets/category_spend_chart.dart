import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/categories.dart';

class CategorySpendChart extends StatelessWidget {
  const CategorySpendChart({
    super.key,
    required this.data,
  });

  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];
    final colors = [
      const Color(0xFF4F46E5),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFF0EA5E9),
      const Color(0xFF9333EA),
      const Color(0xFFF97316),
      const Color(0xFF64748B),
    ];

    var index = 0;
    data.forEach((category, amount) {
      if (amount <= 0) return;
      sections.add(
        PieChartSectionData(
          value: amount,
          radius: 50,
          color: colors[index % colors.length],
          title: category,
          titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
      index += 1;
    });

    if (sections.isEmpty) {
      return const Center(child: Text('Add expenses to see the chart.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 24,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: expenseCategories
              .map((category) => _LegendItem(
                    label: category,
                    color: colors[expenseCategories.indexOf(category) % colors.length],
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
