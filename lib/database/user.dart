class User {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String? photoPath; // Local file path to photo
  final double monthlyBudget;
  final String currency; // ₹, $, €, £, etc.

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.photoPath,
    required this.monthlyBudget,
    required this.currency,
  });

  // Convert to database map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'photoPath': photoPath,
    'monthlyBudget': monthlyBudget,
    'currency': currency,
  };

  // Convert from database map
  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] as String,
    name: map['name'] as String,
    age: map['age'] as int,
    gender: map['gender'] as String,
    photoPath: map['photoPath'] as String?,
    monthlyBudget: map['monthlyBudget'] as double,
    currency: map['currency'] as String,
  );

  // Copy with changed fields
  User copyWith({
    String? name,
    int? age,
    String? gender,
    String? photoPath,
    double? monthlyBudget,
    String? currency,
  }) => User(
    id: id,
    name: name ?? this.name,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    photoPath: photoPath ?? this.photoPath,
    monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    currency: currency ?? this.currency,
  );
}
