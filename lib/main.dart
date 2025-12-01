import 'package:flutter/material.dart';
import 'package:local_job_finder/employee/employee_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const EmployeeHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
