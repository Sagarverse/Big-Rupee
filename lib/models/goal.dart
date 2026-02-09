class Goal {
  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;

  double get progress => targetAmount == 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'targetDate': targetDate.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
        targetDate: DateTime.tryParse(json['targetDate'] as String? ?? '') ?? DateTime.now(),
      );
}
