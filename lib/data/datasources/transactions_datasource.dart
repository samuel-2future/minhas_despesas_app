import 'package:minhas_despesas_app/data/services/supabase_service.dart';
import 'package:minhas_despesas_app/domain/entities/transaction.dart';

class TransactionsDataSource {
  final SupabaseService _supabaseService = SupabaseService();

  static const String _tableName = 'transactions';

  /// Insere uma nova transação no banco de dados
  Future<void> insertTransaction(Transaction transaction) async {
    try {
      await _supabaseService.client.from(_tableName).insert({
        'title': transaction.title,
        'category': transaction.category,
        'month': transaction.month.toIso8601String(),
        'is_paid': transaction.isPaid,
        'type': transaction.type.name,
        'payment_type': transaction.paymentType.name,
        'value': transaction.value,
        'created_at': transaction.createdAt?.toIso8601String(),
        'updated_at': transaction.updatedAt?.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar transação: $e');
    }
  }

  /// Obtém todas as transações do usuário
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .order('month', ascending: false);

      return (response as List)
          .map((data) => _mapToTransaction(data))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações: $e');
    }
  }

  /// Obtém transações de um mês específico
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final response = await _supabaseService.client
          .from(_tableName)
          .select()
          .gte('month', startOfMonth.toIso8601String())
          .lte('month', endOfMonth.toIso8601String())
          .order('month', ascending: false);

      return (response as List)
          .map((data) => _mapToTransaction(data))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações do mês: $e');
    }
  }

  /// Atualiza uma transação
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .update({
            'title': transaction.title,
            'category': transaction.category,
            'month': transaction.month.toIso8601String(),
            'is_paid': transaction.isPaid,
            'type': transaction.type.name,
            'payment_type': transaction.paymentType.name,
            'value': transaction.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transaction.id ?? '');
    } catch (e) {
      throw Exception('Erro ao atualizar transação: $e');
    }
  }

  /// Deleta uma transação
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _supabaseService.client
          .from(_tableName)
          .delete()
          .eq('id', transactionId);
    } catch (e) {
      throw Exception('Erro ao deletar transação: $e');
    }
  }

  /// Mapeia dados do Supabase para entidade Transaction
  Transaction _mapToTransaction(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'],
      title: data['title'],
      category: data['category'],
      month: DateTime.parse(data['month']),
      isPaid: data['is_paid'] ?? false,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.despesa,
      ),
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == data['payment_type'],
        orElse: () => PaymentType.pix,
      ),
      value: (data['value'] as num).toDouble(),
      createdAt:
          data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
      updatedAt:
          data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
    );
  }
}
