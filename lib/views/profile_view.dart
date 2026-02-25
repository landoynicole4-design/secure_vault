import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../utils/constants.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _editFormKey = GlobalKey<FormState>();
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
        // ✅ FIXED: Removed unnecessary null-aware operator
        _nameController.text = authVM.user!.displayName;
      } else {
        _nameController.text = '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ✅ FIXED: Parameter is nullable but handled safely
  void _startEditing(String? currentName) {
    _nameController.text = currentName ?? '';
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  Future<void> _handleLogout(
    BuildContext context,
    AuthViewModel authVM,
    bool isDark,
    Color cardColor,
    Color bgColor,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to\nsign out of SecureVault?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: borderColor, width: 1),
                          backgroundColor: bgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await authVM.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  // ✅ FIXED: Removed null-aware operator, explicit null check
  String _getDisplayName(String? displayName) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return 'User';
  }

  // ✅ FIXED: Removed null-aware operator, explicit null check
  String _getInitials(String? displayName) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 560.0 : double.infinity;
    final horizontalPadding = screenWidth > 600 ? 0.0 : 20.0;

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
            if (!mounted) return;
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
            if (!mounted) return;
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

        // Get safe display name using helper
        final displayName = _getDisplayName(user.displayName);

        return Scaffold(
          backgroundColor: bgColor,
          resizeToAvoidBottomInset: true,
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
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: textSecondary,
                  size: 20,
                ),
                onPressed: () => profileVM.toggleDarkMode(!isDark),
              ),
              IconButton(
                icon:
                    Icon(Icons.logout_outlined, color: textSecondary, size: 20),
                onPressed: () => _handleLogout(
                  context,
                  authVM,
                  isDark,
                  cardColor,
                  bgColor,
                  textPrimary,
                  textSecondary,
                  borderColor,
                ),
              ),
            ],
          ),
          body: Center(
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                              _getInitials(user.displayName),
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
                      displayName,
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
                    _SectionCard(
                      title: 'Profile Information',
                      icon: Icons.person_outline,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textSecondary: textSecondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isEditing) ...[
                            _InfoRow(
                              label: 'Display Name',
                              value: displayName,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              trailing: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _startEditing(user.displayName),
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
                            Text(
                              'Display Name',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Form(
                              key: _editFormKey,
                              child: TextFormField(
                                controller: _nameController,
                                autofocus: true,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Name cannot be empty'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Enter your name',
                                  hintStyle: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: textSecondary,
                                    size: 18,
                                  ),
                                  filled: true,
                                  fillColor: bgColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: borderColor, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: borderColor, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: textSecondary, width: 1),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.error, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.error, width: 1),
                                  ),
                                  errorStyle: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: profileVM.isLoading
                                          ? null
                                          : () async {
                                              if (!_editFormKey.currentState!
                                                  .validate()) {
                                                return;
                                              }
                                              final newName =
                                                  _nameController.text.trim();
                                              if (newName.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Name cannot be empty'),
                                                    backgroundColor:
                                                        AppColors.error,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                                return;
                                              }
                                              FocusScope.of(context).unfocus();
                                              final success = await profileVM
                                                  .updateDisplayName(newName);
                                              if (success && mounted) {
                                                setState(
                                                    () => _isEditing = false);
                                                if (authVM.user != null) {
                                                  authVM.updateLocalUser(
                                                    authVM.user!.copyWith(
                                                        displayName: newName),
                                                  );
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: textPrimary,
                                        foregroundColor: cardColor,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: profileVM.isLoading
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: cardColor,
                                              ),
                                            )
                                          : const Text(
                                              AppStrings.saveChanges,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 40,
                                  child: TextButton(
                                    onPressed: _cancelEditing,
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: borderColor),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Email',
                            value: user.email, // Remove the null-aware operator
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
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
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return textSecondary;
          }),
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
