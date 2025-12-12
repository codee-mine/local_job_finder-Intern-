import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_job_finder/auth/auth_service.dart';
import 'package:local_job_finder/employee/employee_dashboard.dart';
import 'package:local_job_finder/employer/employer_dashboard.dart';
import 'package:local_job_finder/login_and_registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Finder',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 6, 79, 205),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 6, 79, 205),
          secondary: const Color.fromARGB(255, 255, 152, 0),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();

    Widget nextScreen;

    if (isLoggedIn) {
      final tokenValid = await authService.validateToken();
      if (tokenValid) {
        final userRole = await authService.getUserRole();
        if (userRole == 'employee') {
          nextScreen = const EmployeeHomeScreen(initialLoggedIn: true);
        } else if (userRole == 'employer') {
          nextScreen = const EmployerHomeScreen();
        } else {
          nextScreen = const EmployeeHomeScreen(initialLoggedIn: false);
        }
      } else {
        await authService.logout();
        nextScreen = const LoginScreen();
      }
    } else {
      nextScreen = const EmployeeHomeScreen(initialLoggedIn: false);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.work_outline_outlined,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Job Finder',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
