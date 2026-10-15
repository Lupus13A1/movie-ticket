import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_translations.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final tr = AppTranslations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(tr('settings.title')),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── GENERAL ─────────────────────────────────────
          _buildSectionHeader(tr('settings.general')),
          _buildSettingsCard(
            children: [
              _buildSelectionTile(
                context: context,
                icon: Icons.language,
                title: tr('settings.language'),
                value: settings.language == 'th' ? 'ไทย' : 'English',
                onTap: () => _showLanguagePicker(context, settings, tr),
              ),
            ],
          ),

          // ── PLAYBACK ────────────────────────────────────
          _buildSectionHeader(tr('settings.playback')),
          _buildSettingsCard(
            children: [
              _buildSwitchTile(
                icon: Icons.play_circle_outline,
                title: tr('settings.autoPlay'),
                subtitle: tr('settings.autoPlayDesc'),
                value: settings.autoPlayTrailer,
                onChanged: (v) => settings.setAutoPlayTrailer(v),
              ),
              const Divider(height: 1, color: AppTheme.borderColor, indent: 60),
              _buildSelectionTile(
                context: context,
                icon: Icons.high_quality_outlined,
                title: tr('settings.streamingQuality'),
                value: _qualityLabel(settings.streamingQuality, tr),
                onTap: () => _showQualityPicker(context, settings, tr),
              ),
              const Divider(height: 1, color: AppTheme.borderColor, indent: 60),
              _buildSwitchTile(
                icon: Icons.wifi,
                title: tr('settings.wifiOnly'),
                subtitle: tr('settings.wifiOnlyDesc'),
                value: settings.downloadWifiOnly,
                onChanged: (v) => settings.setDownloadWifiOnly(v),
              ),
            ],
          ),

          // ── DATA & PRIVACY ──────────────────────────────
          _buildSectionHeader(tr('settings.dataPrivacy')),
          _buildSettingsCard(
            children: [
              _buildActionTile(
                icon: Icons.delete_outline,
                title: tr('settings.clearCache'),
                subtitle: tr('settings.clearCacheDesc'),
                onTap: () => _showClearCacheDialog(context, tr),
              ),
              const Divider(height: 1, color: AppTheme.borderColor, indent: 60),
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                title: tr('settings.privacyPolicy'),
                onTap: () => _showInfoSnackbar(
                  context,
                  tr('settings.privacyPolicy'),
                  tr,
                ),
              ),
              const Divider(height: 1, color: AppTheme.borderColor, indent: 60),
              _buildActionTile(
                icon: Icons.description_outlined,
                title: tr('settings.termsOfService'),
                onTap: () => _showInfoSnackbar(
                  context,
                  tr('settings.termsOfService'),
                  tr,
                ),
              ),
            ],
          ),

          // ── ABOUT ───────────────────────────────────────
          _buildSectionHeader(tr('settings.about')),
          _buildSettingsCard(
            children: [
              _buildInfoTile(
                icon: Icons.info_outline,
                title: tr('settings.appVersion'),
                value: '1.0.0',
              ),
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────

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

  // ── Settings Card Container ─────────────────────────────

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

  // ── Switch Toggle Tile ──────────────────────────────────

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
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
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
            inactiveThumbColor: AppTheme.mutedForeground,
            inactiveTrackColor: AppTheme.borderColor,
          ),
        ],
      ),
    );
  }

  // ── Selection Tile (with value display) ─────────────────

  Widget _buildSelectionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppTheme.mutedForeground),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.foreground,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  // ── Action Tile (navigable) ─────────────────────────────

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Tile (read-only) ───────────────────────────────

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.mutedForeground),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.foreground,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Quality Label ───────────────────────────────

  String _qualityLabel(String quality, String Function(String) tr) {
    switch (quality) {
      case 'high':
        return tr('settings.qualityHighLabel');
      case 'medium':
        return tr('settings.qualityMediumLabel');
      case 'low':
        return tr('settings.qualityLowLabel');
      default:
        return tr('settings.qualityAutoLabel');
    }
  }

  // ── Language Picker Bottom Sheet ────────────────────────

  void _showLanguagePicker(
    BuildContext context,
    SettingsService settings,
    String Function(String) tr,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    tr('settings.selectLanguage'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  title: 'ไทย',
                  subtitle: 'Thai',
                  isSelected: settings.language == 'th',
                  onTap: () {
                    settings.setLanguage('th');
                    Navigator.pop(ctx);
                  },
                ),
                _buildOptionTile(
                  title: 'English',
                  subtitle: 'อังกฤษ',
                  isSelected: settings.language == 'en',
                  onTap: () {
                    settings.setLanguage('en');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Quality Picker Bottom Sheet ─────────────────────────

  void _showQualityPicker(
    BuildContext context,
    SettingsService settings,
    String Function(String) tr,
  ) {
    final options = [
      {
        'value': 'auto',
        'title': tr('settings.qualityAuto'),
        'subtitle': tr('settings.qualityAutoDesc'),
      },
      {
        'value': 'high',
        'title': tr('settings.qualityHigh'),
        'subtitle': tr('settings.qualityHighDesc'),
      },
      {
        'value': 'medium',
        'title': tr('settings.qualityMedium'),
        'subtitle': tr('settings.qualityMediumDesc'),
      },
      {
        'value': 'low',
        'title': tr('settings.qualityLow'),
        'subtitle': tr('settings.qualityLowDesc'),
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    tr('settings.streamingQuality'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...options.map(
                  (opt) => _buildOptionTile(
                    title: opt['title']!,
                    subtitle: opt['subtitle']!,
                    isSelected: settings.streamingQuality == opt['value'],
                    onTap: () {
                      settings.setStreamingQuality(opt['value']!);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Sheet Option Tile ────────────────────────────

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppTheme.foreground
                          : AppTheme.mutedForeground,
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
            if (isSelected)
              const Icon(Icons.check, color: AppTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // ── Clear Cache Dialog ──────────────────────────────────

  void _showClearCacheDialog(BuildContext context, String Function(String) tr) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            tr('settings.clearCacheTitle'),
            style: const TextStyle(
              color: AppTheme.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            tr('settings.clearCacheMessage'),
            style: const TextStyle(
              color: AppTheme.mutedForeground,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                tr('settings.cancel'),
                style: const TextStyle(color: AppTheme.mutedForeground),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Clear image cache
                imageCache.clear();
                imageCache.clearLiveImages();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('settings.cacheCleared')),
                    backgroundColor: AppTheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: Text(
                tr('settings.clear'),
                style: const TextStyle(color: AppTheme.foreground),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Info Snackbar ───────────────────────────────────────

  void _showInfoSnackbar(
    BuildContext context,
    String title,
    String Function(String) tr,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title${tr('settings.willOpenBrowser')}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
