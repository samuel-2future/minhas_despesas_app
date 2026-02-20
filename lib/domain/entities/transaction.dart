enum TransactionType {
  despesa('Despesa'),
  receita('Receita');

  final String label;
  const TransactionType(this.label);
}

enum PaymentType {
  creditCardInstallments('Cartão Crédito Parcelado'),
  creditCardSpot('Cartão Crédito à Vista'),
  debit('Débito'),
  pix('PIX');

  final String label;
  const PaymentType(this.label);
}

class Transaction {
  final String? id;
  final String title;
  final String category;
  final DateTime month;
  final bool isPaid;
  final TransactionType type;
  final PaymentType paymentType;
  final double value;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Transaction({
    this.id,
    required this.title,
    required this.category,
    required this.month,
    required this.isPaid,
    required this.type,
    required this.paymentType,
    required this.value,
    this.createdAt,
    this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? month,
    bool? isPaid,
    TransactionType? type,
    PaymentType? paymentType,
    double? value,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      month: month ?? this.month,
      isPaid: isPaid ?? this.isPaid,
      type: type ?? this.type,
      paymentType: paymentType ?? this.paymentType,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, category: $category, month: $month, isPaid: $isPaid, type: $type, paymentType: $paymentType, value: $value)';
  }
}
