import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/internet_check.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';
import 'package:local_job_finder/auth/api_service.dart';
import 'package:local_job_finder/auth/auth_service.dart';
import 'package:local_job_finder/employee/employee_dashboard.dart';
import 'package:local_job_finder/employer/employer_add_and_edit_job.dart';
import 'package:local_job_finder/employer/employer_job.dart';
import 'package:local_job_finder/employer/employer_notification_screen.dart';
import 'package:local_job_finder/employer/employer_profile.dart';

class EmployerHomeScreen extends StatefulWidget {
  final int index;
  final int? highlightJobId;
  final VoidCallback? loadPofileData;
  const EmployerHomeScreen({
    super.key,
    this.index = 1,
    this.highlightJobId,
    this.loadPofileData,
  });

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  EmployerUserProfile? _userProfile;
  int _currentIndex = 1;
  int? _highlightedJobId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _highlightedJobId = widget.highlightJobId;
    _loadEmployerProfile();
  }

  Future<void> _loadEmployerProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.getUserProfile();

      if (response['statusCode'] == 200) {
        final userData = response['body']['data'] ?? response['body'];
        setState(() {
          _userProfile = EmployerUserProfile.fromJson(userData);
        });
      } else {
        SnackBarUtil.showErrorMessage(context, 'Failed to load profile');
      }
    } catch (e) {
      SnackBarUtil.showErrorMessage(
        context,
        'Failed to load profile: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeHomeScreen(initialLoggedIn: false),
      ),
      (route) => false,
    );
    SnackBarUtil.showSuccessMessage(context, 'Logged out Successfully');
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

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Posted Jobs';
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
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InternetBanner(child: EmployerPostJobScreen()),
                  ),
                ).then((result) {
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _currentIndex = 0;
                      _highlightedJobId = result['id'];
                    });
                  }
                });
                SnackBarUtil.showSuccessMessage(context, 'Posted Jobs');
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployerNotification(),
                  ),
                );
                SnackBarUtil.showSuccessMessage(context, 'Notifications');
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _buildCurrentTab(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildJobTab();
      case 1:
        return _buildHomeContent();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildJobTab() {
    return EmployerPostedJobsScreen();
  }

  Widget _buildHomeContent() {
    return EmployerHomeContent();
  }

  Widget _buildProfileTab() {
    return EmployerProfileScreen(
      userProfile: _userProfile,
      onProfileUpdated: _loadEmployerProfile,
    );
  }
}

class EmployerHomeContent extends StatefulWidget {
  const EmployerHomeContent({super.key});

  @override
  State<EmployerHomeContent> createState() => _EmployerHomeContentState();
}

class _EmployerHomeContentState extends State<EmployerHomeContent> {
  final TextEditingController _searchInputController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _searchInputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchInput(),
              const SizedBox(height: 20),
              _buildPostJobLists(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          controller: _searchInputController,
          decoration: InputDecoration(
            hintText: 'Seach posted jobs...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
            suffixIcon: _searchInputController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchInputController.clear();
                    },
                    icon: Icon(Icons.clear),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPostJobLists() {
    return ListTile();
  }
}
