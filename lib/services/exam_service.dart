import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _examsRef =>
      _firestore.collection('exams');

  CollectionReference<Map<String, dynamic>> _questionsRef(String examId) =>
      _examsRef.doc(examId).collection('questions');

  /// Creates a new exam in Firestore with the specified examId
  Future<void> createExam(ExamModel exam) async {
    final docRef = _examsRef.doc(exam.examId.trim());
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      throw Exception('An exam with ID "${exam.examId}" already exists. Please choose a unique ID.');
    }
    await docRef.set(exam.toMap());
  }

  /// Fetches an exam by its ID
  Future<ExamModel?> getExam(String examId) async {
    final doc = await _examsRef.doc(examId.trim()).get();
    if (!doc.exists) return null;
    return ExamModel.fromFirestore(doc);
  }

  /// Streams the list of all exams, ordered by creation date descending
  Stream<List<ExamModel>> streamExams() {
    return _examsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ExamModel.fromFirestore(doc)).toList());
  }

  /// Adds a question to the exam's questions subcollection
  Future<void> addQuestion(String examId, QuestionModel question) async {
    final examDoc = _examsRef.doc(examId);
    final questionsCol = _questionsRef(examId);

    // Run transaction or batch to add question and increment totalQuestions count
    await _firestore.runTransaction((transaction) async {
      final examSnapshot = await transaction.get(examDoc);
      if (!examSnapshot.exists) {
        throw Exception('Exam not found');
      }

      final newQuestionDoc = questionsCol.doc();
      transaction.set(newQuestionDoc, question.toMap());

      final currentTotal =
          (examSnapshot.data()?['totalQuestions'] as num?)?.toInt() ?? 0;
      transaction.update(examDoc, {'totalQuestions': currentTotal + 1});
    });
  }

  /// Deletes a question from the exam's questions subcollection
  Future<void> deleteQuestion(String examId, String questionId) async {
    final examDoc = _examsRef.doc(examId);
    final questionDoc = _questionsRef(examId).doc(questionId);

    await _firestore.runTransaction((transaction) async {
      final examSnapshot = await transaction.get(examDoc);
      transaction.delete(questionDoc);

      if (examSnapshot.exists) {
        final currentTotal =
            (examSnapshot.data()?['totalQuestions'] as num?)?.toInt() ?? 1;
        transaction.update(examDoc, {
          'totalQuestions': currentTotal > 0 ? currentTotal - 1 : 0,
        });
      }
    });
  }

  /// Fetches all questions for an exam ordered by order index
  Future<List<QuestionModel>> getQuestions(String examId) async {
    final query = await _questionsRef(examId).orderBy('order').get();
    return query.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
  }

  /// Streams questions for real-time updates
  Stream<List<QuestionModel>> streamQuestions(String examId) {
    return _questionsRef(examId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList());
  }

  /// Deletes an exam and its questions subcollection
  Future<void> deleteExam(String examId) async {
    // Delete subcollection docs first
    final questionsSnapshot = await _questionsRef(examId).get();
    final batch = _firestore.batch();
    for (var doc in questionsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_examsRef.doc(examId));
    await batch.commit();
  }
}
