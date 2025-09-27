import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/shared_preferences_helper.dart';

/// Debug page to check user session persistence status
/// Remove this in production - for development only
class SessionDebugPage extends StatefulWidget {
  const SessionDebugPage({super.key});

  @override
  State<SessionDebugPage> createState() => _SessionDebugPageState();
}

class _SessionDebugPageState extends State<SessionDebugPage> {
  Map<String, String?> _sessionData = {};
  bool _isLoggedIn = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    try {
      final sessionData = await SharedPreferencesHelper.getSavedUserData();
      final isLoggedIn = await SharedPreferencesHelper.getIsLoggedInAsync();
      
      setState(() {
        _sessionData = sessionData;
        _isLoggedIn = isLoggedIn;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Debug Info'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isLoggedIn ? Icons.check_circle : Icons.cancel,
                          color: _isLoggedIn ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLoggedIn ? 'User is logged in' : 'User not logged in',
                          style: TextStyle(
                            color: _isLoggedIn ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Session Data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._sessionData.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value ?? 'null',
                                style: TextStyle(
                                  color: entry.value != null ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Web Persistence Info',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'On web browsers, user session data is saved in localStorage, '
                      'which persists across browser sessions until manually cleared. '
                      'This allows users to stay logged in even after closing the browser.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _loadSessionData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}