// lib/screens/parent/screen_time_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/app_provider.dart';
import '../../services/screen_time_service.dart';
import '../../utils/theme.dart';

class ScreenTimeManagerScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const ScreenTimeManagerScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<ScreenTimeManagerScreen> createState() =>
      _ScreenTimeManagerScreenState();
}

class _ScreenTimeManagerScreenState extends State<ScreenTimeManagerScreen> {
  final ScreenTimeService _screenTimeService = ScreenTimeService();

  int _newLimit = 120; // Default 2 hours
  int _currentLimit = 120; // Track current limit separately
  bool _isSaving = false;
  bool _isInitialized = false; // Track if we've loaded initial data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.childName}\'s Screen Time'),
        backgroundColor: AppTheme.seaGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _screenTimeService.streamScreenTime(widget.childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data available'));
          }

          final rawData = snapshot.data!.data();
          if (rawData == null) {
            return const Center(child: Text('No data available'));
          }

          final data = rawData as Map<String, dynamic>;
          final screenTime = data['screenTime'] ?? 0;
          final limit = data['screenTimeLimit'] ?? 120;
          final percentage = (screenTime / limit * 100).clamp(0, 100);
          final remaining = (limit - screenTime).clamp(0, limit);

          // Only initialize once to prevent slider jumps
          if (!_isInitialized) {
            _newLimit = limit;
            _currentLimit = limit;
            _isInitialized = true;
          } else if (limit != _currentLimit && !_isSaving) {
            // Update current limit if it changed externally (not while saving)
            _currentLimit = limit;
            _newLimit = limit;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Usage Card
                _buildUsageCard(
                    screenTime, _currentLimit, remaining, percentage),

                const SizedBox(height: 24),

                // Adjust Limit Section
                _buildAdjustLimitSection(_currentLimit),

                const SizedBox(height: 24),

                // Reset Button
                _buildResetButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsageCard(
      int screenTime, int limit, int remaining, double percentage) {
    final provider = Provider.of<AppProvider>(context);
    final isOverLimit = screenTime > limit;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Usage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                      Icon(Icons.warning, color: Colors.white, size: 16),
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
              _buildTimeDisplay(
                  'Used', provider.formatScreenTime(screenTime), Icons.timer),
              Container(
                height: 50,
                width: 2,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildTimeDisplay(
                  'Limit', provider.formatScreenTime(limit), Icons.flag),
              Container(
                height: 50,
                width: 2,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildTimeDisplay('Left', provider.formatScreenTime(remaining),
                  Icons.hourglass_bottom),
            ],
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: 0, end: (percentage / 100).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 14,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(0)}% of daily limit used',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
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
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustLimitSection(int currentLimit) {
    final provider = Provider.of<AppProvider>(context);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Adjust Daily Limit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Limit:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                provider.formatScreenTime(_newLimit),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.seaGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _newLimit.toDouble(),
            min: 15,
            max: 480,
            divisions: 93,
            activeColor: AppTheme.seaGreen,
            label: provider.formatScreenTime(_newLimit),
            onChanged: (value) {
              setState(() {
                _newLimit = value.toInt();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15 min',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('8 hours',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _newLimit == currentLimit || _isSaving ? null : _saveNewLimit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save New Limit',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showResetDialog,
        icon: const Icon(Icons.refresh),
        label: const Text('Reset Today\'s Screen Time'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _saveNewLimit() async {
    setState(() => _isSaving = true);

    try {
      await _screenTimeService.updateScreenTimeLimit(widget.childId, _newLimit);

      // Update current limit after successful save
      setState(() {
        _currentLimit = _newLimit;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screen time limit updated successfully'),
            backgroundColor: AppTheme.seaGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Screen Time?'),
        content: const Text(
            'This will reset today\'s screen time to 0 minutes. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _screenTimeService.resetScreenTime(widget.childId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Screen time reset successfully'),
                    backgroundColor: AppTheme.seaGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _screenTimeService.dispose();
    super.dispose();
  }
}
