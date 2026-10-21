import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BarChartEntry {
  final String label;
  final int value;
  const BarChartEntry(this.label, this.value);
}

/// Small vertical bar chart drawn with plain widgets — enough for the
/// dashboard's by-city / by-district breakdowns without a chart package.
class SimpleBarChart extends StatelessWidget {
  final String title;
  final List<BarChartEntry> entries;
  final Color barColor;

  const SimpleBarChart({
    super.key,
    required this.title,
    required this.entries,
    this.barColor = AppColors.teal,
  });

  static const _maxBars = 6;
  static const _chartHeight = 110.0;

  @override
  Widget build(BuildContext context) {
    final shown = entries.take(_maxBars).toList();
    final maxValue = shown.isEmpty
        ? 1
        : shown.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (shown.isEmpty)
            const SizedBox(
              height: _chartHeight,
              child: Center(
                child: Icon(Icons.bar_chart,
                    color: AppColors.textSoft, size: 32),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final entry in shown)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: _chartHeight *
                                (entry.value / maxValue).clamp(0.06, 1.0),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
