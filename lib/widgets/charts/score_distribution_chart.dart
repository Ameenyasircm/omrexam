import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/report_model.dart';

class ScoreDistributionChart extends StatelessWidget {
  final List<ScoreDistribution> distribution;

  const ScoreDistributionChart({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return const Center(child: Text('No score data available'));
    }

    final maxCount = distribution
        .map((e) => e.count)
        .fold<int>(0, (prev, elem) => elem > prev ? elem : prev);

    final maxY = (maxCount == 0 ? 5 : (maxCount + 2)).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: Color(0xFF2563EB), size: 22),
            SizedBox(width: 8),
            Text(
              'Score Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Number of participants across score percentage brackets',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF0F172A),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = distribution[groupIndex].rangeLabel;
                    return BarTooltipItem(
                      '$label\n',
                      const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toInt()} Candidates',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: (maxY / 4).ceilToDouble().clamp(1.0, 100.0),
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= distribution.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          distribution[index].rangeLabel,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY / 4).ceilToDouble().clamp(1.0, 100.0),
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0xFFF1F5F9),
                  strokeWidth: 1.2,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(distribution.length, (index) {
                final item = distribution[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: item.count.toDouble(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 24,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
