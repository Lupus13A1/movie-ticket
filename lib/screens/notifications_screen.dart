import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_translations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final tr = AppTranslations.of(context);
    final isEnabled = settings.pushEnabled;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(tr('notif.title')),
        backgroundColor: Colors.transparent,
      ),
      body: settings.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ── MASTER TOGGLE ───────────────────────
                _buildMasterToggle(settings, tr),

                const SizedBox(height: 8),

                // ── BOOKING ─────────────────────────────
                _buildSectionHeader(tr('notif.booking')),
                AnimatedOpacity(
                  opacity: isEnabled ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 250),
                  child: _buildSettingsCard(
                    children: [
                      _buildNotificationTile(
                        icon: Icons.check_circle_outline,
                        title: tr('notif.bookingConfirmations'),
                        subtitle: tr('notif.bookingConfirmationsDesc'),
                        value: settings.bookingConfirmations,
                        enabled: isEnabled,
                        onChanged: (v) => settings.setBookingConfirmations(v),
                      ),
                      const Divider(
                        height: 1,
                        color: AppTheme.borderColor,
                        indent: 60,
                      ),
                      _buildNotificationTile(
                        icon: Icons.access_time,
                        title: tr('notif.showtimeReminders'),
                        subtitle: tr('notif.showtimeRemindersDesc'),
                        value: settings.showtimeReminders,
                        enabled: isEnabled,
                        onChanged: (v) => settings.setShowtimeReminders(v),
                      ),
                    ],
                  ),
                ),

                // ── DISCOVERY ───────────────────────────
                _buildSectionHeader(tr('notif.discovery')),
                AnimatedOpacity(
                  opacity: isEnabled ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 250),
                  child: _buildSettingsCard(
                    children: [
                      _buildNotificationTile(
                        icon: Icons.movie_filter_outlined,
                        title: tr('notif.newMovieAlerts'),
                        subtitle: tr('notif.newMovieAlertsDesc'),
                        value: settings.newMovieAlerts,
                        enabled: isEnabled,
                        onChanged: (v) => settings.setNewMovieAlerts(v),
                      ),
                      const Divider(
                        height: 1,
                        color: AppTheme.borderColor,
                        indent: 60,
                      ),
                      _buildNotificationTile(
                        icon: Icons.sell_outlined,
                        title: tr('notif.priceAlerts'),
                        subtitle: tr('notif.priceAlertsDesc'),
                        value: settings.priceAlerts,
                        enabled: isEnabled,
                        onChanged: (v) => settings.setPriceAlerts(v),
                      ),
                    ],
                  ),
                ),

                // ── MARKETING ───────────────────────────
                _buildSectionHeader(tr('notif.marketing')),
                AnimatedOpacity(
                  opacity: isEnabled ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 250),
                  child: _buildSettingsCard(
                    children: [
                      _buildNotificationTile(
                        icon: Icons.local_offer_outlined,
                        title: tr('notif.promotions'),
                        subtitle: tr('notif.promotionsDesc'),
                        value: settings.promotions,
                        enabled: isEnabled,
                        onChanged: (v) => settings.setPromotions(v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
    );
  }

  // ── Master Toggle ────────────────────────────────────────

  Widget _buildMasterToggle(
    SettingsService settings,
    String Function(String) tr,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: settings.pushEnabled
              ? AppTheme.primary.withValues(alpha: 0.3)
              : AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: settings.pushEnabled
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : AppTheme.borderColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                settings.pushEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                size: 24,
                color: settings.pushEnabled
                    ? AppTheme.primary
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('notif.pushNotifications'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    settings.pushEnabled
                        ? tr('notif.enabled')
                        : tr('notif.disabled'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: settings.pushEnabled,
              onChanged: (v) => settings.setPushEnabled(v),
              activeThumbColor: AppTheme.primary,
              activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
              inactiveThumbColor: AppTheme.mutedForeground,
              inactiveTrackColor: AppTheme.borderColor,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.mutedForeground,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Settings Card Container ──────────────────────────────

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }

  // ── Notification Toggle Tile ─────────────────────────────

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.mutedForeground),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value && enabled,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
            inactiveThumbColor: AppTheme.mutedForeground,
            inactiveTrackColor: AppTheme.borderColor,
          ),
        ],
      ),
    );
  }
}
