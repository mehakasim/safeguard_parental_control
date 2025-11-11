import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Icon
              Container(
                height: 120,
                width: 120,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57), // Sea green
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              // App Title
              const Text(
                'ChildGuard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // App Subtitle
              const Text(
                'Parental Control Made Simple',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 48),

              // Features List
              _buildFeatureItem(Icons.access_time, 'Monitor Screen Time'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.block, 'Block Inappropriate Content'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.security, 'Ad-Free Experience'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.child_care, 'Multiple Child Profiles'),

              const SizedBox(height: 48),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Register Button
              OutlinedButton(
                onPressed: () {
                  // Navigate to register screen
                  Navigator.pushNamed(context, '/register');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E8B57),
                  side: const BorderSide(color: Color(0xFF2E8B57), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Terms and Privacy
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2E8B57),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
