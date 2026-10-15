import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

/// Manages all app settings with dual storage strategy:
/// - Firebase Realtime DB: notification prefs + language (synced across devices)
/// - SharedPreferences: device-specific UI preferences
class SettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final FirebaseService _firebaseService;
  String? _userId;
  bool _isLoading = false;

  // ── Firebase-backed settings (synced across devices) ──────
  bool _pushEnabled = true;
  bool _bookingConfirmations = true;
  bool _showtimeReminders = true;
  bool _newMovieAlerts = true;
  bool _promotions = false;
  bool _priceAlerts = false;
  String _language = 'th';

  // ── Local-only settings (device-specific) ─────────────────
  bool _autoPlayTrailer = true;
  String _streamingQuality = 'auto';
  bool _downloadWifiOnly = true;

  // ── Getters ───────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get userId => _userId;

  // Firebase-backed
  bool get pushEnabled => _pushEnabled;
  bool get bookingConfirmations => _bookingConfirmations;
  bool get showtimeReminders => _showtimeReminders;
  bool get newMovieAlerts => _newMovieAlerts;
  bool get promotions => _promotions;
  bool get priceAlerts => _priceAlerts;
  String get language => _language;

  // Local-only
  bool get autoPlayTrailer => _autoPlayTrailer;
  String get streamingQuality => _streamingQuality;
  bool get downloadWifiOnly => _downloadWifiOnly;

  // ── Constructor ───────────────────────────────────────────
  SettingsService._(this._prefs, this._firebaseService) {
    _loadLocalSettings();
  }

  /// Async factory: initializes SharedPreferences before construction.
  static Future<SettingsService> create(FirebaseService firebaseService) async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs, firebaseService);
  }

  // ── Load local settings from SharedPreferences ────────────
  void _loadLocalSettings() {
    _autoPlayTrailer = _prefs.getBool('autoPlayTrailer') ?? true;
    _streamingQuality = _prefs.getString('streamingQuality') ?? 'auto';
    _downloadWifiOnly = _prefs.getBool('downloadWifiOnly') ?? true;
  }

  // ── Load user settings from Firebase (call after login) ───
  Future<void> loadUserSettings(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      // Load notification settings
      final notifSettings = await _firebaseService.getNotificationSettings(
        userId,
      );
      if (notifSettings != null) {
        _pushEnabled = notifSettings['pushEnabled'] as bool? ?? true;
        _bookingConfirmations =
            notifSettings['bookingConfirmations'] as bool? ?? true;
        _showtimeReminders =
            notifSettings['showtimeReminders'] as bool? ?? true;
        _newMovieAlerts = notifSettings['newMovieAlerts'] as bool? ?? true;
        _promotions = notifSettings['promotions'] as bool? ?? false;
        _priceAlerts = notifSettings['priceAlerts'] as bool? ?? false;
      }

      // Load user preferences
      final userPrefs = await _firebaseService.getUserPreferences(userId);
      if (userPrefs != null) {
        _language = userPrefs['language'] as String? ?? 'th';
      }
    } catch (e) {
      debugPrint('Error loading user settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Notification Settings (Firebase) ──────────────────────

  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    notifyListeners();
    await _saveNotificationSetting('pushEnabled', value);
  }

  Future<void> setBookingConfirmations(bool value) async {
    _bookingConfirmations = value;
    notifyListeners();
    await _saveNotificationSetting('bookingConfirmations', value);
  }

  Future<void> setShowtimeReminders(bool value) async {
    _showtimeReminders = value;
    notifyListeners();
    await _saveNotificationSetting('showtimeReminders', value);
  }

  Future<void> setNewMovieAlerts(bool value) async {
    _newMovieAlerts = value;
    notifyListeners();
    await _saveNotificationSetting('newMovieAlerts', value);
  }

  Future<void> setPromotions(bool value) async {
    _promotions = value;
    notifyListeners();
    await _saveNotificationSetting('promotions', value);
  }

  Future<void> setPriceAlerts(bool value) async {
    _priceAlerts = value;
    notifyListeners();
    await _saveNotificationSetting('priceAlerts', value);
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    if (_userId == null) return;
    try {
      await _firebaseService.saveNotificationSettings(_userId!, {key: value});
    } catch (e) {
      debugPrint('Error saving notification setting: $e');
    }
  }

  // ── Language (Firebase) ───────────────────────────────────

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    if (_userId == null) return;
    try {
      await _firebaseService.saveUserPreferences(_userId!, {'language': lang});
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  // ── Local Settings (SharedPreferences) ────────────────────

  Future<void> setAutoPlayTrailer(bool value) async {
    _autoPlayTrailer = value;
    notifyListeners();
    await _prefs.setBool('autoPlayTrailer', value);
  }

  Future<void> setStreamingQuality(String quality) async {
    _streamingQuality = quality;
    notifyListeners();
    await _prefs.setString('streamingQuality', quality);
  }

  Future<void> setDownloadWifiOnly(bool value) async {
    _downloadWifiOnly = value;
    notifyListeners();
    await _prefs.setBool('downloadWifiOnly', value);
  }
}
