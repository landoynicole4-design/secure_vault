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

                        // Full Name
                        CustomTextField(
                          label: 'Full Name',
                          hint: AppStrings.fullName,
                          controller: _nameController,
                          validator: Validators.validateFullName,
                        ),
                        const SizedBox(height: 14),

                        // Email
                        CustomTextField(
                          label: 'Email',
                          hint: AppStrings.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 14),

                        // Password
                        CustomTextField(
                          label: 'Password',
                          hint: AppStrings.password,
                          controller: _passwordController,
                          isPassword: true,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 14),

                        // Confirm Password
                        CustomTextField(
                          label: 'Confirm Password',
                          hint: AppStrings.confirmPassword,
                          controller: _confirmPasswordController,
                          isPassword: true,
                          validator: (v) => Validators.validateConfirmPassword(
                              v, _passwordController.text),
                        ),
                        const SizedBox(height: 22),

                        // Register Button
                        CustomButton(
                          text: AppStrings.register,
                          backgroundColor: const Color(0xFF1C1C1E),
                          textColor: Colors.white,
                          isLoading: authVM.isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await authVM.register(
                                fullName: _nameController.text.trim(),
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

                        // Login link
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
