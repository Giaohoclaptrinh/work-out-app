import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'services/service_provider.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.getProviders(),
      child: MaterialApp(
        title: 'Workout App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: "Poppins"),
        home: const AuthWrapper(),
      ),
    );
  }
}
