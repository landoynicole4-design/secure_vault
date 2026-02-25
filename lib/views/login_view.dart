import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _biometricAvailable = false;
  bool _isCheckingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      final enabled = await StorageService().isBiometricEnabled();
      if (mounted) {
        setState(() {
          _biometricAvailable = enabled;
          _isCheckingBiometric = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _isCheckingBiometric = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessModal(BuildContext context, String name) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You have successfully logged in${name.isNotEmpty ? ',\n$name' : ''}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C6C70),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C1C1E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go to Profile',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showErrorModal(BuildContext context, String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  color: Color(0xFFC62828),
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login Failed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C6C70),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, AuthViewModel authVM) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authVM.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final name = authVM.user?.displayName ?? '';
      if (!context.mounted) return;
      await _showSuccessModal(context, name);
      if (context.mounted) {
        // ← fixed
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
      }
    } else {
      final error = authVM.errorMessage ??
          'Incorrect email or password. Please try again.';
      authVM.clearError();
      if (!context.mounted) return;
      await _showErrorModal(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 480.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            if (authVM.isInitializing) {
              return const Center(child: CircularProgressIndicator());
            }

            if (authVM.isLoggedIn) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.profile);
              });
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.10),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF1C1C1E),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                // ← fixed
                                AppStrings.appName,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                // ← fixed
                                AppStrings.tagline,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6C6C70),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 52),
                        CustomTextField(
                          label: 'Email or username',
                          hint: 'Enter email or username',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Password',
                          hint: 'Enter password',
                          controller: _passwordController,
                          isPassword: true,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Password is required'
                              : null,
                        ),
                        const SizedBox(height: 22),
                        CustomButton(
                          text: AppStrings.login,
                          backgroundColor: const Color(0xFF1C1C1E),
                          textColor: Colors.white,
                          isLoading: authVM.isLoading,
                          onPressed: () => _handleLogin(context, authVM),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.register),
                            child: const Text(
                              'Create an account',
                              style: TextStyle(
                                color: Color(0xFF6C6C70),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF6C6C70),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Color(0xFFE0E0E0), thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Or login with',
                                style: TextStyle(
                                    color: Color(0xFF6C6C70), fontSize: 12),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Color(0xFFE0E0E0), thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        CustomButton(
                          text: AppStrings.signInWithFacebook,
                          backgroundColor: AppColors.facebook,
                          textColor: Colors.white,
                          isLoading: authVM.isLoading,
                          leadingWidget: const Icon(Icons.facebook,
                              color: Colors.white, size: 20),
                          onPressed: () async {
                            final success = await authVM.signInWithFacebook();
                            if (!mounted) return;
                            if (success) {
                              final name = authVM.user?.displayName ?? '';
                              if (!context.mounted) return;
                              await _showSuccessModal(context, name);
                              if (context.mounted) {
                                // ← fixed
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.profile);
                              }
                            } else {
                              final error = authVM.errorMessage ??
                                  'Facebook sign-in failed. Please try again.';
                              authVM.clearError();
                              if (!context.mounted) return;
                              await _showErrorModal(context, error);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          text: AppStrings.signInWithGoogle,
                          backgroundColor: const Color(0xFFF5F5F5),
                          textColor: Colors.black87,
                          isLoading: authVM.isLoading,
                          leadingWidget: const _GoogleIcon(),
                          onPressed: () async {
                            final success = await authVM.signInWithGoogle();
                            if (!mounted) return;
                            if (success) {
                              final name = authVM.user?.displayName ?? '';
                              if (!context.mounted) return;
                              await _showSuccessModal(context, name);
                              if (context.mounted) {
                                // ← fixed
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.profile);
                              }
                            } else {
                              final error = authVM.errorMessage ??
                                  'Google sign-in failed. Please try again.';
                              authVM.clearError();
                              if (!context.mounted) return;
                              await _showErrorModal(context, error);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        if (!_isCheckingBiometric && _biometricAvailable)
                          CustomButton(
                            text: 'Login with Fingerprint',
                            backgroundColor: const Color(0xFFF5F5F5),
                            textColor: const Color(0xFF1C1C1E),
                            icon: Icons.fingerprint,
                            isLoading: authVM.isLoading,
                            onPressed: () async {
                              final success =
                                  await authVM.loginWithBiometrics();
                              if (!mounted) return;
                              if (success) {
                                final name = authVM.user?.displayName ?? '';
                                if (!context.mounted) return;
                                await _showSuccessModal(context, name);
                                if (context.mounted) {
                                  // ← fixed
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.profile);
                                }
                              } else {
                                final error = authVM.errorMessage ??
                                    'Biometric authentication failed.';
                                authVM.clearError();
                                if (!context.mounted) return;
                                await _showErrorModal(context, error);
                              }
                            },
                          ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFFDB4437),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
