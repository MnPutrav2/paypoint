class SaleTransaction {
  final int? id;
  final double total;
  final String date;

  SaleTransaction({this.id, required this.total, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'total': total, 'date': date};
  }

  factory SaleTransaction.fromMap(Map<String, dynamic> map) {
    return SaleTransaction(
      id: map['id'],
      total: map['total'],
      date: map['date'],
    );
  }
}
