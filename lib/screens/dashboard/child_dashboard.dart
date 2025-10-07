// lib/screens/dashboard/child_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safeguard_parental_control/services/screen_time_service.dart';
import '../../providers/app_provider.dart';
import '../../utils/theme.dart';
import 'child/child_home_tab.dart';
import 'child/child_apps_tab.dart';
import 'child/child_settings_screen.dart';

class ChildDashboard extends StatefulWidget {
  const ChildDashboard({Key? key}) : super(key: key);

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _screenTimeService = ScreenTimeService();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.currentUserId != null) {
      _screenTimeService.startTracking(provider.currentUserId!);
    }
  }

  /// Firestore stream of the child's document
  Stream<DocumentSnapshot<Map<String, dynamic>>> _childStream(String childId) {
    return _firestore.collection('children').doc(childId).snapshots();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: Colors.red.shade700),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          )
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.logout();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final childId = provider.currentUserId;

    if (childId == null) {
      return const Scaffold(
        body: Center(child: Text('No child logged in')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _childStream(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: const Center(
              child: CircularProgressIndicator(color: AppTheme.seaGreen),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: const Center(child: Text('Child profile not found')),
          );
        }

        final childData = snapshot.data!.data()!;
        return _buildDashboard(childData);
      },
    );
  }

  /// Builds the main dashboard UI with tabs and nav
  Widget _buildDashboard(Map<String, dynamic> childData) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(childData),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            ChildHomeTab(
              childData: childData,
              onRefresh: () {}, // not needed anymore
            ),
            ChildAppsTab(
              restrictions: childData['restrictions'] ?? [],
            ),
            const ChildSettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Builds the AppBar and shows live-updating screenTime
  PreferredSizeWidget _buildAppBar(Map<String, dynamic> childData) {
    final int screenTime = childData['screenTime'] ?? 0;

    return AppBar(
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'SafeGuard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Hi, ${childData['name'] ?? 'User'}!',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: _showHelpDialog,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info, color: AppTheme.seaGreen),
                  SizedBox(width: 8),
                  Text('About'),
                ],
              ),
            ),
            const PopupMenuItem(
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
    );
  }

  void _handleMenuAction(String value) {
    if (value == 'logout') {
      _handleLogout();
    } else if (value == 'about') {
      _showAboutDialog();
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.help_outline, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            const Text('Help'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Here are some tips:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text('• Check your screen time in the Home tab'),
            Text('• Find safe apps in the Apps tab'),
            Text('• View your profile in Settings'),
            SizedBox(height: 12),
            Text('If you need more help, ask your parent!', style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!', style: TextStyle(color: AppTheme.seaGreen)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.seaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield_rounded, color: AppTheme.seaGreen, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('About SafeGuard'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SafeGuard helps keep you safe while exploring the digital world.', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 8),
            Text('• Screen time tracking'),
            Text('• Safe content filtering'),
            Text('• Educational resources'),
            Text('• Fun and safe apps'),
            SizedBox(height: 16),
            Text('Version: 1.0.0', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.seaGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.apps_rounded, 'Apps', 1),
              _buildNavItem(Icons.settings_rounded, 'Settings', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.seaGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppTheme.seaGreen : Colors.grey, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.seaGreen : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
