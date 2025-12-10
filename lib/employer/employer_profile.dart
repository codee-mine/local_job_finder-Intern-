import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final Map<String, dynamic> _profileData = {};
  final bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _locationError;
  String? _websiteError;
  String? _descriptionError;

  bool _nameValidated = false;
  bool _phoneValidated = false;
  bool _locationValidated = false;
  bool _websiteValidated = false;
  bool _descriptionValidated = false;

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

  void _validatewebsite() {
    if (!_websiteValidated) return;
    final value = _websiteController.text.trim();
    final urlPattern = r'^(https?:\/\/)?[\w\-]+(\.[\w\-]+)+[/#?]?.*$';
    final regExp = RegExp(urlPattern);
    if (value.isEmpty) {
      _websiteError = null;
      return;
    } else if (!regExp.hasMatch(value)) {
      _websiteError = 'Please enter a valid website URL';
    } else {
      _websiteError = null;
    }
  }

  void _validateDescription() {
    if (!_locationValidated) return;
    final value = _descriptionController.text.trim();
    if (value.isEmpty) {
      _descriptionError = 'Please enter about your Company';
    } else if (value.length < 2) {
      _descriptionError = 'Description must be at least 100 characters long';
    } else {
      _descriptionError = null;
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;

      // Reset controllers to original values
      _nameController.text = _profileData['fullName'] ?? '';
      _phoneController.text = _profileData['phone'] ?? '';
      _locationController.text = _profileData['location'] ?? '';
      _websiteController.text = _profileData['website'] ?? '';
      _descriptionController.text = _profileData['description'] ?? '';

      // Reset validation states and errors
      _nameValidated = false;
      _phoneValidated = false;
      _locationValidated = false;
      _websiteValidated = false;
      _descriptionValidated = false;
      _nameError = null;
      _phoneError = null;
      _locationError = null;
      _websiteError = null;
      _descriptionError = null;
    });
  }

  bool _validateAllFields() {
    setState(() {
      _nameValidated = true;
      _phoneValidated = true;
      _locationValidated = true;
      _websiteValidated = true;
      _descriptionValidated = true;
    });

    _validateName();
    _validatePhone();
    _validateLocation();
    _validatewebsite();
    _validateDescription();

    return _nameError == null &&
        _phoneError == null &&
        _locationError == null &&
        _websiteError == null &&
        _descriptionError == null;
  }

  void _saveEditProfileData() {
    if (!_validateAllFields()) {
      SnackBarUtil.showErrorMessage(context, 'Please fill all required fields');
      return;
    }

    try {
      SnackBarUtil.showSuccessMessage(context, 'Updated');
    } catch (e) {
      SnackBarUtil.showErrorMessage(context, 'Update Failed');
    }
  }

  Future<void> _refreshData() async {
    SnackBarUtil.showInfoMessage(context, 'Refreshed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
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
          child: Row(
            children: [
              Column(
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
                    'Member Since: ${_formatTimestamp(_profileData['createdAt'])}',
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
              Spacer(),
              TextButton(
                onPressed: () {
                  _showDeleteAccountDialog(context);
                },
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final FocusNode passwordFocus = FocusNode();
    bool isError = false;
    String? passwordError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void validatePassword(String value) {
              setDialogState(() {
                if (value.isEmpty) {
                  passwordError = 'Password is required';
                  isError = true;
                } else if (value.length < 6) {
                  passwordError = 'Password must be at least 6 characters';
                  isError = true;
                } else {
                  passwordError = null;
                  isError = false;
                }
              });
            }

            void deleteAccount() {
              final password = passwordController.text.trim();

              if (password.isEmpty) {
                setDialogState(() {
                  passwordError = 'Password is required';
                  isError = true;
                  passwordFocus.requestFocus();
                });
                return;
              }

              Navigator.pop(dialogContext);
              SnackBarUtil.showSuccessMessage(
                context,
                'Account deletion request submitted',
              );
            }

            return AlertDialog(
              title: Text(
                'Delete Account?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to delete your account? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm your password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: passwordController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                passwordController.clear();
                                validatePassword('');
                              },
                              icon: Icon(Icons.clear),
                            )
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      errorText: passwordError,
                    ),
                    onChanged: (value) {
                      validatePassword(value);
                    },
                    onFieldSubmitted: (value) {
                      if (!isError) {
                        deleteAccount();
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 16,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All your data will be permanently deleted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    passwordController.dispose();
                    passwordFocus.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: isError ? null : deleteAccount,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    disabledForegroundColor: Colors.red.withValues(alpha: 0.5),
                  ),
                  child: Text('Delete Account'),
                ),
              ],
            );
          },
        );
      },
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
          'website',
          _profileData['website'] ?? 'Not provided',
          Icons.public,
        ),
        _buildInfoItem(
          'Description',
          _profileData['description'] ?? 'Not provided',
          Icons.description,
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
          'Website URL',
          _websiteController,
          Icons.public,
          _websiteError,
          _websiteValidated,
          onChanged: (value) {
            if (_websiteValidated) _validatewebsite();
          },
          onTap: () {
            if (!_websiteValidated) {
              setState(() => _websiteValidated = true);
            }
          },
        ),

        const SizedBox(height: 16),
        _buildEditField(
          'Description',
          _descriptionController,
          Icons.description,
          _descriptionError,
          _descriptionValidated,
          onChanged: (value) {
            if (_descriptionValidated) _validateDescription();
          },
          onTap: () {
            if (!_descriptionValidated) {
              setState(() => _descriptionValidated = true);
            }
          },
          maxLines: 5,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
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
                _saveEditProfileData();
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
