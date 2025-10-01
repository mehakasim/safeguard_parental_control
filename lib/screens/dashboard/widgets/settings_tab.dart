// lib/screens/dashboard/widgets/settings_tab.dart
import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Account Settings
          _buildSettingsSection(
            context,
            'Account Settings',
            Icons.person,
            AppTheme.seaGreen,
            [
              _buildSettingsItem('Profile Information', Icons.edit, () {
                _showComingSoon(context, 'Profile settings');
              }),
              _buildSettingsItem('Change Password', Icons.lock, () {
                _showComingSoon(context, 'Change password');
              }),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // App version and info
          _buildAppInfo(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textGrey),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textGrey),
      onTap: onTap,
    );
  }

  Widget _buildAppInfo() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.seaGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.family_restroom,
              color: AppTheme.seaGreen,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SafeGuard Parental Control',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keeping families safe in the digital world',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Screen Time Alerts'),
              subtitle: const Text('Get notified when children exceed limits'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Daily Reports'),
              subtitle: const Text('Receive daily activity summaries'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Safety Alerts'),
              subtitle: const Text('Alerts for blocked content attempts'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Common Questions:'),
            SizedBox(height: 8),
            Text('• How do I add a child?'),
            Text('• How to set screen time limits?'),
            Text('• Managing content restrictions'),
            Text('• Understanding reports'),
            Text('• Troubleshooting issues'),
            SizedBox(height: 16),
            Text('For more help, contact our support team.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? We\'re here for you!'),
            SizedBox(height: 16),
            Text('📧 Email: support@safeguard.com'),
            Text('📞 Phone: 1-800-SAFEGUARD'),
            Text('💬 Live Chat: Available in app'),
            SizedBox(height: 16),
            Text('Support Hours:'),
            Text('Monday - Friday: 9 AM - 8 PM'),
            Text('Saturday - Sunday: 10 AM - 6 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening support chat...')),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.seaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.family_restroom,
                color: AppTheme.seaGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('About SafeGuard'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SafeGuard Parental Control helps parents keep their children safe in the digital world.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text('• Screen time monitoring'),
            Text('• Content filtering'),
            Text('• App usage tracking'),
            Text('• Real-time alerts'),
            Text('• Multiple child profiles'),
            Text('• Family reports'),
            SizedBox(height: 16),
            Text(
              'Mission:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text('Empowering parents to create healthy digital habits for their families.'),
            SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              ),
            ),
            Text(
              '© 2024 SafeGuard Technologies',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.seaGreen),
            ),
          ),
        ],
      ),
    );
  }
}