import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> categoryTotals;
  const CategoryPieChart({super.key, required this.categoryTotals});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final entries = widget.categoryTotals.entries.toList();

    if (entries.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text('No categories',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    final sections = List.generate(entries.length, (i) {
      final e = entries[i];
      final baseColor = Colors.primaries[i % Colors.primaries.length];
      final isTouched = i == _touchedIndex;
      return PieChartSectionData(
        value: e.value,
        title: isTouched ? '${e.key}: ₹ ${e.value.toStringAsFixed(1)}' : e.key,
        color: baseColor.withOpacity(isTouched ? 0.95 : 0.8),
        radius: isTouched ? 60 : 48,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      );
    });

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 36,
              pieTouchData: PieTouchData(touchCallback: (event, resp) {
                final idx = resp?.touchedSection?.touchedSectionIndex ?? -1;
                if (idx < 0 || idx >= entries.length) {
                  setState(() => _touchedIndex = null);
                  return;
                }
                setState(() => _touchedIndex = idx);
              }),
            ),
            swapAnimationDuration: const Duration(milliseconds: 300),
          ),
        ),
        if (_touchedIndex != null &&
            _touchedIndex! >= 0 &&
            _touchedIndex! < entries.length)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${entries[_touchedIndex!].key}: ${entries[_touchedIndex!].value.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
