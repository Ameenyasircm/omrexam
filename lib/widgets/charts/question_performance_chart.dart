import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/report_model.dart';

class QuestionPerformanceChart extends StatelessWidget {
  final List<QuestionPerformance> performance;
  final int totalParticipants;

  const QuestionPerformanceChart({
    super.key,
    required this.performance,
    required this.totalParticipants,
  });

  @override
  Widget build(BuildContext context) {
    if (performance.isEmpty) {
      return const Center(child: Text('No question performance data yet.'));
    }

    final maxY = (totalParticipants == 0 ? 5 : (totalParticipants + 1)).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.leaderboard_rounded, color: Color(0xFF10B981), size: 22),
            SizedBox(width: 8),
            Text(
              'Question-wise Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Total correct answers per question (out of $totalParticipants participants)',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            const minWidthPerBar = 46.0;
            final neededWidth = performance.length * minWidthPerBar + 40;
            final needsScroll = neededWidth > constraints.maxWidth;
            final chartWidth = max(constraints.maxWidth, neededWidth);

            final chartWidget = SizedBox(
              width: chartWidth,
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF0F172A),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = performance[groupIndex];
                        return BarTooltipItem(
                          'Question ${item.order}\n',
                          const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${item.correctCount}/$totalParticipants Correct (${item.correctPercentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 12,
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
                        reservedSize: 30,
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
                          if (index < 0 || index >= performance.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Q${performance[index].order}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
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
                  barGroups: List.generate(performance.length, (index) {
                    final item = performance[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.correctCount.toDouble(),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF34D399)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: min(24.0, chartWidth / (performance.length * 2)),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );

            if (needsScroll) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: chartWidget,
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.swipe_left_rounded, size: 14, color: Color(0xFF94A3B8)),
                      SizedBox(width: 4),
                      Text(
                        'Swipe horizontally to view all questions',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              );
            }

            return chartWidget;
          },
        ),
      ],
    );
  }
}
