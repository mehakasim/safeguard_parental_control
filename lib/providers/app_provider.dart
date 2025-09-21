import 'package:flutter/foundation.dart';

// Temporary enum for demo purposes (replace with actual service import later)
enum UserType { parent, child, unknown }

class AppProvider with ChangeNotifier {
  // Current user state
  bool _isLoggedIn = false;
  String? _currentUserId;
  String? _currentUserName;
  UserType? _userType;
  
  // App state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Children management (for parents)
  List<Map<String, dynamic>> _children = [];
  bool _childrenLoading = false;
  
  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  UserType? get userType => _userType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get children => _children;
  bool get childrenLoading => _childrenLoading;
  
  // Check if current user is parent or child
  bool get isParent => _userType == UserType.parent;
  bool get isChild => _userType == UserType.child;

  // AUTHENTICATION METHODS

  // Universal Login (Parent or Child) - DEMO VERSION
  Future<bool> login(String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Demo logic to determine user type based on email
      // In real implementation, this would come from Firebase
      UserType detectedUserType;
      if (email.toLowerCase().contains('parent') || 
          email.toLowerCase().contains('mom') || 
          email.toLowerCase().contains('dad')) {
        detectedUserType = UserType.parent;
      } else if (email.toLowerCase().contains('child') || 
                 email.toLowerCase().contains('kid')) {
        detectedUserType = UserType.child;
      } else {
        // Default to parent for demo
        detectedUserType = UserType.parent;
      }
      
      // Validate credentials (demo - any non-empty email/password works)
      if (email.isNotEmpty && password.isNotEmpty && password.length >= 3) {
        _isLoggedIn = true;
        _currentUserId = 'demo_${detectedUserType.name}_${DateTime.now().millisecondsSinceEpoch}';
        _currentUserName = email.split('@').first.replaceAll(RegExp(r'[0-9]'), '');
        _userType = detectedUserType;
        
        // If parent, load demo children
        if (_userType == UserType.parent) {
          await _loadDemoChildren();
        }
        
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError('Please enter valid credentials (password must be at least 3 characters)');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }
  
  // Parent Registration - DEMO VERSION
  Future<bool> parentRegister(String name, String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Validate inputs
      if (name.trim().isEmpty) {
        setError('Name is required');
        setLoading(false);
        return false;
      }
      
      if (email.trim().isEmpty || !email.contains('@')) {
        setError('Valid email is required');
        setLoading(false);
        return false;
      }
      
      if (password.length < 6) {
        setError('Password must be at least 6 characters');
        setLoading(false);
        return false;
      }
      
      // Demo success
      _isLoggedIn = true;
      _currentUserId = 'demo_parent_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserName = name;
      _userType = UserType.parent;
      _children = []; // New parent has no children
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Registration failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // CHILD MANAGEMENT METHODS (For Parents Only) - DEMO VERSION

  // Add Child Account
  Future<bool> addChildAccount({
    required String childName,
    required String childEmail,
    required String password,
    required int age,
    int screenTimeLimit = 120,
    List<String> restrictions = const [],
  }) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can add child accounts');
      return false;
    }

    setLoading(true);
    clearError();
    
    try {
      // Validate inputs
      if (childName.trim().isEmpty) {
        setError('Child name is required');
        setLoading(false);
        return false;
      }
      
      if (childEmail.trim().isEmpty || !childEmail.contains('@')) {
        setError('Valid email is required');
        setLoading(false);
        return false;
      }
      
      if (password.length < 6) {
        setError('Password must be at least 6 characters');
        setLoading(false);
        return false;
      }
      
      if (age < 3 || age > 18) {
        setError('Age must be between 3 and 18');
        setLoading(false);
        return false;
      }
      
      // Check if email already exists in demo children
      bool emailExists = _children.any((child) => 
          child['email']?.toString().toLowerCase() == childEmail.toLowerCase());
      
      if (emailExists) {
        setError('A child with this email already exists');
        setLoading(false);
        return false;
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Add new child to demo list
      final newChild = {
        'id': 'demo_child_${DateTime.now().millisecondsSinceEpoch}',
        'name': childName,
        'email': childEmail,
        'age': age,
        'parentId': _currentUserId,
        'screenTimeLimit': screenTimeLimit,
        'restrictions': restrictions,
        'isActive': true,
        'screenTime': 0, // Today's screen time
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      _children.add(newChild);
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to add child: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Update Child Password - DEMO VERSION
  Future<bool> updateChildPassword({
    required String childId,
    required String newPassword,
    required String parentPassword,
  }) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can update child passwords');
      return false;
    }

    setLoading(true);
    clearError();
    
    try {
      // Validate parent password (demo - just check it's not empty)
      if (parentPassword.isEmpty) {
        setError('Parent password is required');
        setLoading(false);
        return false;
      }
      
      if (newPassword.length < 6) {
        setError('New password must be at least 6 characters');
        setLoading(false);
        return false;
      }
      
      // Find child in demo list
      final childIndex = _children.indexWhere((child) => child['id'] == childId);
      if (childIndex == -1) {
        setError('Child not found');
        setLoading(false);
        return false;
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Demo success (in real implementation, password would be updated in Firebase)
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to update password: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Delete Child Account - DEMO VERSION
  Future<bool> deleteChildAccount({
    required String childId,
    required String parentPassword,
  }) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can delete child accounts');
      return false;
    }

    setLoading(true);
    clearError();
    
    try {
      // Validate parent password
      if (parentPassword.isEmpty) {
        setError('Parent password is required');
        setLoading(false);
        return false;
      }
      
      // Find child in demo list
      final childIndex = _children.indexWhere((child) => child['id'] == childId);
      if (childIndex == -1) {
        setError('Child not found');
        setLoading(false);
        return false;
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove child from demo list
      _children.removeAt(childIndex);
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to delete child account: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Load Demo Children (for testing purposes)
  Future<void> _loadDemoChildren() async {
    _childrenLoading = true;
    notifyListeners();
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Demo children data
      _children = [
        {
          'id': 'demo_child_1',
          'name': 'Emma Johnson',
          'email': 'emma.child@example.com',
          'age': 10,
          'parentId': _currentUserId,
          'screenTimeLimit': 120, // 2 hours
          'restrictions': ['adult_content', 'social_media', 'violence'],
          'isActive': true,
          'screenTime': 45, // 45 minutes used today
          'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        },
        {
          'id': 'demo_child_2',
          'name': 'Alex Johnson',
          'email': 'alex.child@example.com',
          'age': 8,
          'parentId': _currentUserId,
          'screenTimeLimit': 90, // 1.5 hours
          'restrictions': ['adult_content', 'social_media', 'violence', 'shopping'],
          'isActive': true,
          'screenTime': 30, // 30 minutes used today
          'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        },
      ];
    } catch (e) {
      setError('Failed to load children: ${e.toString()}');
    }
    
    _childrenLoading = false;
    notifyListeners();
  }

  // Refresh Children List
  Future<void> refreshChildren() async {
    if (!isParent) return;
    await _loadDemoChildren();
  }

  // Update Child Settings - DEMO VERSION
  Future<bool> updateChildSettings({
    required String childId,
    String? name,
    int? age,
    int? screenTimeLimit,
    List<String>? restrictions,
  }) async {
    if (!isParent || _currentUserId == null) {
      setError('Only parents can update child settings');
      return false;
    }

    setLoading(true);
    clearError();
    
    try {
      // Find child in demo list
      final childIndex = _children.indexWhere((child) => child['id'] == childId);
      if (childIndex == -1) {
        setError('Child not found');
        setLoading(false);
        return false;
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update child data in demo list
      final child = _children[childIndex];
      if (name != null) child['name'] = name;
      if (age != null) child['age'] = age;
      if (screenTimeLimit != null) child['screenTimeLimit'] = screenTimeLimit;
      if (restrictions != null) child['restrictions'] = restrictions;
      child['updatedAt'] = DateTime.now().toIso8601String();
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update child settings: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Get specific child by ID
  Map<String, dynamic>? getChildById(String childId) {
    try {
      return _children.firstWhere((child) => child['id'] == childId);
    } catch (e) {
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      // In real implementation, call Firebase sign out
      // await _authService.signOut();
      
      // Simulate logout delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Handle error if needed
    }
    
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _userType = null;
    _children = [];
    clearError();
    notifyListeners();
  }
  
  // Utility methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Demo data methods (for development and testing)
  Map<String, dynamic> getDemoScreenTimeData() {
    return {
      'today': {
        'total': 165,
        'limit': 240,
        'apps': [
          {'name': 'Educational Apps', 'time': 45, 'icon': 'school'},
          {'name': 'Games', 'time': 60, 'icon': 'games'},
          {'name': 'YouTube Kids', 'time': 40, 'icon': 'video'},
          {'name': 'Other', 'time': 20, 'icon': 'apps'},
        ]
      },
      'week': [
        {'day': 'Mon', 'time': 120},
        {'day': 'Tue', 'time': 140},
        {'day': 'Wed', 'time': 100},
        {'day': 'Thu', 'time': 160},
        {'day': 'Fri', 'time': 180},
        {'day': 'Sat', 'time': 200},
        {'day': 'Sun', 'time': 165},
      ]
    };
  }

  // Get child's screen time for today
  int getChildScreenTimeToday(String childId) {
    final child = getChildById(childId);
    return child?['screenTime'] ?? 0;
  }

  // Get child's screen time limit
  int getChildScreenTimeLimit(String childId) {
    final child = getChildById(childId);
    return child?['screenTimeLimit'] ?? 120;
  }

  // Check if child has exceeded screen time
  bool hasChildExceededScreenTime(String childId) {
    final screenTime = getChildScreenTimeToday(childId);
    final limit = getChildScreenTimeLimit(childId);
    return screenTime >= limit;
  }

  // Get screen time progress (0.0 to 1.0)
  double getChildScreenTimeProgress(String childId) {
    final screenTime = getChildScreenTimeToday(childId);
    final limit = getChildScreenTimeLimit(childId);
    if (limit == 0) return 0.0;
    return (screenTime / limit).clamp(0.0, 1.0);
  }

  // Format screen time for display
  String formatScreenTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}