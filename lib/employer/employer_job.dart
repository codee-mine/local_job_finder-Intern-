import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';
import 'package:local_job_finder/employer/employer_add_and_edit_job.dart';

// List to store posted jobs
List<Map<String, dynamic>> postedJobs = [
  {
    'id': 1,
    'title': 'Senior Flutter Developer',
    'description': 'We are looking for an experienced Flutter developer...',
    'requirements': '3+ years Flutter experience, REST APIs, Firebase',
    'jobType': 'Full-Time',
    'category': 'IT & Software',
    'salary': '\$80,000 - \$100,000',
    'applicationEmail': 'careers@company.com',
    'createdAt': '2024-01-15',
    'isActive': true,
    'applicationReceived': 12,
    'views': 156,
  },
  {
    'id': 2,
    'title': 'UI/UX Designer',
    'description': 'Looking for creative designer for mobile apps...',
    'requirements': 'Figma, Adobe XD, 2+ years experience',
    'jobType': 'Contract',
    'category': 'Design & Creative',
    'salary': '\$60,000 - \$80,000',
    'applicationEmail': 'design@company.com',
    'createdAt': '2024-01-10',
    'isActive': true,
    'applicationReceived': 8,
    'views': 89,
  },
  {
    'id': 3,
    'title': 'Sales Manager',
    'description': 'Manage sales team and drive revenue growth...',
    'requirements': '5+ years sales experience, leadership skills',
    'jobType': 'Full-Time',
    'category': 'Sales & Marketing',
    'salary': '\$90,000 - \$120,000',
    'applicationEmail': 'sales@company.com',
    'createdAt': '2024-01-05',
    'isActive': false,
    'applicationReceived': 5,
    'views': 45,
  },
];

class EmployerPostedJobsScreen extends StatefulWidget {
  final int? highlightJobId;
  const EmployerPostedJobsScreen({super.key, this.highlightJobId});

  @override
  State<EmployerPostedJobsScreen> createState() =>
      _EmployerPostedJobsScreenState();
}

