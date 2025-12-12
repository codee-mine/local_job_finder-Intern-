import 'package:flutter/material.dart';
import 'package:local_job_finder/auth/api_service.dart';
import 'package:local_job_finder/auth/auth_service.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';
import 'package:image_picker/image_picker.dart';

class EmployerProfileScreen extends StatefulWidget {
  final EmployerUserProfile? userProfile;
  final VoidCallback? onProfileUpdated;
  const EmployerProfileScreen({
    super.key,
    this.userProfile,
    this.onProfileUpdated,
  });

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  EmployerUserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyWebsiteController =
      TextEditingController();
  final TextEditingController _companySizeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _companyNameError;
  String? _companyWebsiteError;
  String? _companySizeError;

  bool _nameValidated = false;
  bool _phoneValidated = false;
  bool _companyNameValidated = false;
  bool _companyWebsiteValidated = false;
  bool _companySizeValidated = false;

  @override
  void initState() {
    super.initState();
    if (widget.userProfile != null) {
      _userProfile = widget.userProfile;
      _populateFormFields();
      _isLoading = false;
    } else {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getUserProfile();

      if (response['statusCode'] == 200) {
        final userData = response['body'];
        if (userData is Map<String, dynamic>) {
          setState(() {
            _userProfile = EmployerUserProfile.fromJson(userData);
            _populateFormFields();
          });
        } else {
          SnackBarUtil.showErrorMessage(context, 'Invalid profile data format');
        }
      } else {
        final errorMessage =
            response['body']['message'] ?? 'Failed to load profile';
        SnackBarUtil.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      SnackBarUtil.showErrorMessage(
        context,
        'Error loading profile: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormFields() {
    if (_userProfile == null) return;

    _nameController.text = _userProfile!.name;
    _emailController.text = _userProfile!.email;
    _phoneController.text = _userProfile!.phone ?? '';
    _companyNameController.text = _userProfile!.companyName ?? '';
    _companyWebsiteController.text = _userProfile!.companyWebsite ?? '';
    _companySizeController.text = _userProfile!.companySize ?? '';
    _bioController.text = _userProfile!.bio ?? '';
    _addressController.text = _userProfile!.address ?? '';
  }

  void _validateName() {
    if (!_nameValidated) return;
    final value = _nameController.text.trim();
    if (value.isEmpty) {
      _nameError = 'Please enter your name';
    } else if (value.length < 2) {
      _nameError = 'Name must be at least 2 characters long';
    } else {
      _nameError = null;
    }
  }

  void _validatePhone() {
    if (!_phoneValidated) return;
    final value = _phoneController.text.trim();
    if (value.isEmpty) {
      _phoneError = null;
      return;
    } else if (!RegExp(r'^[0-9+\-\s()]{10,15}$').hasMatch(value)) {
      _phoneError = 'Please enter a valid phone number';
    } else {
      _phoneError = null;
    }
  }

  void _validateCompanyName() {
    if (!_companyNameValidated) return;
    final value = _companyNameController.text.trim();
    if (value.isEmpty) {
      _companyNameError = 'Please enter company name';
    } else if (value.length < 2) {
      _companyNameError = 'Company name must be at least 2 characters long';
    } else {
      _companyNameError = null;
    }
  }

  void _validateCompanyWebsite() {
    if (!_companyWebsiteValidated) return;
    final value = _companyWebsiteController.text.trim();
    if (value.isEmpty) {
      _companyWebsiteError = null;
      return;
    }

    final urlPattern =
        r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\- .\/?%&=]*)?$';
    final regExp = RegExp(urlPattern, caseSensitive: false);

    if (!regExp.hasMatch(value)) {
      _companyWebsiteError = 'Please enter a valid website URL';
    } else {
      _companyWebsiteError = null;
    }
  }

  void _validateCompanySize() {
    if (!_companySizeValidated) return;
    final value = _companySizeController.text.trim();
    if (value.isEmpty) {
      _companySizeError = null;
      return;
    }
    _companySizeError = null;
  }

  bool _validateAllFields() {
    setState(() {
      _nameValidated = true;
      _phoneValidated = true;
      _companyNameValidated = true;
      _companyWebsiteValidated = true;
      _companySizeValidated = true;
    });

    _validateName();
    _validatePhone();
    _validateCompanyName();
    _validateCompanyWebsite();
    _validateCompanySize();

    return _nameError == null &&
        _phoneError == null &&
        _companyNameError == null &&
        _companyWebsiteError == null &&
        _companySizeError == null;
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _populateFormFields();

      // Reset validation states
      _nameValidated = false;
      _phoneValidated = false;
      _companyNameValidated = false;
      _companyWebsiteValidated = false;
      _companySizeValidated = false;
      _nameError = null;
      _phoneError = null;
      _companyNameError = null;
      _companyWebsiteError = null;
      _companySizeError = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_validateAllFields()) {
      SnackBarUtil.showErrorMessage(context, 'Please fix all errors');
      return;
    }

    final fullAddress = [
      if (_addressController.text.isNotEmpty) _addressController.text,
      if (_cityController.text.isNotEmpty) _cityController.text,
      if (_stateController.text.isNotEmpty) _stateController.text,
      if (_countryController.text.isNotEmpty) _countryController.text,
      if (_zipCodeController.text.isNotEmpty) _zipCodeController.text,
    ];

    final companyLocation = fullAddress.join(', ');

    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'company_name': _companyNameController.text.trim(),
      'company_website': _companyWebsiteController.text.trim(),
      'company_size': _companySizeController.text.trim(),
      'bio': _bioController.text.trim(),
      'address': _addressController.text.trim(),
      'company_location': companyLocation,
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'country': _countryController.text.trim(),
      'zip_code': _zipCodeController.text.trim(),
    };

