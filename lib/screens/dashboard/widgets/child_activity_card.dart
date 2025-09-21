// lib/screens/dashboard/widgets/child_activity_card.dart
import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import 'child_quick_actions.dart';

class ChildActivityCard extends StatelessWidget {
  final Map<String, dynamic> child;

  const ChildActivityCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenTime = child['screenTime'] ?? 0;
    final limit = child['screenTimeLimit'] ?? 120;
    final progress = limit > 0 ? (screenTime / limit).clamp(0.0, 1.0) : 0.0;
    final isOverLimit = screenTime > limit;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              _buildChildAvatar(isOverLimit),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChildInfo(isOverLimit),
              ),
              _buildMenuButton(context),
            ],
          ),
          const SizedBox(height: 16),
          
          // Screen Time Progress
          _buildScreenTimeProgress(screenTime, limit, progress, isOverLimit),
        ],
      ),
    );
  }

  Widget _buildChildAvatar(bool isOverLimit) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.seaGreen.withOpacity(0.1),
          child: Text(
            child['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(
              color: AppTheme.seaGreen,
              fontWeight: FontWeight.bold,
              fontSize: 20,
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

  Widget _buildChildInfo(bool isOverLimit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                child['name']?.toString() ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
        ),
        Text(
          'Age: ${child['age'] ?? 'Unknown'} • ${child['restrictions']?.length ?? 0} restrictions',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        ChildQuickActions.show(context, child);
      },
      icon: const Icon(Icons.more_vert, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        shape: const CircleBorder(),
      ),
    );
  }

  Widget _buildScreenTimeProgress(int screenTime, int limit, double progress, bool isOverLimit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Screen Time Today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textGrey,
              ),
            ),
            Text(
              '${_formatTime(screenTime)} / ${_formatTime(limit)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isOverLimit ? Colors.red : AppTheme.textBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOverLimit ? Colors.red : AppTheme.seaGreen,
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        if (isOverLimit)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '⚠️ ${_formatTime(screenTime - limit)} over daily limit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
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