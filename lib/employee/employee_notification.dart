import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';

class EmployeeNotification extends StatefulWidget {
  const EmployeeNotification({super.key});

  @override
  State<EmployeeNotification> createState() => _EmployeeNotificationState();
}

class _EmployeeNotificationState extends State<EmployeeNotification> {
  bool _allRead = false;
  bool _isSelected = false;
  Set<int> _selectedItems = {};

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'New Application',
      'message': 'John applied for Developer role',
      'read': false,
      'time': '2 min ago',
    },
    {
      'id': 2,
      'title': 'Message',
      'message': 'Jane sent you a message',
      'read': false,
      'time': '10 min ago',
    },
    {
      'id': 3,
      'title': 'Job Posted',
      'message': 'Your job post is live now',
      'read': true,
      'time': '1 hour ago',
    },
    {
      'id': 4,
      'title': 'Reminder',
      'message': 'Interview scheduled for tomorrow',
      'read': false,
      'time': '2 hours ago',
    },
    {
      'id': 5,
      'title': 'Payment Received',
      'message': 'Payment of \$500 received',
      'read': true,
      'time': '3 hours ago',
    },
    {
      'id': 6,
      'title': 'Profile View',
      'message': 'Someone viewed your profile',
      'read': false,
      'time': '5 hours ago',
    },

    {
      'id': 7,
      'title': 'New Application',
      'message': 'John applied for Developer role',
      'read': false,
      'time': '2 min ago',
    },
    {
      'id': 8,
      'title': 'Message',
      'message': 'Jane sent you a message',
      'read': false,
      'time': '10 min ago',
    },
    {
      'id': 9,
      'title': 'Job Posted',
      'message': 'Your job post is live now',
      'read': true,
      'time': '1 hour ago',
    },
    {
      'id': 10,
      'title': 'Reminder',
      'message': 'Interview scheduled for tomorrow',
      'read': false,
      'time': '2 hours ago',
    },
    {
      'id': 11,
      'title': 'Payment Received',
      'message': 'Payment of \$500 received',
      'read': true,
      'time': '3 hours ago',
    },
    {
      'id': 12,
      'title': 'Profile View',
      'message': 'Someone viewed your profile',
      'read': false,
      'time': '5 hours ago',
    },
  ];

  void _toggleAllReadStatus() {
    setState(() {
      _allRead = !_allRead;
      for (var notification in _notifications) {
        notification['read'] = _allRead;
      }

      SnackBarUtil.showInfoMessage(
        context,
        _allRead
            ? 'All notifications marked as Read'
            : 'All notifications marked as Unread',
      );
    });
  }

  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
      _allRead = false;
    });
    SnackBarUtil.showInfoMessage(context, 'All notifications are Cleared');
  }

  void _markSingleAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;

      _allRead = _notifications.every((n) => n['read'] == true);
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelected = !_isSelected;
      if (!_isSelected) {
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
        _isSelected = false;
      }
    });
  }

  void _selectAllItems() {
    setState(() {
      if (_selectedItems.length == _notifications.length) {
        _selectedItems.clear();
      } else {
        _selectedItems = Set.from(_notifications.map((n) => n['id']));
      }
    });
  }

  void _deleteAllNotifications() {
    if (_notifications.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All notifications',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to clear all Notifications?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
                _selectedItems.clear();
                _isSelected = false;
                _allRead = false;
              });
              Navigator.pop(context);
              SnackBarUtil.showSuccessMessage(
                context,
                'All notifications cleared',
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedNotifications() {
    if (_selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Notifications',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Delete ${_selectedItems.length} selected notification${_selectedItems.length > 1 ? 's' : ''}?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.removeWhere(
                  (notification) => _selectedItems.contains(notification['id']),
                );
                _selectedItems.clear();
                _isSelected = false;
                _allRead =
                    _notifications.isNotEmpty &&
                    _notifications.every((n) => n['read'] == true);
              });
              Navigator.pop(context);
              SnackBarUtil.showSuccessMessage(
                context,
                '${_selectedItems.length} notification${_selectedItems.length > 1 ? 's' : ''} deleted',
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelected
            ? Text('${_selectedItems.length} selected')
            : Text('Notifications'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: _isSelected
            ? IconButton(
                onPressed: _toggleSelectionMode,
                icon: Icon(Icons.close),
              )
            : null,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
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
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                if (_isSelected && _selectedItems.isNotEmpty) {
                  _deleteSelectedNotifications();
                } else {
                  _deleteAllNotifications();
                }
              },
              tooltip: _isSelected && _selectedItems.isNotEmpty
                  ? 'Delete selected'
                  : 'Delete all',
            ),

          // Select all notifications in selection mode
          if (_isSelected)
            IconButton(
              icon: Icon(
                _selectedItems.length == _notifications.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              onPressed: _selectAllItems,
              tooltip: _selectedItems.length == _notifications.length
                  ? 'Deselect all'
                  : 'Select all',
            ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'select_multiple') {
                _toggleSelectionMode();
              }
              if (value == 'toggle_read_status') {
                _toggleAllReadStatus();
              }
              if (value == 'clear_all_notifications') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (BuildContext context) => [
              if (!_isSelected)
                PopupMenuItem(
                  value: 'select_multiple',
                  enabled: _notifications.isNotEmpty,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_box_outlined,
                        size: 20,
                        color: _notifications.isNotEmpty
                            ? null
                            : Colors.grey.shade400,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select multiple',
                        style: TextStyle(
                          color: _notifications.isNotEmpty
                              ? null
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'toggle_read_status',
                enabled: _notifications.isNotEmpty,
                child: Row(
                  children: [
                    Icon(
                      _allRead
                          ? Icons.mark_email_unread
                          : Icons.mark_email_read,
                      color: _notifications.isNotEmpty
                          ? null
                          : Colors.grey.shade400,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _allRead ? 'Mark All as Unread' : 'Mark All as Read',
                      style: TextStyle(
                        color: _notifications.isNotEmpty
                            ? null
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _buildNotificationList(),
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    SnackBarUtil.showSuccessMessage(context, 'Refresh Successfully');
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'No Notifications',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isSelected = _selectedItems.contains(notification['id']);

        return GestureDetector(
          onLongPress: () {
            if (!_isSelected) {
              _toggleSelectionMode();
            }
            _toggleItemSelection(notification['id']);
          },
          onTap: () {
            if (_isSelected) {
              _toggleItemSelection(notification['id']);
            } else {
              if (!notification['read']) {
                _markSingleAsRead(index);
              }
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: isSelected
                ? Colors.blue.shade50
                : (notification['read'] ? Colors.white : Colors.blue.shade50),
            elevation: isSelected ? 2 : 1,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection checkbox
                  if (_isSelected)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) =>
                          _toggleItemSelection(notification['id']),
                      shape: CircleBorder(),
                    ),

                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: notification['read']
                          ? Colors.transparent
                          : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Icon
                  Icon(
                    Icons.notifications,
                    color: notification['read']
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                style: TextStyle(
                                  fontWeight: notification['read']
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                            ),
                            Text(
                              notification['time'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification['message'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Mark as read button for unread notifications (when not in selection mode)
                        if (!notification['read'] && !_isSelected)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: Icon(Icons.check_circle_outline, size: 16),
                              label: Text(
                                'Mark as read',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () => _markSingleAsRead(index),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
