// lib/screens/children/edit_child_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/theme.dart';

class EditChildScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const EditChildScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  
  double _screenTimeLimit = 120;
  List<String> _selectedRestrictions = [];
  bool _isLoading = false;
  
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
  void initState() {
    super.initState();
    _nameController.text = widget.child['name'] ?? '';
    _emailController.text = widget.child['email'] ?? '';
    _ageController.text = widget.child['age']?.toString() ?? '';
    _screenTimeLimit = (widget.child['screenTimeLimit'] ?? 120).toDouble();
    _selectedRestrictions = List<String>.from(widget.child['restrictions'] ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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

  Future<void> _handleUpdateChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      final success = await appProvider.updateChild(
        childId: widget.child['id'],
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.parse(_ageController.text),
        screenTimeLimit: _screenTimeLimit.toInt(),
        restrictions: _selectedRestrictions,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('${_nameController.text}\'s profile updated successfully'),
              ],
            ),
            backgroundColor: AppTheme.seaGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('Failed to update profile. Please try again.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Child Profile'),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
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
                
                // Update Button
                _buildUpdateButton(),
                
                const SizedBox(height: 24),
              ],
            ),
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
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.seaGreen,
                  AppTheme.seaGreen.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.seaGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.child['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Editing profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
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
          
          TextFormField(
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
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'child@example.com',
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

  Widget _buildUpdateButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleUpdateChild,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.seaGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: _isLoading ? 0 : 3,
          shadowColor: AppTheme.seaGreen.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
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
                  Icon(Icons.save, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Save Changes',
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
}