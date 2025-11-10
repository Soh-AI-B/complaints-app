const admin = require('firebase-admin');

// Initialize Firebase Admin SDK once per cold start
const { initializeApp, getApps, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

// Initialize Firebase Admin if not already initialized
if (getApps().length === 0) {
  try {
    console.log('Initializing Firebase Admin SDK...');
    
    if (!process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_KEY environment variable is not set');
    }
    
    console.log('Parsing service account key...');
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
    
    console.log('Service account project_id:', serviceAccount.project_id);
    
    initializeApp({
      credential: cert(serviceAccount),
    });
    
    console.log('Firebase Admin SDK initialized successfully');
  } catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error);
    throw error;
  }
}

module.exports = async (req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight OPTIONS request
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    console.log('=== Task Notification Request ===');
    console.log('Request body:', req.body);
    
    const { 
      taskId,
      taskTitle,
      employeeName,
      priority = 'Normal',
      category = 'General'
    } = req.body;

    console.log('Extracted values:', { taskId, taskTitle, employeeName, priority, category });

    // Validate required fields
    if (!taskId || !taskTitle || !employeeName) {
      console.log('Validation failed - missing required fields');
      return res.status(400).json({ 
        error: 'Missing required fields: taskId, taskTitle, and employeeName are required' 
      });
    }

    const title = 'New Task Created';
    const body = `New ${priority} task "${taskTitle}" reported by ${employeeName}`;
    
    const data = {
      taskId,
      type: 'new_task',
      priority,
      category,
      employeeName,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      // CRITICAL: Include title and body in data payload for custom handling
      title,
      body,
    };

    // Prepare the message template - DATA-ONLY APPROACH for background/terminated delivery
    // DO NOT include 'notification' payload - this ensures our background handler is called
    const messageTemplate = {
      // NO notification payload! This forces Firebase to call our background handler
      data,
      android: {
        priority: 'high',
        // No notification settings here - we'll create notification in Flutter
      },
      apns: {
        payload: {
          aps: {
            'content-available': 1, // Silent notification for iOS background
            sound: 'default',
            badge: 1,
          },
        },
        // For iOS, we need to include notification in APNS but not in root
        headers: {
          'apns-priority': '10',
        },
      },
    };

    console.log('Preparing FCM messages...');
    console.log('Message template:', messageTemplate);

    // Send to managers topic
    const managersMessage = {
      ...messageTemplate,
      topic: 'managers',
    };

    // Send to admins topic
    const adminsMessage = {
      ...messageTemplate,
      topic: 'admins',
    };

    console.log('Sending to managers topic...');
    console.log('Sending to admins topic...');

    // Send both messages
    const messaging = getMessaging();
    const promises = [
      messaging.send(managersMessage),
      messaging.send(adminsMessage),
    ];

    const results = await Promise.allSettled(promises);
    
    const successCount = results.filter(result => result.status === 'fulfilled').length;
    const failures = results
      .filter(result => result.status === 'rejected')
      .map(result => result.reason.message);

    console.log(`Sent ${successCount}/2 notifications successfully`);
    if (failures.length > 0) {
      console.log('Failures:', failures);
    }

    return res.status(200).json({ 
      success: true,
      sent: successCount,
      total: 2,
      failures: failures.length > 0 ? failures : undefined,
      message: `Task notification sent to ${successCount} topic(s)`
    });

  } catch (error) {
    console.error('Error sending task notification:', error);
    
    return res.status(500).json({ 
      error: 'Failed to send task notification',
      details: error.message 
    });
  }
};
