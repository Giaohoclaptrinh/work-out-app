import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'services/service_provider.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(
          create: (context) => context.read<ServiceProvider>().authService,
        ),
        ChangeNotifierProvider(
          create: (context) =>
              context.read<ServiceProvider>().onboardingService,
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = SettingsProvider();
            // Load settings immediately when provider is created
            provider.loadSettings();
            return provider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF8E67E4)),
                      const SizedBox(height: 16),
                      Text(
                        'Loading settings...',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Calculate text scale factor based on user's fontSize preference
          final baseFontSize = 16.0; // Default font size
          final userFontSize = settingsProvider.fontSize;
          final textScaleFactor = userFontSize / baseFontSize;

          final lightTheme = ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8E67E4),
              brightness: Brightness.light,
            ),
            primaryColor: const Color(0xFF8E67E4),
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            fontFamily: 'Poppins',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 16),
              bodyMedium: TextStyle(fontSize: 14),
              bodySmall: TextStyle(fontSize: 12),
              titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );

          final darkTheme = ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFB39DDB),
              brightness: Brightness.dark,
            ),
            primaryColor: const Color(0xFFB39DDB),
            scaffoldBackgroundColor: const Color(0xFF0F0F12),
            cardColor: const Color(0xFF16161A),
            dividerColor: const Color(0xFF2A2A2E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF16161A),
              foregroundColor: Color(0xFFEDEDED),
              elevation: 0,
            ),
            fontFamily: 'Poppins',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFEDEDED)),
              bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB8B8C0)),
              bodySmall: TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
              titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEDEDED)),
              titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFEDEDED)),
              titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFEDEDED)),
            ),
            shadowColor: Colors.black.withOpacity(0.4),
          );

          return MaterialApp(
            title: 'Workout App',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
                child: child!,
              );
            },
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode:
                settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
