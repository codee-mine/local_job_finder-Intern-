import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Job Finder',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 6, 79, 205),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 6, 79, 205),
          secondary: const Color.fromARGB(255, 255, 152, 0),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// SnackBar Utility
class SnackBarUtil {
  static void showSuccessMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green, Icons.check_circle);
  }

  static void showErrorMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red, Icons.error);
  }

  static void showInfoMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue, Icons.info);
  }

  static void showWarningMessage(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orange, Icons.warning);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// Registration
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final List<String> _roleOptions = ['Employee', 'Employer'];
  String? _selectedRole;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _roleError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

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
      _roleValidated = true;
      _emailValidated = true;
      _passwordValidated = true;
      _confirmPasswordValidated = true;
    });

    _validateRole();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    return _roleError == null &&
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
      SnackBarUtil.showSuccessMessage(
        context,
        'Registration successful! Please check your email for verification link.',
      );
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
        ? 'Create employer account to post jobs'
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
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            hint: const Text('Select your role'),
            items: _roleOptions.map((String role) {
              return DropdownMenuItem<String>(value: role, child: Text(role));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue;
                _roleValidated = true;
                _validateRole();
              });
            },
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

  final List<String> _roleOptions = ['Employee', 'Employer'];
  String? _selectedRole;

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _roleError;
  String? _emailError;
  String? _passwordError;

  bool _roleValidated = false;
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
      _roleValidated = true;
      _emailValidated = true;
      _passwordValidated = true;
    });

    _validateRole();
    _validateEmail();
    _validatePassword();

    return _roleError == null && _emailError == null && _passwordError == null;
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

    if (_selectedRole == null) {
      setState(() {
        _roleValidated = true;
        _validateRole();
      });
      SnackBarUtil.showWarningMessage(context, 'Please select your role');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SnackBarUtil.showSuccessMessage(context, 'Logged in successfully!');
    } catch (e) {
      SnackBarUtil.showErrorMessage(context, 'Login failed. Please try again.');
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
          'Welcome Back',
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
        _buildRoleDropdown(),
        const SizedBox(height: 20),
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

  Widget _buildRoleDropdown() {
    final hasError = _roleError != null && _roleValidated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am a *',
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
              color: hasError ? Colors.red : Colors.grey.shade300,
              width: hasError ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            hint: const Text('Select your role'),
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
          ),
        ),
        if (hasError)
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
        onPressed: () {},
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

// employee screen
class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _currentIndex = 1;

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

  @override
  Widget build(BuildContext context) {
    return InternetBanner(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          centerTitle: true,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Handle notifications
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
        body: _buildCurrentIndexTab(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
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
        return _buildSearchTab();
      case 1:
        return _buildHomeTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildSearchTab() {
    return EmployeeSearchScreen();
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

class EmployeeSearchScreen extends StatefulWidget {
  const EmployeeSearchScreen({super.key});

  @override
  State<EmployeeSearchScreen> createState() => _EmployeeSearchScreenState();
}

class _EmployeeSearchScreenState extends State<EmployeeSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Search')));
  }
}

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

// employer screen
class EmployerHomeScreen extends StatefulWidget {
  final int index;
  const EmployerHomeScreen({super.key, this.index = 1});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
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
                SnackBarUtil.showSuccessMessage(context, 'Posted Jobs');
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Handle notifications
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
    return EmployeeSearchScreen();
  }

  Widget _buildHomeContent() {
    return EmployerHomeContent();
  }

  Widget _buildProfileTab() {
    return EmployerProfileScreen();
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

class EmployerSearchScreen extends StatefulWidget {
  const EmployerSearchScreen({super.key});

  @override
  State<EmployerSearchScreen> createState() => _EmployerSearchScreenState();
}

class _EmployerSearchScreenState extends State<EmployerSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Search')));
  }
}

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Search')));
  }
}

enum BannerType { connected, slowInternet, disconnected }

class InternetService with ChangeNotifier {
  static final InternetService _instance = InternetService._internal();
  factory InternetService() => _instance;
  InternetService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> _init() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> result = await _connectivity
          .checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.other,
    );

    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      notifyListeners();
    }
  }

  // Method to check with online operations
  bool checkConnection(BuildContext context, {bool showToast = true}) {
    if (!_isConnected && showToast) {
      SnackBarUtil.showErrorMessage(
        context,
        'No internet connection. Please try again.',
      );
    }
    return _isConnected;
  }
}

class InternetBanner extends StatefulWidget {
  final Widget child;
  final Duration connectedDisplayDuration;
  final String disconnectedText;
  final String connectedText;
  final String slowInternetText;
  final Color disconnectedColor;
  final Color connectedColor;
  final Color slowInternetColor;
  final Color textColor;
  final double height;
  final Duration animationDuration;
  final int slowInternetThreshold;

  const InternetBanner({
    super.key,
    required this.child,
    this.connectedDisplayDuration = const Duration(seconds: 3),
    this.disconnectedText = 'No Internet Connection',
    this.connectedText = 'Internet Connected',
    this.slowInternetText = 'Slow Internet Connection',
    this.disconnectedColor = Colors.red,
    this.connectedColor = Colors.green,
    this.slowInternetColor = Colors.orange,
    this.textColor = Colors.white,
    this.height = 100.0,
    this.animationDuration = const Duration(milliseconds: 500),
    this.slowInternetThreshold = 1000,
  });

  @override
  State<InternetBanner> createState() => _InternetBannerState();
}

