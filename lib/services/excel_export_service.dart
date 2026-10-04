import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/exam_model.dart';
import '../models/report_model.dart';
import '../utils/file_download_helper.dart';

class ExcelExportService {
  /// Exports rank-wise candidate results and question option analysis to an Excel file (.xlsx)
  static Future<bool> exportRankListToExcel({
    required ExamModel exam,
    required ExamReportModel report,
  }) async {
    try {
      final excel = Excel.createExcel();

      // Default sheet rename or use
      const rankSheetName = 'Rank List';
      excel.rename('Sheet1', rankSheetName);
      final rankSheet = excel[rankSheetName];

      // Sheet 1: Rank List
      // Header row
      rankSheet.appendRow([
        TextCellValue('Rank'),
        TextCellValue('Candidate Name'),
        TextCellValue('Phone Number'),
        TextCellValue('Score'),
        TextCellValue('Total Questions'),
        TextCellValue('Percentage (%)'),
        TextCellValue('Result Status'),
        TextCellValue('Submission Date & Time'),
      ]);

      // Populate rank-wise rows
      for (final candidate in report.rankList) {
        rankSheet.appendRow([
          IntCellValue(candidate.rank),
          TextCellValue(candidate.name),
          TextCellValue(candidate.phone),
          IntCellValue(candidate.score),
          IntCellValue(candidate.totalQuestions),
          DoubleCellValue(double.parse(candidate.percentage.toStringAsFixed(1))),
          TextCellValue(candidate.status),
          TextCellValue(
            DateFormat('yyyy-MM-dd hh:mm a').format(candidate.submittedAt),
          ),
        ]);
      }

      // Sheet 2: Question-Wise Option Breakdown (A, B, C, D choices)
      const optionsSheetName = 'Option Breakdown';
      final optionsSheet = excel[optionsSheetName];

      optionsSheet.appendRow([
        TextCellValue('Q No'),
        TextCellValue('Question Text'),
        TextCellValue('Correct Key'),
        TextCellValue('Option A Count'),
        TextCellValue('Option A (%)'),
        TextCellValue('Option B Count'),
        TextCellValue('Option B (%)'),
        TextCellValue('Option C Count'),
        TextCellValue('Option C (%)'),
        TextCellValue('Option D Count'),
        TextCellValue('Option D (%)'),
        TextCellValue('Unanswered'),
        TextCellValue('Total Candidates'),
        TextCellValue('Accuracy Rate (%)'),
      ]);

      for (final qp in report.questionPerformance) {
        final aCount = qp.optionCounts['A'] ?? 0;
        final bCount = qp.optionCounts['B'] ?? 0;
        final cCount = qp.optionCounts['C'] ?? 0;
        final dCount = qp.optionCounts['D'] ?? 0;
        final total = qp.totalAttempts;

        final aPct = total > 0 ? (aCount / total) * 100 : 0.0;
        final bPct = total > 0 ? (bCount / total) * 100 : 0.0;
        final cPct = total > 0 ? (cCount / total) * 100 : 0.0;
        final dPct = total > 0 ? (dCount / total) * 100 : 0.0;

        optionsSheet.appendRow([
          IntCellValue(qp.order),
          TextCellValue(qp.questionText),
          TextCellValue(qp.correctAnswer),
          IntCellValue(aCount),
          DoubleCellValue(double.parse(aPct.toStringAsFixed(1))),
          IntCellValue(bCount),
          DoubleCellValue(double.parse(bPct.toStringAsFixed(1))),
          IntCellValue(cCount),
          DoubleCellValue(double.parse(cPct.toStringAsFixed(1))),
          IntCellValue(dCount),
          DoubleCellValue(double.parse(dPct.toStringAsFixed(1))),
          IntCellValue(qp.unansweredCount),
          IntCellValue(total),
          DoubleCellValue(double.parse(qp.correctPercentage.toStringAsFixed(1))),
        ]);
      }

      // Sheet 3: Exam Executive Summary
      const summarySheetName = 'Exam Summary';
      final summarySheet = excel[summarySheetName];

      summarySheet.appendRow([
        TextCellValue('Metric'),
        TextCellValue('Value'),
      ]);
      summarySheet.appendRow([
        TextCellValue('Exam Title'),
        TextCellValue(exam.title),
      ]);
      summarySheet.appendRow([
        TextCellValue('Exam ID'),
        TextCellValue(exam.examId),
      ]);
      summarySheet.appendRow([
        TextCellValue('Total Participants'),
        IntCellValue(report.totalParticipants),
      ]);
      summarySheet.appendRow([
        TextCellValue('Total Questions'),
        IntCellValue(report.totalQuestions),
      ]);
      summarySheet.appendRow([
        TextCellValue('Average Score'),
        DoubleCellValue(double.parse(report.averageScore.toStringAsFixed(2))),
      ]);
      summarySheet.appendRow([
        TextCellValue('Highest Score'),
        IntCellValue(report.highestScore),
      ]);
      summarySheet.appendRow([
        TextCellValue('Lowest Score'),
        IntCellValue(report.lowestScore),
      ]);
      summarySheet.appendRow([
        TextCellValue('Total Correct Answers Given'),
        IntCellValue(report.totalCorrectAnswers),
      ]);
      summarySheet.appendRow([
        TextCellValue('Total Wrong Answers Given'),
        IntCellValue(report.totalWrongAnswers),
      ]);
      summarySheet.appendRow([
        TextCellValue('Report Generated On'),
        TextCellValue(DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())),
      ]);

      // Generate clean excel filename matching exam name
      String safeExamName = exam.title.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      if (safeExamName.isEmpty) {
        safeExamName = exam.examId.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      }
      if (safeExamName.isEmpty) {
        safeExamName = 'Exam';
      }

      final fileName = safeExamName.toLowerCase().endsWith('.xlsx')
          ? safeExamName
          : '$safeExamName.xlsx';

      // excel.save automatically triggers browser download on Web using fileName
      final fileBytes = excel.save(fileName: fileName);
      if (fileBytes != null) {
        if (!kIsWeb) {
          downloadFile(Uint8List.fromList(fileBytes), fileName);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Exports a dedicated Question-Wise Option Breakdown Excel report (.xlsx)
  static Future<bool> exportOptionAnalysisToExcel({
    required ExamModel exam,
    required ExamReportModel report,
  }) async {
    try {
      final excel = Excel.createExcel();

      const optionsSheetName = 'Option Analysis Report';
      excel.rename('Sheet1', optionsSheetName);
      final sheet = excel[optionsSheetName];

      // Sheet title block
      sheet.appendRow([
        TextCellValue('EXAM: ${exam.title} (${exam.examId})'),
      ]);
      sheet.appendRow([
        TextCellValue('REPORT: QUESTION-WISE OPTION SELECTION BREAKDOWN (A, B, C, D COUNTS)'),
      ]);
      sheet.appendRow([
        TextCellValue('GENERATED ON: ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())}'),
      ]);
      sheet.appendRow([]); // Empty spacer row

      // Headers
      sheet.appendRow([
        TextCellValue('Q No'),
        TextCellValue('Question Text'),
        TextCellValue('Option A Count'),
        TextCellValue('Option A (%)'),
        TextCellValue('Option B Count'),
        TextCellValue('Option B (%)'),
        TextCellValue('Option C Count'),
        TextCellValue('Option C (%)'),
        TextCellValue('Option D Count'),
        TextCellValue('Option D (%)'),
        TextCellValue('Unanswered / Skipped'),
        TextCellValue('Total Candidates'),
        TextCellValue('Correct Key'),
        TextCellValue('Correct Count'),
        TextCellValue('Accuracy (%)'),
      ]);

      for (final qp in report.questionPerformance) {
        final aCount = qp.optionCounts['A'] ?? 0;
        final bCount = qp.optionCounts['B'] ?? 0;
        final cCount = qp.optionCounts['C'] ?? 0;
        final dCount = qp.optionCounts['D'] ?? 0;
        final total = qp.totalAttempts;

        final aPct = total > 0 ? (aCount / total) * 100 : 0.0;
        final bPct = total > 0 ? (bCount / total) * 100 : 0.0;
        final cPct = total > 0 ? (cCount / total) * 100 : 0.0;
        final dPct = total > 0 ? (dCount / total) * 100 : 0.0;

        sheet.appendRow([
          IntCellValue(qp.order),
          TextCellValue(qp.questionText),
          IntCellValue(aCount),
          DoubleCellValue(double.parse(aPct.toStringAsFixed(1))),
          IntCellValue(bCount),
          DoubleCellValue(double.parse(bPct.toStringAsFixed(1))),
          IntCellValue(cCount),
          DoubleCellValue(double.parse(cPct.toStringAsFixed(1))),
          IntCellValue(dCount),
          DoubleCellValue(double.parse(dPct.toStringAsFixed(1))),
          IntCellValue(qp.unansweredCount),
          IntCellValue(total),
          TextCellValue(qp.correctAnswer),
          IntCellValue(qp.correctCount),
          DoubleCellValue(double.parse(qp.correctPercentage.toStringAsFixed(1))),
        ]);
      }

      sheet.appendRow([]); // Spacer
      // Totals Row
      final totalSelections = report.totalACount +
          report.totalBCount +
          report.totalCCount +
          report.totalDCount +
          report.totalUnansweredCount;
      final totalAPct =
          totalSelections > 0 ? (report.totalACount / totalSelections) * 100 : 0.0;
      final totalBPct =
          totalSelections > 0 ? (report.totalBCount / totalSelections) * 100 : 0.0;
      final totalCPct =
          totalSelections > 0 ? (report.totalCCount / totalSelections) * 100 : 0.0;
      final totalDPct =
          totalSelections > 0 ? (report.totalDCount / totalSelections) * 100 : 0.0;
      final totalSkippedPct =
          totalSelections > 0 ? (report.totalUnansweredCount / totalSelections) * 100 : 0.0;

      sheet.appendRow([
        TextCellValue('TOTALS'),
        TextCellValue('ALL QUESTIONS COMBINED'),
        IntCellValue(report.totalACount),
        DoubleCellValue(double.parse(totalAPct.toStringAsFixed(1))),
        IntCellValue(report.totalBCount),
        DoubleCellValue(double.parse(totalBPct.toStringAsFixed(1))),
        IntCellValue(report.totalCCount),
        DoubleCellValue(double.parse(totalCPct.toStringAsFixed(1))),
        IntCellValue(report.totalDCount),
        DoubleCellValue(double.parse(totalDPct.toStringAsFixed(1))),
        IntCellValue(report.totalUnansweredCount),
        IntCellValue(totalSelections),
        TextCellValue('-'),
        IntCellValue(report.totalCorrectAnswers),
        DoubleCellValue(double.parse(totalSkippedPct.toStringAsFixed(1))),
      ]);

      // Sheet 2: Executive Summary
      const summarySheetName = 'Exam Summary';
      final summarySheet = excel[summarySheetName];
      summarySheet.appendRow([TextCellValue('Metric'), TextCellValue('Value')]);
      summarySheet.appendRow([TextCellValue('Exam Title'), TextCellValue(exam.title)]);
      summarySheet.appendRow([TextCellValue('Exam ID'), TextCellValue(exam.examId)]);
      summarySheet.appendRow([TextCellValue('Total Participants'), IntCellValue(report.totalParticipants)]);
      summarySheet.appendRow([TextCellValue('Total Questions'), IntCellValue(report.totalQuestions)]);
      summarySheet.appendRow([
        TextCellValue('Average Score'),
        DoubleCellValue(double.parse(report.averageScore.toStringAsFixed(2))),
      ]);
      summarySheet.appendRow([TextCellValue('Total Option A Chosen'), IntCellValue(report.totalACount)]);
      summarySheet.appendRow([TextCellValue('Total Option B Chosen'), IntCellValue(report.totalBCount)]);
      summarySheet.appendRow([TextCellValue('Total Option C Chosen'), IntCellValue(report.totalCCount)]);
      summarySheet.appendRow([TextCellValue('Total Option D Chosen'), IntCellValue(report.totalDCount)]);
      summarySheet.appendRow([TextCellValue('Total Skipped/Unanswered'), IntCellValue(report.totalUnansweredCount)]);

      // Clean filename
      String safeExamName = exam.title.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      if (safeExamName.isEmpty) {
        safeExamName = exam.examId.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      }
      final fileName = '${safeExamName}_Option_Report.xlsx';

      final fileBytes = excel.save(fileName: fileName);
      if (fileBytes != null) {
        if (!kIsWeb) {
          downloadFile(Uint8List.fromList(fileBytes), fileName);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
