// lib/screens/dashboard/widgets/analytics_tab.dart
import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Family Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Coming soon card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics,
                    size: 64,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Advanced Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Detailed insights and reports about your family\'s digital habits are coming soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Feature previews
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFeatureChip('📊 Weekly Reports', Colors.blue),
                    _buildFeatureChip('📱 App Usage Trends', Colors.green),
                    _buildFeatureChip('⏰ Time Patterns', Colors.orange),
                    _buildFeatureChip('🛡️ Safety Insights', Colors.red),
                    _buildFeatureChip('👨‍👩‍👧‍👦 Family Comparison', Colors.purple),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Mock analytics preview
                _buildAnalyticsPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAnalyticsPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview: Weekly Usage',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          // Mock chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMockBar('Mon', 0.6, Colors.blue),
              _buildMockBar('Tue', 0.8, Colors.green),
              _buildMockBar('Wed', 0.4, Colors.orange),
              _buildMockBar('Thu', 0.9, Colors.red),
              _buildMockBar('Fri', 0.7, Colors.purple),
              _buildMockBar('Sat', 0.5, Colors.cyan),
              _buildMockBar('Sun', 0.3, Colors.amber),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Mock insights
          Row(
            children: [
              Expanded(
                child: _buildMockInsight('2.5h', 'Avg Daily', Icons.access_time),
              ),
              Expanded(
                child: _buildMockInsight('15%', 'This Week', Icons.trending_down),
              ),
              Expanded(
                child: _buildMockInsight('3', 'Peak Apps', Icons.apps),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockBar(String day, double height, Color color) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 60 * height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildMockInsight(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.textGrey, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textGrey,
          ),
        ),
      ],
    );
  }
}