import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';
import 'package:local_job_finder/employee/employee_dashboard.dart';

List<Map<String, dynamic>> get savedJobs {
  return jobListings.where((job) => job['isSaved'] == true).toList();
}

List<Map<String, dynamic>> get appliedJobs {
  return jobListings.where((job) => job['isApplied'] == true).toList();
}

class EmployeeJobsScreen extends StatefulWidget {
  const EmployeeJobsScreen({super.key});

  @override
  State<EmployeeJobsScreen> createState() => _EmployeeJobsScreenState();
}

class _EmployeeJobsScreenState extends State<EmployeeJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSavedJobs = [];
  List<Map<String, dynamic>> _filteredAppliedJobs = [];
  bool _showSavedJobs = true;
  bool _isSelecting = false;
  final Set<int> _selectedSavedItems = {};
  final Set<int> _selectedAppliedItems = {};

  @override
  void initState() {
    super.initState();
    _refreshJobsList();
    _searchController.addListener(() {
      _filterJobs();
    });
  }

  void _refreshJobsList() {
    setState(() {
      _filteredSavedJobs = savedJobs;
      _filteredAppliedJobs = appliedJobs;
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
        _filteredSavedJobs = savedJobs;
        _filteredAppliedJobs = appliedJobs;
      } else {
        _filteredSavedJobs = savedJobs.where((job) {
          return job['title'].toLowerCase().contains(query) ||
              job['company'].toLowerCase().contains(query) ||
              job['location'].toLowerCase().contains(query);
        }).toList();

        _filteredAppliedJobs = appliedJobs.where((job) {
          return job['title'].toLowerCase().contains(query) ||
              job['company'].toLowerCase().contains(query) ||
              job['location'].toLowerCase().contains(query) ||
              (job['applicationStatus'] as String).toLowerCase().contains(
                query,
              );
        }).toList();
      }
    });
  }

  Future<void> _refreshJobs() async {
    await Future.delayed(Duration(seconds: 1));
    _refreshJobsList();
    _searchController.clear();
    SnackBarUtil.showSuccessMessage(context, 'Jobs refreshed');
  }

  void _updateFilteredLists() {
    setState(() {
      _filteredSavedJobs = savedJobs;
      _filteredAppliedJobs = appliedJobs;

      if (_searchController.text.isNotEmpty) {
        _filterJobs();
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelecting = !_isSelecting;
      if (!_isSelecting) {
        _selectedSavedItems.clear();
        _selectedAppliedItems.clear();
      }
    });
  }

  void _toggleSavedItemSelection(int id) {
    setState(() {
      if (_selectedSavedItems.contains(id)) {
        _selectedSavedItems.remove(id);
      } else {
        _selectedSavedItems.add(id);
      }

      if (_selectedSavedItems.isEmpty && _selectedAppliedItems.isEmpty) {
        _isSelecting = false;
      }
    });
  }

  void _toggleAppliedItemSelection(int id) {
    setState(() {
      if (_selectedAppliedItems.contains(id)) {
        _selectedAppliedItems.remove(id);
      } else {
        _selectedAppliedItems.add(id);
      }

      if (_selectedSavedItems.isEmpty && _selectedAppliedItems.isEmpty) {
        _isSelecting = false;
      }
    });
  }

  void _selectAllItems() {
    setState(() {
      if (_showSavedJobs) {
        if (_selectedSavedItems.length == _filteredSavedJobs.length) {
          _selectedSavedItems.clear();
        } else {
          _selectedSavedItems.clear();
          _selectedSavedItems.addAll(
            _filteredSavedJobs.map<int>((job) => job['id'] as int).toSet(),
          );
        }
      } else {
        if (_selectedAppliedItems.length == _filteredAppliedJobs.length) {
          _selectedAppliedItems.clear();
        } else {
          _selectedAppliedItems.clear();
          _selectedAppliedItems.addAll(
            _filteredAppliedJobs.map<int>((job) => job['id'] as int).toSet(),
          );
        }
      }
    });
  }

  void _deleteSelectedJobs() {
    final selectedItems = _showSavedJobs
        ? _selectedSavedItems.length
        : _selectedAppliedItems.length;

    if (selectedItems == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected', textAlign: TextAlign.center),
        content: Text(
          'Delete $selectedItems ${_showSavedJobs ? 'saved' : 'applied'} job${selectedItems > 1 ? 's' : ''}?',
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
                if (_showSavedJobs) {
                  for (var id in _selectedSavedItems) {
                    updateJobStatus(id, isSaved: false);
                  }
                  _selectedSavedItems.clear();
                } else {
                  for (var id in _selectedAppliedItems) {
                    updateJobStatus(id, isApplied: false);
                  }
                  _selectedAppliedItems.clear();
                }
                _isSelecting = false;
              });
              Navigator.pop(context);
              SnackBarUtil.showSuccessMessage(context, 'Jobs removed');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSingleJob(int jobId, bool isSavedJob) {
    final jobList = isSavedJob ? savedJobs : appliedJobs;
    final job = jobList.firstWhere(
      (job) => (job['id'] as int) == jobId,
      orElse: () => {'title': 'this job'},
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isSavedJob ? 'Remove Saved Job' : 'Withdraw Application',
          textAlign: TextAlign.center,
        ),
        content: Text(
          isSavedJob
              ? 'Remove "${job['title']}" from saved jobs?'
              : 'Withdraw application for "${job['title']}"?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              updateJobStatus(
                jobId,
                isSaved: isSavedJob ? false : null,
                isApplied: !isSavedJob ? false : null,
                onUpdate: () {
                  setState(() {
                    _filteredSavedJobs = savedJobs;
                    _filteredAppliedJobs = appliedJobs;

                    if (_searchController.text.isNotEmpty) {
                      _filterJobs();
                    }
                  });
                },
              );
              Navigator.pop(context);
              SnackBarUtil.showSuccessMessage(
                context,
                isSavedJob ? 'Job removed from saved' : 'Application withdrawn',
              );
            },
            child: Text(
              isSavedJob ? 'Remove' : 'Withdraw',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(Map<String, dynamic> job, bool isSavedJob) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final savedDate = job['savedDate'] ?? 'Recently saved';
            final appliedDate = job['appliedDate'] ?? 'Not applied yet';
            final applicationStatus = job['applicationStatus'] ?? 'Not applied';

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
                    ],
                  ),
                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            isSavedJob ? 'Saved Date' : 'Applied Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            isSavedJob ? savedDate : appliedDate,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isSavedJob && job['applicationStatus'] != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(applicationStatus),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                applicationStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.delete_outline),
                          label: Text(isSavedJob ? 'Remove' : 'Withdraw'),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteSingleJob(job['id'] as int, isSavedJob);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      if (isSavedJob)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.send),
                            label: Text('Apply Now'),
                            onPressed: () {
                              Navigator.pop(context);
                              updateJobStatus(
                                job['id'] as int,
                                isApplied: true,
                                applicationStatus: 'Submitted',
                                appliedDate: DateTime.now().toString().split(
                                  ' ',
                                )[0],
                                onUpdate: () {},
                              );
                              SnackBarUtil.showSuccessMessage(
                                context,
                                'Application submitted!',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _updateFilteredLists();
    });
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'under review':
        return Colors.orange;
      case 'interview scheduled':
        return Colors.purple;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildJobCard(Map<String, dynamic> job, bool isSavedJob) {
    final jobId = job['id'] as int;
    final isSelected = isSavedJob
        ? _selectedSavedItems.contains(jobId)
        : _selectedAppliedItems.contains(jobId);

    final isApplied = job['isApplied'] == true;
    final savedDate = job['savedDate']?.toString() ?? 'Recently saved';
    final appliedDate = job['appliedDate']?.toString() ?? '';
    final applicationStatus = job['applicationStatus']?.toString() ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showJobDetails(job, isSavedJob),
        onLongPress: () {
          if (!_isSelecting) {
            _toggleSelectionMode();
          }
          if (isSavedJob) {
            _toggleSavedItemSelection(jobId);
          } else {
            _toggleAppliedItemSelection(jobId);
          }
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSelecting)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    if (isSavedJob) {
                      _toggleSavedItemSelection(jobId);
                    } else {
                      _toggleAppliedItemSelection(jobId);
                    }
                  },
                  shape: CircleBorder(),
                ),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isApplied
                      ? Colors.green.shade50
                      : (isSavedJob
                            ? Colors.blue.shade50
                            : Colors.grey.shade50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApplied
                      ? Icons.check_circle
                      : (isSavedJob ? Icons.bookmark : Icons.send),
                  color: isApplied
                      ? Colors.green
                      : (isSavedJob ? Colors.blue : Colors.grey),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      job['company'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job['location'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
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
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job['salary'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
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
                            job['type'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),

                        if (isSavedJob || job['isSaved'] == true)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Saved: $savedDate',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),

                        if (isApplied && applicationStatus.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(applicationStatus),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              applicationStatus,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        if (isApplied && appliedDate.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Applied: $appliedDate',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.purple.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentJobs = _showSavedJobs
        ? _filteredSavedJobs
        : _filteredAppliedJobs;
    final selectedCount = _showSavedJobs
        ? _selectedSavedItems.length
        : _selectedAppliedItems.length;
    final totalCount = currentJobs.length;
    final hasJobs = currentJobs.isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshJobs,
        child: Column(
          children: [
            // Search bar
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
                    hintText: 'Search saved/applied jobs...',
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showSavedJobs
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        foregroundColor: _showSavedJobs
                            ? Colors.white
                            : Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showSavedJobs = true;
                          if (_isSelecting) {
                            _selectedAppliedItems.clear();
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark, size: 18),
                          SizedBox(width: 6),
                          Text('Saved (${_filteredSavedJobs.length})'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_showSavedJobs
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        foregroundColor: !_showSavedJobs
                            ? Colors.white
                            : Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showSavedJobs = false;
                          if (_isSelecting) {
                            _selectedSavedItems.clear();
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 18),
                          SizedBox(width: 6),
                          Text('Applied (${_filteredAppliedJobs.length})'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isSelecting && hasJobs)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      onPressed: _toggleSelectionMode,
                      tooltip: 'Cancel selection',
                    ),
                    Expanded(
                      child: Text(
                        '$selectedCount selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(
                        selectedCount == totalCount
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                      ),
                      label: Text(
                        selectedCount == totalCount
                            ? 'Deselect all'
                            : 'Select all',
                      ),
                      onPressed: _selectAllItems,
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: Stack(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          if (selectedCount > 0)
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
                                  '$selectedCount',
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
                      onPressed: _deleteSelectedJobs,
                      tooltip: 'Delete selected',
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Text(
                    '${currentJobs.length} ${_showSavedJobs ? 'saved' : 'applied'} jobs',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  if (!_isSelecting && hasJobs)
                    IconButton(
                      icon: Icon(Icons.select_all, size: 20),
                      onPressed: _toggleSelectionMode,
                      tooltip: 'Select multiple',
                      color: Colors.grey.shade600,
                    ),
                ],
              ),
            ),

            Expanded(
              child: !hasJobs
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showSavedJobs
                                ? Icons.bookmark_border
                                : Icons.send_and_archive,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _showSavedJobs
                                ? 'No saved jobs'
                                : 'No applied jobs',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _showSavedJobs
                                ? 'Save jobs to view them here'
                                : 'Apply to jobs to track them here',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: currentJobs.length,
                      itemBuilder: (context, index) {
                        final job = currentJobs[index];
                        return _buildJobCard(job, _showSavedJobs);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
