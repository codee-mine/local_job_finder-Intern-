import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/internet_check.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';
import 'package:local_job_finder/employee/employee_jobs.dart';
import 'package:local_job_finder/employee/employee_notification.dart';
import 'package:local_job_finder/employee/employee_profile.dart';
import 'package:local_job_finder/login_and_registration.dart';

List<Map<String, dynamic>> jobListings = [
  {
    'id': 1,
    'title': 'Senior Flutter Developer',
    'company': 'TechCorp Solutions',
    'location': 'New York, NY',
    'salary': '\$100,000 - \$130,000',
    'type': 'Full-Time',
    'description': 'We are looking for an experienced Flutter developer...',
    'requirements': '5+ years Flutter, REST APIs, Firebase, State Management',
    'postedDate': '2024-01-15',
    'expiryDate': '2024-02-15',
    'isActive': true,
    'applications': 24,
    'views': 156,
    'category': 'IT & Software',
    'experience': '5+ years',
    'education': 'Bachelor\'s Degree',
    'isSaved': false,
    'isApplied': false,
    'savedDate': '',
    'appliedDate': '',
    'applicationStatus': '',
  },
  {
    'id': 2,
    'title': 'UI/UX Designer',
    'company': 'CreativeMinds Inc',
    'location': 'San Francisco, CA',
    'salary': '\$85,000 - \$110,000',
    'type': 'Full-Time',
    'description': 'Design beautiful interfaces for mobile and web...',
    'requirements': '3+ years UI/UX, Figma, Adobe XD, Prototyping',
    'postedDate': '2024-01-18',
    'expiryDate': '2024-02-18',
    'isActive': true,
    'applications': 18,
    'views': 98,
    'category': 'Design & Creative',
    'experience': '3+ years',
    'education': 'Bachelor\'s Degree',
    'isSaved': false,
    'isApplied': false,
    'savedDate': '',
    'appliedDate': '',
    'applicationStatus': '',
  },
  {
    'id': 3,
    'title': 'Marketing Manager',
    'company': 'GrowthHack Marketing',
    'location': 'Remote',
    'salary': '\$90,000 - \$120,000',
    'type': 'Full-Time',
    'description': 'Lead marketing campaigns and drive growth...',
    'requirements': '5+ years marketing, SEO, Social Media, Analytics',
    'postedDate': '2024-01-20',
    'expiryDate': '2024-02-20',
    'isActive': true,
    'applications': 12,
    'views': 76,
    'category': 'Marketing',
    'experience': '5+ years',
    'education': 'Bachelor\'s Degree',
    'isSaved': false,
    'isApplied': false,
    'savedDate': '',
    'appliedDate': '',
    'applicationStatus': '',
  },
  {
    'id': 4,
    'title': 'Data Scientist',
    'company': 'DataTech Analytics',
    'location': 'Boston, MA',
    'salary': '\$120,000 - \$150,000',
    'type': 'Full-Time',
    'description': 'Analyze large datasets and build predictive models...',
    'requirements': 'Python, ML, SQL, 4+ years experience',
    'postedDate': '2024-01-10',
    'expiryDate': '2024-02-10',
    'isActive': true,
    'applications': 32,
    'views': 189,
    'category': 'Data Science',
    'experience': '4+ years',
    'education': 'Master\'s Degree',
    'isSaved': false,
    'isApplied': false,
    'savedDate': '',
    'appliedDate': '',
    'applicationStatus': '',
  },
  {
    'id': 5,
    'title': 'Customer Support Specialist',
    'company': 'HelpDesk Pro',
    'location': 'Chicago, IL',
    'salary': '\$45,000 - \$60,000',
    'type': 'Part-Time',
    'description': 'Provide excellent customer support via phone/email...',
    'requirements': '2+ years customer service, communication skills',
    'postedDate': '2024-01-22',
    'expiryDate': '2024-02-22',
    'isActive': true,
    'applications': 8,
    'views': 45,
    'category': 'Customer Service',
    'experience': '2+ years',
    'education': 'High School Diploma',
    'isSaved': false,
    'isApplied': false,
    'savedDate': '',
    'appliedDate': '',
    'applicationStatus': '',
  },
  {
    'id': 6,
    'title': 'Sales Executive',
    'company': 'SalesForce Pro',
    'location': 'Austin, TX',
    'salary': '\$70,000 + Commission',
    'type': 'Full-Time',
    'description': 'Drive sales and build client relationships...',
    'requirements': '3+ years sales, CRM software, negotiation skills',
    'postedDate': '2024-01-12',
    'expiryDate': '2024-02-12',
    'isActive': true,
    'applications': 15,
    'views': 89,
    'category': 'Sales',
    'experience': '3+ years',
    'education': 'Bachelor\'s Degree',
    'isSaved': false,
    'isApplied': false,
    'savedDate': '',
    'appliedDate': '',
    'applicationStatus': '',
  },
];

