import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/responsive_layout.dart';
import 'admin/admin_login_screen.dart';
import 'user/user_entry_screen.dart';

class HomePortalScreen extends StatelessWidget {
  const HomePortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 32),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'OMR Online Examination System',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                // Hero Header
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const AppLogo(
                        size: 74,
                        showBackground: true,
                        borderRadius: 37,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF38BDF8,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFF38BDF8,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF38BDF8),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Cloud OMR Assessment Engine',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Secure Online OMR Examination Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Interactive OMR bubble sheets, instant evaluation, real-time analytics, and tamper-proof candidate submissions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Portals Selection Cards
                ResponsiveLayout(
                  mobileBody: Column(
                    children: [
                      _buildPortalCard(
                        context: context,
                        title: 'Candidate Portal',
                        subtitle:
                            'Enter your exam credentials to start answering your live OMR test sheet.',
                        icon: Icons.edit_note_rounded,
                        accentColor: const Color(0xFF2563EB),
                        buttonText: 'Enter Exam Room',
                        badgeText: 'STUDENT ACCESS',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserEntryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPortalCard(
                        context: context,
                        title: 'Admin Control Panel',
                        subtitle:
                            'Create exams, manage questions, inspect candidate responses, and view performance charts.',
                        icon: Icons.admin_panel_settings_rounded,
                        accentColor: const Color(0xFF7C3AED),
                        buttonText: 'Access Admin Panel',
                        badgeText: 'STAFF & INSTRUCTORS',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminLoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  desktopBody: Row(
                    children: [
                      Expanded(
                        child: _buildPortalCard(
                          context: context,
                          title: 'Candidate Portal',
                          subtitle:
                              'Enter your exam credentials to start answering your live OMR test sheet.',
                          icon: Icons.edit_note_rounded,
                          accentColor: const Color(0xFF2563EB),
                          buttonText: 'Enter Exam Room',
                          badgeText: 'STUDENT ACCESS',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserEntryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildPortalCard(
                          context: context,
                          title: 'Admin Control Panel',
                          subtitle:
                              'Create exams, manage questions, inspect candidate responses, and view performance charts.',
                          icon: Icons.admin_panel_settings_rounded,
                          accentColor: const Color(0xFF7C3AED),
                          buttonText: 'Access Admin Panel',
                          badgeText: 'STAFF & INSTRUCTORS',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminLoginScreen(),
                              ),
                            );
                          },
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
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String buttonText,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 30),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
