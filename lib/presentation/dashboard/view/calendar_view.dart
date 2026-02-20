import 'package:flutter/material.dart';
import 'package:minhas_despesas_app/domain/models/daily_transactions.dart';
import 'package:minhas_despesas_app/domain/entities/transaction.dart';
import 'package:minhas_despesas_app/config/formatters/currency_formatter.dart';

class CalendarView extends StatefulWidget {
  final List<DailyTransactions> dailyTransactions;

  const CalendarView({
    super.key,
    required this.dailyTransactions,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    final transactionsByDay = <int, List<DailyTransactions>>{};
    for (var daily in widget.dailyTransactions) {
      if (daily.date.year == _selectedMonth.year &&
          daily.date.month == _selectedMonth.month) {
        final day = daily.date.day;
        transactionsByDay.putIfAbsent(day, () => []).add(daily);
      }
    }

    return Column(
      children: [
        _buildMonthSelector(),
        const SizedBox(height: 16),
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        _buildCalendarGrid(
          daysInMonth,
          firstWeekday,
          transactionsByDay,
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          _getMonthName(_selectedMonth),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return Row(
      children: List.generate(7, (index) {
        return Expanded(
          child: Center(
            child: Text(
              weekdays[index],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarGrid(
    int daysInMonth,
    int firstWeekday,
    Map<int, List<DailyTransactions>> transactionsByDay,
  ) {
    final days = <Widget>[];

    // Empty cells for days before first day of month
    for (int i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox.expand());
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final dayTransactions = transactionsByDay[day] ?? [];
      days.add(
        _buildDayCell(day, dayTransactions),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  Widget _buildDayCell(
    int day,
    List<DailyTransactions> dayTransactions,
  ) {
    final hasTransactions = dayTransactions.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasTransactions) {
          showModalBottomSheet(
            context: context,
            builder: (context) => _buildTransactionDetails(dayTransactions),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          color: hasTransactions
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                day.toString(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (hasTransactions)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: List.generate(
                        dayTransactions.length,
                        (index) {
                          final daily = dayTransactions[index];
                          final transaction = daily.transactions.first;
                          final isIncome =
                              transaction.type == TransactionType.receita;

                          return Tooltip(
                            message:
                                '${transaction.title}\n${transaction.value.toReal()}',
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                              child: Text(
                                _truncateValue(transaction.value.toRealNoSymbol()),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(List<DailyTransactions> dayTransactions) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transações do dia ${dayTransactions.first.date.day}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dayTransactions.length,
            itemBuilder: (context, index) {
              final daily = dayTransactions[index];
              return Column(
                children: List.generate(
                  daily.transactions.length,
                  (transIndex) {
                    final transaction = daily.transactions[transIndex];
                    final isIncome =
                        transaction.type == TransactionType.receita;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  transaction.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isIncome
                                ? '+${transaction.value.toReal()}'
                                : '-${transaction.value.toReal()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${months[date.month - 1]} de ${date.year}';
  }

  String _truncateValue(String value) {
    return value.length > 6 ? value.substring(0, 6) : value;
  }
}
