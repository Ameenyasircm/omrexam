import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/report_model.dart';

class QuestionOptionsBarChart extends StatelessWidget {
  final List<QuestionPerformance> performance;
  final int totalParticipants;
  final int totalACount;
  final int totalBCount;
  final int totalCCount;
  final int totalDCount;
  final int totalUnansweredCount;

  const QuestionOptionsBarChart({
    super.key,
    required this.performance,
    required this.totalParticipants,
    this.totalACount = 0,
    this.totalBCount = 0,
    this.totalCCount = 0,
    this.totalDCount = 0,
    this.totalUnansweredCount = 0,
  });

  static const colorA = Color(0xFF2563EB); // Blue
  static const colorB = Color(0xFFD97706); // Amber
  static const colorC = Color(0xFF7C3AED); // Purple
  static const colorD = Color(0xFFDB2777); // Pink/Rose

  @override
  Widget build(BuildContext context) {
    if (performance.isEmpty) {
      return const Center(child: Text('No question option data available.'));
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    // Find maximum count among all options in all questions to calibrate maxY
    int maxOptionCount = 0;
    for (final q in performance) {
      final a = q.optionCounts['A'] ?? 0;
      final b = q.optionCounts['B'] ?? 0;
      final c = q.optionCounts['C'] ?? 0;
      final d = q.optionCounts['D'] ?? 0;
      maxOptionCount = max(maxOptionCount, max(max(a, b), max(c, d)));
    }

    final maxY = max(5.0, (maxOptionCount + 2).toDouble());
    final totalSelections = totalACount + totalBCount + totalCCount + totalDCount + totalUnansweredCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF4F46E5), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Option Selection Graph (A, B, C, D)',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Number of candidates choosing Option A, B, C, D per question',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _buildLegendItem('Option A', colorA),
            _buildLegendItem('Option B', colorB),
            _buildLegendItem('Option C', colorC),
            _buildLegendItem('Option D', colorD),
          ],
        ),
        const SizedBox(height: 20),

        // Horizontally scrollable chart for mobile / desktop
        LayoutBuilder(
          builder: (context, constraints) {
            const minWidthPerGroup = 64.0;
            final neededWidth = performance.length * minWidthPerGroup + 40;
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
                        final optKey = ['A', 'B', 'C', 'D'][rodIndex];
                        final count = item.optionCounts[optKey] ?? 0;
                        final isCorrect = item.correctAnswer.toUpperCase() == optKey;

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
                                  'Option $optKey: $count chosen${isCorrect ? " (✓ Correct Key)" : ""}',
                              style: TextStyle(
                                color: isCorrect
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFF1F5F9),
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
                        reservedSize: 28,
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
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= performance.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
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
                    final a = (item.optionCounts['A'] ?? 0).toDouble();
                    final b = (item.optionCounts['B'] ?? 0).toDouble();
                    final c = (item.optionCounts['C'] ?? 0).toDouble();
                    final d = (item.optionCounts['D'] ?? 0).toDouble();

                    return BarChartGroupData(
                      x: index,
                      barsSpace: 3,
                      barRods: [
                        _buildRod(a, colorA),
                        _buildRod(b, colorB),
                        _buildRod(c, colorC),
                        _buildRod(d, colorD),
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

        const SizedBox(height: 18),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 14),

        // Overall aggregate option counts across all questions: 2x2 grid on mobile or 4-row wrap
        isMobile
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          'No. of Option A',
                          totalACount,
                          totalSelections > 0 ? (totalACount / totalSelections) * 100 : 0,
                          colorA,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          'No. of Option B',
                          totalBCount,
                          totalSelections > 0 ? (totalBCount / totalSelections) * 100 : 0,
                          colorB,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          'No. of Option C',
                          totalCCount,
                          totalSelections > 0 ? (totalCCount / totalSelections) * 100 : 0,
                          colorC,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          'No. of Option D',
                          totalDCount,
                          totalSelections > 0 ? (totalDCount / totalSelections) * 100 : 0,
                          colorD,
                        ),
                      ),
                    ],
                  ),
                  if (totalUnansweredCount > 0) ...[
                    const SizedBox(height: 8),
                    _buildMetricTile(
                      'No. of Skipped / Unanswered',
                      totalUnansweredCount,
                      totalSelections > 0 ? (totalUnansweredCount / totalSelections) * 100 : 0,
                      const Color(0xFF64748B),
                    ),
                  ],
                ],
              )
            : Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _buildMetricTile(
                    'Total Option A Chosen',
                    totalACount,
                    totalSelections > 0 ? (totalACount / totalSelections) * 100 : 0,
                    colorA,
                  ),
                  _buildMetricTile(
                    'Total Option B Chosen',
                    totalBCount,
                    totalSelections > 0 ? (totalBCount / totalSelections) * 100 : 0,
                    colorB,
                  ),
                  _buildMetricTile(
                    'Total Option C Chosen',
                    totalCCount,
                    totalSelections > 0 ? (totalCCount / totalSelections) * 100 : 0,
                    colorC,
                  ),
                  _buildMetricTile(
                    'Total Option D Chosen',
                    totalDCount,
                    totalSelections > 0 ? (totalDCount / totalSelections) * 100 : 0,
                    colorD,
                  ),
                  if (totalUnansweredCount > 0)
                    _buildMetricTile(
                      'Total Skipped',
                      totalUnansweredCount,
                      totalSelections > 0 ? (totalUnansweredCount / totalSelections) * 100 : 0,
                      const Color(0xFF64748B),
                    ),
                ],
              ),
      ],
    );
  }

  BarChartRodData _buildRod(double value, Color color) {
    return BarChartRodData(
      toY: value,
      color: color,
      width: 7.0,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(3),
        topRight: Radius.circular(3),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String title, int count, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '$count times (${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
