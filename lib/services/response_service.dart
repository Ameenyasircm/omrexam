import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response_model.dart';

class ResponseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _responsesRef =>
      _firestore.collection('responses');

  CollectionReference<Map<String, dynamic>> _examResponsesRef(String examId) =>
      _firestore.collection('exams').doc(examId).collection('responses');

  /// Checks if a candidate with the given phone number has already submitted for this exam
  Future<bool> hasUserAlreadySubmitted({
    required String examId,
    required String phone,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').trim();

    // Query subcollection for isolation and direct lookup
    final subQuery = await _examResponsesRef(examId)
        .where('phone', isEqualTo: cleanPhone)
        .limit(1)
        .get();

    if (subQuery.docs.isNotEmpty) {
      return true;
    }

    // Secondary check on top-level responses collection
    final topQuery = await _responsesRef
        .where('examId', isEqualTo: examId)
        .where('phone', isEqualTo: cleanPhone)
        .limit(1)
        .get();

    return topQuery.docs.isNotEmpty;
  }

  /// Submits an exam response to both exams/{examId}/responses and /responses for easy reporting
  Future<String> submitResponse(ResponseModel response) async {
    // 1. Guard against duplicate submission
    final isDuplicate = await hasUserAlreadySubmitted(
      examId: response.examId,
      phone: response.phone,
    );

    if (isDuplicate) {
      throw Exception(
        'A submission with phone number "${response.phone}" already exists for Exam "${response.examId}". Only one submission is permitted.',
      );
    }

    final batch = _firestore.batch();

    // Top-level responses doc
    final topDoc = _responsesRef.doc();
    batch.set(topDoc, response.toMap());

    // Subcollection doc inside exams/{examId}/responses
    final subDoc = _examResponsesRef(response.examId).doc(topDoc.id);
    batch.set(subDoc, response.toMap());

    await batch.commit();
    return topDoc.id;
  }

  /// Streams all responses submitted for an exam
  Stream<List<ResponseModel>> streamResponsesForExam(String examId) {
    return _examResponsesRef(examId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ResponseModel.fromFirestore(doc)).toList());
  }

  /// Fetches all responses submitted for an exam
  Future<List<ResponseModel>> getResponsesForExam(String examId) async {
    final query = await _examResponsesRef(examId)
        .orderBy('submittedAt', descending: true)
        .get();
    return query.docs.map((doc) => ResponseModel.fromFirestore(doc)).toList();
  }
}
