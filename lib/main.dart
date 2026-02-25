import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // ADD THIS
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/profile_view.dart';
import 'utils/constants.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Facebook SDK - ADD THIS SECTION
  await FacebookAuth.instance.webAndDesktopInitialize(
    appId: "YOUR_FACEBOOK_APP_ID", // Replace with your actual Facebook App ID
    cookie: true,
    xfbml: true,
    version: "v18.0",
  );

  final storageService = StorageService();
  final isDarkMode = await storageService.getDarkMode();

  runApp(SecureVaultApp(initialDarkMode: isDarkMode));
}

class SecureVaultApp extends StatefulWidget {
  final bool initialDarkMode;

  const SecureVaultApp({super.key, this.initialDarkMode = false});

  @override
  State<SecureVaultApp> createState() => _SecureVaultAppState();
}

class _SecureVaultAppState extends State<SecureVaultApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) =>
              ProfileViewModel()..setInitialDarkMode(widget.initialDarkMode),
        ),
      ],
      child: Consumer<ProfileViewModel>(
        builder: (context, profileVM, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            themeMode: profileVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1877F2),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1877F2),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            initialRoute: AppRoutes.login,
            routes: {
              AppRoutes.login: (_) => const LoginView(),
              AppRoutes.register: (_) => const RegisterView(),
              AppRoutes.profile: (_) => const ProfileView(),
            },
          );
        },
      ),
    );
  }
}
