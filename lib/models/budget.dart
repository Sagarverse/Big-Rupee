class Budget {
  Budget({
    required this.monthlyLimit,
    required this.categoryLimits,
    this.rolloverEnabled = false,
    this.carryoverAmount = 0,
    this.lastRolloverMonth = '',
  });

  final double monthlyLimit;
  final Map<String, double> categoryLimits;
  final bool rolloverEnabled;
  final double carryoverAmount;
  final String lastRolloverMonth;

  Map<String, dynamic> toJson() => {
        'monthlyLimit': monthlyLimit,
        'categoryLimits': categoryLimits,
      'rolloverEnabled': rolloverEnabled,
      'carryoverAmount': carryoverAmount,
      'lastRolloverMonth': lastRolloverMonth,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 0,
        categoryLimits: Map<String, dynamic>.from(json['categoryLimits'] as Map? ?? {})
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
      rolloverEnabled: json['rolloverEnabled'] as bool? ?? false,
      carryoverAmount: (json['carryoverAmount'] as num?)?.toDouble() ?? 0,
      lastRolloverMonth: json['lastRolloverMonth'] as String? ?? '',
      );
}
