// lib/screens/children/child_view_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/app_provider.dart';
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

class _ChildViewScreenState extends State<ChildViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              child: Icon(Icons.warning, color: Colors.red.shade700),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Child Account',
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
              'Are you sure you want to delete ${widget.child['name']}\'s account?',
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
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action will:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDeleteWarningItem('Remove their account permanently'),
                  _buildDeleteWarningItem('Delete all activity logs'),
                  _buildDeleteWarningItem('Remove all screen time data'),
                  _buildDeleteWarningItem('Delete restriction settings'),
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ This action cannot be undone',
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
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Show loading
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
                Navigator.pop(context); // Close loading

                if (success) {
                  Navigator.pop(context); // Go back to previous screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('${widget.child['name']}\'s account deleted'),
                        ],
                      ),
                      backgroundColor: AppTheme.seaGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Failed to delete account'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade700,
              ),
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
        // Get updated child data
        final currentChild =
            provider.getChildById(widget.child['id']) ?? widget.child;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomScrollView(
            slivers: [
              // App Bar with gradient
              _buildSliverAppBar(context, provider, currentChild),

              // Stats Cards
              SliverToBoxAdapter(
                child: _buildStatsCards(currentChild),
              ),

              // Tabs
              SliverToBoxAdapter(
                child: _buildTabs(),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(currentChild),
                    _buildActivityTab(currentChild),
                    _buildRestrictionsTab(currentChild),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppProvider provider,
      Map<String, dynamic> currentChild) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.seaGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.seaGreen,
                AppTheme.seaGreen.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Center(
                // 👈 ensures everything stays centered
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 👈 important
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // reduced height
                    Flexible(
                      child: Text(
                        currentChild['name'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        '${currentChild['age'] ?? 'Unknown'} years old',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditChildScreen(child: currentChild),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
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
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete Account', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> child) {
    final screenTime = child['screenTime'] ?? 0;
    final limit = child['screenTimeLimit'] ?? 120;
    final percentage = (screenTime / limit * 100).clamp(0, 100).toInt();
    final restrictions = child['restrictions'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.timer,
              title: 'Screen Time',
              value: Provider.of<AppProvider>(context, listen: false)
                  .formatScreenTime(screenTime),
              subtitle:
                  'of ${Provider.of<AppProvider>(context, listen: false).formatScreenTime(limit)}',
              color: screenTime > limit ? Colors.red : AppTheme.seaGreen,
              progress: percentage / 100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.security,
              title: 'Restrictions',
              value: '${restrictions.length}',
              subtitle: 'active',
              color: Colors.orange,
              progress: restrictions.length / 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.seaGreen,
        unselectedLabelColor: AppTheme.textGrey,
        indicator: BoxDecoration(
          color: AppTheme.seaGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.history),
            text: 'Activity',
          ),
          Tab(
            icon: Icon(Icons.security),
            text: 'Restrictions',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> child) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoSection(
          title: 'Personal Information',
          icon: Icons.person,
          children: [
            _buildInfoRow(
                'Full Name', child['name'] ?? 'Unknown', Icons.person_outline),
            _buildInfoRow('Age', '${child['age'] ?? 'Unknown'} years',
                Icons.cake_outlined),
            _buildInfoRow(
                'Email', child['email'] ?? 'Not set', Icons.email_outlined),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoSection(
          title: 'Screen Time Settings',
          icon: Icons.timer,
          children: [
            _buildInfoRow(
              'Daily Limit',
              Provider.of<AppProvider>(context, listen: false)
                  .formatScreenTime(child['screenTimeLimit'] ?? 120),
              Icons.access_time,
            ),
            _buildInfoRow(
              'Today\'s Usage',
              Provider.of<AppProvider>(context, listen: false)
                  .formatScreenTime(child['screenTime'] ?? 0),
              Icons.phone_android,
            ),
            _buildInfoRow(
              'Remaining Time',
              Provider.of<AppProvider>(context, listen: false).formatScreenTime(
                ((child['screenTimeLimit'] ?? 120) - (child['screenTime'] ?? 0))
                    .clamp(0, 10000),
              ),
              Icons.hourglass_bottom,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoSection(
          title: 'Account Details',
          icon: Icons.admin_panel_settings,
          children: [
            _buildInfoRow(
              'Account Created',
              _formatDate(child['createdAt']),
              Icons.calendar_today,
            ),
            _buildInfoRow(
              'Account Status',
              'Active',
              Icons.check_circle,
              valueColor: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityTab(Map<String, dynamic> child) {
    // Mock activity data - replace with real data from Firebase
    final activities = [
      {
        'app': 'YouTube',
        'time': '45 min',
        'icon': Icons.play_circle,
        'color': Colors.red,
        'timestamp': '2 hours ago',
      },
      {
        'app': 'Instagram',
        'time': '30 min',
        'icon': Icons.camera_alt,
        'color': Colors.pink,
        'timestamp': '4 hours ago',
      },
      {
        'app': 'TikTok',
        'time': '25 min',
        'icon': Icons.music_note,
        'color': Colors.black,
        'timestamp': '5 hours ago',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Activity tracking will be available once child device is connected',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['app'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['timestamp'] as String,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.seaGreen,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictionsTab(Map<String, dynamic> child) {
    final restrictions = child['restrictions'] as List? ?? [];

    final allRestrictions = [
      {
        'id': 'adult_content',
        'name': 'Adult Content',
        'icon': Icons.block,
        'color': Colors.red
      },
      {
        'id': 'social_media',
        'name': 'Social Media',
        'icon': Icons.people,
        'color': Colors.blue
      },
      {
        'id': 'gaming',
        'name': 'Gaming',
        'icon': Icons.games,
        'color': Colors.purple
      },
      {
        'id': 'shopping',
        'name': 'Shopping',
        'icon': Icons.shopping_cart,
        'color': Colors.orange
      },
      {
        'id': 'violence',
        'name': 'Violence',
        'icon': Icons.warning,
        'color': Colors.deepOrange
      },
      {
        'id': 'ads',
        'name': 'Advertisements',
        'icon': Icons.ad_units,
        'color': Colors.amber
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Active Restrictions (${restrictions.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        const SizedBox(height: 16),
        ...allRestrictions.map((restriction) {
          final isActive = restrictions.contains(restriction['id']);
          return _buildRestrictionItem(
            name: restriction['name'] as String,
            icon: restriction['icon'] as IconData,
            color: restriction['color'] as Color,
            isActive: isActive,
          );
        }),
      ],
    );
  }

  Widget _buildRestrictionItem({
    required String name,
    required IconData icon,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isActive ? color : AppTheme.textGrey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
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
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textGrey,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? AppTheme.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown';

    DateTime? date;

    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    } else if (dateValue is String) {
      try {
        date = DateTime.parse(dateValue);
      } catch (_) {
        return 'Unknown';
      }
    } else if (dateValue is DateTime) {
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
