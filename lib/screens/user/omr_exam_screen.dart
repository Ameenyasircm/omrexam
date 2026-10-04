import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_taker_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/omr_bubble.dart';
import '../../widgets/responsive_layout.dart';
import 'exam_result_screen.dart';

class OmrExamScreen extends StatelessWidget {
  const OmrExamScreen({super.key});

  void _showSubmitConfirmation(BuildContext context) {
    final examTaker = context.read<ExamTakerProvider>();
    final total = examTaker.totalQuestions;
    final answered = examTaker.answeredCount;
    final unanswered = examTaker.unansweredCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF2563EB), size: 24),
            SizedBox(width: 10),
            Text('Submit Examination?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please review your attempt summary before final submission. Once submitted, your answers cannot be altered.',
              style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Total Questions:', '$total'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Answered:', '$answered',
                      valueColor: const Color(0xFF10B981)),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Unanswered:', '$unanswered',
                      valueColor: unanswered > 0
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back to Test'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await examTaker.submitExam();
              if (success && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ExamResultScreen()),
                );
              }
            },
            child: const Text('Confirm & Submit'),
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFF0F172A))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final examTaker = context.watch<ExamTakerProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final exam = examTaker.currentExam;
    final currentQ = examTaker.currentQuestion;

    if (exam == null || currentQ == null) {
      return const Scaffold(
        body: Center(child: Text('No active exam session found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const AppLogo(size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Candidate: ${examTaker.candidateName} | Phone: ${examTaker.candidatePhone}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Mobile OMR Sheet Opener button
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.grid_on_rounded, color: Color(0xFF2563EB)),
              tooltip: 'Open OMR Bubble Sheet',
              onPressed: () {
                _showMobileOmrSheet(context);
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: FilledButton.icon(
              onPressed: examTaker.isLoading
                  ? null
                  : () => _showSubmitConfirmation(context),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(isDesktop ? 'Submit Exam' : 'Submit'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: examTaker.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left Question Panel
                Expanded(
                  flex: 7,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: _buildQuestionCard(context),
                      ),
                    ),
                  ),
                ),

                // Right OMR Sheet Panel (Desktop only)
                if (isDesktop)
                  Container(
                    width: 340,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(left: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: const OmrPaletteView(),
                  ),
              ],
            ),
    );
  }

  void _showMobileOmrSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: const OmrPaletteView(),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final examTaker = context.watch<ExamTakerProvider>();
    final q = examTaker.currentQuestion!;
    final qIndex = examTaker.currentQuestionIndex;
    final totalQ = examTaker.totalQuestions;
    final selectedOption = examTaker.answers[q.id];
    final isFlagged = examTaker.flaggedForReview.contains(q.id);

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question number & Flag toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Question ${qIndex + 1} of $totalQ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => examTaker.toggleFlagForReview(q.id),
                icon: Icon(
                  isFlagged ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 16,
                  color: isFlagged ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                ),
                label: Text(
                  isFlagged ? 'Flagged for Review' : 'Mark for Review',
                  style: TextStyle(
                    fontSize: 12,
                    color: isFlagged ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isFlagged
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE2E8F0),
                  ),
                  backgroundColor: isFlagged
                      ? const Color(0xFFFFFBEB)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Prompt
          Text(
            q.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Select your answer option:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Options A, B, C, D
          ...['A', 'B', 'C', 'D'].map((key) {
            final isChosen = selectedOption == key;
            final optionText = q.options[key] ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => examTaker.selectOption(q.id, key),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isChosen
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isChosen
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                      width: isChosen ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      OmrBubble(
                        label: key,
                        isSelected: isChosen,
                        onTap: () => examTaker.selectOption(q.id, key),
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isChosen
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isChosen
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (isChosen)
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF2563EB), size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 20),

          // Navigation row: Clear, Previous, Next with responsive Wrap
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              TextButton.icon(
                onPressed: selectedOption == null
                    ? null
                    : () => examTaker.clearAnswer(q.id),
                icon: const Icon(Icons.restart_alt_rounded, size: 16),
                label: const Text('Clear Bubble'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: qIndex > 0 ? examTaker.previousQuestion : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: qIndex < totalQ - 1
                        ? examTaker.nextQuestion
                        : () => _showSubmitConfirmation(context),
                    icon: Icon(qIndex < totalQ - 1
                        ? Icons.chevron_right_rounded
                        : Icons.check_rounded),
                    label: Text(qIndex < totalQ - 1 ? 'Next' : 'Review & Finish'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dedicated OMR Sheet Palette View (reusable on desktop sidebar & mobile modal)
class OmrPaletteView extends StatelessWidget {
  const OmrPaletteView({super.key});

  @override
  Widget build(BuildContext context) {
    final examTaker = context.watch<ExamTakerProvider>();
    final questions = examTaker.questions;
    final currentIndex = examTaker.currentQuestionIndex;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.ballot_outlined,
                      color: Color(0xFF2563EB), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'OMR Answer Sheet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Legend
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildLegend(
                    color: const Color(0xFF0F172A),
                    label: 'Answered (${examTaker.answeredCount})',
                  ),
                  _buildLegend(
                    color: const Color(0xFFCBD5E1),
                    label: 'Unanswered (${examTaker.unansweredCount})',
                  ),
                  _buildLegend(
                    color: const Color(0xFFF59E0B),
                    label: 'Flagged (${examTaker.flaggedForReview.length})',
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Questions OMR Rows
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            separatorBuilder: (_, index) =>
                const Divider(height: 12, color: Color(0xFFF8FAFC)),
            itemBuilder: (context, idx) {
              final q = questions[idx];
              final isCurrent = idx == currentIndex;
              final selectedOpt = examTaker.answers[q.id];
              final isFlagged = examTaker.flaggedForReview.contains(q.id);

              return InkWell(
                onTap: () {
                  examTaker.goToQuestion(idx);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFFEFF6FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isCurrent
                        ? Border.all(color: const Color(0xFFBFDBFE))
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Question indicator
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 32,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          if (isFlagged)
                            const Positioned(
                              top: -4,
                              right: -4,
                              child: Icon(Icons.bookmark_rounded,
                                  size: 14, color: Color(0xFFF59E0B)),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Bubbles A, B, C, D
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['A', 'B', 'C', 'D'].map((opt) {
                            return OmrBubble(
                              label: opt,
                              isSelected: selectedOpt == opt,
                              size: 30,
                              onTap: () {
                                examTaker.selectOption(q.id, opt);
                                examTaker.goToQuestion(idx);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
