class Transaction {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note, // optional
  });

  // Convert Dart object → database row
  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'type': type,
    'category': category,
    'date': date.toIso8601String(),
    'note': note,
  };

  // Convert database row → Dart object
  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    id: map['id'] as String,
    amount: map['amount'] as double,
    type: map['type'] as String,
    category: map['category'] as String,
    date: DateTime.parse(map['date'] as String),
    note: map['note'] as String?,
  );

  // Useful for editing — copy with changed fields
  Transaction copyWith({
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
  }) => Transaction(
    id: id,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    category: category ?? this.category,
    date: date ?? this.date,
    note: note ?? this.note,
  );
}
