// lib/screens/admin/widgets/admin_parents_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/theme.dart';

class AdminParentsTab extends StatefulWidget {
  const AdminParentsTab({Key? key}) : super(key: key);

  @override
  State<AdminParentsTab> createState() => _AdminParentsTabState();
}

class _AdminParentsTabState extends State<AdminParentsTab> {
  List<Map<String, dynamic>> _parents = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadParents();
  }

  Future<void> _loadParents() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final parents = await provider.getAllParents();
    setState(() {
      _parents = parents;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredParents {
    if (_searchQuery.isEmpty) return _parents;
    return _parents.where((parent) {
      final name = parent['name']?.toString().toLowerCase() ?? '';
      final email = parent['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search parents...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // Parents List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredParents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No parents found' : 'No matching parents',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadParents,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredParents.length,
                        itemBuilder: (context, index) {
                          final parent = _filteredParents[index];
                          return _buildParentCard(parent);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildParentCard(Map<String, dynamic> parent) {
    final childrenCount = parent['childrenCount'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.seaGreen.withOpacity(0.1),
          child: Text(
            parent['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(
              color: AppTheme.seaGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          parent['name']?.toString() ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    parent['email']?.toString() ?? 'No email',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.child_care, size: 14, color: AppTheme.seaGreen),
                const SizedBox(width: 4),
                Text(
                  '$childrenCount ${childrenCount == 1 ? 'child' : 'children'}',
                  style: const TextStyle(
                    color: AppTheme.seaGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleParentAction(value, parent),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_children',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Text('View Children'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Delete Account', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleParentAction(String action, Map<String, dynamic> parent) async {
    switch (action) {
      case 'view_children':
        _showChildrenDialog(parent);
        break;
      case 'delete':
        _showDeleteDialog(parent);
        break;
    }
  }

  void _showChildrenDialog(Map<String, dynamic> parent) async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final children = await provider.getChildrenByParent(parent['id']);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${parent['name']}\'s Children'),
        content: SizedBox(
          width: double.maxFinite,
          child: children.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No children found'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.seaGreen.withOpacity(0.1),
                        child: Text(
                          child['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(color: AppTheme.seaGreen),
                        ),
                      ),
                      title: Text(child['name'] ?? 'Unknown'),
                      subtitle: Text('Age: ${child['age'] ?? 'N/A'}'),
                      trailing: Icon(
                        child['isActive'] == true ? Icons.check_circle : Icons.cancel,
                        color: child['isActive'] == true ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
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

  void _showDeleteDialog(Map<String, dynamic> parent) {
    showDialog(
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
              child: Icon(Icons.warning, color: Colors.red.shade700),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Parent Account',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${parent['name']}\'s account?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ This will permanently:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem('Delete parent account'),
                  _buildWarningItem('Delete all associated children'),
                  _buildWarningItem('Remove all data'),
                  const SizedBox(height: 8),
                  Text(
                    'This action cannot be undone!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              final provider = Provider.of<AdminProvider>(context, listen: false);
              final success = await provider.deleteParentAccount(parent['id']);

              if (mounted) {
                Navigator.pop(context); // Close loading
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Parent account deleted successfully'),
                      backgroundColor: AppTheme.seaGreen,
                    ),
                  );
                  _loadParents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to delete account'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}