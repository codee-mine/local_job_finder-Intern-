
import 'package:flutter/material.dart';

class EmployeeSearchScreen extends StatefulWidget {
  const EmployeeSearchScreen({super.key});

  @override
  State<EmployeeSearchScreen> createState() => _EmployeeSearchScreenState();
}

class _EmployeeSearchScreenState extends State<EmployeeSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Search')));
  }
}

