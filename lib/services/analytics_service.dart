import 'dart:math';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/report_model.dart';
import '../models/response_model.dart';

class AnalyticsService {
  /// Computes rich analytics, question-wise option breakdowns, and rank list
  static ExamReportModel generateReport({
    required ExamModel exam,
    required List<QuestionModel> questions,
    required List<ResponseModel> responses,
  }) {
    if (responses.isEmpty) {
      return ExamReportModel.empty(exam.examId, exam.title);
    }

    final totalParticipants = responses.length;
    final totalQuestions = questions.length;

    // Sort questions by order for consistent reporting
    final sortedQuestions = List<QuestionModel>.from(questions)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Scores calculation
    int sumScore = 0;
    int highestScore = 0;
    int lowestScore = totalQuestions;

    // Score distribution brackets: [0-20%], [21-40%], [41-60%], [61-80%], [81-100%]
    int b1 = 0; // 0 - 20%
    int b2 = 0; // 21 - 40%
    int b3 = 0; // 41 - 60%
    int b4 = 0; // 61 - 80%
    int b5 = 0; // 81 - 100%

    int totalCorrectAnswers = 0;
    int totalWrongAnswers = 0;

    for (final response in responses) {
      final score = response.score;
      sumScore += score;
      highestScore = max(highestScore, score);
      lowestScore = min(lowestScore, score);

      final percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;
      if (percentage <= 20) {
        b1++;
      } else if (percentage <= 40) {
        b2++;
      } else if (percentage <= 60) {
        b3++;
      } else if (percentage <= 80) {
        b4++;
      } else {
        b5++;
      }

      totalCorrectAnswers += score;
      totalWrongAnswers += max(0, totalQuestions - score);
    }

    final averageScore = sumScore / totalParticipants;

    // Calculate Rank List (sorted rank-wise)
    // 1st: Score descending
    // 2nd: Percentage descending
    // 3rd: Earlier submission time ascending
    final sortedResponses = List<ResponseModel>.from(responses)
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;

        final pctCompare = b.percentage.compareTo(a.percentage);
        if (pctCompare != 0) return pctCompare;

        return a.submittedAt.compareTo(b.submittedAt);
      });

    final List<CandidateRankItem> rankList = [];
    for (int i = 0; i < sortedResponses.length; i++) {
      final r = sortedResponses[i];
      rankList.add(
        CandidateRankItem(
          rank: i + 1,
          name: r.name,
          phone: r.phone,
          score: r.score,
          totalQuestions: r.totalQuestions,
          percentage: r.percentage,
          submittedAt: r.submittedAt,
          status: r.percentage >= 50 ? 'Pass' : 'Needs Improvement',
        ),
      );
    }

    // Question-wise option selection count breakdown
    final List<QuestionPerformance> questionPerformance = [];
    int totalACount = 0;
    int totalBCount = 0;
    int totalCCount = 0;
    int totalDCount = 0;
    int totalUnanswered = 0;

    for (final question in sortedQuestions) {
      final Map<String, int> counts = {
        'A': 0,
        'B': 0,
        'C': 0,
        'D': 0,
      };
      int unanswered = 0;

      for (final response in responses) {
        final chosen = response.answers[question.id]?.trim().toUpperCase();
        if (chosen == 'A' || chosen == 'B' || chosen == 'C' || chosen == 'D') {
          counts[chosen!] = (counts[chosen] ?? 0) + 1;
        } else {
          unanswered++;
        }
      }

      totalACount += counts['A'] ?? 0;
      totalBCount += counts['B'] ?? 0;
      totalCCount += counts['C'] ?? 0;
      totalDCount += counts['D'] ?? 0;
      totalUnanswered += unanswered;

      final correctKey = question.correctAnswer.toUpperCase();
      final correctCount = counts[correctKey] ?? 0;
      final correctPct =
          totalParticipants > 0 ? (correctCount / totalParticipants) * 100 : 0.0;

      final List<OptionChoiceBreakdown> optionsBreakdown = [];
      for (final optKey in ['A', 'B', 'C', 'D']) {
        final optCount = counts[optKey] ?? 0;
        final optPct = totalParticipants > 0
            ? (optCount / totalParticipants) * 100
            : 0.0;
        optionsBreakdown.add(
          OptionChoiceBreakdown(
            optionKey: optKey,
            optionText: question.options[optKey] ?? '',
            count: optCount,
            percentage: optPct,
            isCorrect: optKey == correctKey,
          ),
        );
      }

      counts['unanswered'] = unanswered;

      questionPerformance.add(
        QuestionPerformance(
          questionId: question.id,
          questionText: question.questionText,
          order: question.order,
          correctAnswer: correctKey,
          correctCount: correctCount,
          totalAttempts: totalParticipants,
          correctPercentage: correctPct,
          optionCounts: counts,
          optionsBreakdown: optionsBreakdown,
          unansweredCount: unanswered,
        ),
      );
    }

    return ExamReportModel(
      examId: exam.examId,
      examTitle: exam.title,
      totalParticipants: totalParticipants,
      averageScore: averageScore,
      highestScore: highestScore,
      lowestScore: lowestScore,
      totalQuestions: totalQuestions,
      totalCorrectAnswers: totalCorrectAnswers,
      totalWrongAnswers: totalWrongAnswers,
      scoreDistribution: [
        ScoreDistribution(rangeLabel: '0-20%', count: b1),
        ScoreDistribution(rangeLabel: '21-40%', count: b2),
        ScoreDistribution(rangeLabel: '41-60%', count: b3),
        ScoreDistribution(rangeLabel: '61-80%', count: b4),
        ScoreDistribution(rangeLabel: '81-100%', count: b5),
      ],
      questionPerformance: questionPerformance,
      rankList: rankList,
      totalACount: totalACount,
      totalBCount: totalBCount,
      totalCCount: totalCCount,
      totalDCount: totalDCount,
      totalUnansweredCount: totalUnanswered,
    );
  }
}
