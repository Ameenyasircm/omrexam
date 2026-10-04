import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TotalOptionsDistributionChart extends StatefulWidget {
  final int totalA;
  final int totalB;
  final int totalC;
  final int totalD;
  final int totalUnanswered;

  const TotalOptionsDistributionChart({
    super.key,
    required this.totalA,
    required this.totalB,
    required this.totalC,
    required this.totalD,
    this.totalUnanswered = 0,
  });

  static const colorA = Color(0xFF2563EB); // Blue
  static const colorB = Color(0xFFD97706); // Amber
  static const colorC = Color(0xFF7C3AED); // Purple
  static const colorD = Color(0xFFDB2777); // Pink/Rose
  static const colorUnanswered = Color(0xFF64748B); // Slate

  @override
  State<TotalOptionsDistributionChart> createState() =>
      _TotalOptionsDistributionChartState();
}

class _TotalOptionsDistributionChartState
    extends State<TotalOptionsDistributionChart> {
  int _selectedChartType = 0; // 0 = Bar Chart, 1 = Donut Pie Chart

  @override
  Widget build(BuildContext context) {
    final totalSelections = widget.totalA +
        widget.totalB +
        widget.totalC +
        widget.totalD +
        widget.totalUnanswered;

    if (totalSelections == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No option selections recorded yet.',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Color(0xFF4F46E5),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Option Choices Distribution (A, B, C, D)',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Overall number and percentage of times Option A, B, C, and D were selected',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            // Toggle for Bar / Donut view on Mobile or Desktop
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleBtn(
                    icon: Icons.bar_chart_rounded,
                    tooltip: 'Bar Chart View',
                    isSelected: _selectedChartType == 0,
                    onTap: () => setState(() => _selectedChartType = 0),
                  ),
                  _buildToggleBtn(
                    icon: Icons.pie_chart_rounded,
                    tooltip: 'Donut Share View',
                    isSelected: _selectedChartType == 1,
                    onTap: () => setState(() => _selectedChartType = 1),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Chart Content
        _selectedChartType == 0
            ? _buildBarChart(totalSelections, isMobile)
            : _buildDonutChart(totalSelections, isMobile),

        const SizedBox(height: 18),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 14),

        // Bottom Breakdown Tiles
        isMobile
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionTile(
                          'Option A',
                          widget.totalA,
                          totalSelections > 0
                              ? (widget.totalA / totalSelections) * 100
                              : 0,
                          TotalOptionsDistributionChart.colorA,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOptionTile(
                          'Option B',
                          widget.totalB,
                          totalSelections > 0
                              ? (widget.totalB / totalSelections) * 100
                              : 0,
                          TotalOptionsDistributionChart.colorB,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionTile(
                          'Option C',
                          widget.totalC,
                          totalSelections > 0
                              ? (widget.totalC / totalSelections) * 100
                              : 0,
                          TotalOptionsDistributionChart.colorC,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOptionTile(
                          'Option D',
                          widget.totalD,
                          totalSelections > 0
                              ? (widget.totalD / totalSelections) * 100
                              : 0,
                          TotalOptionsDistributionChart.colorD,
                        ),
                      ),
                    ],
                  ),
                  if (widget.totalUnanswered > 0) ...[
                    const SizedBox(height: 8),
                    _buildOptionTile(
                      'Skipped / Unanswered',
                      widget.totalUnanswered,
                      totalSelections > 0
                          ? (widget.totalUnanswered / totalSelections) * 100
                          : 0,
                      TotalOptionsDistributionChart.colorUnanswered,
                    ),
                  ],
                ],
              )
            : Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _buildOptionTile(
                    'Option A Total',
                    widget.totalA,
                    totalSelections > 0
                        ? (widget.totalA / totalSelections) * 100
                        : 0,
                    TotalOptionsDistributionChart.colorA,
                  ),
                  _buildOptionTile(
                    'Option B Total',
                    widget.totalB,
                    totalSelections > 0
                        ? (widget.totalB / totalSelections) * 100
                        : 0,
                    TotalOptionsDistributionChart.colorB,
                  ),
                  _buildOptionTile(
                    'Option C Total',
                    widget.totalC,
                    totalSelections > 0
                        ? (widget.totalC / totalSelections) * 100
                        : 0,
                    TotalOptionsDistributionChart.colorC,
                  ),
                  _buildOptionTile(
                    'Option D Total',
                    widget.totalD,
                    totalSelections > 0
                        ? (widget.totalD / totalSelections) * 100
                        : 0,
                    TotalOptionsDistributionChart.colorD,
                  ),
                  if (widget.totalUnanswered > 0)
                    _buildOptionTile(
                      'Skipped Total',
                      widget.totalUnanswered,
                      totalSelections > 0
                          ? (widget.totalUnanswered / totalSelections) * 100
                          : 0,
                      TotalOptionsDistributionChart.colorUnanswered,
                    ),
                ],
              ),
      ],
    );
  }

  Widget _buildToggleBtn({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? const Color(0xFF4F46E5)
              : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildBarChart(int totalSelections, bool isMobile) {
    final maxCount = max(
      max(widget.totalA, widget.totalB),
      max(widget.totalC, widget.totalD),
    );
    final maxY = max(5.0, (maxCount + (maxCount * 0.15) + 2).ceilToDouble());

    final items = [
      ('Option A', widget.totalA, TotalOptionsDistributionChart.colorA),
      ('Option B', widget.totalB, TotalOptionsDistributionChart.colorB),
      ('Option C', widget.totalC, TotalOptionsDistributionChart.colorC),
      ('Option D', widget.totalD, TotalOptionsDistributionChart.colorD),
      if (widget.totalUnanswered > 0)
        (
          'Skipped',
          widget.totalUnanswered,
          TotalOptionsDistributionChart.colorUnanswered
        ),
    ];

    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0F172A),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = items[groupIndex];
                final count = item.$2;
                final pct =
                    totalSelections > 0 ? (count / totalSelections) * 100 : 0.0;
                return BarTooltipItem(
                  '${item.$1}\n',
                  const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '$count times (${pct.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: item.$3,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
                interval: (maxY / 4).ceilToDouble().clamp(1.0, 1000.0),
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
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      items[idx].$1,
                      style: TextStyle(
                        color: items[idx].$3,
                        fontSize: isMobile ? 11 : 12,
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
            horizontalInterval: (maxY / 4).ceilToDouble().clamp(1.0, 1000.0),
            getDrawingHorizontalLine: (value) => const FlLine(
              color: Color(0xFFF1F5F9),
              strokeWidth: 1.2,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(items.length, (index) {
            final item = items[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.$2.toDouble(),
                  gradient: LinearGradient(
                    colors: [
                      item.$3.withValues(alpha: 0.8),
                      item.$3,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: isMobile ? 26 : 38,
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
    );
  }

  Widget _buildDonutChart(int totalSelections, bool isMobile) {
    final aPct =
        totalSelections > 0 ? (widget.totalA / totalSelections) * 100 : 0.0;
    final bPct =
        totalSelections > 0 ? (widget.totalB / totalSelections) * 100 : 0.0;
    final cPct =
        totalSelections > 0 ? (widget.totalC / totalSelections) * 100 : 0.0;
    final dPct =
        totalSelections > 0 ? (widget.totalD / totalSelections) * 100 : 0.0;
    final skippedPct = totalSelections > 0
        ? (widget.totalUnanswered / totalSelections) * 100
        : 0.0;

    final sections = [
      if (widget.totalA > 0)
        PieChartSectionData(
          color: TotalOptionsDistributionChart.colorA,
          value: widget.totalA.toDouble(),
          title: '${aPct.toStringAsFixed(0)}%',
          radius: isMobile ? 42 : 52,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (widget.totalB > 0)
        PieChartSectionData(
          color: TotalOptionsDistributionChart.colorB,
          value: widget.totalB.toDouble(),
          title: '${bPct.toStringAsFixed(0)}%',
          radius: isMobile ? 42 : 52,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (widget.totalC > 0)
        PieChartSectionData(
          color: TotalOptionsDistributionChart.colorC,
          value: widget.totalC.toDouble(),
          title: '${cPct.toStringAsFixed(0)}%',
          radius: isMobile ? 42 : 52,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (widget.totalD > 0)
        PieChartSectionData(
          color: TotalOptionsDistributionChart.colorD,
          value: widget.totalD.toDouble(),
          title: '${dPct.toStringAsFixed(0)}%',
          radius: isMobile ? 42 : 52,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (widget.totalUnanswered > 0)
        PieChartSectionData(
          color: TotalOptionsDistributionChart.colorUnanswered,
          value: widget.totalUnanswered.toDouble(),
          title: '${skippedPct.toStringAsFixed(0)}%',
          radius: isMobile ? 42 : 52,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: isMobile ? 32 : 44,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDonutLegendItem('Option A', widget.totalA, aPct,
                    TotalOptionsDistributionChart.colorA),
                const SizedBox(height: 8),
                _buildDonutLegendItem('Option B', widget.totalB, bPct,
                    TotalOptionsDistributionChart.colorB),
                const SizedBox(height: 8),
                _buildDonutLegendItem('Option C', widget.totalC, cPct,
                    TotalOptionsDistributionChart.colorC),
                const SizedBox(height: 8),
                _buildDonutLegendItem('Option D', widget.totalD, dPct,
                    TotalOptionsDistributionChart.colorD),
                if (widget.totalUnanswered > 0) ...[
                  const SizedBox(height: 8),
                  _buildDonutLegendItem('Skipped', widget.totalUnanswered,
                      skippedPct, TotalOptionsDistributionChart.colorUnanswered),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutLegendItem(
      String label, int count, double pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $count (${pct.toStringAsFixed(0)}%)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
      String title, int count, double percentage, Color color) {
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
                width: 8,
                height: 8,
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