void updateJobStatus(
  int jobId, {
  bool? isSaved,
  bool? isApplied,
  String? applicationStatus,
  String? appliedDate,
  VoidCallback? onUpdate,
}) {
  final index = jobListings.indexWhere((job) => (job['id'] as int) == jobId);
  if (index != -1) {
    if (isSaved != null) {
      jobListings[index]['isSaved'] = isSaved;

      if (isSaved &&
          (jobListings[index]['savedDate'] == null ||
              jobListings[index]['savedDate'] == '')) {
        jobListings[index]['savedDate'] = DateTime.now().toString().split(
          ' ',
        )[0];
      }
    }
    if (isApplied != null) {
      jobListings[index]['isApplied'] = isApplied;
    }
    if (applicationStatus != null) {
      jobListings[index]['applicationStatus'] = applicationStatus;
    }
    if (appliedDate != null) {
      jobListings[index]['appliedDate'] = appliedDate;
    }

    if (onUpdate != null) {
      onUpdate();
    }
  }
}

class EmployeeHomeScreen extends StatefulWidget {
  final bool? initialLoggedIn;
  const EmployeeHomeScreen({super.key, this.initialLoggedIn});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _currentIndex = 1;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    isLoggedIn = widget.initialLoggedIn ?? true;
    if (!isLoggedIn) {
      _currentIndex = 1;
    }
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
    setState(() {
      isLoggedIn = false;
    });
    if (_currentIndex != 1) {
      setState(() {
        _currentIndex = 1;
      });
    }
    SnackBarUtil.showSuccessMessage(context, 'Logged out successfully');
  }

  Future<void> _login() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    ).then((value) {
      if (value == true) {
        setState(() {
          isLoggedIn = true;
        });
        SnackBarUtil.showSuccessMessage(context, 'Logged in successfully');
      }
    });
  }

  String _getAppBarTitle() {
    if (!isLoggedIn) {
      return 'Job Listings';
    }
    switch (_currentIndex) {
      case 0:
        return 'My Jobs';
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
            if (isLoggedIn)
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeNotification(),
                    ),
                  );
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
                        Icon(Icons.login, color: Colors.blue),
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
        bottomNavigationBar: isLoggedIn
            ? BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark),
                    label: 'My Jobs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
            : Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: TextButton(
                  onPressed: _login,
                  child: Text(
                    'Sign in to access more features',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentIndexTab() {
    switch (_currentIndex) {
      case 0:
        return EmployeeJobsScreen();
      case 1:
        return EmployeeHomeContent(isLoggedIn: isLoggedIn);
      case 2:
        return EmployeeProfileScreen();
      default:
        return EmployeeHomeContent(isLoggedIn: isLoggedIn);
    }
  }
}

class EmployeeHomeContent extends StatefulWidget {
  final bool isLoggedIn;
  const EmployeeHomeContent({super.key, required this.isLoggedIn});

  @override
  State<EmployeeHomeContent> createState() => _EmployeeHomeContentState();
}

class _EmployeeHomeContentState extends State<EmployeeHomeContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _filteredJobs = jobListings;
    _searchController.addListener(() {
      _filterJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterJobs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredJobs = jobListings;
      } else {
        _filteredJobs = jobListings.where((job) {
          return job['title'].toLowerCase().contains(query) ||
              job['company'].toLowerCase().contains(query) ||
              job['location'].toLowerCase().contains(query) ||
              job['category'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(Map<String, dynamic> job) {
    if (!widget.isLoggedIn) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sign in to view job details and apply',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'SIGN IN',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.work, color: Colors.blue),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['title'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              job['company'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          job['isSaved'] == true
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: job['isSaved'] == true
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: () {
                          final isCurrentlySaved = job['isSaved'] == true;
                          updateJobStatus(
                            job['id'] as int,
                            isSaved: !isCurrentlySaved,
                          );
                          setState(() {});
                          Navigator.pop(context);
                          SnackBarUtil.showSuccessMessage(
                            context,
                            !isCurrentlySaved
                                ? 'Job saved'
                                : 'Job removed from saved',
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(job['location']),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      Chip(
                        label: Text(job['salary']),
                        backgroundColor: Colors.green.shade50,
                      ),
                      Chip(
                        label: Text(job['type']),
                        backgroundColor: Colors.purple.shade50,
                      ),
                      Chip(
                        label: Text(job['category']),
                        backgroundColor: Colors.orange.shade50,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  _buildDetailRow('Posted Date', job['postedDate']),
                  _buildDetailRow('Expiry Date', job['expiryDate']),
                  _buildDetailRow('Experience', job['experience']),
                  _buildDetailRow('Education', job['education']),
                  _buildDetailRow('Applications', '${job['applications']}'),
                  _buildDetailRow('Views', '${job['views']}'),
                  SizedBox(height: 20),

                  Text(
                    'Job Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    job['description'],
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Requirements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    job['requirements'],
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (job['isApplied'] == true) {
                          SnackBarUtil.showErrorMessage(
                            context,
                            'Already applied for this job',
                          );
                          return;
                        }

                        updateJobStatus(
                          job['id'] as int,
                          isApplied: true,
                          applicationStatus: 'Submitted',
                          appliedDate: DateTime.now().toString().split(' ')[0],
                          onUpdate: () {
                            setState(() {});
                          },
                        );

                        // when applied, also save the job
                        /*
                        if (job['isSaved'] != true) {
                          updateJobStatus(
                            job['id'] as int,
                            isSaved: true,
                            onUpdate: () {
                              setState(() {}); 
                            },
                          );
                        }
                        */

                        Navigator.pop(context);
                        SnackBarUtil.showSuccessMessage(
                          context,
                          'Application submitted!',
                        );
                      },
                      child: Text(
                        job['isApplied'] == true
                            ? 'Already Applied'
                            : 'Apply Now',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _refreshData() async {
    SnackBarUtil.showInfoMessage(context, 'Job Refreshed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                      hintText: 'Search jobs, companies, locations...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterJobs();
                              },
                              icon: Icon(Icons.clear),
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              /*
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${_filteredJobs.length} jobs found',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    if (!widget.isLoggedIn)
                      Text(
                        'Guest View',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              */
              Expanded(
                child: _filteredJobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No jobs found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try different keywords',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          return _buildJobCard(job);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showJobDetails(job),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isLoggedIn)
                    IconButton(
                      icon: Icon(
                        job['isSaved'] == true
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: job['isSaved'] == true
                            ? Colors.blue
                            : Colors.grey.shade600,
                      ),
                      onPressed: () {
                        final isCurrentlySaved = job['isSaved'] == true;
                        updateJobStatus(
                          job['id'] as int,
                          isSaved: !isCurrentlySaved,
                          onUpdate: () {
                            setState(() {});
                          },
                        );

                        SnackBarUtil.showSuccessMessage(
                          context,
                          !isCurrentlySaved
                              ? 'Job saved'
                              : 'Job removed from saved',
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                ],
              ),
              SizedBox(height: 8),

              if (widget.isLoggedIn) ...[
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job['company'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
              ],

              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job['location'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job['salary'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (widget.isLoggedIn) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Posted: ${job['postedDate']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Expires: ${job['expiryDate']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      job['type'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

                  if (widget.isLoggedIn && job['isSaved'] == true)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bookmark, size: 12, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'Saved',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (widget.isLoggedIn && job['isApplied'] == true)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Applied',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
