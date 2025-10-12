// lib/screens/admin/widgets/admin_children_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/theme.dart';

class AdminChildrenTab extends StatefulWidget {
  const AdminChildrenTab({Key? key}) : super(key: key);

  @override
  State<AdminChildrenTab> createState() => _AdminChildrenTabState();
}

class _AdminChildrenTabState extends State<AdminChildrenTab> {
  List<Map<String, dynamic>> _children = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all'; 

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final children = await provider.getAllChildren();
    setState(() {
      _children = children;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredChildren {
    var filtered = _children;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((child) {
        final name = child['name']?.toString().toLowerCase() ?? '';
        final email = child['email']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_filterStatus != 'all') {
      final isActive = _filterStatus == 'active';
      filtered = filtered.where((child) => child['isActive'] == isActive).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search children...',
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
              const SizedBox(height: 12),

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Inactive', 'inactive'),
                ],
              ),
            ],
          ),
        ),

        // Children List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredChildren.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No children found' : 'No matching children',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadChildren,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredChildren.length,
                        itemBuilder: (context, index) {
                          final child = _filteredChildren[index];
                          return _buildChildCard(child);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: AppTheme.seaGreen.withOpacity(0.2),
      checkmarkColor: AppTheme.seaGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.seaGreen : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    final isActive = child['isActive'] ?? true;
    final screenTime = child['screenTime'] ?? 0;
    final screenTimeLimit = child['screenTimeLimit'] ?? 120;
    final provider = Provider.of<AdminProvider>(context, listen: false);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: !isActive ? Border.all(color: Colors.red.shade300, width: 2) : null,
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
        leading: Stack(
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
            if (!isActive)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Row(
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
            if (!isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.cake, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${child['age'] ?? 'N/A'} years old'),
                const SizedBox(width: 12),
                Icon(Icons.email, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    child['email']?.toString() ?? 'No email',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 14, color: AppTheme.seaGreen),
                const SizedBox(width: 4),
                Text(
                  'Screen Time: ${provider.formatScreenTime(screenTime)} / ${provider.formatScreenTime(screenTimeLimit)}',
                  style: const TextStyle(
                    color: AppTheme.seaGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleChildAction(value, child),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.block : Icons.check_circle,
                    color: isActive ? Colors.orange : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view_details',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Text('View Details'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChildAction(String action, Map<String, dynamic> child) async {
    switch (action) {
      case 'toggle_status':
        _toggleChildStatus(child);
        break;
      case 'view_details':
        _showChildDetails(child);
        break;
    }
  }

  void _toggleChildStatus(Map<String, dynamic> child) async {
    final isActive = child['isActive'] ?? true;
    final newStatus = !isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus ? 'Activate' : 'Deactivate'} Child Account'),
        content: Text(
          'Are you sure you want to ${newStatus ? 'activate' : 'deactivate'} ${child['name']}\'s account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(newStatus ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final success = await provider.toggleChildStatus(child['id'], newStatus);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Child account ${newStatus ? 'activated' : 'deactivated'} successfully'),
              backgroundColor: AppTheme.seaGreen,
            ),
          );
          _loadChildren();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to update status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showChildDetails(Map<String, dynamic> child) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final screenTime = child['screenTime'] ?? 0;
    final screenTimeLimit = child['screenTimeLimit'] ?? 120;
    final restrictions = child['restrictions'] as List? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${child['name']}\'s Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', child['name'] ?? 'Unknown'),
              _buildDetailRow('Email', child['email'] ?? 'No email'),
              _buildDetailRow('Age', '${child['age'] ?? 'N/A'} years'),
              _buildDetailRow(
                'Status',
                child['isActive'] == true ? 'Active' : 'Inactive',
                valueColor: child['isActive'] == true ? Colors.green : Colors.red,
              ),
              const Divider(height: 24),
              _buildDetailRow(
                'Screen Time Today',
                provider.formatScreenTime(screenTime),
              ),
              _buildDetailRow(
                'Screen Time Limit',
                provider.formatScreenTime(screenTimeLimit),
              ),
              const Divider(height: 24),
              const Text(
                'Restrictions:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (restrictions.isEmpty)
                const Text('No restrictions applied', style: TextStyle(color: Colors.grey))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: restrictions.map((r) => Chip(
                    label: Text(r.toString()),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                  )).toList(),
                ),
            ],
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

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}