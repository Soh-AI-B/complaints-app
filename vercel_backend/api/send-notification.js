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
      topic, 
      title, 
      body, 
      data = {},
      token // For direct token messaging
    } = req.body;

    // Validate required fields
    if (!title || !body) {
      return res.status(400).json({ 
        error: 'Missing required fields: title and body are required' 
      });
    }

    if (!topic && !token) {
      return res.status(400).json({ 
        error: 'Either topic or token must be provided' 
      });
    }

    // Prepare the message
    const message = {
      notification: {
        title,
        body,
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    // Add topic or token to message
    if (topic) {
      message.topic = topic;
    } else {
      message.token = token;
    }

    // Send the message
    const response = await admin.messaging().send(message);
    
    console.log('Successfully sent message:', response);
    
    return res.status(200).json({ 
      success: true, 
      messageId: response,
      message: 'Notification sent successfully'
    });

  } catch (error) {
    console.error('Error sending notification:', error);
    
    return res.status(500).json({ 
      error: 'Failed to send notification',
      details: error.message 
    });
  }
};
