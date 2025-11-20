import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryTouchedIndexProvider = StateProvider<int?>((ref) => null);

class CategoryPieChart extends ConsumerWidget {
  final Map<String, double> categoryTotals;
  const CategoryPieChart({super.key, required this.categoryTotals});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = categoryTotals.entries.toList();
    final touchedIndex = ref.watch(categoryTouchedIndexProvider);

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
      final isTouched = i == touchedIndex;
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
                  ref.read(categoryTouchedIndexProvider.notifier).state = null;
                  return;
                }
                ref.read(categoryTouchedIndexProvider.notifier).state = idx;
              }),
            ),
            swapAnimationDuration: const Duration(milliseconds: 300),
          ),
        ),
        if (touchedIndex != null &&
            touchedIndex >= 0 &&
            touchedIndex < entries.length)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${entries[touchedIndex].key}: ${entries[touchedIndex].value.toStringAsFixed(2)}',
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
