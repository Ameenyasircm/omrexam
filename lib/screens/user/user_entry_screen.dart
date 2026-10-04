import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_taker_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_text_field.dart';
import 'omr_exam_screen.dart';

class UserEntryScreen extends StatefulWidget {
  const UserEntryScreen({super.key});

  @override
  State<UserEntryScreen> createState() => _UserEntryScreenState();
}

class _UserEntryScreenState extends State<UserEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _examIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _examIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleStartExam() async {
    if (!_formKey.currentState!.validate()) return;

    final examTaker = context.read<ExamTakerProvider>();
    final success = await examTaker.validateAndStartExam(
      name: _nameController.text,
      phone: _phoneController.text,
      examId: _examIdController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OmrExamScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final examTaker = context.watch<ExamTakerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 28),
            SizedBox(width: 10),
            Text('Candidate Exam Entry'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: AppLogo(
                        size: 64,
                        showBackground: true,
                        borderRadius: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Candidate Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your candidate information and exam credentials to begin your OMR examination.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),

                    if (examTaker.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                examTaker.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'e.g. John Doe',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number (Used for unique submission)',
                      hint: 'e.g. +1 555-0199 or 9876543210',
                      prefixIcon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (val.trim().length < 6) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _examIdController,
                      label: 'Exam ID',
                      hint: 'e.g. CS101',
                      prefixIcon: Icons.qr_code_rounded,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter the Exam ID'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _passwordController,
                      label: 'Exam Passcode',
                      hint: 'Enter the exam password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter the exam passcode'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: examTaker.isLoading ? null : _handleStartExam,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: examTaker.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Verify & Start Exam',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),

                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.security_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                          SizedBox(width: 6),
                          Text(
                            'Each phone number can only submit this exam once',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
