import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/internet_check.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';
import 'package:local_job_finder/employee/employee_jobs.dart';
import 'package:local_job_finder/employee/employee_profile.dart';
import 'package:local_job_finder/login_and_registration.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _currentIndex = 1;
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _login() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  String _getAppBarTitle() {
    if (!isLoggedIn) {
      return 'Job List';
    }
    switch (_currentIndex) {
      case 0:
        return 'Jobs';
      case 1:
        return 'Dashboard';
      case 2:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InternetBanner(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          centerTitle: true,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                SnackBarUtil.showSuccessMessage(context, 'Notifications');
              },
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
                if (value == 'login') {
                  _login();
                }
              },
              itemBuilder: (BuildContext context) => [
                if (isLoggedIn)
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                if (!isLoggedIn)
                  PopupMenuItem<String>(
                    value: 'login',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Login'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: _buildCurrentIndexTab(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.work_history),
              label: 'Saved Jobs',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentIndexTab() {
    switch (_currentIndex) {
      case 0:
        return _buildJobTab();
      case 1:
        return _buildHomeTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildJobTab() {
    return EmployeeJobsScreen();
  }

  Widget _buildHomeTab() {
    return EmployeeHomeContent();
  }

  Widget _buildProfileTab() {
    return EmployeeProfileScreen();
  }
}

class EmployeeHomeContent extends StatefulWidget {
  const EmployeeHomeContent({super.key});

  @override
  State<EmployeeHomeContent> createState() => _EmployeeHomeContentState();
}

class _EmployeeHomeContentState extends State<EmployeeHomeContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [_buildSearchInput()]),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for Jobs...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: Icon(Icons.clear),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