class _InternetBannerState extends State<InternetBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final InternetService _internetService = InternetService();
  final bool _isConnected = false;
  bool _showBanner = false;
  BannerType _currentBannerType = BannerType.connected;
  Timer? _internetSpeedTimer;
  int _lastResponseTime = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _updateBannerState(_internetService.isConnected);
    _internetService.addListener(_onInternetStatusChanged);
    _startInternetSpeedMonitoring();
  }

  void _updateBannerState(bool isConnected) {
    if (!isConnected) {
      _currentBannerType = BannerType.disconnected;
      _showBanner = true;
      _animationController.forward();
    } else {
      _showBanner = false;
      _animationController.reverse();
    }
  }

  void _onInternetStatusChanged() {
    final isConnected = _internetService.isConnected;

    setState(() {
      if (!isConnected) {
        // Internet disconnected - show red banner immediately
        _currentBannerType = BannerType.disconnected;
        _showBanner = true;
        _animationController.forward();
      } else if (_currentBannerType == BannerType.disconnected) {
        // Internet reconnected - show green banner temporarily
        _currentBannerType = BannerType.connected;
        _showBanner = true;
        _animationController.forward();

        // Check speed immediately when reconnected
        _checkInternetSpeed();

        Future.delayed(widget.connectedDisplayDuration, () {
          if (mounted &&
              _internetService.isConnected &&
              _currentBannerType == BannerType.connected) {
            _animationController.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _showBanner = false;
                });
              }
            });
          }
        });
      }
    });
  }

  void _startInternetSpeedMonitoring() {
    _internetSpeedTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_isConnected) {
        _checkInternetSpeed();
      }
    });
  }

  Future<void> _checkInternetSpeed() async {
    final stopwatch = Stopwatch()..start();

    try {
      await Future.any([
        // Try multiple endpoints for better accuracy
        _testConnection('https://www.google.com/favicon.ico'),
        _testConnection('https://www.cloudflare.com/favicon.ico'),
        _testConnection('https://www.apple.com/favicon.ico'),
      ]);

      stopwatch.stop();
      _lastResponseTime = stopwatch.elapsedMilliseconds;

      if (mounted) {
        setState(() {
          if (_lastResponseTime > widget.slowInternetThreshold &&
              _isConnected) {
            _currentBannerType = BannerType.slowInternet;
            _showBanner = true;
            _animationController.forward();
          } else if (_lastResponseTime <= widget.slowInternetThreshold &&
              _currentBannerType == BannerType.slowInternet &&
              _isConnected) {
            // Speed improved, show connected banner
            _currentBannerType = BannerType.connected;
            _showBanner = true;
            _animationController.forward();

            Future.delayed(widget.connectedDisplayDuration, () {
              if (mounted &&
                  _isConnected &&
                  _currentBannerType == BannerType.connected) {
                _animationController.reverse().then((_) {
                  if (mounted) {
                    setState(() {
                      _showBanner = false;
                    });
                  }
                });
              }
            });
          }
        });
      }
    } catch (e) {
      stopwatch.stop();

      // If speed test fails, assume slow connection
      if (mounted && _isConnected) {
        setState(() {
          _currentBannerType = BannerType.slowInternet;
          _showBanner = true;
          _animationController.forward();
        });
      }
    }
  }

  Future<bool> _testConnection(String url) async {
    try {
      final response = await HttpClient().getUrl(Uri.parse(url));
      await response.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Color get _bannerColor {
    switch (_currentBannerType) {
      case BannerType.connected:
        return widget.connectedColor;
      case BannerType.disconnected:
        return widget.disconnectedColor;
      case BannerType.slowInternet:
        return widget.slowInternetColor;
    }
  }

  String get _bannerText {
    switch (_currentBannerType) {
      case BannerType.connected:
        return widget.connectedText;
      case BannerType.disconnected:
        return widget.disconnectedText;
      case BannerType.slowInternet:
        return '${widget.slowInternetText} (${_lastResponseTime}ms)';
    }
  }

  Widget get _bannerIcon {
    switch (_currentBannerType) {
      case BannerType.connected:
        return Icon(Icons.wifi, color: widget.textColor, size: 24);
      case BannerType.disconnected:
        return Icon(Icons.wifi_off, color: widget.textColor, size: 24);
      case BannerType.slowInternet:
        return Icon(Icons.network_check, color: widget.textColor, size: 24);
    }
  }

  String get _bannerSubtitle {
    switch (_currentBannerType) {
      case BannerType.connected:
        return 'Connection is stable';
      case BannerType.disconnected:
        return 'Please check your network connection';
      case BannerType.slowInternet:
        return 'Loading may take longer than usual';
    }
  }

  @override
  void dispose() {
    _internetService.removeListener(_onInternetStatusChanged);
    _internetSpeedTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: widget.height,
                padding: EdgeInsets.only(top: statusBarHeight),
                decoration: BoxDecoration(
                  color: _bannerColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 18.0,
                      offset: const Offset(0, 4),
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bannerIcon,
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _bannerText,
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    _bannerSubtitle,
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            if (_currentBannerType == BannerType.disconnected ||
                                _currentBannerType == BannerType.slowInternet)
                              const SizedBox(width: 12.0),
                            if (_currentBannerType == BannerType.disconnected ||
                                _currentBannerType == BannerType.slowInternet)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.textColor,
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
            ),
          ),
      ],
    );
  }
}
