import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/tmdb_service.dart';
import 'services/firebase_service.dart';
import 'services/settings_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Make sure to run flutterfire configure first!
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase not initialized: $e");
  }

  // Pre-initialize SettingsService with SharedPreferences
  final firebaseService = FirebaseService();
  final settingsService = await SettingsService.create(firebaseService);

  runApp(
    MyApp(firebaseService: firebaseService, settingsService: settingsService),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseService firebaseService;
  final SettingsService settingsService;

  const MyApp({
    super.key,
    required this.firebaseService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => TmdbService()),
        Provider.value(value: firebaseService),
        ChangeNotifierProvider.value(value: settingsService),
      ],
      child: MaterialApp(
        title: 'Movie Ticket Booking',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        builder: (context, child) {
          return child!;
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Load user settings from Firebase when user logs in
    if (authService.isAuthenticated) {
      final userId = authService.user!.uid;
      if (_lastUserId != userId) {
        _lastUserId = userId;
        // Schedule after frame to avoid calling during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<SettingsService>().loadUserSettings(userId);
        });
      }
      return const HomeScreen();
    } else {
      _lastUserId = null;
      return const LoginScreen();
    }
  }
}
