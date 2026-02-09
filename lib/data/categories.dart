import 'package:flutter/material.dart';

const List<String> expenseCategories = [
  'Food',
  'Rent',
  'Transport',
  'Education',
  'Subscriptions',
  'Entertainment',
  'Miscellaneous',
];

const List<String> incomeCategories = [
  'Allowance',
  'Stipend',
  'Job',
  'Other',
];

const Map<String, IconData> categoryIcons = {
  'Food': Icons.lunch_dining_outlined,
  'Rent': Icons.home_outlined,
  'Transport': Icons.directions_bus_outlined,
  'Education': Icons.school_outlined,
  'Subscriptions': Icons.subscriptions_outlined,
  'Entertainment': Icons.movie_outlined,
  'Miscellaneous': Icons.more_horiz,
  'Allowance': Icons.card_giftcard_outlined,
  'Stipend': Icons.work_outline,
  'Job': Icons.badge_outlined,
  'Other': Icons.attach_money,
};
