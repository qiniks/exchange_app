class Currency {
  final int id;
  final String code;

  Currency({required this.id, required this.code});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      code: json['code'],
    );
  }
}
