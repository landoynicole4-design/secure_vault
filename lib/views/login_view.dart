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

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final enabled = await StorageService().isBiometricEnabled();
    if (mounted) setState(() => _biometricAvailable = enabled);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            if (authVM.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authVM.errorMessage!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                authVM.clearError();
              });
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

                        // Shield icon + App name
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

                        // Email field
                        CustomTextField(
                          label: 'Email or username',
                          hint: 'Enter email or username',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 14),

                        // Password field
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

                        // Login Button
                        CustomButton(
                          text: AppStrings.login,
                          backgroundColor: const Color(0xFF1C1C1E),
                          textColor: Colors.white,
                          isLoading: authVM.isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await authVM.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                              if (success && context.mounted) {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.profile);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 18),

                        // Create account link
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

                        // Divider
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
                                  color: Color(0xFF6C6C70),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Color(0xFFE0E0E0), thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Facebook Button
                        CustomButton(
                          text: AppStrings.signInWithFacebook,
                          backgroundColor: AppColors.facebook,
                          textColor: Colors.white,
                          isLoading: authVM.isLoading,
                          leadingWidget: const Icon(Icons.facebook,
                              color: Colors.white, size: 20),
                          onPressed: () async {
                            final success = await authVM.signInWithFacebook();
                            if (success && context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.profile);
                            }
                          },
                        ),
                        const SizedBox(height: 10),

                        // Google Button
                        CustomButton(
                          text: AppStrings.signInWithGoogle,
                          backgroundColor: const Color(0xFFF5F5F5),
                          textColor: Colors.black87,
                          isLoading: authVM.isLoading,
                          leadingWidget: const _GoogleIcon(),
                          onPressed: () async {
                            final success = await authVM.signInWithGoogle();
                            if (success && context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.profile);
                            }
                          },
                        ),
                        const SizedBox(height: 10),

                        // Biometric Button
                        if (_biometricAvailable)
                          CustomButton(
                            text: 'Login with Fingerprint',
                            backgroundColor: const Color(0xFFF5F5F5),
                            textColor: const Color(0xFF1C1C1E),
                            icon: Icons.fingerprint,
                            isLoading: authVM.isLoading,
                            onPressed: () async {
                              final success =
                                  await authVM.loginWithBiometrics();
                              if (success && context.mounted) {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.profile);
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
