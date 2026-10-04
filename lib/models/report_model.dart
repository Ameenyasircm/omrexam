class OptionChoiceBreakdown {
  final String optionKey; // 'A', 'B', 'C', 'D'
  final String optionText; // Text of the option
  final int count; // Count of candidates who selected this option
  final double percentage; // Percentage of participants (0.0 to 100.0)
  final bool isCorrect; // True if this is the correct answer key

  OptionChoiceBreakdown({
    required this.optionKey,
    required this.optionText,
    required this.count,
    required this.percentage,
    required this.isCorrect,
  });
}

class QuestionPerformance {
  final String questionId;
  final String questionText;
  final int order;
  final String correctAnswer;
  final int correctCount;
  final int totalAttempts;
  final double correctPercentage;
  final Map<String, int> optionCounts; // Key: 'A', 'B', 'C', 'D', 'unanswered' -> Count
  final List<OptionChoiceBreakdown> optionsBreakdown;
  final int unansweredCount;

  QuestionPerformance({
    required this.questionId,
    required this.questionText,
    required this.order,
    this.correctAnswer = 'A',
    required this.correctCount,
    required this.totalAttempts,
    required this.correctPercentage,
    this.optionCounts = const {},
    this.optionsBreakdown = const [],
    this.unansweredCount = 0,
  });
}

class CandidateRankItem {
  final int rank;
  final String name;
  final String phone;
  final int score;
  final int totalQuestions;
  final double percentage;
  final DateTime submittedAt;
  final String status;

  CandidateRankItem({
    required this.rank,
    required this.name,
    required this.phone,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.submittedAt,
    required this.status,
  });
}

class ScoreDistribution {
  final String rangeLabel; // e.g. "0-20%", "21-40%", "41-60%", "61-80%", "81-100%"
  final int count;

  ScoreDistribution({required this.rangeLabel, required this.count});
}

class ExamReportModel {
  final String examId;
  final String examTitle;
  final int totalParticipants;
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final int totalQuestions;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final List<ScoreDistribution> scoreDistribution;
  final List<QuestionPerformance> questionPerformance;
  final List<CandidateRankItem> rankList;
  final int totalACount;
  final int totalBCount;
  final int totalCCount;
  final int totalDCount;
  final int totalUnansweredCount;

  ExamReportModel({
    required this.examId,
    required this.examTitle,
    required this.totalParticipants,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.totalQuestions,
    required this.totalCorrectAnswers,
    required this.totalWrongAnswers,
    required this.scoreDistribution,
    required this.questionPerformance,
    this.rankList = const [],
    this.totalACount = 0,
    this.totalBCount = 0,
    this.totalCCount = 0,
    this.totalDCount = 0,
    this.totalUnansweredCount = 0,
  });

  factory ExamReportModel.empty(String examId, String examTitle) {
    return ExamReportModel(
      examId: examId,
      examTitle: examTitle,
      totalParticipants: 0,
      averageScore: 0.0,
      highestScore: 0,
      lowestScore: 0,
      totalQuestions: 0,
      totalCorrectAnswers: 0,
      totalWrongAnswers: 0,
      scoreDistribution: [
        ScoreDistribution(rangeLabel: '0-20%', count: 0),
        ScoreDistribution(rangeLabel: '21-40%', count: 0),
        ScoreDistribution(rangeLabel: '41-60%', count: 0),
        ScoreDistribution(rangeLabel: '61-80%', count: 0),
        ScoreDistribution(rangeLabel: '81-100%', count: 0),
      ],
      questionPerformance: [],
      rankList: [],
      totalACount: 0,
      totalBCount: 0,
      totalCCount: 0,
      totalDCount: 0,
      totalUnansweredCount: 0,
    );
  }
}
