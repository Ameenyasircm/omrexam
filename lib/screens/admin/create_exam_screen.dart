import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/custom_text_field.dart';

class CreateExamScreen extends StatefulWidget {
  final VoidCallback? onExamCreated;

  const CreateExamScreen({super.key, this.onExamCreated});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _examIdController.dispose();
    _titleController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });

    final admin = context.read<AdminProvider>();
    final success = await admin.createExam(
      examId: _examIdController.text,
      title: _titleController.text,
      password: _passwordController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exam "${_examIdController.text}" created successfully!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      if (widget.onExamCreated != null) {
        widget.onExamCreated!();
      } else {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _errorMsg = admin.errorMessage ?? 'Failed to create exam.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24, vertical: isMobile ? 16 : 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.post_add_rounded,
                          color: Color(0xFF2563EB),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Examination',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Set up a new OMR test with security credentials',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 36, color: Color(0xFFE2E8F0)),

                  if (_errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Color(0xFFDC2626), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMsg!,
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

                  // Exam ID & Password: Side-by-side on desktop, stacked on mobile
                  if (isMobile) ...[
                    CustomTextField(
                      controller: _examIdController,
                      label: 'Exam ID (Unique code)',
                      hint: 'e.g. CS101, MATH2024',
                      prefixIcon: Icons.fingerprint_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Exam ID is required';
                        }
                        if (val.trim().contains(' ')) {
                          return 'No spaces allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Exam Access Password',
                      hint: 'e.g. PASS#2024',
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Password required'
                          : null,
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _examIdController,
                            label: 'Exam ID (Unique code)',
                            hint: 'e.g. CS101, MATH2024',
                            prefixIcon: Icons.fingerprint_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Exam ID is required';
                              }
                              if (val.trim().contains(' ')) {
                                return 'No spaces allowed';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _passwordController,
                            label: 'Exam Access Password',
                            hint: 'e.g. PASS#2024',
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Password required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _titleController,
                    label: 'Exam Title',
                    hint: 'e.g. Midterm Physics OMR Assessment',
                    prefixIcon: Icons.title_rounded,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Exam title is required'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description / Instructions (Optional)',
                    hint: 'e.g. 50 minutes, negative marking: none...',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Publish Examination',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
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
    );
  }
}
