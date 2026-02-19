import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../utils/constants.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final profileVM = context.read<ProfileViewModel>();
      if (authVM.user != null) {
        profileVM.loadUser(authVM.user!);
        _nameController.text = authVM.user!.fullName;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 560.0 : double.infinity;
    final horizontalPadding = screenWidth > 600 ? 0.0 : 20.0;

    // FIX: Consumer2 wraps the entire Scaffold so authVM is available
    // for logout AND profileVM is available for dark mode
    return Consumer2<AuthViewModel, ProfileViewModel>(
      builder: (context, authVM, profileVM, _) {
        final isDark = profileVM.isDarkMode;
        final bgColor =
            isDark ? AppColors.darkBackground : AppColors.background;
        final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSecondary =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        final borderColor =
            isDark ? AppColors.darkSurfaceBorder : AppColors.surfaceBorder;

        if (profileVM.successMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(profileVM.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.all(16),
              ),
            );
            profileVM.clearMessages();
          });
        }

        if (profileVM.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(profileVM.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.all(16),
              ),
            );
            profileVM.clearMessages();
          });
        }

        final user = profileVM.user ?? authVM.user;
        if (user == null) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              AppStrings.profile,
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: cardColor,
            foregroundColor: textPrimary,
            automaticallyImplyLeading: false,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: borderColor),
            ),
            actions: [
              // Dark mode toggle button in AppBar
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: textSecondary,
                  size: 20,
                ),
                onPressed: () => profileVM.toggleDarkMode(!isDark),
              ),
              // FIX: logout uses authVM from Consumer2 — no longer needs context.read
              IconButton(
                icon:
                    Icon(Icons.logout_outlined, color: textSecondary, size: 20),
                onPressed: () async {
                  await authVM.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    CircleAvatar(
                      radius: 40,
                      backgroundColor: borderColor,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 28,
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),

                    Text(
                      user.fullName,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 28),

                    // Profile Information Card
                    _SectionCard(
                      title: 'Profile Information',
                      icon: Icons.person_outline,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textSecondary: textSecondary,
                      child: Column(
                        children: [
                          if (!_isEditing) ...[
                            _InfoRow(
                              label: 'Display Name',
                              value: user.fullName,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              trailing: GestureDetector(
                                onTap: () => setState(() {
                                  _isEditing = true;
                                  _nameController.text = user.fullName;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            CustomTextField(
                              label: 'Display Name',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: AppStrings.saveChanges,
                                    isLoading: profileVM.isLoading,
                                    onPressed: () async {
                                      if (_nameController.text.isNotEmpty) {
                                        final success =
                                            await profileVM.updateDisplayName(
                                                _nameController.text.trim());
                                        if (success) {
                                          setState(() => _isEditing = false);
                                          authVM.updateLocalUser(
                                            authVM.user!.copyWith(
                                                fullName: _nameController.text
                                                    .trim()),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _isEditing = false),
                                  child: Text('Cancel',
                                      style: TextStyle(color: textSecondary)),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Email',
                            value: user.email,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Security Card
                    _SectionCard(
                      title: 'Security',
                      icon: Icons.shield_outlined,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textSecondary: textSecondary,
                      child: Column(
                        children: [
                          _ToggleRow(
                            icon: Icons.fingerprint,
                            title: AppStrings.enableBiometrics,
                            subtitle: 'Use fingerprint to login next time',
                            value: profileVM.biometricEnabled,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            borderColor: borderColor,
                            bgColor: bgColor,
                            onChanged: (v) => profileVM.toggleBiometric(v),
                          ),
                          const SizedBox(height: 12),
                          _ToggleRow(
                            icon: isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: isDark
                                ? 'Currently using dark theme'
                                : 'Currently using light theme',
                            value: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            borderColor: borderColor,
                            bgColor: bgColor,
                            onChanged: (v) => profileVM.toggleDarkMode(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color cardColor;
  final Color borderColor;
  final Color textSecondary;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.cardColor,
    required this.borderColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textSecondary, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final Widget? trailing;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final Color bgColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.bgColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, color: textSecondary, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: TextStyle(color: textSecondary, fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          inactiveThumbColor: textSecondary,
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.success;
            }
            return borderColor;
          }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
