import 'package:flutter/material.dart';

class EmployerSearchScreen extends StatefulWidget {
  const EmployerSearchScreen({super.key});

  @override
  State<EmployerSearchScreen> createState() => _EmployerSearchScreenState();
}

class _EmployerSearchScreenState extends State<EmployerSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Search')));
  }
}
