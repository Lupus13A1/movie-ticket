import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // On success, auth state changes will navigate away automatically
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
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
    if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (error.contains('popup-closed-by-user')) {
      return 'Sign-in cancelled.';
    }
    return 'An error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                  SizedBox(height: isSmall ? 24 : 48),

                  // ── Back Navigation ─────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: AppTheme.foreground,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'BACK',
                            style: TextStyle(
                              fontFamily: AppTheme.fontBody,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3.0,
                              color: AppTheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isSmall ? 32 : 48),

                  // ── Hero Typography ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'CREATE',
                          style: TextStyle(
                            fontFamily: AppTheme.fontDisplay,
                            fontSize: isSmall ? 48 : 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2.0,
                            height: 0.9,
                            color: AppTheme.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'ACCOUNT',
                          style: TextStyle(
                            fontFamily: AppTheme.fontDisplay,
                            fontSize: isSmall ? 48 : 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2.0,
                            height: 0.9,
                            color: AppTheme.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 60,
                          height: 4,
                          color: AppTheme.foreground,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'JOIN THE EXPERIENCE',
                          style: TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 5.0,
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmall ? 32 : 48),

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
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          const Text(
                            'EMAIL ADDRESS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3.0,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
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
                          const SizedBox(height: 28),

                          // Password
                          const Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3.0,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.foreground,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
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
                              if (value.length < 6) {
                                return 'At least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Confirm Password
                          const Text(
                            'CONFIRM PASSWORD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3.0,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.foreground,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  );
                                },
                                child: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.mutedForeground,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Register Button ─────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppTheme.background,
                              ),
                            )
                          : const Text('CREATE ACCOUNT  →'),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Divider ─────────────────────────────────────
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

                  const SizedBox(height: 28),

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
                                const Text('SIGN UP WITH GOOGLE'),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Login Link ──────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: AppTheme.fontBody,
                            fontSize: 14,
                            color: AppTheme.mutedForeground,
                            height: 1.5,
                          ),
                          children: const [
                            TextSpan(text: 'Already have an account?  '),
                            TextSpan(
                              text: 'SIGN IN',
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

                  SizedBox(height: isSmall ? 24 : 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
