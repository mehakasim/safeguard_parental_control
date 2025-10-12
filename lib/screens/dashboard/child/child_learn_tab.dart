// lib/screens/dashboard/child/child_learn_tab.dart
import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class ChildLearnTab extends StatelessWidget {
  const ChildLearnTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      {
        'title': 'Learn to Code',
        'description': 'Start your coding journey with fun games',
        'icon': Icons.code_rounded,
        'color': Colors.blue,
        'duration': '20 min',
      },
      {
        'title': 'Math Games',
        'description': 'Practice math with interactive challenges',
        'icon': Icons.calculate_rounded,
        'color': Colors.orange,
        'duration': '15 min',
      },
      {
        'title': 'Reading Corner',
        'description': 'Discover amazing stories and books',
        'icon': Icons.menu_book_rounded,
        'color': Colors.green,
        'duration': '30 min',
      },
      {
        'title': 'Science Lab',
        'description': 'Explore science experiments and facts',
        'icon': Icons.science_rounded,
        'color': Colors.purple,
        'duration': '25 min',
      },
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          title: const Text(
            'Learn & Explore',
            style: TextStyle(
              color: AppTheme.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = recommendations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildLearningCard(
                    context,
                    item['title'] as String,
                    item['description'] as String,
                    item['icon'] as IconData,
                    item['color'] as Color,
                    item['duration'] as String,
                  ),
                );
              },
              childCount: recommendations.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String duration,
  ) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting $title...'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}