class _EmployerPostedJobsScreenState extends State<EmployerPostedJobsScreen> {
  bool _isSelecting = false;
  Set<int> _selectedItems = {};
  int? _highlightedJobId;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    // Initialize highlighted job
    if (widget.highlightJobId != null) {
      _highlightedJobId = widget.highlightJobId;
      _startHighlightTimer();
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _startHighlightTimer() {
    // Remove highlight after 3 seconds
    _highlightTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _highlightedJobId = null;
        });
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelecting = !_isSelecting;
      if (!_isSelecting) {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(int id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }

      if (_selectedItems.isEmpty) {
        _isSelecting = false;
      }
    });
  }

  void _selectAllItems() {
    setState(() {
      if (_selectedItems.length == postedJobs.length) {
        _selectedItems.clear();
      } else {
        _selectedItems = Set.from(postedJobs.map((job) => job['id']));
      }
    });
  }

  void _deleteAllJobs() {
    if (postedJobs.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete All Jobs', textAlign: TextAlign.center),
        content: Text(
          'Are you sure you want to delete all ${postedJobs.length} jobs?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                postedJobs.clear();
                _selectedItems.clear();
                _isSelecting = false;
                _highlightedJobId = null;
              });
              Navigator.pop(context);
              SnackBarUtil.showSuccessMessage(context, 'All jobs deleted');
            },
            child: Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedJobs() {
    if (_selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Jobs', textAlign: TextAlign.center),
        content: Text(
          'Delete ${_selectedItems.length} job${_selectedItems.length > 1 ? 's' : ''}?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                postedJobs.removeWhere(
                  (job) => _selectedItems.contains(job['id']),
                );
                _selectedItems.clear();
                _isSelecting = false;

                // Clear highlight if highlighted job was deleted
                if (_highlightedJobId != null &&
                    postedJobs.indexWhere(
                          (job) => job['id'] == _highlightedJobId,
                        ) ==
                        -1) {
                  _highlightedJobId = null;
                }
              });
              Navigator.pop(context);
              SnackBarUtil.showSuccessMessage(context, 'Jobs deleted');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSingleJob(int jobId) {
    final job = postedJobs.firstWhere(
      (job) => job['id'] == jobId,
      orElse: () => {'title': 'this job'},
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Job', textAlign: TextAlign.center),
        content: Text(
          'Are you sure you want to delete "${job['title']}"?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                postedJobs.removeWhere((job) => job['id'] == jobId);

                // Remove from selection if selected
                if (_selectedItems.contains(jobId)) {
                  _selectedItems.remove(jobId);
                }

                // Clear highlight if this job was highlighted
                if (_highlightedJobId == jobId) {
                  _highlightedJobId = null;
                }

                // Exit selection mode if no items left
                if (_selectedItems.isEmpty) {
                  _isSelecting = false;
                }
              });
              Navigator.pop(context);
              SnackBarUtil.showSuccessMessage(context, 'Job deleted');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToAddJob() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmployerPostJobScreen()),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        // Update the list and highlight the new job
        setState(() {
          postedJobs.add(result);
          _highlightedJobId = result['id'];
          _startHighlightTimer();
        });
      }
    });
  }

  void _navigateToEditJob(Map<String, dynamic> job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployerPostJobScreen(
          existingJob: job,
          onJobSaved: (updatedJob) {
            setState(() {
              final index = postedJobs.indexWhere((j) => j['id'] == job['id']);
              if (index != -1) {
                postedJobs[index] = updatedJob;
              }
              _highlightedJobId = updatedJob['id'];
              _startHighlightTimer();
            });
          },
          onJobDeleted: (deletedJobId) {
            setState(() {
              postedJobs.removeWhere((j) => j['id'] == deletedJobId);

              if (_selectedItems.contains(deletedJobId)) {
                _selectedItems.remove(deletedJobId);
              }
              if (_highlightedJobId == deletedJobId) {
                _highlightedJobId = null;
              }
              if (_selectedItems.isEmpty) {
                _isSelecting = false;
              }
            });
          },
        ),
      ),
    );
  }

  void _toggleJobStatus(int id) {
    setState(() {
      final index = postedJobs.indexWhere((job) => job['id'] == id);
      if (index != -1) {
        postedJobs[index]['isActive'] = !postedJobs[index]['isActive'];
      }
    });
  }

  Future<void> _refreshData() async {
    SnackBarUtil.showSuccessMessage(context, 'Refreshed Successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(onRefresh: _refreshData, child: _buildJobList()),
    );
  }

  Widget _buildJobList() {
    if (postedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(
              'No Jobs Posted',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to post your first job',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateToAddJob,
              icon: Icon(Icons.add),
              label: Text('Post Your First Job'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (postedJobs.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isSelecting ? Colors.blue.shade50 : Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                if (_isSelecting)
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: _toggleSelectionMode,
                    tooltip: 'Cancel selection',
                  ),

                if (_isSelecting)
                  Expanded(
                    child: Text(
                      '${_selectedItems.length} selected',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                if (_isSelecting)
                  TextButton.icon(
                    icon: Icon(
                      _selectedItems.length == postedJobs.length
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    label: Text(
                      _selectedItems.length == postedJobs.length
                          ? 'Deselect all'
                          : 'Select all',
                    ),
                    onPressed: _selectAllItems,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),

                Spacer(),

                if (postedJobs.isNotEmpty)
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: (_isSelecting && _selectedItems.isNotEmpty)
                              ? Colors.red
                              : Colors.red,
                        ),
                        if (_selectedItems.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${_selectedItems.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      if (_isSelecting && _selectedItems.isNotEmpty) {
                        _deleteSelectedJobs();
                      } else {
                        _deleteAllJobs();
                      }
                    },
                    tooltip: _isSelecting && _selectedItems.isNotEmpty
                        ? 'Delete selected jobs'
                        : 'Delete all jobs',
                  ),
              ],
            ),
          ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: postedJobs.length,
            itemBuilder: (context, index) {
              final job = postedJobs[index];
              final isSelected = _selectedItems.contains(job['id']);
              final isHighlighted = _highlightedJobId == job['id'];

              return GestureDetector(
                onLongPress: () {
                  if (!_isSelecting) {
                    _toggleSelectionMode();
                  }
                  _toggleItemSelection(job['id']);
                },
                onTap: () {
                  if (_isSelecting) {
                    _toggleItemSelection(job['id']);
                  }
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: isHighlighted
                      ? Colors.yellow.shade50
                      : (isSelected ? Colors.blue.shade50 : Colors.white),
                  elevation: isHighlighted || isSelected ? 2 : 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isHighlighted
                          ? Colors.amber
                          : (isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent),
                      width: isHighlighted ? 3 : (isSelected ? 2 : 0),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selection checkbox
                            if (_isSelecting)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      _toggleItemSelection(job['id']),
                                  shape: CircleBorder(),
                                ),
                              ),

                            if (isHighlighted && !_isSelecting)
                              Container(
                                width: 4,
                                margin: EdgeInsets.only(
                                  top: 4,
                                  bottom: 4,
                                  right: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                            Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.only(top: 8, right: 8),
                              decoration: BoxDecoration(
                                color: job['isActive']
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          job['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : null,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: job['isActive']
                                              ? Colors.green.shade50
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: job['isActive']
                                                ? Colors.green.shade200
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          job['isActive']
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: job['isActive']
                                                ? Colors.green.shade800
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          job['salary'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.work_history,
                                        size: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          job['jobType'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            top: 6,
                            left: _isSelecting ? 48 : (isHighlighted ? 44 : 40),
                          ),
                          child: Text(
                            job['category'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${job['applicationReceived']} apps',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${job['views']} views',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (!_isSelecting) ...[
                              IconButton(
                                icon: Icon(Icons.edit, size: 16),
                                onPressed: () => _navigateToEditJob(job),
                                color: Colors.grey.shade600,
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                tooltip: 'Edit job',
                              ),

                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 16),
                                onPressed: () => _deleteSingleJob(job['id']),
                                color: Colors.red.shade400,
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                tooltip: 'Delete job',
                              ),

                              GestureDetector(
                                onTap: () => _toggleJobStatus(job['id']),
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    job['isActive']
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    size: 22,
                                    color: job['isActive']
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            top: 4,
                            left: _isSelecting ? 48 : (isHighlighted ? 44 : 40),
                          ),
                          child: Text(
                            'Posted: ${job['createdAt']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
