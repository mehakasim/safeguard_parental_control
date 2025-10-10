// lib/screens/children/child_view_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/theme.dart';
import 'edit_child_screen.dart';

class ChildViewScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const ChildViewScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ChildViewScreen> createState() => _ChildViewScreenState();
}

class _ChildViewScreenState extends State<ChildViewScreen> {
  void _showDeleteDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_rounded,
                  color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Account?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete ${widget.child['name']}\'s account permanently?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'This will remove:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDeleteItem('Account & profile'),
                  _buildDeleteItem('Activity history'),
                  _buildDeleteItem('All settings'),
                  const SizedBox(height: 12),
                  Text(
                    'This action cannot be undone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                      fontSize: 13,
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final success = await provider.deleteChildComplete(
                widget.child['id'],
                widget.child['email'],
              );

              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          success ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          success
                              ? '${widget.child['name']}\'s account deleted'
                              : 'Failed to delete account',
                        ),
                      ],
                    ),
                    backgroundColor: success ? AppTheme.seaGreen : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final currentChild =
            provider.getChildById(widget.child['id']) ?? widget.child;
        final screenTime = currentChild['screenTime'] ?? 0;
        final limit = currentChild['screenTimeLimit'] ?? 120;
        final restrictions = currentChild['restrictions'] as List? ?? [];
        final isOverLimit = screenTime > limit;
        final isActive = currentChild['isActive'] ?? true;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.seaGreen,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.seaGreen,
                          AppTheme.seaGreen.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          // Avatar
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                currentChild['name']
                                        ?.toString()
                                        .substring(0, 1)
                                        .toUpperCase() ??
                                    '?',
                                style: const TextStyle(
                                  color: AppTheme.seaGreen,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            currentChild['name'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Age Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentChild['age'] ?? 'Unknown'} years old',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditChildScreen(child: currentChild),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context, provider);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded,
                                color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Delete Account',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screen Time Card
                      _buildScreenTimeCard(
                          screenTime, limit, isOverLimit, provider),
                      const SizedBox(height: 16),

                      // Quick Stats Grid
                      _buildQuickStatsGrid(
                          currentChild, restrictions, provider),
                      const SizedBox(height: 24),

                      // Personal Information
                      _buildSectionTitle(
                          'Personal Information', Icons.person_rounded),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildInfoTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: currentChild['name'] ?? 'Unknown',
                          color: Colors.blue,
                        ),
                        _buildInfoTile(
                          icon: Icons.cake_rounded,
                          label: 'Age',
                          value: '${currentChild['age'] ?? 'Unknown'} years',
                          color: Colors.purple,
                        ),
                        _buildInfoTile(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: currentChild['email'] ?? 'Not set',
                          color: Colors.orange,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Active Restrictions
                      _buildSectionTitle(
                          'Content Restrictions', Icons.security_rounded),
                      const SizedBox(height: 12),
                      _buildRestrictionsGrid(restrictions),
                      const SizedBox(height: 24),

                      // Account Status
                      _buildSectionTitle(
                          'Account Status', Icons.admin_panel_settings_rounded),
                      const SizedBox(height: 12),
                      _buildStatusCard(currentChild),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScreenTimeCard(
      int screenTime, int limit, bool isOverLimit, AppProvider provider) {
    final percentage = (screenTime / limit * 100).clamp(0, 100);
    final remaining = (limit - screenTime).clamp(0, limit);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverLimit
              ? [Colors.red.shade400, Colors.red.shade600]
              : [AppTheme.seaGreen, AppTheme.seaGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (isOverLimit ? Colors.red : AppTheme.seaGreen).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timer_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Screen Time Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isOverLimit)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Over Limit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeDisplay('Used', provider.formatScreenTime(screenTime)),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildTimeDisplay('Limit', provider.formatScreenTime(limit)),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildTimeDisplay('Left', provider.formatScreenTime(remaining)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(0)}% of daily limit used',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsGrid(
      Map<String, dynamic> child, List restrictions, AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            icon: Icons.security_rounded,
            label: 'Restrictions',
            value: '${restrictions.length}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            icon: Icons.check_circle_rounded,
            label: 'Status',
            value: child['isActive'] == true ? 'Active' : 'Inactive',
            color: child['isActive'] == true ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textGrey,
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.seaGreen, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictionsGrid(List restrictions) {
    final allRestrictions = [
      {
        'id': 'adult_content',
        'name': 'Adult Content',
        'description': 'Block mature and explicit content',
        'icon': Icons.block_rounded,
        'color': Colors.red
      },
      {
        'id': 'social_media',
        'name': 'Social Media',
        'description': 'Restrict access to social platforms',
        'icon': Icons.people_rounded,
        'color': Colors.blue
      },
      {
        'id': 'gaming',
        'name': 'Gaming',
        'description': 'Control gaming apps and websites',
        'icon': Icons.sports_esports_rounded,
        'color': Colors.purple
      },
      {
        'id': 'shopping',
        'name': 'Shopping',
        'description': 'Block shopping and purchase sites',
        'icon': Icons.shopping_cart_rounded,
        'color': Colors.orange
      },
      {
        'id': 'violence',
        'name': 'Violence',
        'description': 'Filter violent content',
        'icon': Icons.warning_rounded,
        'color': Colors.deepOrange
      },
      {
        'id': 'ads',
        'name': 'Advertisements',
        'description': 'Block ads and sponsored content',
        'icon': Icons.ad_units_rounded,
        'color': Colors.amber
      },
    ];

    return Column(
      children: allRestrictions.map((restriction) {
        final isActive = restrictions.contains(restriction['id']);
        final color = restriction['color'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : Colors.grey.shade300,
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  restriction['icon'] as IconData,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restriction['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isActive ? color : AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restriction['description'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? color : AppTheme.textGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> child) {
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
          _buildStatusRow(
            Icons.check_circle_rounded,
            'Account Status',
            child['isActive'] == true ? 'Active' : 'Inactive',
            child['isActive'] == true ? Colors.green : Colors.red,
          ),
          const Divider(height: 32),
          _buildStatusRow(
            Icons.calendar_today_rounded,
            'Created',
            _formatDate(child['createdAt']),
            Colors.blue,
          ),
          const Divider(height: 32),
          _buildStatusRow(
            Icons.update_rounded,
            'Last Updated',
            _formatDate(child['updatedAt']),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown';

    DateTime? date;

    if (dateValue is Timestamp) {
      // ✅ Firestore Timestamp
      date = dateValue.toDate();
    } else if (dateValue is String) {
      // ✅ Already stored as String
      try {
        date = DateTime.parse(dateValue);
      } catch (_) {
        return 'Unknown';
      }
    } else if (dateValue is DateTime) {
      // ✅ Just in case you already have DateTime
      date = dateValue;
    } else {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
