import 'package:flutter/material.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final Map<String, dynamic> _profileData = {};
  final bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _locationError;
  String? _skillsError;

  bool _nameValidated = false;
  bool _phoneValidated = false;
  bool _locationValidated = false;
  bool _skillsValidated = false;

  @override
  void initState() {
    super.initState();
  }

  void _validateName() {
    if (!_nameValidated) return;
    final value = _nameController.text.trim();
    if (value.isEmpty) {
      _nameError = 'Please enter your full name';
    } else if (value.length < 2) {
      _nameError = 'Name must be at least 2 characters long';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      _nameError = 'Name can only contain letters and spaces';
    } else {
      _nameError = null;
    }
  }

  void _validatePhone() {
    if (!_phoneValidated) return;
    final value = _phoneController.text.trim();
    if (value.isEmpty) {
      _phoneError = 'Please enter your phone number';
    } else if (!RegExp(r'^[0-9+\-\s()]{10,15}$').hasMatch(value)) {
      _phoneError = 'Please enter a valid phone number';
    } else {
      _phoneError = null;
    }
  }

  void _validateLocation() {
    if (!_locationValidated) return;
    final value = _locationController.text.trim();
    if (value.isEmpty) {
      _locationError = 'Please enter your location';
    } else if (value.length < 2) {
      _locationError = 'Location must be at least 2 characters long';
    } else {
      _locationError = null;
    }
  }

  void _validateSkills() {
    if (!_skillsValidated) return;
    final value = _skillsController.text.trim();
    if (value.isEmpty) {
      _skillsError = 'Please enter at least one skill';
    } else if (value.split(',').isEmpty) {
      _skillsError = 'Please enter at least one skill (comma separated)';
    } else {
      _skillsError = null;
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;

      // Reset controllers to original values
      _nameController.text = _profileData['fullName'] ?? '';
      _phoneController.text = _profileData['phone'] ?? '';
      _locationController.text = _profileData['location'] ?? '';
      _skillsController.text = _profileData['skills']?.join(', ') ?? '';

      // Reset validation states and errors
      _nameValidated = false;
      _phoneValidated = false;
      _locationValidated = false;
      _skillsValidated = false;
      _nameError = null;
      _phoneError = null;
      _locationError = null;
      _skillsError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _isEditing ? _buildEditForm() : _buildProfileInfo(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    String getAvatarText() {
      final name = _profileData['fullName']?.toString().trim();
      if (name != null && name.isNotEmpty) {
        return name.substring(0, 1).toUpperCase();
      }
      final email = _profileData['email']?.toString().trim();
      if (email != null && email.isNotEmpty) {
        return email.substring(0, 1).toUpperCase();
      }
      return 'U';
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            getAvatarText(),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profileData['fullName'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profileData['email'] ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: _profileData['emailVerified'] == true
                        ? Colors.green
                        : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _profileData['emailVerified'] == true
                        ? 'Verified'
                        : 'Not Verified',
                    style: TextStyle(
                      color: _profileData['emailVerified'] == true
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem(
          'Full Name',
          _profileData['fullName'] ?? 'Not provided',
          Icons.person,
        ),
        _buildInfoItem(
          'Phone',
          _profileData['phone'] ?? 'Not provided',
          Icons.phone,
        ),
        _buildInfoItem(
          'Location',
          _profileData['location'] ?? 'Not provided',
          Icons.location_on,
        ),
        _buildInfoItem(
          'Skills',
          _profileData['skills']?.join(', ') ?? 'Not provided',
          Icons.work,
        ),
        _buildInfoItem(
          'Member since',
          _formatTimestamp(_profileData['createdAt']),
          Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildEditField(
          'Full Name *',
          _nameController,
          Icons.person,
          _nameError,
          _nameValidated,
          onChanged: (value) {
            if (_nameValidated) _validateName();
          },
          onTap: () {
            if (!_nameValidated) {
              setState(() => _nameValidated = true);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildEditField(
          'Phone Number *',
          _phoneController,
          Icons.phone,
          _phoneError,
          _phoneValidated,
          onChanged: (value) {
            if (_phoneValidated) _validatePhone();
          },
          onTap: () {
            if (!_phoneValidated) {
              setState(() => _phoneValidated = true);
            }
          },
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildEditField(
          'Location *',
          _locationController,
          Icons.location_on,
          _locationError,
          _locationValidated,
          onChanged: (value) {
            if (_locationValidated) _validateLocation();
          },
          onTap: () {
            if (!_locationValidated) {
              setState(() => _locationValidated = true);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildEditField(
          'Skills (comma separated) *',
          _skillsController,
          Icons.work,
          _skillsError,
          _skillsValidated,
          onChanged: (value) {
            if (_skillsValidated) _validateSkills();
          },
          onTap: () {
            if (!_skillsValidated) {
              setState(() => _skillsValidated = true);
            }
          },
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
    String? error,
    bool validated, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    final hasError = error != null && validated;
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? Colors.red : primaryColor,
              ),
            ),
            errorText: validated ? error : null,
            errorMaxLines: 2,
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_isEditing) {
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelEditing,
              child: const Text('Cancel'),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
