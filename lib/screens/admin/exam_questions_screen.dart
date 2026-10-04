import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exam_model.dart';
import '../../models/question_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_text_field.dart';

class ExamQuestionsScreen extends StatefulWidget {
  final ExamModel exam;

  const ExamQuestionsScreen({super.key, required this.exam});

  @override
  State<ExamQuestionsScreen> createState() => _ExamQuestionsScreenState();
}

class _ExamQuestionsScreenState extends State<ExamQuestionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().selectExam(widget.exam);
    });
  }

  void _showAddQuestionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddQuestionDialog(exam: widget.exam),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final questions = admin.selectedExamQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.exam.title} (${widget.exam.examId})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Manage Exam Questions',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: _showAddQuestionDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Question'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: admin.isLoading && questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.help_outline_rounded,
                            size: 48,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'No Questions Added Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add multiple-choice questions with 4 options (A, B, C, D) and specify the correct answer.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _showAddQuestionDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add First Question'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: questions.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return _buildQuestionCard(context, q, index + 1);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildQuestionCard(
      BuildContext context, QuestionModel question, int number) {
    final admin = context.read<AdminProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.4,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 20),
                tooltip: 'Delete Question',
                onPressed: () {
                  _confirmDelete(context, admin, question.id, number);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Options Grid
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: ['A', 'B', 'C', 'D'].map((key) {
              final isCorrect = question.correctAnswer == key;
              final text = question.options[key] ?? '';

              return Container(
                constraints: const BoxConstraints(minWidth: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                    width: isCorrect ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFCBD5E1),
                      ),
                      child: Center(
                        child: Text(
                          key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isCorrect ? FontWeight.w600 : FontWeight.normal,
                          color: isCorrect
                              ? const Color(0xFF065F46)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 16),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AdminProvider admin, String qId, int number) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question?'),
        content: Text('Are you sure you want to delete Question Q$number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              admin.deleteQuestion(qId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddQuestionDialog extends StatefulWidget {
  final ExamModel exam;

  const _AddQuestionDialog({required this.exam});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _optCController = TextEditingController();
  final _optDController = TextEditingController();
  String _selectedCorrect = 'A';
  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    _optAController.dispose();
    _optBController.dispose();
    _optCController.dispose();
    _optDController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final admin = context.read<AdminProvider>();
    final success = await admin.addQuestion(
      questionText: _questionController.text,
      options: {
        'A': _optAController.text.trim(),
        'B': _optBController.text.trim(),
        'C': _optCController.text.trim(),
        'D': _optDController.text.trim(),
      },
      correctAnswer: _selectedCorrect,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question added successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Exam Question',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),

                CustomTextField(
                  controller: _questionController,
                  label: 'Question Prompt',
                  hint: 'Enter the question text...',
                  maxLines: 3,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Question text cannot be empty'
                      : null,
                ),
                const SizedBox(height: 18),

                const Text(
                  'Four Options (A, B, C, D)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _optAController,
                  label: 'Option A',
                  hint: 'Enter option A text',
                  prefixIcon: Icons.looks_one_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Option A required' : null,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _optBController,
                  label: 'Option B',
                  hint: 'Enter option B text',
                  prefixIcon: Icons.looks_two_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Option B required' : null,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _optCController,
                  label: 'Option C',
                  hint: 'Enter option C text',
                  prefixIcon: Icons.looks_3_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Option C required' : null,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _optDController,
                  label: 'Option D',
                  hint: 'Enter option D text',
                  prefixIcon: Icons.looks_4_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Option D required' : null,
                ),
                const SizedBox(height: 20),

                // Select Correct Answer Radio/Segmented
                const Text(
                  'Select Correct Answer:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: ['A', 'B', 'C', 'D'].map((opt) {
                    final isChosen = _selectedCorrect == opt;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCorrect = opt;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isChosen
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isChosen ? Colors.white : const Color(0xFF334155),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _isSaving ? null : _saveQuestion,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Question',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
