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

    // Use Dicebear for avatar, utilizing the user's email as the seed.
    final seed = user?.email ?? 'CinemaUser';
    final String avatarUrl =
        'https://api.dicebear.com/7.x/avataaars/png?seed=$seed&backgroundColor=ffffff';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER SECTION
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.foreground, width: 4),
              ),
            ),
            child: Column(
              children: [
                // AVATAR
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    border: Border.all(color: AppTheme.foreground, width: 2),
                    shape: BoxShape.rectangle, // Strictly zero radius
                  ),
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      size: 64,
                      color: AppTheme.foreground,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // NAME
                Text(
                  (user?.displayName ?? 'USER ACCOUNT').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontDisplay,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                // EMAIL
                Text(
                  user?.email?.toUpperCase() ?? 'NO EMAIL PROVIDED',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // MENU LIST
          _buildMenuTile(
            icon: Icons.person_outline,
            title: 'ACCOUNT SETTINGS',
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
            icon: Icons.credit_card,
            title: 'PAYMENT METHODS',
            onTap: () {
              _showComingSoon(context);
            },
          ),
          _buildMenuTile(
            icon: Icons.notifications_outlined,
            title: 'NOTIFICATIONS',
            onTap: () {
              _showComingSoon(context);
            },
          ),
          _buildMenuTile(
            icon: Icons.language,
            title: 'LANGUAGE',
            subtitle: 'ENGLISH',
            onTap: () {
              _showComingSoon(context);
            },
          ),
          _buildMenuTile(
            icon: Icons.help_outline,
            title: 'HELP & SUPPORT',
            onTap: () {
              _showComingSoon(context);
            },
          ),

          // LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton(
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
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.foreground, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(
                  fontFamily: AppTheme.fontMono,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'COMING SOON',
          style: TextStyle(fontFamily: AppTheme.fontMono),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.foreground, width: 2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: AppTheme.foreground),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontMono,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppTheme.foreground,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontMono,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.foreground,
            ),
          ],
        ),
      ),
    );
  }
}
