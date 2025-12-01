import 'package:flutter/material.dart';

class EmployerPostedJobsScreen extends StatefulWidget {
  const EmployerPostedJobsScreen({super.key});

  @override
  State<EmployerPostedJobsScreen> createState() =>
      _EmployerPostedJobsScreenState();
}

class _EmployerPostedJobsScreenState extends State<EmployerPostedJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Posted job list')));
  }
}
