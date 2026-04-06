class Budget {
  final String id;
  final int month;
  final int year;
  final double amount;

  Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'month': month, 'year': year, 'amount': amount};
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      month: map['month'],
      year: map['year'],
      amount: map['amount'],
    );
  }
}
