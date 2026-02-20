class CategorySpending {
  final String category;
  final double value;
  final int transactions;

  const CategorySpending({
    required this.category,
    required this.value,
    required this.transactions,
  });
}

class MonthlyData {
  final DateTime month;
  final double income;
  final double expenses;

  const MonthlyData({
    required this.month,
    required this.income,
    required this.expenses,
  });

  double get balance => income - expenses;
}

class DashboardData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final List<CategorySpending> categorySpending;
  final List<MonthlyData> monthlyData;

  const DashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.categorySpending,
    required this.monthlyData,
  });
}
