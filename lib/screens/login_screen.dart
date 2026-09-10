import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorMessage = _parseError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = _parseError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Try again later.';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid email or password.';
    } else if (error.contains('popup-closed-by-user')) {
      return 'Sign-in cancelled.';
    }
    return 'An error occurred. Please try again.';
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isSmall ? 32 : 64),

                  // ── Hero Typography ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'CINEMA',
                          style: TextStyle(
                            fontFamily: AppTheme.fontDisplay,
                            fontSize: isSmall ? 64 : 88,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -3.0,
                            height: 0.85,
                            color: AppTheme.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Thick decorative rule
                        Container(
                          width: 60,
                          height: 4,
                          color: AppTheme.foreground,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'MOVIE TICKETS',
                          style: TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 6.0,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmall ? 40 : 64),

                  // ── Error Message ───────────────────────────────
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.foreground,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.background,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontBody,
                                fontSize: 13,
                                color: AppTheme.background,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Form ────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email label
                        const Text(
                          'EMAIL ADDRESS',
                          style: TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.0,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 16,
                            color: AppTheme.foreground,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'your@email.com',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Password label
                        const Text(
                          'PASSWORD',
                          style: TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.0,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 16,
                            color: AppTheme.foreground,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.mutedForeground,
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Sign In Button ──────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppTheme.background,
                              ),
                            )
                          : const Text('SIGN IN  →'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Divider with "or" ───────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.borderLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3.0,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.borderLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Google Sign In Button ────────────────────────
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppTheme.foreground,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Simple G letter as Google icon (monochrome)
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.foreground,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontDisplay,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.foreground,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Text('SIGN IN WITH GOOGLE'),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Register Link ───────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _navigateToRegister,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                            height: 1.5,
                          ),
                          children: const [
                            TextSpan(text: "Don't have an account?  "),
                            TextSpan(
                              text: 'REGISTER',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: AppTheme.foreground,
                                decoration: TextDecoration.underline,
                                decorationThickness: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmall ? 32 : 64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
