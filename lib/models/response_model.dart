import 'package:cloud_firestore/cloud_firestore.dart';

class ResponseModel {
  final String id;
  final String examId;
  final String name;
  final String phone;
  final Map<String, String> answers; // questionId -> selectedOption
  final int score;
  final int totalQuestions;
  final double percentage;
  final DateTime submittedAt;
  final Map<String, dynamic>? itemDetails; // questionId -> {'isCorrect': bool, ...}

  ResponseModel({
    required this.id,
    required this.examId,
    required this.name,
    required this.phone,
    required this.answers,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.submittedAt,
    this.itemDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'name': name.trim(),
      'phone': phone.trim(),
      'answers': answers,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'itemDetails': itemDetails ?? {},
    };
  }

  factory ResponseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawAnswers = data['answers'] as Map<dynamic, dynamic>? ?? {};
    final castedAnswers = <String, String>{};
    rawAnswers.forEach((key, value) {
      castedAnswers[key.toString()] = value?.toString() ?? '';
    });

    DateTime parsedDate;
    if (data['submittedAt'] is Timestamp) {
      parsedDate = (data['submittedAt'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    final rawScore = (data['score'] as num?)?.toInt() ?? 0;
    final rawTotal = (data['totalQuestions'] as num?)?.toInt() ?? 0;
    final rawPercentage = (data['percentage'] as num?)?.toDouble() ??
        (rawTotal > 0 ? (rawScore / rawTotal) * 100 : 0.0);

    return ResponseModel(
      id: doc.id,
      examId: data['examId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      answers: castedAnswers,
      score: rawScore,
      totalQuestions: rawTotal,
      percentage: rawPercentage,
      submittedAt: parsedDate,
      itemDetails: data['itemDetails'] as Map<String, dynamic>?,
    );
  }
}
