import 'package:cloud_firestore/cloud_firestore.dart';

class ExamModel {
  final String examId;
  final String title;
  final String password;
  final String description;
  final int totalQuestions;
  final DateTime createdAt;
  final bool isActive;

  ExamModel({
    required this.examId,
    required this.title,
    required this.password,
    this.description = '',
    this.totalQuestions = 0,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'title': title,
      'password': password,
      'description': description,
      'totalQuestions': totalQuestions,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  factory ExamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime parsedDate;
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return ExamModel(
      examId: doc.id,
      title: data['title'] ?? '',
      password: data['password'] ?? '',
      description: data['description'] ?? '',
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      createdAt: parsedDate,
      isActive: data['isActive'] ?? true,
    );
  }

  ExamModel copyWith({
    String? examId,
    String? title,
    String? password,
    String? description,
    int? totalQuestions,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ExamModel(
      examId: examId ?? this.examId,
      title: title ?? this.title,
      password: password ?? this.password,
      description: description ?? this.description,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
