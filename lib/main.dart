import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'services/service_provider.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'widgets/auth_wrapper.dart';

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
            theme: ThemeData(
              brightness: settingsProvider.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              primarySwatch: Colors.purple,
              primaryColor: Color(0xFF8E67E4),
              fontFamily: 'Poppins',
              // Use standard TextTheme without manual fontSize adjustments
              // Let MediaQuery handle the scaling
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: baseFontSize),
                bodyMedium: TextStyle(fontSize: baseFontSize - 2),
                bodySmall: TextStyle(fontSize: baseFontSize - 4),
                titleLarge: TextStyle(
                  fontSize: baseFontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
                titleMedium: TextStyle(
                  fontSize: baseFontSize + 2,
                  fontWeight: FontWeight.w600,
                ),
                titleSmall: TextStyle(
                  fontSize: baseFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: settingsProvider.isDarkMode
                    ? Colors.grey[850]
                    : Colors.white,
                foregroundColor: settingsProvider.isDarkMode
                    ? Colors.grey[100]
                    : Colors.black,
                elevation: 0,
              ),
              scaffoldBackgroundColor: settingsProvider.isDarkMode
                  ? Colors.grey[900]
                  : Colors.white,
              cardTheme: CardThemeData(
                color: settingsProvider.isDarkMode
                    ? Colors.grey[850]
                    : Colors.white,
                elevation: 2,
              ),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
