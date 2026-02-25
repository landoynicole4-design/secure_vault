import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessModal(BuildContext context) async {
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
                'Account Created!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your SecureVault account has been\nsuccessfully created.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                    'Continue to Profile',
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

  Future<void> _handleRegister(
      BuildContext context, AuthViewModel authVM) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authVM.register(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (!context.mounted) return;
      await _showSuccessModal(context);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
      }
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
                            height: MediaQuery.of(context).size.height * 0.08),
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
                                'Create your account',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6C6C70),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomTextField(
                          label: 'Full Name',
                          hint: AppStrings.fullName,
                          controller: _nameController,
                          validator: Validators.validateFullName,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Email',
                          hint: AppStrings.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Password',
                          hint: AppStrings.password,
                          controller: _passwordController,
                          isPassword: true,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Confirm Password',
                          hint: AppStrings.confirmPassword,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          validator: (v) => Validators.validateConfirmPassword(
                              v, _passwordController.text),
                        ),
                        const SizedBox(height: 22),
                        CustomButton(
                          text: AppStrings.register,
                          backgroundColor: const Color(0xFF1C1C1E),
                          textColor: Colors.white,
                          isLoading: authVM.isLoading,
                          onPressed: () => _handleRegister(context, authVM),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(
                                color: Color(0xFF6C6C70),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF6C6C70),
                              ),
                            ),
                          ),
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
