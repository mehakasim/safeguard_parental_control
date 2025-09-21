// lib/screens/dashboard/widgets/children_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../utils/theme.dart';
import '../../children/add_child_screen.dart';
import 'child_quick_actions.dart';

class ChildrenTab extends StatelessWidget {
  const ChildrenTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.childrenLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading children...'),
              ],
            ),
          );
        }

        final children = provider.children;

        if (children.isEmpty) {
          return _buildEmptyChildrenState(context);
        }

        return Column(
          children: [
            // Header with stats
            _buildHeaderCard(children),
            
            // Children list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.refreshChildren();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return _ChildListItem(
                      child: child,
                      provider: provider,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCard(List<Map<String, dynamic>> children) {
    final activeToday = children.where((c) => (c['screenTime'] ?? 0) > 0).length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.seaGreen, AppTheme.seaGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.family_restroom, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${children.length} ${children.length == 1 ? 'Child' : 'Children'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$activeToday active today',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(children.fold<num>(0, (sum, c) => sum + (c['screenTime'] ?? 0)) / 60).toStringAsFixed(1)}h',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChildrenState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.seaGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom,
                size: 80,
                color: AppTheme.seaGreen,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Children Added',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add your first child to start monitoring their digital activity and keeping them safe online.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddChildScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add First Child',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildListItem extends StatelessWidget {
  final Map<String, dynamic> child;
  final AppProvider provider;

  const _ChildListItem({
    required this.child,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final screenTime = child['screenTime'] ?? 0;
    final limit = child['screenTimeLimit'] ?? 120;
    final isOverLimit = screenTime > limit;
    final restrictions = child['restrictions'] as List? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverLimit ? Border.all(color: Colors.red.shade300, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildAvatar(isOverLimit),
        title: _buildTitle(isOverLimit),
        subtitle: _buildSubtitle(screenTime, limit, restrictions),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppTheme.seaGreen, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => ChildQuickActions.show(context, child),
      ),
    );
  }

  Widget _buildAvatar(bool isOverLimit) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.seaGreen.withOpacity(0.1),
          child: Text(
            child['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(
              color: AppTheme.seaGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        if (isOverLimit)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(bool isOverLimit) {
    return Row(
      children: [
        Expanded(
          child: Text(
            child['name']?.toString() ?? 'Unknown',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        if (isOverLimit)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Over Limit',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubtitle(int screenTime, int limit, List restrictions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.cake, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text('${child['age'] ?? 'Unknown'} years old'),
            const SizedBox(width: 12),
            Icon(Icons.email, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                child['email']?.toString() ?? 'No email',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.timer, size: 14, color: AppTheme.seaGreen),
            const SizedBox(width: 4),
            Text(
              'Today: ${provider.formatScreenTime(screenTime)} / ${provider.formatScreenTime(limit)}',
              style: TextStyle(
                color: screenTime > limit ? Colors.red : AppTheme.seaGreen,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.security, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              '${restrictions.length} restrictions active',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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
            Text('Delete Child Account'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${child['name']}\'s account?\n\nThis will:\n• Remove their account permanently\n• Delete all their data\n• Cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit child feature coming soon!')),
        );
        break;
      case 'details':
        ChildQuickActions.show(context, child);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }
}