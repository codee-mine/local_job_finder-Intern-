import 'package:flutter/material.dart';
import 'package:local_job_finder/Utilizes/toasts_messages.dart';

class EmployerPostJobScreen extends StatefulWidget {
  final Map<String, dynamic>? existingJob;
  final Function(Map<String, dynamic>)? onJobSaved;
  final Function(int)? onJobDeleted;
  const EmployerPostJobScreen({
    super.key,
    this.existingJob,
    this.onJobSaved,
    this.onJobDeleted,
  });
  @override
  State<EmployerPostJobScreen> createState() => _EmployerPostJobScreenState();
}

class _EmployerPostJobScreenState extends State<EmployerPostJobScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _applicationEmailController =
      TextEditingController();

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _requirementsFocusNode = FocusNode();
  final _categoriesFocusNode = FocusNode();
  final _salaryFocusNode = FocusNode();
  final _applicationEmailFocusNode = FocusNode();

  bool _isLoading = false;
  String? _titleError;
  String? _descriptionError;
  String? _requirementsError;
  String? _categoriesError;
  String? _salaryError;
  String? _appEmailError;

  String? _selectedJobTypes;
  String? _selectedCategory;

  bool _isTitleValidate = false;
  bool _isDescriptionValidate = false;
  bool _isRequirementsValidate = false;
  bool _isCategoryValidate = false;
  bool _isSalaryValidate = false;
  bool _isAppEmailValidate = false;

  final List<String> _jobTypes = [
    'Full-Time',
    'Part-Time',
    'Contract',
    'Freelance',
    'Internship',
    'Remote',
  ];

  final List<String> _categories = [
    'IT & Software',
    'Design & Creative',
    'Sales & Marketing',
    'Writing & Translation',
    'Administrative',
    'Customer Service',
    'Human Resources',
    'Accounting & Finance',
    'Engineering',
    'Healthcare',
  ];

  bool get _isEditing => widget.existingJob != null;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
    _requirementsController.addListener(() => setState(() {}));
    _categoriesController.addListener(() => setState(() {}));
    _salaryController.addListener(() => setState(() {}));
    _applicationEmailController.addListener(() => setState(() {}));
    if (_isEditing) {
      _initializeEditWithExistingJob();
    } else {
      _loadCompanyProfileData();
    }
  }

  void _initializeEditWithExistingJob() {
    final job = widget.existingJob;
    _titleController.text = job?['title'] ?? '';
    _descriptionController.text = job?['description'] ?? '';
    _requirementsController.text = job?['requirements'] ?? '';
    _salaryController.text = job?['salary'] ?? '';
    _applicationEmailController.text = job?['applicationEmail'] ?? '';
    _selectedJobTypes = job?['jobType'];
    _selectedCategory = job?['category'];
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _titleFocusNode.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    _requirementsController.dispose();
    _requirementsFocusNode.dispose();
    _categoriesController.dispose();
    _categoriesFocusNode.dispose();
    _salaryController.dispose();
    _salaryFocusNode.dispose();
    _applicationEmailController.dispose();
    _applicationEmailFocusNode.dispose();
  }

  void _titleValidate() {
    if (!_isTitleValidate) return;
    final value = _titleController.text.trim();
    if (value.isEmpty) {
      _titleError = 'Title is Required.';
    } else if (value.length < 3) {
      _titleError = 'Title must be at least 3 character long ';
    } else {
      _titleError = null;
    }
  }

  void _descriptionValidate() {
    if (!_isDescriptionValidate) return;
    final value = _descriptionController.text.trim();
    if (value.isEmpty) {
      _descriptionError = 'Decription cannot be empty.';
    } else if (value.length > 100) {
      _descriptionError = 'Decription must be at leat 100 characters long';
    } else {
      _descriptionError = null;
    }
  }

  void _requirementsValidate() {
    if (!_isRequirementsValidate) return;
    if (_selectedJobTypes == null) {
      _requirementsError = 'Select one Job type';
    } else {
      _requirementsError = null;
    }
  }

  void _categoriesValidate() {
    if (!_isCategoryValidate) return;
    if (_selectedCategory == null) {
      _categoriesError = 'Select one Category type';
    } else {
      _categoriesError = null;
    }
  }

  void _salaryValidate() {
    if (!_isSalaryValidate) return;
    final value = _salaryController.text.trim();
    if (value.isEmpty) {
      _salaryError = 'Please write approx salary';
    } else {
      _salaryError = null;
    }
  }

  void _appEmailValidate() {
    if (!_isAppEmailValidate) return;
    final value = _applicationEmailController.text.trim();
    if (value.isEmpty) {
      _appEmailError = 'Please write approx salary';
    } else {
      _appEmailError = null;
    }
  }

  bool _validateAll() {
    setState(() {
      _isTitleValidate = true;
      _isDescriptionValidate = true;
      _isRequirementsValidate = true;
      _isCategoryValidate = true;
      _isSalaryValidate = true;
      _isAppEmailValidate = true;
    });

    _titleValidate();
    _descriptionValidate();
    _requirementsValidate();
    _salaryValidate();
    _categoriesValidate();
    _appEmailValidate();

    return _titleError == null &&
        _descriptionError == null &&
        _requirementsError == null &&
        _categoriesError == null &&
        _salaryError == null &&
        _appEmailError == null;
  }

  Future<void> _loadCompanyProfileData() async {
    try {
      SnackBarUtil.showErrorMessage(context, 'Job added');
    } catch (e) {
      SnackBarUtil.showErrorMessage(context, 'Failed to load email');
      setState(() {
        _applicationEmailController.text = '';
      });
    }
  }

  Future<void> _postJobs() async {
    if (!_validateAll()) {
      SnackBarUtil.showErrorMessage(context, 'Please fix all errors');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jobId =
          widget.existingJob?['id'] ?? DateTime.now().millisecondsSinceEpoch;
      final jobData = {
        'id': jobId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'jobType': _selectedJobTypes,
        'category': _selectedCategory,
        'salary': _salaryController.text.trim(),
        'applicationEmail': _applicationEmailController.text.trim(),
        'createdAt':
            widget.existingJob?['createdAt'] ?? DateTime.now().toString(),
        'isActive': widget.existingJob?['isActive'] ?? true,
        'applicationReceived': widget.existingJob?['applicationReceived'] ?? 0,
        'views': widget.existingJob?['views'] ?? 0,
      };

      if (widget.existingJob != null) {
        SnackBarUtil.showSuccessMessage(context, 'Job Updated Successfully');
      } else {
        SnackBarUtil.showSuccessMessage(context, 'Job Posted Successfully');
      }

      if (widget.onJobSaved != null) {
        widget.onJobSaved!(jobData);
      }

      Navigator.pop(context, jobData);
    } catch (e) {
      SnackBarUtil.showErrorMessage(
        context,
        'Failed to ${widget.existingJob != null ? 'update' : 'post'} job: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Job' : 'Post New Job'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        actions: [
          if (widget.existingJob != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Delete this Job!',
                      textAlign: TextAlign.center,
                    ),
                    content: Text(
                      'Are you sure you want to delete this job?',
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (widget.onJobDeleted != null) {
                            widget.onJobDeleted!(widget.existingJob!['id']);
                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                          SnackBarUtil.showSuccessMessage(
                            context,
                            'Job deleted',
                          );
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Delete job',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildJobtypeDropdown(),
            const SizedBox(height: 20),
            _buildCategoryDropdown(),
            const SizedBox(height: 20),
            _buildSalaryField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 20),
            _buildApplicationEmailField(),
            const SizedBox(height: 40),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    final hasError = _titleError != null && _isTitleValidate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter Job Title...',
            prefixIcon: Icon(Icons.work),
            suffixIcon: _titleController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _titleController.clear();
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
            errorText: _isTitleValidate ? _titleError : null,
          ),
          onChanged: (value) {
            if (_isTitleValidate) _titleValidate();
          },
          onTap: () {
            if (!_isTitleValidate) {
              setState(() {
                _isTitleValidate = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    final hasError = _descriptionError != null && _isDescriptionValidate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter Job Discription...',
            prefixIcon: Icon(Icons.description),
            suffixIcon: _descriptionController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _descriptionController.clear();
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
            errorText: _isDescriptionValidate ? _descriptionError : null,
          ),
          minLines: 1,
          maxLines: 10,
          onChanged: (value) {
            if (_isDescriptionValidate) _descriptionValidate();
          },
          onTap: () {
            if (!_isDescriptionValidate) {
              setState(() {
                _isDescriptionValidate = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildJobtypeDropdown() {
    final hasError = _requirementsError != null && _isRequirementsValidate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedJobTypes,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.work_history),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            hint: Text('Select Job type'),
            isExpanded: true,
            items: _jobTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedJobTypes = newValue;
                _isRequirementsValidate = true;
                _requirementsValidate();
              });
            },
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(left: 12, top: 4),
            child: Text(
              _requirementsError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final hasError = _categoriesError != null && _isCategoryValidate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.category),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            hint: Text('Select Category type'),
            isExpanded: true,
            items: _categories.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
                _isCategoryValidate = true;
                _categoriesValidate();
              });
            },
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(left: 12, top: 4),
            child: Text(
              _categoriesError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSalaryField() {
    final hasError = _salaryError != null && _isSalaryValidate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _salaryController,
          focusNode: _salaryFocusNode,
          decoration: InputDecoration(
            hintText: 'Enter Salary: e.g: \$50,000- \$70,000',
            prefixIcon: Icon(Icons.attach_money),
            suffixIcon: _salaryController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _salaryController.clear();
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
            errorText: _isSalaryValidate ? _salaryError : null,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (_isSalaryValidate) _salaryValidate();
          },
          onTap: () {
            if (!_isSalaryValidate) {
              setState(() {
                _isSalaryValidate = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildApplicationEmailField() {
    final hasError = _appEmailError != null && _isAppEmailValidate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _applicationEmailController,
          focusNode: _applicationEmailFocusNode,
          decoration: InputDecoration(
            hintText: 'Email for applications',
            prefixIcon: const Icon(Icons.email),
            suffixIcon: _applicationEmailController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _applicationEmailController.clear();
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
            errorText: _isAppEmailValidate ? _appEmailError : null,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            if (_isAppEmailValidate) _salaryValidate();
          },
          onTap: () {
            if (!_isAppEmailValidate) {
              setState(() {
                _isAppEmailValidate = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          _postJobs();
        },
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                _isEditing ? 'Update Job' : 'Post Job',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}
