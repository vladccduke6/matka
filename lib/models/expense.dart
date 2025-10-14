class Expense {
  final String id;
  final String journeyId;
  final String title;
  final double amount;
  final String currency;
  final DateTime date;
  final String paidBy;
  final List<String> sharedWith;

  const Expense({
    required this.id,
    required this.journeyId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    required this.paidBy,
    required this.sharedWith,
  });

  Expense copyWith({
    String? id,
    String? journeyId,
    String? title,
    double? amount,
    String? currency,
    DateTime? date,
    String? paidBy,
    List<String>? sharedWith,
  }) {
    return Expense(
      id: id ?? this.id,
      journeyId: journeyId ?? this.journeyId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      paidBy: paidBy ?? this.paidBy,
      sharedWith: sharedWith ?? List<String>.from(this.sharedWith),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'journeyId': journeyId,
        'title': title,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'paidBy': paidBy,
        'sharedWith': sharedWith,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as String,
        journeyId: map['journeyId'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        currency: map['currency'] as String,
        date: DateTime.parse(map['date'] as String),
        paidBy: map['paidBy'] as String,
        sharedWith: (map['sharedWith'] as List<dynamic>).cast<String>(),
      );
}
