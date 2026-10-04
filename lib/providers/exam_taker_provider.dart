import 'package:flutter/foundation.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/response_model.dart';
import '../services/exam_service.dart';
import '../services/response_service.dart';

class ExamTakerProvider extends ChangeNotifier {
  final ExamService _examService = ExamService();
  final ResponseService _responseService = ResponseService();

  bool _isLoading = false;
  String? _errorMessage;

  String _candidateName = '';
  String _candidatePhone = '';
  String _examId = '';
  ExamModel? _currentExam;
  List<QuestionModel> _questions = [];

  int _currentQuestionIndex = 0;
  // Map of questionId -> selected option ('A', 'B', 'C', or 'D')
  final Map<String, String> _answers = {};
  // Set of question IDs flagged for review
  final Set<String> _flaggedForReview = {};

  ResponseModel? _submissionResult;
  DateTime? _examStartTime;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get candidateName => _candidateName;
  String get candidatePhone => _candidatePhone;
  String get examId => _examId;
  ExamModel? get currentExam => _currentExam;
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get answers => _answers;
  Set<String> get flaggedForReview => _flaggedForReview;
  ResponseModel? get submissionResult => _submissionResult;
  DateTime? get examStartTime => _examStartTime;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;

  int get totalQuestions => _questions.length;
  int get answeredCount => _answers.length;
  int get unansweredCount => _questions.length - _answers.length;

  /// Validates candidate credentials, verifies exam password, and guards against duplicate submission
  Future<bool> validateAndStartExam({
    required String name,
    required String phone,
    required String examId,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanExamId = examId.trim();
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').trim();
      final cleanName = name.trim();

      // 1. Fetch Exam
      final exam = await _examService.getExam(cleanExamId);
      if (exam == null) {
        _errorMessage = 'Exam "$cleanExamId" not found. Please check the Exam ID.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!exam.isActive) {
        _errorMessage = 'This exam is currently not active.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Validate Password
      if (exam.password != password.trim()) {
        _errorMessage = 'Incorrect Exam Password. Please contact your administrator.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. Prevent duplicate submission by phone number
      final hasAlreadySubmitted = await _responseService.hasUserAlreadySubmitted(
        examId: cleanExamId,
        phone: cleanPhone,
      );

      if (hasAlreadySubmitted) {
        _errorMessage =
            'A response has already been submitted for phone number $cleanPhone on this exam. Duplicate attempts are not permitted.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 4. Fetch questions dynamically
      final fetchedQuestions = await _examService.getQuestions(cleanExamId);
      if (fetchedQuestions.isEmpty) {
        _errorMessage = 'This exam does not have any questions published yet.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 5. Initialize session
      _candidateName = cleanName;
      _candidatePhone = cleanPhone;
      _examId = cleanExamId;
      _currentExam = exam;
      _questions = fetchedQuestions;
      _currentQuestionIndex = 0;
      _answers.clear();
      _flaggedForReview.clear();
      _submissionResult = null;
      _examStartTime = DateTime.now();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error initiating exam: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select an answer bubble for a question
  void selectOption(String questionId, String option) {
    _answers[questionId] = option.toUpperCase();
    notifyListeners();
  }

  /// Clear the selected bubble
  void clearAnswer(String questionId) {
    _answers.remove(questionId);
    notifyListeners();
  }

  /// Toggle flag for review
  void toggleFlagForReview(String questionId) {
    if (_flaggedForReview.contains(questionId)) {
      _flaggedForReview.remove(questionId);
    } else {
      _flaggedForReview.add(questionId);
    }
    notifyListeners();
  }

  /// Navigate directly to a specific question index
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Calculates score based on correct answers and submits to Firestore
  Future<bool> submitExam() async {
    if (_currentExam == null || _questions.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int score = 0;
      final Map<String, dynamic> itemDetails = {};

      for (final q in _questions) {
        final chosen = _answers[q.id]?.toUpperCase();
        final correct = q.correctAnswer.toUpperCase();
        final isCorrect = (chosen != null && chosen == correct);

        if (isCorrect) {
          score += q.marks;
        }

        itemDetails[q.id] = {
          'questionText': q.questionText,
          'selected': chosen ?? 'UNANSWERED',
          'correct': correct,
          'isCorrect': isCorrect,
          'marks': isCorrect ? q.marks : 0,
        };
      }

      final percentage = _questions.isNotEmpty
          ? (score / _questions.length) * 100
          : 0.0;

      final response = ResponseModel(
        id: '',
        examId: _currentExam!.examId,
        name: _candidateName,
        phone: _candidatePhone,
        answers: Map<String, String>.from(_answers),
        score: score,
        totalQuestions: _questions.length,
        percentage: percentage,
        submittedAt: DateTime.now(),
        itemDetails: itemDetails,
      );

      final docId = await _responseService.submitResponse(response);

      _submissionResult = ResponseModel(
        id: docId,
        examId: response.examId,
        name: response.name,
        phone: response.phone,
        answers: response.answers,
        score: response.score,
        totalQuestions: response.totalQuestions,
        percentage: response.percentage,
        submittedAt: response.submittedAt,
        itemDetails: itemDetails,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset session after completion
  void resetSession() {
    _candidateName = '';
    _candidatePhone = '';
    _examId = '';
    _currentExam = null;
    _questions = [];
    _currentQuestionIndex = 0;
    _answers.clear();
    _flaggedForReview.clear();
    _submissionResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
