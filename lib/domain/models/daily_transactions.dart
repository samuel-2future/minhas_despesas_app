import 'package:minhas_despesas_app/domain/entities/transaction.dart';

class DailyTransactions {
  final DateTime date;
  final List<Transaction> transactions;

  DailyTransactions({
    required this.date,
    required this.transactions,
  });

  double get totalAmount => transactions.fold(
    0,
    (sum, t) => sum +
        (t.type == TransactionType.receita ? t.value : -t.value),
  );
}
