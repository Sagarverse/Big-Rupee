import 'transaction_entry.dart';

class RecurringTemplate {
  RecurringTemplate({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.dayOfMonth,
    required this.lastAppliedMonth,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final int dayOfMonth;
  final String lastAppliedMonth;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'type': type.name,
        'dayOfMonth': dayOfMonth,
        'lastAppliedMonth': lastAppliedMonth,
      };

  factory RecurringTemplate.fromJson(Map<String, dynamic> json) => RecurringTemplate(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        category: json['category'] as String? ?? 'Miscellaneous',
        type: TransactionType.values.firstWhere(
          (value) => value.name == json['type'],
          orElse: () => TransactionType.expense,
        ),
        dayOfMonth: json['dayOfMonth'] as int? ?? 1,
        lastAppliedMonth: json['lastAppliedMonth'] as String? ?? '',
      );
}
