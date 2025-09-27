const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
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
    const { 
      tokens = [],
      taskId,
      taskTitle,
      employeeName,
      priority = 'Normal',
      category = 'General',
      title,
      body,
      data = {}
    } = req.body;

    // Validate required fields
    if ((!title || !body) && (!taskId || !taskTitle || !employeeName)) {
      return res.status(400).json({ 
        error: 'Either (title, body) or (taskId, taskTitle, employeeName) must be provided' 
      });
    }

    if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
      return res.status(400).json({ 
        error: 'Tokens array is required and must not be empty' 
      });
    }

    // Build notification content
    const notificationTitle = title || 'New Task Created';
    const notificationBody = body || `New ${priority} task "${taskTitle}" reported by ${employeeName}`;
    
    const notificationData = {
      ...data,
      ...(taskId && { taskId }),
      ...(priority && { priority }),
      ...(category && { category }),
      ...(employeeName && { employeeName }),
      type: data.type || 'new_task',
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      // Include title and body in data so Flutter can display them
      title: notificationTitle,
      body: notificationBody,
    };

    // Prepare message template - ONLY DATA, NO NOTIFICATION PAYLOAD
    // This prevents Android from auto-showing notifications (avoiding duplicates)
    const messageTemplate = {
      // Remove the notification payload to prevent duplicate notifications
      // notification: {
      //   title: notificationTitle,
      //   body: notificationBody,
      // },
      data: notificationData,
      android: {
        priority: 'high',
        // Remove notification config to prevent auto-display
        // notification: {
        //   sound: 'default',
        //   channelId: 'default',
        // },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            'content-available': 1, // This ensures data-only message delivery
          },
        },
      },
    };

    console.log(`Sending notifications to ${tokens.length} manager tokens...`);
    console.log('Message template:', messageTemplate);

    // Create individual messages for each token
    const messages = tokens.map(token => ({
      ...messageTemplate,
      token,
    }));

    // Send all messages
    const messaging = admin.messaging();
    const results = await Promise.allSettled(
      messages.map(message => messaging.send(message))
    );

    const successful = results.filter(result => result.status === 'fulfilled').length;
    const failed = results.filter(result => result.status === 'rejected');

    console.log(`Successfully sent ${successful}/${tokens.length} notifications`);
    
    if (failed.length > 0) {
      console.log('Failed notifications:', failed.map(f => f.reason?.message));
    }

    return res.status(200).json({ 
      success: true,
      sent: successful,
      total: tokens.length,
      failed: failed.length,
      failures: failed.length > 0 ? failed.map(f => f.reason?.message) : undefined,
      message: `Notification sent to ${successful}/${tokens.length} managers`
    });

  } catch (error) {
    console.error('Error sending notifications to managers:', error);
    
    return res.status(500).json({ 
      error: 'Failed to send notifications to managers',
      details: error.message 
    });
  }
};
