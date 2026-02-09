class UserProfile {
  UserProfile({
    required this.age,
    required this.isStudent,
    required this.monthlyIncome,
    required this.currency,
    required this.savingsGoal,
  });

  final int age;
  final bool isStudent;
  final double monthlyIncome;
  final String currency;
  final double savingsGoal;

  Map<String, dynamic> toJson() => {
        'age': age,
        'isStudent': isStudent,
        'monthlyIncome': monthlyIncome,
        'currency': currency,
        'savingsGoal': savingsGoal,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        age: json['age'] as int? ?? 0,
        isStudent: json['isStudent'] as bool? ?? true,
        monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'USD',
        savingsGoal: (json['savingsGoal'] as num?)?.toDouble() ?? 0,
      );
}
