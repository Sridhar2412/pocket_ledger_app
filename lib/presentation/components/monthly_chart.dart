import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ledger_app/core/theme/app_color.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;

  const MonthlyBarChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
  });

  // Helper method to get the name of the month based on its index (0=Jan)
  String getMonthLabel(int index) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[index % 12];
  }

  // Calculate the highest value across all data sets to set the maxY limit
  double get maxDataValue {
    final maxIncome =
        incomeData.isEmpty ? 0.0 : incomeData.reduce((a, b) => a > b ? a : b);
    final maxExpense =
        expenseData.isEmpty ? 0.0 : expenseData.reduce((a, b) => a > b ? a : b);
    return (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.15;
  }

  // Helper Widget for the legend item
  Widget _buildLegendItem(BuildContext context, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxY = maxDataValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Legend
        Padding(
          padding: const EdgeInsets.only(
              left: 12.0, right: 12.0, bottom: 8.0, top: 8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 4.0,
            children: [
              _buildLegendItem(
                  context, Theme.of(context).colorScheme.primary, 'Income'),
              _buildLegendItem(
                  context, Theme.of(context).colorScheme.error, 'Expense'),
            ],
          ),
        ),

        // 2. Bar Chart
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                groupsSpace: 12,
                barTouchData: _buildBarTouchData(context),
                titlesData: _buildTitlesData(context, maxY),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColor.lightGrey.withOpacity(0.2),
                    strokeWidth: 0.5,
                  ),
                ),
                barGroups: List.generate(
                  12,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      // Income Rod
                      BarChartRodData(
                        toY: incomeData[index],
                        color: Theme.of(context).colorScheme.primary,
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppColor.grey1,
                        ),
                      ),
                      // Expense Rod
                      BarChartRodData(
                        toY: expenseData[index],
                        color: Theme.of(context).colorScheme.error,
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppColor.grey1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // UI Component Builders

  FlTitlesData _buildTitlesData(BuildContext context, double maxY) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (double value, TitleMeta meta) {
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                getMonthLabel(value.toInt()),
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: maxY > 0 ? maxY / 4 : 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            String text;
            if (value == 0) {
              text = '0';
            } else if (value >= 1000) {
              text = '${(value / 1000).toStringAsFixed(0)}k';
            } else {
              text = value.toStringAsFixed(0);
            }
            return Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            );
          },
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData(BuildContext context) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final isIncome = rodIndex == 0;
          final label = isIncome ? 'Income' : 'Expense';
          final color = isIncome
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error;

          return BarTooltipItem(
            '$label\n₹${rod.toY.toStringAsFixed(0)}',
            TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: '\n${getMonthLabel(group.x)}',
                style: const TextStyle(
                  color: AppColor.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
