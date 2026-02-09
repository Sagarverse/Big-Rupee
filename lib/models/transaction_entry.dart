enum TransactionType { income, expense }

class TransactionEntry {
  TransactionEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.recurringId,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;
  final String? recurringId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'type': type.name,
      'recurringId': recurringId,
      };

  factory TransactionEntry.fromJson(Map<String, dynamic> json) => TransactionEntry(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        category: json['category'] as String? ?? 'Miscellaneous',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        type: TransactionType.values.firstWhere(
          (value) => value.name == json['type'],
          orElse: () => TransactionType.expense,
        ),
        recurringId: json['recurringId'] as String?,
      );
}
