import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String questionText;
  final Map<String, String> options; // Key: 'A', 'B', 'C', 'D' -> Value: Option text
  final String correctAnswer; // 'A', 'B', 'C', or 'D'
  final int order;
  final int marks;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.order,
    this.marks = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer.toUpperCase(),
      'order': order,
      'marks': marks,
    };
  }

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Safely cast options map
    final rawOptions = data['options'] as Map<dynamic, dynamic>? ?? {};
    final castedOptions = <String, String>{
      'A': rawOptions['A']?.toString() ?? '',
      'B': rawOptions['B']?.toString() ?? '',
      'C': rawOptions['C']?.toString() ?? '',
      'D': rawOptions['D']?.toString() ?? '',
    };

    return QuestionModel(
      id: doc.id,
      questionText: data['questionText']?.toString() ?? '',
      options: castedOptions,
      correctAnswer: (data['correctAnswer']?.toString() ?? 'A').toUpperCase(),
      order: (data['order'] as num?)?.toInt() ?? 0,
      marks: (data['marks'] as num?)?.toInt() ?? 1,
    );
  }

  QuestionModel copyWith({
    String? id,
    String? questionText,
    Map<String, String>? options,
    String? correctAnswer,
    int? order,
    int? marks,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      order: order ?? this.order,
      marks: marks ?? this.marks,
    );
  }
}
