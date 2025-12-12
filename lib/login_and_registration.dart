// Registration
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_job_finder/Utilizes/internet_check.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';
import 'package:local_job_finder/auth/api_service.dart';
import 'package:local_job_finder/auth/auth_service.dart';
import 'package:local_job_finder/employee/employee_dashboard.dart';
import 'package:local_job_finder/employer/employer_dashboard.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final List<String> _roleOptions = ['employee', 'employer'];
  String? _selectedRole;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _nameError;
  String? _roleError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _nameValidated = false;
  bool _roleValidated = false;
  bool _emailValidated = false;
  bool _passwordValidated = false;
  bool _confirmPasswordValidated = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _validateRole() {
    if (!_roleValidated) return;
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      _roleError = 'Please select your role';
    } else {
      _roleError = null;
    }
  }

  void _validateEmail() {
    if (!_emailValidated) return;
    final value = _emailController.text;
    if (value.isEmpty) {
      _emailError = 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      _emailError = 'Please enter a valid email address';
    } else {
      _emailError = null;
    }
  }

  void _validateName() {
    if (!_nameValidated) return;
    final value = _nameController.text;
    if (value.isEmpty) {
      _nameError = 'Please enter your email';
    } else {
      _nameError = null;
    }
  }

  void _validatePassword() {
    if (!_passwordValidated) return;
    final value = _passwordController.text;
    if (value.isEmpty) {
      _passwordError = 'Please enter a password';
    } else if (value.length < 8) {
      _passwordError = 'Password must be at least 8 characters long';
    } else {
      _passwordError = null;
    }
  }

  void _validateConfirmPassword() {
    if (!_confirmPasswordValidated) return;
    final value = _confirmPasswordController.text;
    if (value.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
    } else if (value != _passwordController.text) {
      _confirmPasswordError = 'Passwords do not match';
    } else {
      _confirmPasswordError = null;
    }
  }

  bool _validateAllFields() {
    setState(() {
      _nameValidated = true;
      _roleValidated = true;
      _emailValidated = true;
      _passwordValidated = true;
      _confirmPasswordValidated = true;
    });

    _validateName();
    _validateRole();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    return _nameError == null &&
        _roleError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _register() async {
    if (!_validateAllFields()) {
      SnackBarUtil.showWarningMessage(
        context,
        'Please fill all required fields correctly.',
      );
      return;
    }

    if (_selectedRole == null) {
      SnackBarUtil.showErrorMessage(context, 'Please select your role.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService().registerUser(
        _nameController.text,
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole!,
      );

      if (result['statusCode'] == 201) {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        SnackBarUtil.showSuccessMessage(context, 'Registration successful!');
      } else {
        SnackBarUtil.showErrorMessage(
          context,
          result['body']['errors']?.toString() ?? 'Registration failed.',
        );
      }
    } catch (e) {
      SnackBarUtil.showErrorMessage(
        context,
        'Registration failed. Please try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return InternetBanner(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(primaryColor),
                const SizedBox(height: 24),
                _buildRegistrationForm(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    String headerText = _selectedRole == 'Employer'
        ? 'Hire Top Talent'
        : 'Find Your Dream Job';
    String subText = _selectedRole == 'Employer'
        ? 'Create Employer account to post jobs'
        : 'Create account to apply for jobs';

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _selectedRole == 'Employer'
                ? Icons.business_center
                : Icons.work_outline,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedRole != null ? headerText : 'Choose your role to continue',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        if (_selectedRole != null) ...[
          const SizedBox(height: 4),
          Text(
            subText,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildRegistrationForm(Color primaryColor) {
    return Column(
      children: [
        _buildRoleDropdown(),
        const SizedBox(height: 16),
        _buildNameField(primaryColor),
        const SizedBox(height: 16),
        _buildEmailField(primaryColor),
        const SizedBox(height: 16),
        _buildPasswordField(primaryColor),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(primaryColor),
        const SizedBox(height: 40),
        _buildRegisterButton(primaryColor),
        const SizedBox(height: 10),
        _buildLoginLink(primaryColor),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I want to be a *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _roleError != null ? Colors.red : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton2<String>(
            isExpanded: true,
            value: _selectedRole,
            hint: const Row(
              children: [
                Icon(Icons.list, size: 16, color: Colors.black),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Select Item',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: _roleOptions.map((String role) {
              return DropdownMenuItem<String>(value: role, child: Text(role));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue;
                _roleValidated = true;
                _roleError = null;
              });
            },
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
              ),
              offset: const Offset(0, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all<double>(6),
                thumbVisibility: WidgetStateProperty.all<bool>(true),
              ),
            ),
          ),
        ),
        if (_roleError != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              _roleError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildNameField(Color primaryColor) {
    final hasError = _nameError != null && _nameValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: _nameController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _nameController.clear();
                      setState(() {});
                    },
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
            errorText: _nameValidated ? _nameError : null,
          ),
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            if (_nameValidated) _validateName();
          },
          onTap: () {
            if (!_nameValidated) {
              setState(() => _nameValidated = true);
            }
          },
          onFieldSubmitted: (_) {
            _nameValidated = true;
            _validateName();
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(Color primaryColor) {
    final hasError = _emailError != null && _emailValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: _emailController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _emailController.clear();
                      setState(() {});
                    },
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
            errorText: _emailValidated ? _emailError : null,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            if (_emailValidated) _validateEmail();
          },
          onTap: () {
            if (!_emailValidated) {
              setState(() => _emailValidated = true);
            }
          },
          onFieldSubmitted: (_) {
            _emailValidated = true;
            _validateEmail();
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(Color primaryColor) {
    final hasError = _passwordError != null && _passwordValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(
              _obscurePassword ? Icons.lock_outline : Icons.lock_open_outlined,
            ),
            suffixIcon: _buildPasswordSufficIcons(
              controller: _passwordController,
              obscured: _obscurePassword,
              onVisibility: () {
                _obscurePassword = !_obscurePassword;
                setState(() {});
              },
              onClear: () {
                _passwordController.clear();
                setState(() {});
              },
            ),
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
            errorText: _passwordValidated ? _passwordError : null,
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            if (_passwordValidated) _validatePassword();
          },
          onTap: () {
            if (!_passwordValidated) {
              setState(() => _passwordValidated = true);
            }
          },
          onFieldSubmitted: (_) {
            _passwordValidated = true;
            _validatePassword();
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(Color primaryColor) {
    final hasError = _confirmPasswordError != null && _confirmPasswordValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            prefixIcon: Icon(
              _obscureConfirmPassword
                  ? Icons.lock_outline
                  : Icons.lock_open_outlined,
            ),
            suffixIcon: _buildPasswordSufficIcons(
              controller: _confirmPasswordController,
              obscured: _obscureConfirmPassword,
              onVisibility: () {
                _obscureConfirmPassword = !_obscureConfirmPassword;
                setState(() {});
              },
              onClear: () {
                _confirmPasswordController.clear();
                setState(() {});
              },
            ),
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
            errorText: _confirmPasswordValidated ? _confirmPasswordError : null,
          ),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            if (_confirmPasswordValidated) _validateConfirmPassword();
          },
          onTap: () {
            if (!_confirmPasswordValidated) {
              setState(() => _confirmPasswordValidated = true);
            }
          },
          onFieldSubmitted: (_) {
            _confirmPasswordValidated = true;
            _validateConfirmPassword();
            _register();
          },
        ),
      ],
    );
  }

  Widget _buildRegisterButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                _register();
                FocusScope.of(context).unfocus();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLoginLink(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?'),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _navigateToLogin,
          child: Text(
            'Sign In',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSufficIcons({
    required TextEditingController controller,
    required bool obscured,
    required VoidCallback onVisibility,
    required VoidCallback onClear,
  }) {
    if (controller.text.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onVisibility,
            icon: Icon(
              obscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
          IconButton(onPressed: onClear, icon: Icon(Icons.clear)),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

// login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  bool _emailValidated = false;
  bool _passwordValidated = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    if (!_emailValidated) return;
    final value = _emailController.text;
    if (value.isEmpty) {
      _emailError = 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      _emailError = 'Please enter a valid email address';
    } else {
      _emailError = null;
    }
  }

  void _validatePassword() {
    if (!_passwordValidated) return;
    final value = _passwordController.text;
    if (value.isEmpty) {
      _passwordError = 'Please enter your password';
    } else if (value.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
    } else {
      _passwordError = null;
    }
  }

  bool _validateAllFields() {
    setState(() {
      _emailValidated = true;
      _passwordValidated = true;
    });

    _validateEmail();
    _validatePassword();

    return _emailError == null && _passwordError == null;
  }

  void _navigateToVerificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VerificationScreen()),
    );
    SnackBarUtil.showInfoMessage(context, 'Verification sent.');
  }

  Future<void> _forgotPasswordAlert(BuildContext context) async {
    final TextEditingController emailControllerInForgetPassword =
        TextEditingController();
    String? emailErrorInForgetPassword;
    bool emailValidated = false;

    emailControllerInForgetPassword.addListener(() {});

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final hasError = emailErrorInForgetPassword != null;
            return AlertDialog(
              title: Text(
                'Forgot password ?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Enter your registered email to reset password.'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailControllerInForgetPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter registered email',
                      prefixIcon: Icon(Icons.email_outlined),
                      suffixIcon:
                          emailControllerInForgetPassword.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                emailControllerInForgetPassword.clear();
                                setState(() {});
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
                          color: hasError ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      errorText: emailErrorInForgetPassword,
                    ),
                    onChanged: (value) {
                      if (!emailValidated) return;

                      setState(() {
                        if (value.isEmpty) {
                          emailErrorInForgetPassword =
                              'Please enter registered email address.';
                        } else if (!value.contains('@')) {
                          emailErrorInForgetPassword = 'Invalid email';
                        } else {
                          emailErrorInForgetPassword = null;
                        }
                      });
                    },

                    onTap: () {
                      if (!emailValidated) {
                        setState(() => emailValidated = true);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (emailControllerInForgetPassword.text.isEmpty) {
                        emailErrorInForgetPassword =
                            'Please enter registered email address.';
                      } else if (!emailControllerInForgetPassword.text.contains(
                        '@',
                      )) {
                        emailErrorInForgetPassword = 'Invalid email';
                      } else {
                        emailErrorInForgetPassword = null;
                        Navigator.pop(context);
                        _navigateToVerificationScreen();
                        FocusScope.of(context).unfocus();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Reset'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // login
  Future<void> _login() async {
    if (!_validateAllFields()) {
      SnackBarUtil.showWarningMessage(
        context,
        'Please fill all required fields',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService().loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result['statusCode'] == 200) {
        final token = result['body']['access_token'];
        final user = result['body']['user'];
        final userRole = user['user_type'];

        await AuthService().saveLoggedInData(
          token: token,
          role: userRole,
          email: _emailController.text.trim(),
        );

        SnackBarUtil.showSuccessMessage(context, 'Logged in successfully!');

        if (userRole == 'employee') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeHomeScreen(initialLoggedIn: true),
            ),
            (route) => false,
          );
        } else if (userRole == 'employer') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => EmployerHomeScreen()),
            (route) => false,
          );
        }
      } else if (result['statusCode'] == 401) {
        SnackBarUtil.showErrorMessage(context, 'Invaid email or ppassword');
      } else if (result['statusCode'] == 403) {
        SnackBarUtil.showErrorMessage(
          context,
          'Your account has been deactivated. Please ontact support teams.',
        );
      } else {
        SnackBarUtil.showErrorMessage(
          context,
          'Logged failed. Please try again.',
        );
      }
    } catch (e) {
      SnackBarUtil.showErrorMessage(
        context,
        'Something went wrong. Please try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return InternetBanner(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildLoginHeader(primaryColor),
                const SizedBox(height: 24),
                _buildLoginForm(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginHeader(Color primaryColor) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.work_outline, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to your account',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLoginForm(Color primaryColor) {
    return Column(
      children: [
        _buildEmailField(primaryColor),
        const SizedBox(height: 16),
        _buildPasswordField(primaryColor),
        const SizedBox(height: 16),
        _buildForgotPassword(),
        const SizedBox(height: 20),
        _buildLoginButton(primaryColor),
        const SizedBox(height: 20),
        _buildSocialLogin(),
        const SizedBox(height: 10),
        _buildSignUpLink(primaryColor),
      ],
    );
  }

  Widget _buildEmailField(Color primaryColor) {
    final hasError = _emailError != null && _emailValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: _emailController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _emailController.clear();
                      setState(() {
                        _emailError = null;
                      });
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
            errorText: hasError ? _emailError : null,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            if (_emailValidated) {
              setState(() {
                _emailError = null;
              });
              _validateEmail();
            }
          },
          onTap: () {
            if (!_emailValidated) {
              setState(() => _emailValidated = true);
            }
          },
          onFieldSubmitted: (_) {
            _emailValidated = true;
            _validateEmail();
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(Color primaryColor) {
    final hasError = _passwordError != null && _passwordValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(
              _obscurePassword ? Icons.lock_outline : Icons.lock_open_outlined,
            ),
            suffixIcon: _buildPasswordSuffixIcons(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onVisibilityToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              onClear: () {
                _passwordController.clear();
                setState(() {
                  _passwordError = null;
                });
              },
            ),
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
            errorText: hasError ? _passwordError : null,
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            if (_passwordValidated) {
              setState(() {
                _passwordError = null;
              });
              _validatePassword();
            }
          },
          onTap: () {
            if (!_passwordValidated) {
              setState(() => _passwordValidated = true);
            }
          },
          onFieldSubmitted: (_) {
            _passwordValidated = true;
            _validatePassword();
            _login();
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSuffixIcons({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
    required VoidCallback onClear,
  }) {
    if (controller.text.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onVisibilityToggle,
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: onClear,
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          _forgotPasswordAlert(context);
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                _login();
                if (_validateAllFields()) {
                  FocusScope.of(context).unfocus();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Or continue with'),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  SnackBarUtil.showInfoMessage(
                    context,
                    'Google login coming soon!',
                  );
                },
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  SnackBarUtil.showInfoMessage(
                    context,
                    'Facebook login coming soon!',
                  );
                },
                icon: const Icon(Icons.facebook, size: 24),
                label: const Text('Facebook'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpLink(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _navigateToRegistration,
          child: Text(
            'Sign Up',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _inputController = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNode = List.generate(6, (_) => FocusNode());
  final List<String> _otp = List.filled(6, '');
  bool _isError = false;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    for (int i = 0; i < _focusNode.length; i++) {
      _focusNode[i].addListener(() {
        if (!_focusNode[i].hasFocus && _inputController[i].text.isEmpty) {
          _isError = true;
          _errorMessage = 'Please verify your OTP';
          setState(() {});
        }
      });
    }
  }

  void _onChanged(String value, int index) {
    if (_isError) {
      _isError = false;
      _errorMessage = '';
    }

    if (value.length <= 1) {
      _otp[index] = value;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNode[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNode[index - 1].requestFocus();
    }

    if (_otp.every((digit) => digit.isNotEmpty) && index == 5) {
      _verifyOtp;
    }

    setState(() {});
  }

  void _verifyOtp() async {
    if (_isLoading) return;
    final enteredOtp = _otp.join();

    if (enteredOtp.length != 6) {
      setState(() {
        _isError = true;
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(enteredOtp)) {
      setState(() {
        _isError = true;
        _errorMessage = 'OTP should contain only numbers';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (enteredOtp == '123456') {
        SnackBarUtil.showSuccessMessage(context, 'OTP Verified');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => EmployeeHomeScreen()),
          (route) => false,
        );
        _isError = false;
        _errorMessage = '';
        _clearAllFields();
      } else {
        setState(() {
          _isError = true;
          _errorMessage = 'Invalid OTP. Please try again';
          _clearAllFields();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Network error. Please try again';
      });
    }
  }

  void _clearAllFields() {
    for (var controller in _inputController) {
      controller.clear();
    }

    for (var node in _focusNode) {
      node.unfocus();
    }

    _focusNode[0].requestFocus();
    _otp.fillRange(0, 6, '');
    setState(() {});
  }

  void _onPaste(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length >= 6) {
      for (int i = 0; i < 6; i++) {
        _inputController[i].text = digits[i];
        _otp[i] = digits[i];
      }
      _focusNode[5].requestFocus();
      _verifyOtp();
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var controlle in _inputController) {
      controlle.dispose();
    }

    for (var node in _focusNode) {
      node.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your OTP to verify your account.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        height: 60,
                        child: TextField(
                          controller: _inputController[index],
                          focusNode: _focusNode[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isError
                                    ? Colors.red
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isError
                                    ? Colors.red
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isError
                                    ? Colors.red
                                    : Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: _isError
                                ? Colors.red.shade50
                                : Colors.grey.shade50,
                            contentPadding: EdgeInsets.zero,
                            counterText: '',
                          ),
                          onChanged: (value) => _onChanged(value, index),
                          onTap: () {
                            if (_isError) {
                              _isError = false;
                              _errorMessage = '';
                              setState(() {});
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),

                if (_isError) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final clipBoardData = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        if (clipBoardData?.text != null) {
                          _onPaste(clipBoardData!.text!);
                        }
                        FocusScope.of(context).unfocus();
                      },

                      icon: Icon(Icons.paste),
                      label: Text('Paste otp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _clearAllFields,

                      icon: Icon(Icons.clear),
                      label: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Verifying..'),
                            ],
                          )
                        : Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive otp?",
                      style: TextStyle(color: Colors.green.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearAllFields();
                        SnackBarUtil.showSuccessMessage(
                          context,
                          'OTP resent successfully',
                        );
                      },
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
