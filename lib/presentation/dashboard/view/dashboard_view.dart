import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:minhas_despesas_app/presentation/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:minhas_despesas_app/presentation/dashboard/view/calendar_view.dart';
import 'package:minhas_despesas_app/config/formatters/currency_formatter.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 18,
                        color: !_viewModel.isCalendarView
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _viewModel.isCalendarView,
                        onChanged: (_) => _viewModel.toggleView(),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: _viewModel.isCalendarView
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _viewModel.refresh(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_viewModel.isCalendarView) {
            return RefreshIndicator(
              onRefresh: () => _viewModel.refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  CalendarView(
                    dailyTransactions: _viewModel.dailyTransactions,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _viewModel.refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 24),
                _buildSectionTitle('Gastos por Categoria'),
                const SizedBox(height: 16),
                _buildCategoryPieChart(),
                const SizedBox(height: 32),
                _buildSectionTitle('Fluxo Mensal (Últimos 6 Meses)'),
                const SizedBox(height: 16),
                _buildMonthlyLineChart(),
                const SizedBox(height: 32),
                _buildCategoryDetails(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    final data = _viewModel.dashboardData;
    
    return Column(
      children: [
        _buildCard(
          title: 'Saldo',
          value: data.totalBalance.toReal(),
          color: data.totalBalance >= 0 ? Colors.green : Colors.red,
          icon: Icons.account_balance_wallet,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                title: 'Receita',
                value: data.totalIncome.toReal(),
                color: Colors.greenAccent,
                icon: Icons.trending_up,
                compact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                title: 'Despesa',
                value: data.totalExpenses.toReal(),
                color: Colors.redAccent,
                icon: Icons.trending_down,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    bool compact = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: compact ? 20 : 28),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 14 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCategoryPieChart() {
    final data = _viewModel.dashboardData;
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: PieChart(
        PieChartData(
          sections: List.generate(
            data.categorySpending.length,
            (index) {
              final category = data.categorySpending[index];
              final percentage =
                  (category.value / data.totalExpenses) * 100;

              return PieChartSectionData(
                value: category.value,
                color: colors[index % colors.length],
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                title: '${percentage.toStringAsFixed(0)}%',
              );
            },
          ),
          centerSpaceRadius: 50,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildMonthlyLineChart() {
    final data = _viewModel.dashboardData;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 500,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.monthlyData.length) {
                    return const SizedBox.shrink();
                  }
                  final month = data.monthlyData[index].month.month;
                  return Text(
                    'M$month',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 500,
                getTitlesWidget: (value, meta) {
                  return Text(
                    (value ~/1000).toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          minX: 0,
          maxX: (data.monthlyData.length - 1).toDouble(),
          minY: 0,
          maxY: 4000,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.monthlyData.length,
                (index) => FlSpot(index.toDouble(), data.monthlyData[index].income),
              ),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withValues(alpha: 0.2),
              ),
            ),
            LineChartBarData(
              spots: List.generate(
                data.monthlyData.length,
                (index) => FlSpot(index.toDouble(), data.monthlyData[index].expenses),
              ),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDetails() {
    final data = _viewModel.dashboardData;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Detalhes por Categoria',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.categorySpending.length,
            itemBuilder: (context, index) {
              final category = data.categorySpending[index];
              final percentage =
                  (category.value / data.totalExpenses) * 100;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              category.value.toReal(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${category.transactions} transações',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 6,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          HSLColor.fromAHSL(
                            1.0,
                            (index * 60) % 360,
                            0.7,
                            0.5,
                          ).toColor(),
                        ),
                      ),
                    ),
                    if (index < data.categorySpending.length - 1)
                      const SizedBox(height: 4),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
