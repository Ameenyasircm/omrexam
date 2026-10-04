import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/exam_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/responsive_layout.dart';
import '../home_portal_screen.dart';
import 'create_exam_screen.dart';
import 'exam_questions_screen.dart';
import 'exam_reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().listenToExams();
    });
  }

  void _handleLogout() {
    context.read<AdminProvider>().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePortalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 28),
            SizedBox(width: 10),
            Text(
              'Admin Control Center',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      drawer: isDesktop ? null : _buildNavigationDrawer(),
      body: Row(
        children: [
          if (isDesktop) _buildDesktopSidebar(),
          Expanded(
            child: _buildCurrentTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                AppLogo(size: 32),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MET School',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'OMR Admin Portal',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          _buildSidebarNavItem(
            icon: Icons.list_alt_rounded,
            title: 'Exams List',
            index: 0,
          ),
          _buildSidebarNavItem(
            icon: Icons.add_circle_outline_rounded,
            title: 'Create Exam',
            index: 1,
          ),
          const Spacer(),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ListTile(
            leading:
                const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            title: const Text('Sign Out',
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            onTap: _handleLogout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const AppLogo(
                  size: 42,
                  showBackground: true,
                  borderRadius: 21,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Admin Control Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'Online OMR Examination System',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_rounded),
            title: const Text('Exams Management'),
            selected: _selectedTabIndex == 0,
            onTap: () {
              setState(() => _selectedTabIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: const Text('Create New Exam'),
            selected: _selectedTabIndex == 1,
            onTap: () {
              setState(() => _selectedTabIndex = 1);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            title: const Text('Sign Out',
                style: TextStyle(color: Color(0xFFEF4444))),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF7C3AED).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildExamsListTab();
      case 1:
        return CreateExamScreen(
          onExamCreated: () {
            setState(() {
              _selectedTabIndex = 0;
            });
          },
        );
      default:
        return _buildExamsListTab();
    }
  }

  Widget _buildExamsListTab() {
    final admin = context.watch<AdminProvider>();
    final exams = admin.exams;

    if (admin.isLoading && exams.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Examinations Management',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage test papers, add question banks, and review candidate results',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create New Exam'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (exams.isEmpty)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.library_books_rounded,
                            size: 54, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 16),
                        const Text(
                          'No Exams Created Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first exam with a unique Exam ID and password to get started.',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => setState(() => _selectedTabIndex = 1),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                          child: const Text('Create Exam'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exams.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return _buildExamCard(context, exam);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, ExamModel exam) {
    final admin = context.read<AdminProvider>();
    final formattedDate =
        DateFormat('MMM dd, yyyy - hh:mm a').format(exam.createdAt);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_rounded,
                    color: Color(0xFF2563EB), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          exam.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${exam.examId}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (exam.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        exam.description,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text('Passcode: ${exam.password}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.help_center_rounded,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text('${exam.totalQuestions} Questions',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text('Created: $formattedDate',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444)),
                tooltip: 'Delete Exam',
                onPressed: () {
                  _showDeleteConfirm(context, admin, exam.examId);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Actions
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamQuestionsScreen(exam: exam),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz_rounded, size: 16),
                label: const Text('Questions'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamReportsScreen(
                        exam: exam,
                        initialTabIndex: 1, // Directly open Option A,B,C,D report tab
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart_rounded, size: 16),
                label: const Text('Option Analysis'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamReportsScreen(
                        exam: exam,
                        initialTabIndex: 0,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.insights_rounded, size: 16),
                label: const Text('Reports & Ranks'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, AdminProvider admin, String examId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exam?'),
        content: Text(
            'Are you sure you want to delete exam "$examId"? All questions and student responses for this exam will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.pop(ctx);
              admin.deleteExam(examId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
