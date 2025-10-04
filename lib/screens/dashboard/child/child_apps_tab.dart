// lib/screens/dashboard/child/child_apps_tab.dart
import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class ChildAppsTab extends StatelessWidget {
  final List restrictions;

  const ChildAppsTab({
    Key? key,
    required this.restrictions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final safeApps = [
      {'name': 'YouTube Kids', 'icon': '📺', 'color': Colors.red, 'category': 'entertainment'},
      {'name': 'Khan Academy', 'icon': '📚', 'color': Colors.green, 'category': 'education'},
      {'name': 'Duolingo', 'icon': '🦉', 'color': Colors.blue, 'category': 'education'},
      {'name': 'Scratch Jr', 'icon': '🎨', 'color': Colors.orange, 'category': 'education'},
      {'name': 'PBS Kids', 'icon': '📖', 'color': Colors.purple, 'category': 'entertainment'},
      {'name': 'Toca Life', 'icon': '🏠', 'color': Colors.pink, 'category': 'gaming'},
      {'name': 'Minecraft Edu', 'icon': '⛏️', 'color': Colors.brown, 'category': 'gaming'},
      {'name': 'Calculator', 'icon': '🔢', 'color': Colors.teal, 'category': 'utility'},
    ];

    // Filter apps based on restrictions
    final filteredApps = safeApps.where((app) {
      if (restrictions.contains('gaming') && app['category'] == 'gaming') {
        return false;
      }
      return true;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          title: const Text(
            'My Apps',
            style: TextStyle(
              color: AppTheme.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppTheme.textBlack),
              onPressed: () {},
            ),
          ],
        ),
        if (filteredApps.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apps_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No apps available',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = filteredApps[index];
                  return _buildAppIcon(
                    context,
                    app['name'] as String,
                    app['icon'] as String,
                    app['color'] as Color,
                  );
                },
                childCount: filteredApps.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppIcon(BuildContext context, String name, String icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $name...'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}