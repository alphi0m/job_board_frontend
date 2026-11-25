import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'providers/jobs_provider.dart';
import 'screens/public/jobs_board_screen.dart';
import 'services/api_service.dart';
import 'services/applications_service.dart';
import 'services/auth_service.dart';
import 'services/jobs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza configurazione API (legge URL salvato in cache)
  final apiConfig = ApiConfig();
  await apiConfig.init();

  // Inizializza servizi
  final apiService = ApiService(apiConfig);
  final authService = AuthService(apiService);
  final jobsService = JobsService(apiService);
  final applicationsService = ApplicationsService(apiService);

  // Inizializza provider di stato
  final authProvider = AuthProvider(authService);
  await authProvider.checkSession();

  final jobsProvider = JobsProvider(
    jobsService: jobsService,
    applicationsService: applicationsService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiConfig>.value(value: apiConfig),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<JobsProvider>.value(value: jobsProvider),
      ],
      child: const JobBoardApp(),
    ),
  );
}

class JobBoardApp extends StatelessWidget {
  const JobBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacheca Lavoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.04),
        ),
      ),
      home: const JobsBoardScreen(),
    );
  }
}
