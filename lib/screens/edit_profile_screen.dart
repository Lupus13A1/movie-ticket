import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().user;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = context.read<AuthService>().user;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        // Force reload user to get the new display name in state
        await user.reload();
        // Notify listeners if necessary, but Firebase Auth state stream might handle it.
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'PROFILE UPDATED SUCCESSFULLY',
              style: TextStyle(fontFamily: AppTheme.fontMono),
            ),
            backgroundColor: AppTheme.foreground,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('EDIT PROFILE'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppTheme.foreground, height: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DISPLAY NAME',
              style: TextStyle(
                fontFamily: AppTheme.fontMono,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppTheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'ENTER YOUR NAME'),
              style: const TextStyle(
                fontFamily: AppTheme.fontBody,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.foreground,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: AppTheme.fontMono,
                  fontSize: 12,
                  color: AppTheme.foreground,
                ),
              ),
            ],
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.background,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
