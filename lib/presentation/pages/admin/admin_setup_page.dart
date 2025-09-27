import 'package:flutter/material.dart';
import '../../../core/utils/admin_setup.dart';

class AdminSetupPage extends StatefulWidget {
  const AdminSetupPage({super.key});

  @override
  State<AdminSetupPage> createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Setup'),
        backgroundColor: const Color(0xFF253b74),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Initial Admin Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253b74),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Account Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Email: ${AdminSetup.adminEmail}'),
                  Text('Password: ${AdminSetup.adminPassword}'),
                  const SizedBox(height: 8),
                  const Text(
                    'This will create the initial admin user that can manage all users and roles.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (_message.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSuccess ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message,
                        style: TextStyle(
                          color: _isSuccess
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF253b74),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Creating Admin...'),
                        ],
                      )
                    : const Text(
                        'Create Initial Admin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Only run this setup once\n'
                    '• The admin can manage all users and roles\n'
                    '• Change the password after first login\n'
                    '• The admin role cannot be changed by other users\n'
                    '• Ensure Firestore Security Rules allow authenticated access',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Firestore Rules Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Firestore Security Rules',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you get permission errors, update your Firestore Security Rules in Firebase Console:',
                    style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'rules_version = \'2\';\n'
                      'service cloud.firestore {\n'
                      '  match /databases/{database}/documents {\n'
                      '    match /users/{document} {\n'
                      '      allow read, write: if request.auth != null;\n'
                      '    }\n'
                      '    match /tasks/{document} {\n'
                      '      allow read, write: if request.auth != null;\n'
                      '    }\n'
                      '  }\n'
                      '}',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAdmin() async {
    setState(() {
      _isLoading = true;
      _message = '';
      _isSuccess = false;
    });

    try {
      await AdminSetup.createInitialAdmin();
      setState(() {
        _message =
            'Admin user created successfully! You can now login with the credentials above.';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _message = 'Error creating admin user: $e';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