    try {
      final response = await _apiService.updateUserProfile(updatedData);

      if (response['statusCode'] == 200) {
        SnackBarUtil.showSuccessMessage(
          context,
          'Profile updated successfully',
        );
        setState(() {
          _isEditing = false;
        });
        await _loadProfileData();
        if (widget.onProfileUpdated != null) {
          widget.onProfileUpdated!();
        }
      } else {
        final error = response['body']['message'] ?? 'Failed to update profile';
        SnackBarUtil.showErrorMessage(context, error);
      }
    } catch (e) {
      SnackBarUtil.showErrorMessage(
        context,
        'Error updating profile: ${e.toString()}',
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadProfileData();
    SnackBarUtil.showInfoMessage(context, 'Profile refreshed');
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      SnackBarUtil.showInfoMessage(context, 'Image upload feature coming soon');
    }
  }

  void _showChangePasswordDialog() {
    showDialog(context: context, builder: (context) => ChangePasswordDialog());
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteAccountDialog(
          onAccountDeleted: () async {
            await _authService.deleteAccount();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );

            SnackBarUtil.showSuccessMessage(
              context,
              'Account deleted Successfully',
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
      final name = _userProfile?.name;
      if (name != null && name.isNotEmpty) {
        return name.substring(0, 1).toUpperCase();
      }
      final email = _userProfile?.email;
      if (email != null && email.isNotEmpty) {
        return email.substring(0, 1).toUpperCase();
      }
      return 'E';
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _uploadProfileImage,
          child: CircleAvatar(
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
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile?.companyName ??
                          _userProfile?.name ??
                          'No Name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (_userProfile?.createdAt != null) ...[
                      Text(
                        'Member Since: ${_formatDate(_userProfile!.createdAt!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      _userProfile?.email ?? '',
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: const Text('Employer'),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showDeleteConfirmation,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Logout',
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
          'Contact Person',
          _userProfile?.name ?? 'Not provided',
          Icons.person,
        ),
        _buildInfoItem(
          'Email',
          _userProfile?.email ?? 'Not provided',
          Icons.email,
        ),
        _buildInfoItem(
          'Phone',
          _userProfile?.phone ?? 'Not provided',
          Icons.phone,
        ),
        _buildInfoItem(
          'Company Name',
          _userProfile?.companyName ?? 'Not provided',
          Icons.business,
        ),
        _buildInfoItem(
          'Company Location',
          _userProfile?.companyLocation ?? 'Not provided',
          Icons.business,
        ),
        _buildInfoItem(
          'Website',
          _userProfile?.companyWebsite ?? 'Not provided',
          Icons.public,
        ),
        _buildInfoItem(
          'Company Size',
          _userProfile?.companySize ?? 'Not provided',
          Icons.people,
        ),
        _buildInfoItem(
          'Address',
          _userProfile?.address ?? 'Not provided',
          Icons.location_on,
        ),

        if (_userProfile?.bio != null && _userProfile!.bio!.isNotEmpty)
          _buildInfoItem('Company Bio', _userProfile!.bio!, Icons.description),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildEditField(
          'Contact Person *',
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
        const SizedBox(height: 12),
        _buildEditField(
          'Email',
          _emailController,
          Icons.email,
          null,
          false,
          enabled: false,
        ),
        const SizedBox(height: 12),
        _buildEditField(
          'Phone',
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
        const SizedBox(height: 12),
        _buildEditField(
          'Company Name *',
          _companyNameController,
          Icons.business,
          _companyNameError,
          _companyNameValidated,
          onChanged: (value) {
            if (_companyNameValidated) _validateCompanyName();
          },
          onTap: () {
            if (!_companyNameValidated) {
              setState(() => _companyNameValidated = true);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildEditField(
          'Website',
          _companyWebsiteController,
          Icons.public,
          _companyWebsiteError,
          _companyWebsiteValidated,
          onChanged: (value) {
            if (_companyWebsiteValidated) _validateCompanyWebsite();
          },
          onTap: () {
            if (!_companyWebsiteValidated) {
              setState(() => _companyWebsiteValidated = true);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildEditField(
          'Company Size',
          _companySizeController,
          Icons.people,
          _companySizeError,
          _companySizeValidated,
          onChanged: (value) {
            if (_companySizeValidated) _validateCompanySize();
          },
          onTap: () {
            if (!_companySizeValidated) {
              setState(() => _companySizeValidated = true);
            }
          },
          hintText: 'e.g., 1-10, 11-50, 51-200, 201-500, 500+',
        ),
        const SizedBox(height: 12),
        _buildEditField(
          'Address',
          _addressController,
          Icons.location_on,
          null,
          false,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildEditField(
          'City',
          _cityController,
          Icons.location_city,
          null,
          false,
        ),
        const SizedBox(height: 12),
        _buildEditField('State', _stateController, Icons.map, null, false),
        const SizedBox(height: 12),
        _buildEditField('Country', _countryController, Icons.flag, null, false),
        const SizedBox(height: 12),
        _buildEditField(
          'ZIP Code',
          _zipCodeController,
          Icons.numbers,
          null,
          false,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildEditField(
          'Company Bio',
          _bioController,
          Icons.description,
          null,
          false,
          maxLines: 4,
          hintText: 'Tell us about your company...',
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
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
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
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hintText,
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
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                    },
                    icon: Icon(Icons.clear),
                  )
                : null,
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
            hintText: hintText,
            filled: !enabled,
            fillColor: !enabled ? Colors.grey.shade100 : null,
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Edit Profile',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _showChangePasswordDialog,
          child: const Text('Change Password'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _companyWebsiteController.dispose();
    _companySizeController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final ApiService _apiService = ApiService();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrent = !_obscureCurrent;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      SnackBarUtil.showErrorMessage(context, 'Please fill all fields');
      return;
    }

    if (newPassword != confirmPassword) {
      SnackBarUtil.showErrorMessage(context, 'Passwords do not match');
      return;
    }

    if (newPassword.length < 8) {
      SnackBarUtil.showErrorMessage(
        context,
        'Password must be at least 8 characters',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.changePassword(
        currentPassword,
        newPassword,
      );

      if (response['statusCode'] == 200) {
        SnackBarUtil.showSuccessMessage(
          context,
          'Password changed successfully',
        );
        Navigator.pop(context);
      } else {
        final error =
            response['body']['message'] ?? 'Failed to change password';
        SnackBarUtil.showErrorMessage(context, error);
      }
    } catch (e) {
      SnackBarUtil.showErrorMessage(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onAccountDeleted;
  const DeleteAccountDialog({super.key, required this.onAccountDeleted});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final ApiService _apiService = ApiService();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      _passwordFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
    });

    try {
      final response = await _apiService.deleteAccount(password);

      if (response['statusCode'] == 200) {
        if (mounted) {
          Navigator.pop(context);
          widget.onAccountDeleted();
        }
      } else if (response['statusCode'] == 401) {
        setState(() {
          _passwordError = 'Incorrect password';
          _passwordFocus.requestFocus();
        });
      } else {
        final error = response['body']['message'] ?? 'Failed to delete account';
        if (mounted) {
          SnackBarUtil.showErrorMessage(context, error);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showErrorMessage(
          context,
          'Network error. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete Account',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'All your data, including profile, jobs, and applications will be permanently deleted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _passwordError,
              ),
              onChanged: (value) {
                if (_passwordError != null) {
                  setState(() {
                    _passwordError = null;
                  });
                }
              },
              onFieldSubmitted: (_) {
                if (!_isLoading) {
                  _deleteAccount();
                }
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'After deletion, you cannot recover your account or data.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Delete Account'),
        ),
      ],
    );
  }
}
