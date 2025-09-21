import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/theme.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({Key? key}) : super(key: key);

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _screenTimeLimitController = TextEditingController(text: '120');

  bool _isPasswordVisible = false;
  List<String> _selectedRestrictions = [];

  final List<Map<String, dynamic>> _restrictionOptions = [
    {
      'id': 'adult_content',
      'title': 'Adult Content',
      'description': 'Block mature and explicit content',
      'icon': Icons.block,
    },
    {
      'id': 'social_media',
      'title': 'Social Media',
      'description': 'Restrict access to social platforms',
      'icon': Icons.people,
    },
    {
      'id': 'gaming',
      'title': 'Gaming',
      'description': 'Control gaming apps and websites',
      'icon': Icons.games,
    },
    {
      'id': 'shopping',
      'title': 'Online Shopping',
      'description': 'Block shopping and purchase sites',
      'icon': Icons.shopping_cart,
    },
    {
      'id': 'violence',
      'title': 'Violence',
      'description': 'Filter violent content',
      'icon': Icons.warning,
    },
    {
      'id': 'ads',
      'title': 'Advertisements',
      'description': 'Block ads and sponsored content',
      'icon': Icons.ad_units,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _screenTimeLimitController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Child\'s name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < 3 || age > 18) {
      return 'Age must be between 3 and 18';
    }
    return null;
  }

  String? _validateScreenTimeLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Screen time limit is required';
    }
    final limit = int.tryParse(value);
    if (limit == null) {
      return 'Please enter a valid number';
    }
    if (limit < 30 || limit > 480) {
      return 'Limit must be between 30 and 480 minutes';
    }
    return null;
  }

  Future<void> _handleAddChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final success = await appProvider.addChildAccount(
      childName: _nameController.text.trim(),
      childEmail: _emailController.text.trim(),
      password: _passwordController.text,
      age: int.parse(_ageController.text),
      screenTimeLimit: int.parse(_screenTimeLimitController.text),
      restrictions: _selectedRestrictions,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} added successfully!'),
          backgroundColor: AppTheme.seaGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Child'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.seaGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.seaGreen,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.child_care,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Add New Child',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create a safe digital account for your child',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Basic Information Section
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textBlack,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Child Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                      decoration: const InputDecoration(
                        labelText: 'Child\'s Full Name',
                        hintText: 'Enter your child\'s name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppTheme.seaGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Age
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      validator: _validateAge,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        hintText: 'Enter your child\'s age',
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                          color: AppTheme.seaGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Create an email for your child',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppTheme.seaGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Set a password for your child',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.seaGreen,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textGrey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Screen Time Section
                    const Text(
                      'Screen Time Control',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textBlack,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Screen Time Limit
                    TextFormField(
                      controller: _screenTimeLimitController,
                      keyboardType: TextInputType.number,
                      validator: _validateScreenTimeLimit,
                      decoration: const InputDecoration(
                        labelText: 'Daily Screen Time Limit (minutes)',
                        hintText: 'e.g., 120 for 2 hours',
                        prefixIcon: Icon(
                          Icons.timer_outlined,
                          color: AppTheme.seaGreen,
                        ),
                        suffixText: 'minutes',
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Content Restrictions Section
                    const Text(
                      'Content Restrictions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textBlack,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Select what content to block for your child',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Restrictions List
                    ..._restrictionOptions.map(
                      (restriction) => _buildRestrictionTile(restriction),
                    ),

                    const SizedBox(height: 32),

                    // Error Message
                    if (appProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                appProvider.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Add Child Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            appProvider.isLoading ? null : _handleAddChild,
                        child: appProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Add Child',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRestrictionTile(Map<String, dynamic> restriction) {
    final isSelected = _selectedRestrictions.contains(restriction['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppTheme.seaGreen : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? AppTheme.seaGreen.withOpacity(0.05) : Colors.white,
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedRestrictions.add(restriction['id']);
            } else {
              _selectedRestrictions.remove(restriction['id']);
            }
          });
        },
        activeColor: AppTheme.seaGreen,
        title: Text(
          restriction['title'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.seaGreen : AppTheme.textBlack,
          ),
        ),
        subtitle: Text(
          restriction['description'],
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textGrey,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                (isSelected ? AppTheme.seaGreen : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            restriction['icon'],
            color: isSelected ? AppTheme.seaGreen : Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }
}
