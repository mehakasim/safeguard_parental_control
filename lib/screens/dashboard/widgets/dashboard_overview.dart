// lib/screens/dashboard/widgets/dashboard_overview.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../utils/theme.dart';
import '../../children/add_child_screen.dart';
import 'child_activity_card.dart';
import 'quick_stats_card.dart';
import 'settings_tab.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final children = provider.children;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Cards
              _buildStatsGrid(children),

              const SizedBox(height: 24),

              // Today's Activity Section
              _buildSectionHeader('Today\'s Activity', () {
                provider.refreshChildren();
              }),

              const SizedBox(height: 16),

              // Children Activity List
              if (provider.childrenLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (children.isEmpty)
                _buildEmptyState(context)
              else
                ...children.map((child) => ChildActivityCard(child: child)),

              const SizedBox(height: 24),

              // Recent Alerts Section
              _buildRecentAlertsSection(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(List<Map<String, dynamic>> children) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickStatsCard(
                title: 'Total Children',
                value: children.length.toString(),
                icon: Icons.family_restroom,
                color: AppTheme.seaGreen,
                subtitle: 'Active accounts',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickStatsCard(
                title: 'Active Today',
                value: children
                    .where((child) => (child['screenTime'] ?? 0) > 0)
                    .length
                    .toString(),
                icon: Icons.access_time,
                color: Colors.blue,
                subtitle: 'Using devices',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickStatsCard(
                title: 'Avg Screen Time',
                value: _calculateAverageScreenTime(children),
                icon: Icons.timer,
                color: Colors.orange,
                subtitle: 'Per child today',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickStatsCard(
                title: 'Restrictions',
                value: _countTotalRestrictions(children).toString(),
                icon: Icons.security,
                color: Colors.red,
                subtitle: 'Active filters',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onRefresh) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: onRefresh,
          icon: Icon(
            Icons.refresh,
            size: 18,
            color: AppTheme.seaGreen,
          ),
          label: const Text(
            'Refresh',
            style: TextStyle(color: AppTheme.seaGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.seaGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom,
              size: 64,
              color: AppTheme.seaGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Children Added Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first child to start monitoring their digital activity and keeping them safe online.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddChildScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Child'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Alerts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
              Icon(
                Icons.notifications_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                'No Recent Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGrey,
                ),
              ),
              const Text(
                'All your children are using their devices safely.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Add Child',
                Icons.person_add,
                AppTheme.seaGreen,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddChildScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Settings',
                Icons.settings,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Settings')),
                        body: const SettingsTab(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _calculateAverageScreenTime(List<Map<String, dynamic>> children) {
    if (children.isEmpty) return '0m';

    int totalMinutes = 0;
    for (var child in children) {
      totalMinutes += (child['screenTime'] ?? 0) as int;
    }

    int average = (totalMinutes / children.length).round();
    return _formatTime(average);
  }

  int _countTotalRestrictions(List<Map<String, dynamic>> children) {
    int count = 0;
    for (var child in children) {
      List restrictions = child['restrictions'] ?? [];
      count += restrictions.length;
    }
    return count;
  }

  String _formatTime(int minutes) {
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
