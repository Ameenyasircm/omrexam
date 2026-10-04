import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AccuracyPieChart extends StatelessWidget {
  final int totalCorrect;
  final int totalWrong;

  const AccuracyPieChart({
    super.key,
    required this.totalCorrect,
    required this.totalWrong,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalCorrect + totalWrong;
    if (total == 0) {
      return const Center(
        child: Text(
          'No attempts recorded yet',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    final correctPct = (totalCorrect / total) * 100;
    final wrongPct = (totalWrong / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.pie_chart_rounded, color: Color(0xFFF59E0B), size: 22),
            SizedBox(width: 8),
            Text(
              'Overall Accuracy Ratio',
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
          'Ratio of all correct vs wrong/unattempted selections',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF10B981),
                        value: totalCorrect.toDouble(),
                        title: '${correctPct.toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFEF4444),
                        value: totalWrong.toDouble(),
                        title: '${wrongPct.toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIndicator(
                      color: const Color(0xFF10B981),
                      text: 'Correct',
                      count: totalCorrect,
                    ),
                    const SizedBox(height: 12),
                    _buildIndicator(
                      color: const Color(0xFFEF4444),
                      text: 'Wrong / Missed',
                      count: totalWrong,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required Color color,
    required String text,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              Text(
                '$count items',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
