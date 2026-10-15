import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

/// Centralized translations for TH/EN localization.
/// Usage in build():
///   final lang = context.watch<SettingsService>().language;
///   String tr(String key) => AppTranslations.translate(key, lang);
///   // then use: tr('home.nowPlaying')
class AppTranslations {
  AppTranslations._();

  /// Translate a key to the given language, fallback to English.
  static String translate(String key, String lang) {
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }

  /// Helper to get a tr() function from BuildContext (must be called in build).
  static String Function(String) of(BuildContext context) {
    final lang = context.watch<SettingsService>().language;
    return (String key) => translate(key, lang);
  }

  static const Map<String, Map<String, String>> _translations = {
    // ═══════════════════════════════════════════════════════
    // ENGLISH
    // ═══════════════════════════════════════════════════════
    'en': {
      // ── Home Screen ─────────────────────────────────────
      'home.nowPlaying': 'Now Playing',
      'home.popularOnCinema': 'Popular on Cinema',
      'home.comingSoon': 'Coming Soon',
      'home.bookNow': 'Book Now',
      'home.details': 'Details',
      'home.noMovies': 'No movies available',
      'nav.home': 'Home',
      'nav.tickets': 'Tickets',
      'nav.more': 'More',

      // ── Profile Screen ──────────────────────────────────
      'profile.manageProfiles': 'Manage Profiles',
      'profile.paymentDetails': 'Payment Details',
      'profile.notifications': 'Notifications',
      'profile.appSettings': 'App Settings',
      'profile.help': 'Help',
      'profile.signOut': 'Sign Out',
      'profile.comingSoon': 'Coming Soon',

      // ── Edit Profile Screen ─────────────────────────────
      'editProfile.title': 'Edit Profile',
      'editProfile.displayName': 'Display Name',
      'editProfile.enterName': 'Enter your name',
      'editProfile.updated': 'Profile updated successfully',
      'editProfile.saveChanges': 'Save Changes',

      // ── Login Screen ────────────────────────────────────
      'login.signIn': 'Sign In',
      'login.email': 'Email',
      'login.password': 'Password',
      'login.emailRequired': 'Email is required',
      'login.validEmail': 'Enter a valid email',
      'login.passwordRequired': 'Password is required',
      'login.signInGoogle': 'Sign In with Google',
      'login.newToCinema': 'New to Cinema? ',
      'login.signUpNow': 'Sign up now.',
      'login.noAccount': 'No account found with this email.',
      'login.wrongPassword': 'Incorrect password.',
      'login.invalidEmail': 'Invalid email address.',
      'login.tooManyAttempts': 'Too many attempts. Try again later.',
      'login.invalidCredentials': 'Invalid email or password.',
      'login.cancelled': 'Sign-in cancelled.',
      'login.genericError': 'An error occurred. Please try again.',

      // ── Register Screen ─────────────────────────────────
      'register.createAccount': 'Create Account',
      'register.fullName': 'Full Name',
      'register.nameRequired': 'Name is required',
      'register.email': 'Email',
      'register.emailRequired': 'Email is required',
      'register.validEmail': 'Enter a valid email',
      'register.password': 'Password',
      'register.passwordRequired': 'Password is required',
      'register.passwordMin': 'At least 6 characters',
      'register.confirmPassword': 'Confirm Password',
      'register.confirmRequired': 'Please confirm your password',
      'register.passwordMismatch': 'Passwords do not match',
      'register.signUp': 'Sign Up',
      'register.signUpGoogle': 'Sign Up with Google',
      'register.alreadyHaveAccount': 'Already have an account? ',
      'register.signIn': 'Sign In.',
      'register.emailExists': 'An account already exists with this email.',
      'register.invalidEmail': 'Invalid email address.',
      'register.weakPassword':
          'Password is too weak. Use at least 6 characters.',
      'register.cancelled': 'Sign-in cancelled.',
      'register.genericError': 'An error occurred. Please try again.',

      // ── Movie Detail Screen ─────────────────────────────
      'movieDetail.error': 'Error',
      'movieDetail.failedToLoad': 'Failed to load details',
      'movieDetail.unknown': 'Unknown',
      'movieDetail.noOverview': 'No overview available.',
      'movieDetail.bookTickets': 'Book Tickets',

      // ── Showtime Screen ─────────────────────────────────
      'showtime.noShowtimesToday': 'No showtimes remaining today',
      'showtime.noShowtimes': 'No showtimes available',

      // ── Seat Selection Screen ───────────────────────────
      'seat.title': 'Select Seats',
      'seat.errorLoading': 'Error loading seats',
      'seat.screen': 'SCREEN',
      'seat.available': 'Available',
      'seat.selected': 'Selected',
      'seat.booked': 'Booked',
      'seat.seatCount': '{n} Seat(s)',
      'seat.continue': 'Continue',
      'seat.holdExpired': 'Seat hold expired. Please select again.',

      // ── Booking Summary Screen ──────────────────────────
      'summary.title': 'Summary',
      'summary.completeWithin': 'Complete booking within',
      'summary.cinema': 'Cinema',
      'summary.format': 'Format',
      'summary.date': 'Date',
      'summary.time': 'Time',
      'summary.seats': 'Seats',
      'summary.totalPayment': 'Total Payment',
      'summary.confirmBooking': 'Confirm Booking',
      'summary.holdExpired': 'Seat hold expired. Please select seats again.',
      'summary.showtimePassed': 'This showtime has already passed',
      'summary.notLoggedIn': 'User not logged in',
      'summary.bookingFailed': 'Booking failed: ',

      // ── Booking Success Screen ──────────────────────────
      'success.confirmed': 'Booking Confirmed!',
      'success.ready': 'Your tickets are ready.',
      'success.seats': 'Seats',
      'success.totalPaid': 'Total Paid',
      'success.viewTickets': 'View My Tickets',
      'success.backHome': 'Back to Home',

      // ── My Bookings Screen ──────────────────────────────
      'bookings.loginRequired': 'Please login to view bookings',
      'bookings.failedToLoad': 'Failed to load bookings',
      'bookings.cancelTitle': 'Cancel Booking',
      'bookings.cancelConfirm': 'Are you sure you want to cancel this booking?',
      'bookings.no': 'No',
      'bookings.yes': 'Yes',
      'bookings.cancelFailed': 'Failed to cancel booking',
      'bookings.upcoming': 'Upcoming',
      'bookings.completed': 'Completed',
      'bookings.cancelled': 'Cancelled',
      'bookings.seatsPrefix': 'Seats: ',
      'bookings.cancelBooking': 'Cancel Booking',
      'bookings.noTickets': 'No tickets booked yet.',
      'bookings.upcomingShowtimes': 'Upcoming Showtimes',
      'bookings.pastShowtimes': 'Past Showtimes',
      'bookings.cancelledSection': 'Cancelled',

      // ── App Settings Screen ─────────────────────────────
      'settings.title': 'App Settings',
      'settings.general': 'GENERAL',
      'settings.language': 'Language',
      'settings.playback': 'PLAYBACK',
      'settings.autoPlay': 'Auto-play Trailers',
      'settings.autoPlayDesc': 'Play trailers automatically on movie details',
      'settings.streamingQuality': 'Streaming Quality',
      'settings.wifiOnly': 'Wi-Fi Only Download',
      'settings.wifiOnlyDesc': 'Download content only over Wi-Fi',
      'settings.dataPrivacy': 'DATA & PRIVACY',
      'settings.clearCache': 'Clear Cache',
      'settings.clearCacheDesc': 'Free up storage space',
      'settings.privacyPolicy': 'Privacy Policy',
      'settings.termsOfService': 'Terms of Service',
      'settings.about': 'ABOUT',
      'settings.appVersion': 'App Version',
      'settings.selectLanguage': 'Select Language',
      'settings.qualityAuto': 'Auto',
      'settings.qualityAutoDesc': 'Adjusts to your connection',
      'settings.qualityHigh': 'High',
      'settings.qualityHighDesc': '1080p · Uses more data',
      'settings.qualityMedium': 'Medium',
      'settings.qualityMediumDesc': '720p · Balanced',
      'settings.qualityLow': 'Low',
      'settings.qualityLowDesc': '480p · Saves data',
      'settings.qualityAutoLabel': 'Auto',
      'settings.qualityHighLabel': 'High (1080p)',
      'settings.qualityMediumLabel': 'Medium (720p)',
      'settings.qualityLowLabel': 'Low (480p)',
      'settings.clearCacheTitle': 'Clear Cache',
      'settings.clearCacheMessage':
          'This will remove cached images and temporary data. Your account data and bookings will not be affected.',
      'settings.cancel': 'Cancel',
      'settings.clear': 'Clear',
      'settings.cacheCleared': 'Cache cleared successfully',
      'settings.willOpenBrowser': ' will open in browser',

      // ── Notifications Screen ────────────────────────────
      'notif.title': 'Notifications',
      'notif.pushNotifications': 'Push Notifications',
      'notif.enabled': 'Notifications are enabled',
      'notif.disabled': 'All notifications are disabled',
      'notif.booking': 'BOOKING',
      'notif.bookingConfirmations': 'Booking Confirmations',
      'notif.bookingConfirmationsDesc':
          'Get notified when your booking is confirmed',
      'notif.showtimeReminders': 'Showtime Reminders',
      'notif.showtimeRemindersDesc':
          'Remind 30 minutes before your show starts',
      'notif.discovery': 'DISCOVERY',
      'notif.newMovieAlerts': 'New Movie Alerts',
      'notif.newMovieAlertsDesc': 'Get notified about new movie releases',
      'notif.priceAlerts': 'Price Alerts',
      'notif.priceAlertsDesc': 'Notify when ticket prices change',
      'notif.marketing': 'MARKETING',
      'notif.promotions': 'Promotions & Offers',
      'notif.promotionsDesc': 'Special deals and discounts',
    },

    // ═══════════════════════════════════════════════════════
    // THAI
    // ═══════════════════════════════════════════════════════
    'th': {
      // ── Home Screen ─────────────────────────────────────
      'home.nowPlaying': 'กำลังฉาย',
      'home.popularOnCinema': 'ยอดนิยม',
      'home.comingSoon': 'เร็วๆ นี้',
      'home.bookNow': 'จองตั๋ว',
      'home.details': 'รายละเอียด',
      'home.noMovies': 'ไม่มีหนังในขณะนี้',
      'nav.home': 'หน้าแรก',
      'nav.tickets': 'ตั๋วของฉัน',
      'nav.more': 'เพิ่มเติม',

      // ── Profile Screen ──────────────────────────────────
      'profile.manageProfiles': 'จัดการโปรไฟล์',
      'profile.paymentDetails': 'ข้อมูลการชำระเงิน',
      'profile.notifications': 'การแจ้งเตือน',
      'profile.appSettings': 'ตั้งค่าแอป',
      'profile.help': 'ช่วยเหลือ',
      'profile.signOut': 'ออกจากระบบ',
      'profile.comingSoon': 'เร็วๆ นี้',

      // ── Edit Profile Screen ─────────────────────────────
      'editProfile.title': 'แก้ไขโปรไฟล์',
      'editProfile.displayName': 'ชื่อที่แสดง',
      'editProfile.enterName': 'กรอกชื่อของคุณ',
      'editProfile.updated': 'อัปเดตโปรไฟล์สำเร็จ',
      'editProfile.saveChanges': 'บันทึกการเปลี่ยนแปลง',

      // ── Login Screen ────────────────────────────────────
      'login.signIn': 'เข้าสู่ระบบ',
      'login.email': 'อีเมล',
      'login.password': 'รหัสผ่าน',
      'login.emailRequired': 'กรุณากรอกอีเมล',
      'login.validEmail': 'กรุณากรอกอีเมลที่ถูกต้อง',
      'login.passwordRequired': 'กรุณากรอกรหัสผ่าน',
      'login.signInGoogle': 'เข้าสู่ระบบด้วย Google',
      'login.newToCinema': 'ยังไม่มีบัญชี? ',
      'login.signUpNow': 'สมัครเลย',
      'login.noAccount': 'ไม่พบบัญชีที่ใช้อีเมลนี้',
      'login.wrongPassword': 'รหัสผ่านไม่ถูกต้อง',
      'login.invalidEmail': 'อีเมลไม่ถูกต้อง',
      'login.tooManyAttempts': 'ลองหลายครั้งเกินไป กรุณาลองใหม่ภายหลัง',
      'login.invalidCredentials': 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
      'login.cancelled': 'ยกเลิกการเข้าสู่ระบบ',
      'login.genericError': 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',

      // ── Register Screen ─────────────────────────────────
      'register.createAccount': 'สร้างบัญชี',
      'register.fullName': 'ชื่อ-นามสกุล',
      'register.nameRequired': 'กรุณากรอกชื่อ',
      'register.email': 'อีเมล',
      'register.emailRequired': 'กรุณากรอกอีเมล',
      'register.validEmail': 'กรุณากรอกอีเมลที่ถูกต้อง',
      'register.password': 'รหัสผ่าน',
      'register.passwordRequired': 'กรุณากรอกรหัสผ่าน',
      'register.passwordMin': 'อย่างน้อย 6 ตัวอักษร',
      'register.confirmPassword': 'ยืนยันรหัสผ่าน',
      'register.confirmRequired': 'กรุณายืนยันรหัสผ่าน',
      'register.passwordMismatch': 'รหัสผ่านไม่ตรงกัน',
      'register.signUp': 'สมัครสมาชิก',
      'register.signUpGoogle': 'สมัครด้วย Google',
      'register.alreadyHaveAccount': 'มีบัญชีแล้ว? ',
      'register.signIn': 'เข้าสู่ระบบ',
      'register.emailExists': 'อีเมลนี้มีบัญชีอยู่แล้ว',
      'register.invalidEmail': 'อีเมลไม่ถูกต้อง',
      'register.weakPassword': 'รหัสผ่านไม่ปลอดภัย ใช้อย่างน้อย 6 ตัวอักษร',
      'register.cancelled': 'ยกเลิกการลงทะเบียน',
      'register.genericError': 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',

      // ── Movie Detail Screen ─────────────────────────────
      'movieDetail.error': 'ข้อผิดพลาด',
      'movieDetail.failedToLoad': 'ไม่สามารถโหลดรายละเอียดได้',
      'movieDetail.unknown': 'ไม่ทราบ',
      'movieDetail.noOverview': 'ไม่มีเรื่องย่อ',
      'movieDetail.bookTickets': 'จองตั๋ว',

      // ── Showtime Screen ─────────────────────────────────
      'showtime.noShowtimesToday': 'ไม่มีรอบฉายที่เหลือวันนี้',
      'showtime.noShowtimes': 'ไม่มีรอบฉาย',

      // ── Seat Selection Screen ───────────────────────────
      'seat.title': 'เลือกที่นั่ง',
      'seat.errorLoading': 'ไม่สามารถโหลดข้อมูลที่นั่งได้',
      'seat.screen': 'จอภาพ',
      'seat.available': 'ว่าง',
      'seat.selected': 'เลือกแล้ว',
      'seat.booked': 'จองแล้ว',
      'seat.seatCount': '{n} ที่นั่ง',
      'seat.continue': 'ดำเนินการต่อ',
      'seat.holdExpired': 'หมดเวลาค้างที่นั่ง กรุณาเลือกใหม่',

      // ── Booking Summary Screen ──────────────────────────
      'summary.title': 'สรุปการจอง',
      'summary.completeWithin': 'กรุณาจองภายใน',
      'summary.cinema': 'โรงภาพยนตร์',
      'summary.format': 'รูปแบบ',
      'summary.date': 'วันที่',
      'summary.time': 'เวลา',
      'summary.seats': 'ที่นั่ง',
      'summary.totalPayment': 'ยอดชำระทั้งหมด',
      'summary.confirmBooking': 'ยืนยันการจอง',
      'summary.holdExpired': 'หมดเวลาค้างที่นั่ง กรุณาเลือกที่นั่งใหม่',
      'summary.showtimePassed': 'รอบฉายนี้ผ่านไปแล้ว',
      'summary.notLoggedIn': 'ยังไม่ได้เข้าสู่ระบบ',
      'summary.bookingFailed': 'จองไม่สำเร็จ: ',

      // ── Booking Success Screen ──────────────────────────
      'success.confirmed': 'จองสำเร็จ!',
      'success.ready': 'ตั๋วของคุณพร้อมแล้ว',
      'success.seats': 'ที่นั่ง',
      'success.totalPaid': 'ยอดชำระ',
      'success.viewTickets': 'ดูตั๋วของฉัน',
      'success.backHome': 'กลับหน้าแรก',

      // ── My Bookings Screen ──────────────────────────────
      'bookings.loginRequired': 'กรุณาเข้าสู่ระบบเพื่อดูการจอง',
      'bookings.failedToLoad': 'ไม่สามารถโหลดข้อมูลการจองได้',
      'bookings.cancelTitle': 'ยกเลิกการจอง',
      'bookings.cancelConfirm': 'คุณต้องการยกเลิกการจองนี้ใช่ไหม?',
      'bookings.no': 'ไม่',
      'bookings.yes': 'ใช่',
      'bookings.cancelFailed': 'ไม่สามารถยกเลิกการจองได้',
      'bookings.upcoming': 'กำลังจะมาถึง',
      'bookings.completed': 'เสร็จสิ้น',
      'bookings.cancelled': 'ยกเลิกแล้ว',
      'bookings.seatsPrefix': 'ที่นั่ง: ',
      'bookings.cancelBooking': 'ยกเลิกการจอง',
      'bookings.noTickets': 'ยังไม่มีตั๋วที่จอง',
      'bookings.upcomingShowtimes': 'รอบฉายที่จะถึง',
      'bookings.pastShowtimes': 'รอบฉายที่ผ่านมา',
      'bookings.cancelledSection': 'ยกเลิกแล้ว',

      // ── App Settings Screen ─────────────────────────────
      'settings.title': 'ตั้งค่าแอป',
      'settings.general': 'ทั่วไป',
      'settings.language': 'ภาษา',
      'settings.playback': 'การเล่น',
      'settings.autoPlay': 'เล่น Trailer อัตโนมัติ',
      'settings.autoPlayDesc': 'เล่น trailer อัตโนมัติในหน้ารายละเอียดหนัง',
      'settings.streamingQuality': 'คุณภาพการสตรีม',
      'settings.wifiOnly': 'ดาวน์โหลดผ่าน Wi-Fi เท่านั้น',
      'settings.wifiOnlyDesc': 'ดาวน์โหลดเนื้อหาผ่าน Wi-Fi เท่านั้น',
      'settings.dataPrivacy': 'ข้อมูลและความเป็นส่วนตัว',
      'settings.clearCache': 'ล้างแคช',
      'settings.clearCacheDesc': 'เพิ่มพื้นที่จัดเก็บ',
      'settings.privacyPolicy': 'นโยบายความเป็นส่วนตัว',
      'settings.termsOfService': 'เงื่อนไขการใช้บริการ',
      'settings.about': 'เกี่ยวกับ',
      'settings.appVersion': 'เวอร์ชันแอป',
      'settings.selectLanguage': 'เลือกภาษา',
      'settings.qualityAuto': 'อัตโนมัติ',
      'settings.qualityAutoDesc': 'ปรับตามสัญญาณอินเทอร์เน็ต',
      'settings.qualityHigh': 'สูง',
      'settings.qualityHighDesc': '1080p · ใช้ข้อมูลมากขึ้น',
      'settings.qualityMedium': 'ปานกลาง',
      'settings.qualityMediumDesc': '720p · สมดุล',
      'settings.qualityLow': 'ต่ำ',
      'settings.qualityLowDesc': '480p · ประหยัดข้อมูล',
      'settings.qualityAutoLabel': 'อัตโนมัติ',
      'settings.qualityHighLabel': 'สูง (1080p)',
      'settings.qualityMediumLabel': 'ปานกลาง (720p)',
      'settings.qualityLowLabel': 'ต่ำ (480p)',
      'settings.clearCacheTitle': 'ล้างแคช',
      'settings.clearCacheMessage':
          'การดำเนินการนี้จะลบรูปภาพและข้อมูลชั่วคราวที่แคชไว้ ข้อมูลบัญชีและการจองของคุณจะไม่ได้รับผลกระทบ',
      'settings.cancel': 'ยกเลิก',
      'settings.clear': 'ล้าง',
      'settings.cacheCleared': 'ล้างแคชสำเร็จ',
      'settings.willOpenBrowser': ' จะเปิดในเบราว์เซอร์',

      // ── Notifications Screen ────────────────────────────
      'notif.title': 'การแจ้งเตือน',
      'notif.pushNotifications': 'การแจ้งเตือนแบบ Push',
      'notif.enabled': 'เปิดการแจ้งเตือนอยู่',
      'notif.disabled': 'ปิดการแจ้งเตือนทั้งหมดแล้ว',
      'notif.booking': 'การจอง',
      'notif.bookingConfirmations': 'ยืนยันการจอง',
      'notif.bookingConfirmationsDesc': 'แจ้งเตือนเมื่อการจองได้รับการยืนยัน',
      'notif.showtimeReminders': 'เตือนก่อนรอบฉาย',
      'notif.showtimeRemindersDesc': 'เตือน 30 นาทีก่อนรอบฉายเริ่ม',
      'notif.discovery': 'ค้นพบ',
      'notif.newMovieAlerts': 'หนังเข้าใหม่',
      'notif.newMovieAlertsDesc': 'แจ้งเตือนเมื่อมีหนังเข้าใหม่',
      'notif.priceAlerts': 'แจ้งเตือนราคา',
      'notif.priceAlertsDesc': 'แจ้งเตือนเมื่อราคาตั๋วมีการเปลี่ยนแปลง',
      'notif.marketing': 'โปรโมชั่น',
      'notif.promotions': 'โปรโมชั่นและข้อเสนอ',
      'notif.promotionsDesc': 'ดีลพิเศษและส่วนลด',
    },
  };
}
