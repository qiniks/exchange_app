class Transaction {
  final int id;
  final int user;
  final String currency;
  final String operationType;
  final double amount;
  final double rate;
  final double total;
  final String date;

  Transaction({
    required this.id,
    required this.user,
    required this.currency,
    required this.operationType,
    required this.amount,
    required this.rate,
    required this.total,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      user: json['user'],
      currency: json['currency'],
      operationType: json['operation_type'],
      amount: double.parse(json['amount']),
      rate: double.parse(json['rate']),
      total: double.parse(json['total']),
      date: json['date'],
    );
  }
}
