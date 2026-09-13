import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.user;

    // Use Dicebear for avatar
    final seed = user?.email ?? 'CinemaUser';
    final String avatarUrl =
        'https://api.dicebear.com/7.x/avataaars/png?seed=$seed&backgroundColor=b6e3f4';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                children: [
                  // AVATAR
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              size: 48,
                              color: AppTheme.mutedForeground,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // NAME & EMAIL
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Netflix User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'no_email@provided.com',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // MENU LIST
            _buildMenuTile(
              icon: Icons.edit_outlined,
              title: 'Manage Profiles',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            _buildMenuTile(
              icon: Icons.credit_card_outlined,
              title: 'Payment Details',
              onTap: () {
                _showComingSoon(context);
              },
            ),
            _buildMenuTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {
                _showComingSoon(context);
              },
            ),
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: 'App Settings',
              onTap: () {
                _showComingSoon(context);
              },
            ),
            _buildMenuTile(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () {
                _showComingSoon(context);
              },
            ),

            const Divider(),

            // LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: TextButton(
                  onPressed: () async {
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: AppTheme.mutedForeground),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.foreground,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: AppTheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
