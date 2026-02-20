import 'package:flutter/material.dart';
import 'package:minhas_despesas_app/domain/models/dashboard_data.dart';
import 'package:minhas_despesas_app/domain/models/daily_transactions.dart';
import 'package:minhas_despesas_app/domain/entities/transaction.dart';
import 'package:minhas_despesas_app/data/datasources/transactions_datasource.dart';

class DashboardViewModel extends ChangeNotifier {
  late DashboardData _dashboardData;
  late List<DailyTransactions> _dailyTransactions;
  bool _isLoading = true;
  bool _isCalendarView = false;
  String? _errorMessage;
  
  final TransactionsDataSource _dataSource = TransactionsDataSource();

  DashboardData get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  bool get isCalendarView => _isCalendarView;
  List<DailyTransactions> get dailyTransactions => _dailyTransactions;
  String? get errorMessage => _errorMessage;

  DashboardViewModel() {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transactions = await _dataSource.getTransactions();
      
      if (transactions.isEmpty) {
        // Se não há transações, usar dados mockados para demo
        _dashboardData = _generateMockedData();
        _dailyTransactions = _generateDailyTransactions();
      } else {
        _dashboardData = _processTransactionsToDashboardData(transactions);
        _dailyTransactions = _processTransactionsToDailyTransactions(transactions);
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do Supabase: $e');
      _errorMessage = 'Erro ao carregar dados. Usando dados de demonstração.';
      // Fallback para dados mockados em caso de erro
      _dashboardData = _generateMockedData();
      _dailyTransactions = _generateDailyTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DashboardData _generateMockedData() {
    final now = DateTime.now();

    // Dados por categoria
    final categorySpending = [
      CategorySpending(
        category: 'Alimentação',
        value: 850.50,
        transactions: 15,
      ),
      CategorySpending(
        category: 'Transporte',
        value: 420.00,
        transactions: 8,
      ),
      CategorySpending(
        category: 'Lazer',
        value: 350.00,
        transactions: 5,
      ),
      CategorySpending(
        category: 'Saúde',
        value: 280.00,
        transactions: 4,
      ),
      CategorySpending(
        category: 'Educação',
        value: 500.00,
        transactions: 3,
      ),
      CategorySpending(
        category: 'Utilidades',
        value: 150.00,
        transactions: 2,
      ),
    ];

    // Dados mensais (últimos 6 meses)
    final monthlyData = [
      MonthlyData(
        month: DateTime(now.year, now.month - 5),
        income: 3500.00,
        expenses: 2100.00,
      ),
      MonthlyData(
        month: DateTime(now.year, now.month - 4),
        income: 3500.00,
        expenses: 2350.00,
      ),
      MonthlyData(
        month: DateTime(now.year, now.month - 3),
        income: 3500.00,
        expenses: 1950.00,
      ),
      MonthlyData(
        month: DateTime(now.year, now.month - 2),
        income: 3500.00,
        expenses: 2600.00,
      ),
      MonthlyData(
        month: DateTime(now.year, now.month - 1),
        income: 3500.00,
        expenses: 2080.00,
      ),
      MonthlyData(
        month: now,
        income: 3500.00,
        expenses: 2550.00,
      ),
    ];

    final totalExpenses = categorySpending.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    final totalIncome = monthlyData.fold<double>(
      0,
      (sum, item) => sum + item.income,
    );

    return DashboardData(
      totalBalance: totalIncome - totalExpenses,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      categorySpending: categorySpending,
      monthlyData: monthlyData,
    );
  }

  Future<void> refresh() async {
    await _loadDashboardData();
  }

  void toggleView() {
    _isCalendarView = !_isCalendarView;
    notifyListeners();
  }

  DashboardData _processTransactionsToDashboardData(List<Transaction> transactions) {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    // Filtrar transações dos últimos 6 meses
    final recentTransactions = transactions
        .where((t) => t.month.isAfter(sixMonthsAgo) || t.month.month == sixMonthsAgo.month)
        .toList();

    // Agrupar por categoria
    final categoryMap = <String, List<Transaction>>{};
    for (var transaction in recentTransactions) {
      if (transaction.type == TransactionType.despesa) {
        categoryMap.putIfAbsent(transaction.category, () => []);
        categoryMap[transaction.category]!.add(transaction);
      }
    }

    // Converter para CategorySpending
    final categorySpending = categoryMap.entries
        .map((entry) => CategorySpending(
              category: entry.key,
              value: entry.value.fold(0.0, (sum, t) => sum + t.value),
              transactions: entry.value.length,
            ))
        .toList();

    // Agrupar por mês para MonthlyData
    final monthMap = <String, Map<String, double>>{};
    for (var transaction in recentTransactions) {
      final monthKey = '${transaction.month.year}-${transaction.month.month}';
      monthMap.putIfAbsent(monthKey, () => {'income': 0.0, 'expenses': 0.0});

      if (transaction.type == TransactionType.receita) {
        monthMap[monthKey]!['income'] = monthMap[monthKey]!['income']! + transaction.value;
      } else {
        monthMap[monthKey]!['expenses'] = monthMap[monthKey]!['expenses']! + transaction.value;
      }
    }

    final monthlyData = <MonthlyData>[];
    for (int i = -5; i <= 0; i++) {
      final month = DateTime(now.year, now.month + i, 1);
      final monthKey = '${month.year}-${month.month}';
      final data = monthMap[monthKey];

      monthlyData.add(MonthlyData(
        month: month,
        income: data?['income'] ?? 0.0,
        expenses: data?['expenses'] ?? 0.0,
      ));
    }

    final totalExpenses = categorySpending.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    final totalIncome = monthlyData.fold<double>(
      0,
      (sum, item) => sum + item.income,
    );

    return DashboardData(
      totalBalance: totalIncome - totalExpenses,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      categorySpending: categorySpending,
      monthlyData: monthlyData,
    );
  }

  List<DailyTransactions> _processTransactionsToDailyTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    final dailyMap = <DateTime, List<Transaction>>{};

    // Agrupar transações por dia (apenas do mês atual)
    for (var transaction in transactions) {
      if (transaction.month.year == now.year && transaction.month.month == now.month) {
        final dateKey = DateTime(now.year, now.month, transaction.month.day);
        dailyMap.putIfAbsent(dateKey, () => []);
        dailyMap[dateKey]!.add(transaction);
      }
    }

    // Converter para list de DailyTransactions
    final dailyList = dailyMap.entries
        .map((entry) => DailyTransactions(
              date: entry.key,
              transactions: entry.value,
            ))
        .toList();

    // Ordenar por data
    dailyList.sort((a, b) => a.date.compareTo(b.date));

    return dailyList;
  }

  List<DailyTransactions> _generateDailyTransactions() {
    final now = DateTime.now();
    final dailyList = <DailyTransactions>[];

    // Gerar transações para cada dia do mês atual
    final lastDay = DateTime(now.year, now.month + 1, 0);

    for (int i = 1; i <= lastDay.day; i++) {
      final date = DateTime(now.year, now.month, i);
      final transactions = <Transaction>[];

      // Adicionar transações mockadas em alguns dias
      if (i % 3 == 0) {
        transactions.add(
          Transaction(
            title: 'Compras Supermercado',
            category: 'Alimentação',
            month: date,
            isPaid: true,
            type: TransactionType.despesa,
            paymentType: PaymentType.creditCardSpot,
            value: 150.50,
          ),
        );
      }
      if (i % 5 == 0) {
        transactions.add(
          Transaction(
            title: 'Passagem Ônibus',
            category: 'Transporte',
            month: date,
            isPaid: true,
            type: TransactionType.despesa,
            paymentType: PaymentType.pix,
            value: 8.50,
          ),
        );
      }
      if (i % 7 == 0) {
        transactions.add(
          Transaction(
            title: 'Salário',
            category: 'Outras',
            month: date,
            isPaid: true,
            type: TransactionType.receita,
            paymentType: PaymentType.pix,
            value: 3500.00,
          ),
        );
      }
      if (i % 2 == 0 && i % 5 != 0) {
        transactions.add(
          Transaction(
            title: 'Cinema',
            category: 'Lazer',
            month: date,
            isPaid: true,
            type: TransactionType.despesa,
            paymentType: PaymentType.debit,
            value: 45.00,
          ),
        );
      }

      if (transactions.isNotEmpty) {
        dailyList.add(
          DailyTransactions(
            date: date,
            transactions: transactions,
          ),
        );
      }
    }

    return dailyList;
  }
}
