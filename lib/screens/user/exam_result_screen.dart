import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_taker_provider.dart';
import '../../widgets/app_logo.dart';
import '../home_portal_screen.dart';

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final examTaker = context.watch<ExamTakerProvider>();
    final result = examTaker.submissionResult;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No submission result available.')),
      );
    }

    final formattedDate =
        DateFormat('MMM dd, yyyy - hh:mm a').format(result.submittedAt);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            AppLogo(size: 28),
            SizedBox(width: 10),
            Text('Submission Confirmation'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24, vertical: isMobile ? 20 : 36),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Successfully Completed Hero Card
                Container(
                  padding: EdgeInsets.all(isMobile ? 24 : 36),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF047857).withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const AppLogo(
                        size: 68,
                        showBackground: true,
                        borderRadius: 34,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF34D399),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Successfully Completed!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thank you, ${result.name}. Your examination responses have been securely submitted and recorded.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submission Details Receipt Card
                Container(
                  padding: EdgeInsets.all(isMobile ? 20 : 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.receipt_long_rounded,
                                  color: Color(0xFF2563EB), size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Submission Receipt',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 14, color: Color(0xFF059669)),
                                SizedBox(width: 4),
                                Text(
                                  'RECORDED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28, color: Color(0xFFF1F5F9)),

                      _buildReceiptRow('Candidate Name', result.name),
                      _buildReceiptRow('Phone Number', result.phone),
                      _buildReceiptRow('Exam Code / ID', result.examId),
                      _buildReceiptRow(
                        'Questions Attempted',
                        '${result.answers.length} of ${result.totalQuestions} Questions',
                      ),
                      _buildReceiptRow('Submitted At', formattedDate),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informational Notice Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your responses have been successfully logged in the database. Examination results, scores, and grade reports will be published by the institution administrators.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Back to Portal Button
                FilledButton.icon(
                  onPressed: () {
                    examTaker.resetSession();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomePortalScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Back to Home Portal'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
