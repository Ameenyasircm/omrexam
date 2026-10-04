import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/exam_model.dart';
import '../../models/report_model.dart';
import '../../providers/admin_provider.dart';
import '../../services/excel_export_service.dart';
import '../../widgets/charts/accuracy_pie_chart.dart';
import '../../widgets/charts/question_options_bar_chart.dart';
import '../../widgets/charts/question_performance_chart.dart';
import '../../widgets/charts/score_distribution_chart.dart';
import '../../widgets/charts/total_options_distribution_chart.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/stat_card.dart';

class ExamReportsScreen extends StatefulWidget {
  final ExamModel exam;
  final int initialTabIndex;

  const ExamReportsScreen({
    super.key,
    required this.exam,
    this.initialTabIndex = 0,
  });

  @override
  State<ExamReportsScreen> createState() => _ExamReportsScreenState();
}

class _ExamReportsScreenState extends State<ExamReportsScreen> {
  bool _isExporting = false;
  bool _preferCardViewOnMobile = true;
  bool _showOptionMatrixTable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().selectExam(widget.exam);
    });
  }

  Future<void> _exportRankExcel(ExamReportModel report) async {
    setState(() => _isExporting = true);
    try {
      final success = await ExcelExportService.exportRankListToExcel(
        exam: widget.exam,
        report: report,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar(
          'Rank list for "${widget.exam.title}" downloaded as Excel successfully!',
        );
      } else {
        _showErrorSnackBar('Failed to generate Excel file. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Export error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportOptionExcel(ExamReportModel report) async {
    setState(() => _isExporting = true);
    try {
      final success = await ExcelExportService.exportOptionAnalysisToExcel(
        exam: widget.exam,
        report: report,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar(
          'Question Option Report for "${widget.exam.title}" downloaded as Excel successfully!',
        );
      } else {
        _showErrorSnackBar('Failed to generate Option Report Excel. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Export error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final report = admin.currentReport;
    final rankList = report?.rankList ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMobile ? widget.exam.title : '${widget.exam.title} (${widget.exam.examId})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isMobile
                    ? 'ID: ${widget.exam.examId} • Analytics & Reports'
                    : 'Performance Analytics, Option A/B/C/D Analysis & Question Reports',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            if (report != null && report.totalParticipants > 0)
              Padding(
                padding: EdgeInsets.only(right: isMobile ? 8 : 16),
                child: isMobile
                    ? PopupMenuButton<String>(
                        tooltip: 'Export Reports to Excel',
                        icon: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: _isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF059669),
                                  ),
                                )
                              : const Icon(
                                  Icons.file_download_rounded,
                                  size: 18,
                                  color: Color(0xFF059669),
                                ),
                        ),
                        onSelected: (val) {
                          if (val == 'rank') {
                            _exportRankExcel(report);
                          } else if (val == 'options') {
                            _exportOptionExcel(report);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rank',
                            child: Row(
                              children: [
                                Icon(Icons.military_tech_rounded, size: 18, color: Color(0xFFD97706)),
                                SizedBox(width: 8),
                                Text('Export Rank List (.xlsx)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'options',
                            child: Row(
                              children: [
                                Icon(Icons.bar_chart_rounded, size: 18, color: Color(0xFF6366F1)),
                                SizedBox(width: 8),
                                Text('Export Option Report (.xlsx)'),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isExporting ? null : () => _exportOptionExcel(report),
                            icon: const Icon(Icons.poll_outlined, size: 16),
                            label: const Text('Export Option Report (.xlsx)'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4F46E5),
                              side: const BorderSide(color: Color(0xFF4F46E5)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton.icon(
                            onPressed: _isExporting ? null : () => _exportRankExcel(report),
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.file_download_rounded, size: 18),
                            label: Text(
                              _isExporting ? 'Exporting...' : 'Export Rank-Wise Excel',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF4F46E5),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF4F46E5),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                icon: Icon(Icons.leaderboard_rounded, size: 18),
                text: 'Performance & Ranks',
              ),
              Tab(
                icon: Icon(Icons.bar_chart_rounded, size: 18),
                text: 'Option A, B, C, D Report & Graph',
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: admin.isLoading && report == null
            ? const Center(child: CircularProgressIndicator())
            : report == null || report.totalParticipants == 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              size: 48,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'No Exam Submissions Yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share Exam ID "${widget.exam.examId}" and Password with candidates to collect responses and generate graphs.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    children: [
                      // TAB 1: Performance & Candidate Rank List
                      _buildPerformanceTab(report, rankList, isMobile),

                      // TAB 2: Dedicated Option A, B, C, D Counts Report & Graph
                      _buildOptionAnalysisTab(report, isMobile),
                    ],
                  ),
      ),
    );
  }

  /// TAB 1: Performance, Score Distribution & Candidate Rank List
  Widget _buildPerformanceTab(
      ExamReportModel report, List<CandidateRankItem> rankList, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Stat Cards
              ResponsiveLayout(
                mobileBody: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Candidates',
                            value: '${report.totalParticipants}',
                            icon: Icons.people_alt_rounded,
                            iconColor: const Color(0xFF2563EB),
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'Average Score',
                            value:
                                '${report.averageScore.toStringAsFixed(1)} / ${report.totalQuestions}',
                            icon: Icons.speed_rounded,
                            iconColor: const Color(0xFF10B981),
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Highest Score',
                            value: '${report.highestScore} / ${report.totalQuestions}',
                            icon: Icons.emoji_events_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'Lowest Score',
                            value: '${report.lowestScore} / ${report.totalQuestions}',
                            icon: Icons.trending_down_rounded,
                            iconColor: const Color(0xFFEF4444),
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                desktopBody: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Participants',
                        value: '${report.totalParticipants}',
                        icon: Icons.people_alt_rounded,
                        iconColor: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Average Score',
                        value:
                            '${report.averageScore.toStringAsFixed(1)} / ${report.totalQuestions}',
                        icon: Icons.speed_rounded,
                        iconColor: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Highest Score',
                        value: '${report.highestScore} / ${report.totalQuestions}',
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Lowest Score',
                        value: '${report.lowestScore} / ${report.totalQuestions}',
                        icon: Icons.trending_down_rounded,
                        iconColor: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // Charts: Score Distribution & Accuracy Pie
              ResponsiveLayout(
                mobileBody: Column(
                  children: [
                    _buildCard(
                      isMobile: isMobile,
                      child: ScoreDistributionChart(
                        distribution: report.scoreDistribution,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      isMobile: isMobile,
                      child: AccuracyPieChart(
                        totalCorrect: report.totalCorrectAnswers,
                        totalWrong: report.totalWrongAnswers,
                      ),
                    ),
                  ],
                ),
                desktopBody: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildCard(
                        isMobile: isMobile,
                        child: ScoreDistributionChart(
                          distribution: report.scoreDistribution,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: _buildCard(
                        isMobile: isMobile,
                        child: AccuracyPieChart(
                          totalCorrect: report.totalCorrectAnswers,
                          totalWrong: report.totalWrongAnswers,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // Question Performance Overview Bar Chart
              _buildCard(
                isMobile: isMobile,
                child: QuestionPerformanceChart(
                  performance: report.questionPerformance,
                  totalParticipants: report.totalParticipants,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // Question-Wise Accuracy Summary
              _buildQuestionSummaryCard(report, isMobile),
              SizedBox(height: isMobile ? 16 : 24),

              // Candidate Rank List
              _buildRankListSection(report, rankList, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  /// TAB 2: Option Selection Report (No. of A, No. of B, No. of C, No. of D counts & Graph)
  Widget _buildOptionAnalysisTab(ExamReportModel report, bool isMobile) {
    final totalSelections = report.totalACount +
        report.totalBCount +
        report.totalCCount +
        report.totalDCount +
        report.totalUnansweredCount;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4 Option KPI Stat Cards (Total No of A, No of B, No of C, No of D)
              ResponsiveLayout(
                mobileBody: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'No. of Option A',
                            value: '${report.totalACount}',
                            subtitle: totalSelections > 0
                                ? '${((report.totalACount / totalSelections) * 100).toStringAsFixed(1)}% of all answers'
                                : null,
                            icon: Icons.font_download_rounded,
                            iconColor: const Color(0xFF2563EB),
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'No. of Option B',
                            value: '${report.totalBCount}',
                            subtitle: totalSelections > 0
                                ? '${((report.totalBCount / totalSelections) * 100).toStringAsFixed(1)}% of all answers'
                                : null,
                            icon: Icons.font_download_rounded,
                            iconColor: const Color(0xFFD97706),
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'No. of Option C',
                            value: '${report.totalCCount}',
                            subtitle: totalSelections > 0
                                ? '${((report.totalCCount / totalSelections) * 100).toStringAsFixed(1)}% of all answers'
                                : null,
                            icon: Icons.font_download_rounded,
                            iconColor: const Color(0xFF7C3AED),
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: 'No. of Option D',
                            value: '${report.totalDCount}',
                            subtitle: totalSelections > 0
                                ? '${((report.totalDCount / totalSelections) * 100).toStringAsFixed(1)}% of all answers'
                                : null,
                            icon: Icons.font_download_rounded,
                            iconColor: const Color(0xFFDB2777),
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                desktopBody: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Option A Chosen',
                        value: '${report.totalACount}',
                        subtitle: totalSelections > 0
                            ? '${((report.totalACount / totalSelections) * 100).toStringAsFixed(1)}% of choices'
                            : null,
                        icon: Icons.font_download_rounded,
                        iconColor: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Option B Chosen',
                        value: '${report.totalBCount}',
                        subtitle: totalSelections > 0
                            ? '${((report.totalBCount / totalSelections) * 100).toStringAsFixed(1)}% of choices'
                            : null,
                        icon: Icons.font_download_rounded,
                        iconColor: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Option C Chosen',
                        value: '${report.totalCCount}',
                        subtitle: totalSelections > 0
                            ? '${((report.totalCCount / totalSelections) * 100).toStringAsFixed(1)}% of choices'
                            : null,
                        icon: Icons.font_download_rounded,
                        iconColor: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Option D Chosen',
                        value: '${report.totalDCount}',
                        subtitle: totalSelections > 0
                            ? '${((report.totalDCount / totalSelections) * 100).toStringAsFixed(1)}% of choices'
                            : null,
                        icon: Icons.font_download_rounded,
                        iconColor: const Color(0xFFDB2777),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // Overall Total Option Choices Graph (Bar & Donut Views for Total A, B, C, D)
              _buildCard(
                isMobile: isMobile,
                child: TotalOptionsDistributionChart(
                  totalA: report.totalACount,
                  totalB: report.totalBCount,
                  totalC: report.totalCCount,
                  totalD: report.totalDCount,
                  totalUnanswered: report.totalUnansweredCount,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // 1. OPTION GRAPH REPORT (All questions No. of A, B, C, D)
              _buildCard(
                isMobile: isMobile,
                child: QuestionOptionsBarChart(
                  performance: report.questionPerformance,
                  totalParticipants: report.totalParticipants,
                  totalACount: report.totalACount,
                  totalBCount: report.totalBCount,
                  totalCCount: report.totalCCount,
                  totalDCount: report.totalDCount,
                  totalUnansweredCount: report.totalUnansweredCount,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // 2. QUESTION-WISE OPTION COUNTS REPORT & MATRIX
              _buildQuestionOptionMatrixReportCard(report, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  /// Question-Wise Option A, B, C, D Selection Matrix Report & Cards
  Widget _buildQuestionOptionMatrixReportCard(ExamReportModel report, bool isMobile) {
    final totalSelections = report.totalACount +
        report.totalBCount +
        report.totalCCount +
        report.totalDCount +
        report.totalUnansweredCount;

    return _buildCard(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.table_chart_rounded,
                      color: Color(0xFF4F46E5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question Options Count Report',
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'For all questions: No. of A, No. of B, No. of C, No. of D chosen',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Actions: Export Excel and View Toggle
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _exportOptionExcel(report),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download_outlined, size: 16),
                    label: Text(
                      _isExporting ? 'Exporting...' : 'Export Option Excel (.xlsx)',
                      style: TextStyle(fontSize: isMobile ? 11 : 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: isMobile ? 6 : 8,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _showOptionMatrixTable
                        ? 'Switch to Option Cards'
                        : 'Switch to Option Matrix Table',
                    icon: Icon(
                      _showOptionMatrixTable
                          ? Icons.view_agenda_outlined
                          : Icons.grid_view_rounded,
                      size: 20,
                      color: const Color(0xFF64748B),
                    ),
                    onPressed: () {
                      setState(() {
                        _showOptionMatrixTable = !_showOptionMatrixTable;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Show either the Comparative Matrix Table or the Detailed Option Cards
          _showOptionMatrixTable
              ? _buildOptionMatrixTable(report, totalSelections, isMobile)
              : _buildOptionDetailedCardsList(report, isMobile),
        ],
      ),
    );
  }

  /// Option Matrix Table: Side-by-side comparison of A, B, C, D chosen counts per question
  Widget _buildOptionMatrixTable(
      ExamReportModel report, int totalSelections, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columnSpacing: isMobile ? 18 : 26,
            horizontalMargin: 12,
            columns: const [
              DataColumn(
                label: Text('Q#', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Question Text', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Option A', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
              DataColumn(
                label: Text('Option B', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
              ),
              DataColumn(
                label: Text('Option C', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
              ),
              DataColumn(
                label: Text('Option D', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDB2777))),
              ),
              DataColumn(
                label: Text('Skipped', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ),
              DataColumn(
                label: Text('Correct Key', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
              ),
              DataColumn(
                label: Text('Accuracy Rate', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: [
              ...report.questionPerformance.map((qp) {
                final aCount = qp.optionCounts['A'] ?? 0;
                final bCount = qp.optionCounts['B'] ?? 0;
                final cCount = qp.optionCounts['C'] ?? 0;
                final dCount = qp.optionCounts['D'] ?? 0;
                final total = qp.totalAttempts;

                final aPct = total > 0 ? (aCount / total) * 100 : 0.0;
                final bPct = total > 0 ? (bCount / total) * 100 : 0.0;
                final cPct = total > 0 ? (cCount / total) * 100 : 0.0;
                final dPct = total > 0 ? (dCount / total) * 100 : 0.0;

                final correctKey = qp.correctAnswer.toUpperCase();

                return DataRow(
                  cells: [
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Q${qp.order}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )),
                    DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        qp.questionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )),
                    DataCell(_buildCellChoiceBadge(aCount, aPct, correctKey == 'A', const Color(0xFF2563EB))),
                    DataCell(_buildCellChoiceBadge(bCount, bPct, correctKey == 'B', const Color(0xFFD97706))),
                    DataCell(_buildCellChoiceBadge(cCount, cPct, correctKey == 'C', const Color(0xFF7C3AED))),
                    DataCell(_buildCellChoiceBadge(dCount, dPct, correctKey == 'D', const Color(0xFFDB2777))),
                    DataCell(Text(
                      '${qp.unansweredCount}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        'Option $correctKey',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    )),
                    DataCell(Text(
                      '${qp.correctPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: qp.correctPercentage >= 50
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    )),
                  ],
                );
              }),
              // Highlighted Totals Summary Row
              DataRow(
                color: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                cells: [
                  const DataCell(Text(
                    'TOTAL',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  )),
                  DataCell(Text(
                    'All ${report.totalQuestions} Questions Combined',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )),
                  DataCell(_buildTotalChoiceBadge(report.totalACount, totalSelections, const Color(0xFF2563EB))),
                  DataCell(_buildTotalChoiceBadge(report.totalBCount, totalSelections, const Color(0xFFD97706))),
                  DataCell(_buildTotalChoiceBadge(report.totalCCount, totalSelections, const Color(0xFF7C3AED))),
                  DataCell(_buildTotalChoiceBadge(report.totalDCount, totalSelections, const Color(0xFFDB2777))),
                  DataCell(Text(
                    '${report.totalUnansweredCount}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )),
                  const DataCell(Text('-', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(
                    '${report.totalCorrectAnswers} Correct',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF059669),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCellChoiceBadge(int count, double pct, bool isCorrect, Color baseColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFDCFCE7) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isCorrect ? Border.all(color: const Color(0xFF86EFAC)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCorrect ? const Color(0xFF15803D) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${pct.toStringAsFixed(0)}%)',
            style: TextStyle(
              fontSize: 11,
              color: isCorrect ? const Color(0xFF166534) : const Color(0xFF64748B),
            ),
          ),
          if (isCorrect) ...[
            const SizedBox(width: 3),
            const Icon(Icons.check, size: 12, color: Color(0xFF15803D)),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalChoiceBadge(int count, int totalSelections, Color color) {
    final pct = totalSelections > 0 ? (count / totalSelections) * 100 : 0.0;
    return Text(
      '$count (${pct.toStringAsFixed(0)}%)',
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 12,
        color: color,
      ),
    );
  }

  /// Option Detailed Cards List View
  Widget _buildOptionDetailedCardsList(ExamReportModel report, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: report.questionPerformance.length,
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemBuilder: (context, idx) {
        final qp = report.questionPerformance[idx];
        return _buildSingleQuestionOptionCard(qp, report.totalParticipants, isMobile);
      },
    );
  }

  Widget _buildSingleQuestionOptionCard(
      QuestionPerformance qp, int totalParticipants, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header: Responsive Row with Expanded Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${qp.order}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qp.questionText,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 12, color: Color(0xFF059669)),
                          const SizedBox(width: 4),
                          Text(
                            'Correct Answer: Option ${qp.correctAnswer}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Options Grid (A, B, C, D)
          Column(
            children: [
              for (final opt in qp.optionsBreakdown) ...[
                _buildOptionCountRow(opt, totalParticipants, isMobile),
                const SizedBox(height: 8),
              ],
              if (qp.unansweredCount > 0) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Unanswered / Skipped: ${qp.unansweredCount} (${totalParticipants > 0 ? ((qp.unansweredCount / totalParticipants) * 100).toStringAsFixed(1) : 0}%)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCountRow(
      OptionChoiceBreakdown opt, int totalParticipants, bool isMobile) {
    final isCorrect = opt.isCorrect;
    final progressFraction =
        totalParticipants > 0 ? (opt.count / totalParticipants).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 8 : 9,
      ),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: isCorrect ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Option badge A, B, C, D
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  opt.optionKey,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Option text + KEY badge
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 3,
                  children: [
                    Text(
                      opt.optionText.isEmpty ? 'Option ${opt.optionKey}' : opt.optionText,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                        color: isCorrect
                            ? const Color(0xFF065F46)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    if (isCorrect)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'KEY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Chosen Count & Percentage stacked
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${opt.count} chosen',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.bold,
                      color: isCorrect
                          ? const Color(0xFF059669)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${opt.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isCorrect
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Percentage Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCorrect
                    ? const Color(0xFF10B981)
                    : (opt.count > 0 ? const Color(0xFF3B82F6) : Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Question-Wise Correct Count Summary
  Widget _buildQuestionSummaryCard(ExamReportModel report, bool isMobile) {
    return _buildCard(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_list_numbered_rounded,
                  color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                'Question Accuracy Summary',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Number of candidates who answered each question correctly',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: report.questionPerformance.length,
            separatorBuilder: (_, index) =>
                const Divider(height: 14, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, idx) {
              final qp = report.questionPerformance[idx];
              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Q${qp.order}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                qp.questionText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            '${qp.correctCount} / ${report.totalParticipants} Correct (${qp.correctPercentage.toStringAsFixed(0)}%)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Q${qp.order}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Text(
                                qp.questionText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            '${qp.correctCount} / ${report.totalParticipants} Correct (${qp.correctPercentage.toStringAsFixed(0)}%)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  /// Candidate Submissions Rank List (Responsive: Cards for mobile, Table for desktop)
  Widget _buildRankListSection(
      ExamReportModel report, List<CandidateRankItem> rankList, bool isMobile) {
    return _buildCard(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.military_tech_rounded,
                      color: Color(0xFFD97706), size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Candidate Rank List',
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ordered rank-wise by highest score and submission time',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (isMobile)
                    IconButton(
                      tooltip: _preferCardViewOnMobile ? 'Switch to Table' : 'Switch to Cards',
                      icon: Icon(
                        _preferCardViewOnMobile
                            ? Icons.table_chart_outlined
                            : Icons.view_agenda_outlined,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () {
                        setState(() {
                          _preferCardViewOnMobile = !_preferCardViewOnMobile;
                        });
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${rankList.length} Candidates',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _exportRankExcel(report),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download_outlined, size: 16),
                    label: Text(
                      _isExporting ? 'Exporting...' : 'Export Excel (.xlsx)',
                      style: TextStyle(fontSize: isMobile ? 12 : 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(color: Color(0xFF059669)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 12,
                        vertical: isMobile ? 6 : 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Render Mobile Card View or Desktop DataTable
          isMobile && _preferCardViewOnMobile
              ? _buildMobileRankListCards(rankList)
              : _buildDesktopRankListTable(rankList),
        ],
      ),
    );
  }

  /// Mobile-optimized candidate rank cards (Clean, vertical, easy to read on phones)
  Widget _buildMobileRankListCards(List<CandidateRankItem> rankList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rankList.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final r = rankList[index];
        final isPassed = r.percentage >= 50;
        final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(r.submittedAt);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: r.rank <= 3 ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
              width: r.rank <= 3 ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildRankBadge(r.rank),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPassed ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    r.phone,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                  const Spacer(),
                  const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Score & Percentage Row with mini progress bar
              Row(
                children: [
                  Text(
                    'Score: ${r.score} / ${r.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${r.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (r.percentage / 100).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Desktop DataTable view with horizontal scrolling
  Widget _buildDesktopRankListTable(List<CandidateRankItem> rankList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        columnSpacing: 28,
        columns: const [
          DataColumn(
            label: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Candidate Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Score', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Submitted At', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: rankList.map((r) {
          final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(r.submittedAt);
          return DataRow(
            cells: [
              DataCell(_buildRankBadge(r.rank)),
              DataCell(Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(r.phone)),
              DataCell(Text(
                '${r.score} / ${r.totalQuestions}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              )),
              DataCell(Text(
                '${r.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: r.percentage >= 50
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              )),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: r.percentage >= 50
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  r.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: r.percentage >= 50
                        ? const Color(0xFF065F46)
                        : const Color(0xFF991B1B),
                  ),
                ),
              )),
              DataCell(Text(
                dateStr,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color bg;
    Color fg;
    String label = '#$rank';

    if (rank == 1) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      label = '🥇 #1';
    } else if (rank == 2) {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
      label = '🥈 #2';
    } else if (rank == 3) {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFC2410C);
      label = '🥉 #3';
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, bool isMobile = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
