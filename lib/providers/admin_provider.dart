import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/report_model.dart';
import '../models/response_model.dart';
import '../services/analytics_service.dart';
import '../services/exam_service.dart';
import '../services/response_service.dart';

class AdminProvider extends ChangeNotifier {
  final ExamService _examService = ExamService();
  final ResponseService _responseService = ResponseService();

  bool _isAdminLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<ExamModel> _exams = [];
  ExamModel? _selectedExam;
  List<QuestionModel> _selectedExamQuestions = [];
  List<ResponseModel> _selectedExamResponses = [];
  ExamReportModel? _currentReport;

  StreamSubscription? _examsSub;
  StreamSubscription? _questionsSub;
  StreamSubscription? _responsesSub;

  // Getters
  bool get isAdminLoggedIn => _isAdminLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ExamModel> get exams => _exams;
  ExamModel? get selectedExam => _selectedExam;
  List<QuestionModel> get selectedExamQuestions => _selectedExamQuestions;
  List<ResponseModel> get selectedExamResponses => _selectedExamResponses;
  ExamReportModel? get currentReport => _currentReport;

  /// Default Admin Login (supports credentials e.g. yusr / yusr123)
  bool login(String username, String password) {
    if (username.trim() == 'yusr' && password == 'yusr123') {
      _isAdminLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
      listenToExams();
      return true;
    } else {
      _errorMessage = 'Invalid admin credentials.';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAdminLoggedIn = false;
    _selectedExam = null;
    _selectedExamQuestions = [];
    _selectedExamResponses = [];
    _currentReport = null;
    _cancelSubscriptions();
    notifyListeners();
  }

  /// Listen to real-time exams stream
  void listenToExams() {
    _examsSub?.cancel();
    _setLoading(true);
    _examsSub = _examService.streamExams().listen(
      (examsList) {
        _exams = examsList;
        _setLoading(false);
      },
      onError: (err) {
        _errorMessage = 'Error loading exams: $err';
        _setLoading(false);
      },
    );
  }

  /// Select an exam and listen to its questions & responses
  void selectExam(ExamModel exam) {
    _selectedExam = exam;
    _questionsSub?.cancel();
    _responsesSub?.cancel();
    _setLoading(true);

    _questionsSub = _examService.streamQuestions(exam.examId).listen((questions) {
      _selectedExamQuestions = questions;
      _computeReport();
      _setLoading(false);
    });

    _responsesSub = _responseService.streamResponsesForExam(exam.examId).listen((responses) {
      _selectedExamResponses = responses;
      _computeReport();
      _setLoading(false);
    });
  }

  void _computeReport() {
    if (_selectedExam != null) {
      _currentReport = AnalyticsService.generateReport(
        exam: _selectedExam!,
        questions: _selectedExamQuestions,
        responses: _selectedExamResponses,
      );
      notifyListeners();
    }
  }

  /// Create a new exam
  Future<bool> createExam({
    required String examId,
    required String title,
    required String password,
    String description = '',
  }) async {
    _setLoading(true);
    try {
      final newExam = ExamModel(
        examId: examId.trim(),
        title: title.trim(),
        password: password.trim(),
        description: description.trim(),
        createdAt: DateTime.now(),
        totalQuestions: 0,
      );
      await _examService.createExam(newExam);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Add a question to the selected exam
  Future<bool> addQuestion({
    required String questionText,
    required Map<String, String> options,
    required String correctAnswer,
  }) async {
    if (_selectedExam == null) return false;
    _setLoading(true);

    try {
      final nextOrder = _selectedExamQuestions.length + 1;
      final newQuestion = QuestionModel(
        id: '',
        questionText: questionText.trim(),
        options: options,
        correctAnswer: correctAnswer.toUpperCase().trim(),
        order: nextOrder,
      );

      await _examService.addQuestion(_selectedExam!.examId, newQuestion);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Delete a question
  Future<void> deleteQuestion(String questionId) async {
    if (_selectedExam == null) return;
    try {
      await _examService.deleteQuestion(_selectedExam!.examId, questionId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Delete an exam
  Future<void> deleteExam(String examId) async {
    try {
      await _examService.deleteExam(examId);
      if (_selectedExam?.examId == examId) {
        _selectedExam = null;
        _selectedExamQuestions = [];
        _selectedExamResponses = [];
        _currentReport = null;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _examsSub?.cancel();
    _questionsSub?.cancel();
    _responsesSub?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
