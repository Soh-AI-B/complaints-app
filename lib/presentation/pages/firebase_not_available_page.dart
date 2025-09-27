import 'package:flutter/material.dart';

class FirebaseNotAvailablePage extends StatelessWidget {
  const FirebaseNotAvailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            // 👈 added here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF253b74),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.cloud_off,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Complaints Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF253b74),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                const Text(
                  'Clean Architecture Demo',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Firebase Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 32,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Firebase Configuration Required',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The app is running in development mode without Firebase. '
                        'Add Firebase configuration to enable authentication and data features.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Success Indicators
                _buildFeatureStatus(
                  '✅',
                  'Clean Architecture',
                  'Implemented',
                  true,
                ),
                const SizedBox(height: 12),
                _buildFeatureStatus(
                  '✅',
                  'Dart Compilation',
                  'Successful',
                  true,
                ),
                const SizedBox(height: 12),
                _buildFeatureStatus(
                  '✅',
                  'Dependency Injection',
                  'Working',
                  true,
                ),
                const SizedBox(height: 12),
                _buildFeatureStatus(
                  '⚠️',
                  'Firebase Services',
                  'Configuration needed',
                  false,
                ),

                const SizedBox(height: 48),

                // Instructions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Steps:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Create Firebase project\n'
                        '2. Add google-services.json\n'
                        '3. Enable Authentication & Firestore\n'
                        '4. Hot restart the app',
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureStatus(
    String icon,
    String feature,
    String status,
    bool isWorking,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWorking ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWorking ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isWorking ? Colors.green[800] : Colors.orange[800],
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isWorking ? Colors.green[600] : Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
