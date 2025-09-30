// lib/screens/children/add_child_screen.dart
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
  
  bool _isPasswordVisible = false;
  double _screenTimeLimit = 120; // Default 2 hours
  List<String> _selectedRestrictions = [];
  
  final List<Map<String, dynamic>> _restrictionOptions = [
    {
      'id': 'adult_content',
      'title': 'Adult Content',
      'description': 'Block mature and explicit content',
      'icon': Icons.block,
      'color': Colors.red,
    },
    {
      'id': 'social_media',
      'title': 'Social Media',
      'description': 'Restrict access to social platforms',
      'icon': Icons.people,
      'color': Colors.blue,
    },
    {
      'id': 'gaming',
      'title': 'Gaming',
      'description': 'Control gaming apps and websites',
      'icon': Icons.games,
      'color': Colors.purple,
    },
    {
      'id': 'shopping',
      'title': 'Online Shopping',
      'description': 'Block shopping and purchase sites',
      'icon': Icons.shopping_cart,
      'color': Colors.orange,
    },
    {
      'id': 'violence',
      'title': 'Violence',
      'description': 'Filter violent content',
      'icon': Icons.warning,
      'color': Colors.deepOrange,
    },
    {
      'id': 'ads',
      'title': 'Advertisements',
      'description': 'Block ads and sponsored content',
      'icon': Icons.ad_units,
      'color': Colors.amber,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Child\'s name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
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

  void _applyAgeBasedDefaults(int age) {
    // Apply recommended restrictions based on age
    setState(() {
      if (age >= 3 && age <= 8) {
        _selectedRestrictions = ['adult_content', 'violence', 'social_media', 'shopping', 'ads'];
        _screenTimeLimit = 60; // 1 hour
      } else if (age >= 9 && age <= 12) {
        _selectedRestrictions = ['adult_content', 'violence', 'shopping', 'ads'];
        _screenTimeLimit = 120; // 2 hours
      } else if (age >= 13 && age <= 15) {
        _selectedRestrictions = ['adult_content', 'violence', 'shopping'];
        _screenTimeLimit = 180; // 3 hours
      } else {
        _selectedRestrictions = ['adult_content', 'violence'];
        _screenTimeLimit = 240; // 4 hours
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied age-appropriate settings for $age years old'),
        backgroundColor: AppTheme.seaGreen,
        duration: const Duration(seconds: 2),
      ),
    );
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
      screenTimeLimit: _screenTimeLimit.toInt(),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Child'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Basic Information
                    _buildSectionTitle('Basic Information', Icons.person),
                    const SizedBox(height: 16),
                    _buildBasicInfoSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Screen Time Control
                    _buildSectionTitle('Screen Time Control', Icons.timer),
                    const SizedBox(height: 16),
                    _buildScreenTimeSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Content Restrictions
                    _buildSectionTitle('Content Restrictions', Icons.security),
                    const SizedBox(height: 8),
                    Text(
                      'Select what content to block for ${_nameController.text.isEmpty ? "your child" : _nameController.text}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRestrictionsSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Error Message
                    if (appProvider.errorMessage != null)
                      _buildErrorMessage(appProvider.errorMessage!),
                    
                    // Add Child Button
                    _buildAddButton(appProvider),
                    
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

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.seaGreen.withOpacity(0.1),
            AppTheme.seaGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.seaGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.seaGreen,
                  AppTheme.seaGreen.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.seaGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
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
              fontSize: 24,
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
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.seaGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.seaGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Child Name
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            validator: _validateName,
            decoration: InputDecoration(
              labelText: 'Child\'s Full Name',
              hintText: 'Enter your child\'s name',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.seaGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppTheme.seaGreen,
                  size: 20,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Age with auto-apply button
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: _validateAge,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: 'Enter age',
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.seaGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.cake_outlined,
                        color: AppTheme.seaGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (_ageController.text.isNotEmpty) {
                    final age = int.tryParse(_ageController.text);
                    if (age != null && age >= 3 && age <= 18) {
                      _applyAgeBasedDefaults(age);
                    }
                  }
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Auto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.seaGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Create an email for your child',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.seaGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: AppTheme.seaGreen,
                  size: 20,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Set a password for your child',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.seaGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppTheme.seaGreen,
                  size: 20,
                ),
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
        ],
      ),
    );
  }

  Widget _buildScreenTimeSection() {
    final hours = _screenTimeLimit ~/ 60;
    final minutes = _screenTimeLimit % 60;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Screen Time Limit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.seaGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hours > 0
                      ? '${hours}h ${minutes > 0 ? "${minutes}m" : ""}'
                      : '${minutes}m',
                  style: const TextStyle(
                    color: AppTheme.seaGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Slider(
            value: _screenTimeLimit,
            min: 30,
            max: 480,
            divisions: 45,
            activeColor: AppTheme.seaGreen,
            inactiveColor: Colors.grey.shade300,
            label: hours > 0
                ? '${hours}h ${minutes > 0 ? "${minutes}m" : ""}'
                : '${minutes}m',
            onChanged: (value) {
              setState(() {
                _screenTimeLimit = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '30 min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '8 hours',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictionsSection() {
    return Column(
      children: _restrictionOptions.map((restriction) {
        final isSelected = _selectedRestrictions.contains(restriction['id']);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? restriction['color'] : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: restriction['color'].withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
            activeColor: restriction['color'],
            title: Text(
              restriction['title'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? restriction['color'] : AppTheme.textBlack,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: restriction['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                restriction['icon'],
                color: restriction['color'],
                size: 24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(AppProvider appProvider) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: appProvider.isLoading ? null : _handleAddChild,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.seaGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: appProvider.isLoading ? 0 : 3,
          shadowColor: AppTheme.seaGreen.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: appProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Add Child',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.seaGreen),
            SizedBox(width: 8),
            Text('How to Add a Child'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Enter your child\'s basic information',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              '2. Set a daily screen time limit',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              '3. Select content restrictions',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              '4. Click "Add Child" to create the account',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text(
              '💡 Tip: Use the "Auto" button next to age to apply recommended settings automatically!',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(color: AppTheme.seaGreen),
            ),
          ),
        ],
      ),
    );
  }
}