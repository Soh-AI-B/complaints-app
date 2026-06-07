const admin = require('firebase-admin');

// Initialize Firebase Admin SDK once per cold start
const { initializeApp, getApps, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

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

const db = getFirestore();
const summaryTimeZone = process.env.DAILY_SUMMARY_TIME_ZONE || 'Africa/Algiers';

function getCurrentTimeSlot() {
  return new Intl.DateTimeFormat('en-GB', {
    timeZone: summaryTimeZone,
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(new Date());
}

function getUserReminderTimes(userData) {
  const times = Array.isArray(userData.notification_times)
    ? userData.notification_times
    : ['08:00', '12:00', '16:00'];

  return times.map((time) => String(time));
}

function roleName(role) {
  return String(role || '').toLowerCase();
}

module.exports = async (req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight OPTIONS request
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow GET and POST requests
  if (req.method !== 'GET' && req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const configuredSecret = process.env.CRON_SECRET;
    const providedSecret =
      req.query.secret || req.headers['x-cron-secret'] || req.body?.secret;

    if (configuredSecret && providedSecret !== configuredSecret) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    console.log('=== Daily Task Summary Request ===');
    const currentTimeSlot = req.query.time || req.body?.time || getCurrentTimeSlot();
    console.log(`Current reminder slot: ${currentTimeSlot} (${summaryTimeZone})`);
    
    // Get admins and managers. Missing notification fields are treated as enabled
    // for backward compatibility with existing users.
    const usersSnapshot = await db.collection('users')
      .where('role', 'in', ['Admin', 'Manager'])
      .get();
    
    console.log(`Found ${usersSnapshot.size} users with notifications enabled`);
    
    // Process each user
    const results = [];
    
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const userEmail = userData.userEmail;
      const role = roleName(userData.role);
      const managedCategories = userData.managed_categories || [];
      const notificationsEnabled = userData.notification_enabled !== false;
      const reminderNotificationsEnabled =
        userData.task_reminder_notifications_enabled !== false;
      const reminderTimes = getUserReminderTimes(userData);
      
      console.log(`Processing user: ${userEmail} (role: ${role})`);

      if (!notificationsEnabled) {
        results.push({
          userEmail,
          success: true,
          skipped: true,
          reason: 'notifications_disabled'
        });
        continue;
      }

      if (!reminderNotificationsEnabled) {
        results.push({
          userEmail,
          success: true,
          skipped: true,
          reason: 'reminders_disabled'
        });
        continue;
      }

      if (!reminderTimes.includes(currentTimeSlot)) {
        results.push({
          userEmail,
          success: true,
          skipped: true,
          reason: 'outside_schedule'
        });
        continue;
      }
      
      let pendingCount = 0;
      
      const tasksSnapshot = await db.collection('tasks').get();
      pendingCount = tasksSnapshot.docs.filter((taskDoc) => {
        const task = taskDoc.data();
        if (task.status === 'Completed' || task.status === 'Cancelled') {
          return false;
        }

        if (role === 'manager' && managedCategories.length > 0) {
          return managedCategories.includes(task.category);
        }

        return true;
      }).length;
      
      console.log(`User ${userEmail} has ${pendingCount} pending tasks`);
      
      // Only send notification if there are pending tasks
      if (pendingCount > 0) {
        const notificationTitle = 'Daily Task Summary';
        const notificationBody = `You have ${pendingCount} pending task${pendingCount !== 1 ? 's' : ''}`;
        
        // Prepare the message data
        const messageData = {
          type: 'daily_summary',
          count: pendingCount.toString(),
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          title: notificationTitle,
          body: notificationBody,
        };
        
        const tokens = Array.isArray(userData.fcmTokens)
          ? userData.fcmTokens.filter(token => typeof token === 'string' && token.length > 0)
          : [];

        if (tokens.length > 0) {
          try {
            // Import messaging here to avoid initialization issues
            const { getMessaging } = require('firebase-admin/messaging');
            const messaging = getMessaging();
            
            const messageTemplate = {
              data: messageData,
              android: {
                priority: 'high',
              },
              apns: {
                payload: {
                  aps: {
                    sound: 'default',
                    badge: pendingCount,
                  },
                },
              },
            };
            
            const sendResults = await Promise.allSettled(
              tokens.map(token => messaging.send({ ...messageTemplate, token }))
            );
            const sent = sendResults.filter(result => result.status === 'fulfilled').length;
            const failed = sendResults.length - sent;
            console.log(`Sent daily summary to ${userEmail}: ${sent}/${tokens.length} tokens`);
            
            results.push({
              userEmail,
              success: true,
              sent,
              failed,
              pendingCount
            });
          } catch (msgError) {
            console.error(`Error sending message to ${userEmail}:`, msgError);
            results.push({
              userEmail,
              success: false,
              error: msgError.message
            });
          }
        } else {
          console.log(`No FCM tokens for ${userEmail}, skipping notification`);
          results.push({
            userEmail,
            success: true,
            pendingCount,
            skipped: true,
            reason: 'no_tokens'
          });
        }
      } else {
        console.log(`No pending tasks for ${userEmail}, skipping notification`);
        results.push({
          userEmail,
          success: true,
          pendingCount: 0,
          skipped: true
        });
      }
    }
    
    const successCount = results.filter(r => r.success && !r.skipped).length;
    const skippedCount = results.filter(r => r.skipped).length;
    const failureCount = results.filter(r => !r.success).length;
    
    console.log(`Daily summary completed: ${successCount} sent, ${skippedCount} skipped, ${failureCount} failed`);
    
    return res.status(200).json({ 
      success: true,
      sent: successCount,
      skipped: skippedCount,
      failed: failureCount,
      total: usersSnapshot.size,
      results: results,
      message: `Daily task summary processed: ${successCount} sent, ${skippedCount} skipped, ${failureCount} failed`
    });
    
  } catch (error) {
    console.error('Error sending daily task summaries:', error);
    
    return res.status(500).json({ 
      error: 'Failed to send daily task summaries',
      details: error.message 
    });
  }
};
