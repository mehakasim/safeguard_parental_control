// lib/screens/dashboard/child/child_home_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../utils/theme.dart';

class ChildHomeTab extends StatelessWidget {
  final Map<String, dynamic> childData;
  final VoidCallback onRefresh;

  const ChildHomeTab({
    Key? key,
    required this.childData,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final screenTime = childData['screenTime'] ?? 0;
        final limit = childData['screenTimeLimit'] ?? 120;
        final remaining = (limit - screenTime).clamp(0, limit);
        final percentage = (screenTime / limit * 100).clamp(0, 100);
        final restrictions = childData['restrictions'] as List? ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            onRefresh();
          },
          child: CustomScrollView(
            slivers: [
              // Welcome Message
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textBlack,
                    ),
                  ),
                ),
              ),

              // Screen Time Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: percentage > 100
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [Colors.purple.shade400, Colors.purple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (percentage > 100 ? Colors.red : Colors.purple).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Screen Time Today',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  percentage > 100 ? 'Over limit!' : 'Keep it balanced!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.timer_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTimeBox('Used', provider.formatScreenTime(screenTime), Icons.phone_android),
                            Container(
                              height: 50,
                              width: 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            _buildTimeBox('Left', provider.formatScreenTime(remaining), Icons.hourglass_bottom),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (percentage / 100).clamp(0.0, 1.0),
                            minHeight: 14,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${percentage.toStringAsFixed(0)}% of daily time used',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Active Restrictions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Protections',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'These keep you safe online',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      restrictions.isEmpty
                          ? const Text('No active restrictions')
                          : _buildRestrictionsGrid(restrictions),
                    ],
                  ),
                ),
              ),

              // Quick Tips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tips for Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTipCard(
                        'Take Breaks',
                        'Remember to rest your eyes every 20 minutes!',
                        Icons.remove_red_eye_rounded,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildTipCard(
                        'Stay Active',
                        'Don\'t forget to move around and play outside!',
                        Icons.directions_run_rounded,
                        Colors.green,
                      ),
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

  Widget _buildTimeBox(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildRestrictionsGrid(List restrictions) {
    final allRestrictions = {
      'social_media': {'name': 'Social Media', 'icon': '📱', 'color': Colors.blue},
      'gaming': {'name': 'Gaming', 'icon': '🎮', 'color': Colors.purple},
      'shopping': {'name': 'Shopping', 'icon': '🛒', 'color': Colors.orange},
      'adult_content': {'name': 'Adult Content', 'icon': '🚫', 'color': Colors.red},
      'violence': {'name': 'Violence', 'icon': '⚠️', 'color': Colors.deepOrange},
      'ads': {'name': 'Ads', 'icon': '📢', 'color': Colors.amber},
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: restrictions.map((restrictionId) {
        final restriction = allRestrictions[restrictionId];
        if (restriction == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: (restriction['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (restriction['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                restriction['icon'] as String,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                restriction['name'] as String,
                style: TextStyle(
                  color: restriction['color'] as Color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon, Color color) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}