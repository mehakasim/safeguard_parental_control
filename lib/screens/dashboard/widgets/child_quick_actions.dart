// lib/screens/dashboard/widgets/child_quick_actions.dart
import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class ChildQuickActions {
  static void show(BuildContext context, Map<String, dynamic> child) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ChildQuickActionsSheet(child: child),
    );
  }
}

class _ChildQuickActionsSheet extends StatelessWidget {
  final Map<String, dynamic> child;

  const _ChildQuickActionsSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.seaGreen.withOpacity(0.1),
                child: Text(
                  child['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(
                    color: AppTheme.seaGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                child['name']?.toString() ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Action Items
          _buildActionItem(
            context,
            'Edit Settings',
            Icons.edit,
            AppTheme.seaGreen,
            () => _handleEditSettings(context),
          ),
          
          _buildActionItem(
            context,
            'Pause Device',
            Icons.pause_circle,
            Colors.orange,
            () => _handlePauseDevice(context),
          ),
          
          _buildActionItem(
            context,
            'Add Time',
            Icons.add_circle,
            Colors.blue,
            () => _showAddTimeDialog(context),
          ),
          
          _buildActionItem(
            context,
            'View Details',
            Icons.info_outline,
            Colors.purple,
            () => _showChildDetails(context),
          ),
          
          const Divider(),
          
          _buildActionItem(
            context,
            'Remove Child',
            Icons.delete,
            Colors.red,
            () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _handleEditSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit settings coming soon!')),
    );
  }

  void _handlePauseDevice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device pause feature coming soon!')),
    );
  }

  void _showAddTimeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Time for ${child['name']}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How much additional time would you like to add?'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added 30 minutes!')),
              );
            },
            child: const Text('Add 30 min'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added 1 hour!')),
              );
            },
            child: const Text('Add 1 hour'),
          ),
        ],
      ),
    );
  }

  void _showChildDetails(BuildContext context) {
    final restrictions = child['restrictions'] as List? ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${child['name']} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Age', '${child['age'] ?? 'Unknown'} years old'),
            _buildDetailRow('Email', child['email'] ?? 'Not set'),
            _buildDetailRow('Screen Time Limit', '${child['screenTimeLimit'] ?? 120} minutes/day'),
            _buildDetailRow('Restrictions', '${restrictions.length} active'),
            if (restrictions.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Active Restrictions:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...restrictions.map((r) => Text(
                '• ${_getRestrictionName(r.toString())}',
                style: const TextStyle(fontSize: 12),
              )),
            ],
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Remove Child'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${child['name']}?\n\nThis will:\n• Delete their account permanently\n• Remove all their data\n• Cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Remove child feature coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRestrictionName(String restriction) {
    const restrictionMap = {
      'adult_content': 'Adult Content',
      'social_media': 'Social Media',
      'gaming': 'Gaming',
      'shopping': 'Online Shopping',
      'violence': 'Violence',
      'ads': 'Advertisements',
    };
    return restrictionMap[restriction] ?? restriction;
  }
}