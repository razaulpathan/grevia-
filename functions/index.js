const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Push Notification Fanout for New Messages
 */
exports.sendNewMessageNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;

    if (!message || message.type === "system") return;

    // Fetch chat to get participants
    const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
    if (!chatDoc.exists) return;

    const participantIds = chatDoc.data().participantIds || [];
    const recipients = participantIds.filter((id) => id !== message.senderId);

    for (const recipientId of recipients) {
      const userDoc = await admin.firestore().collection("users").doc(recipientId).get();
      if (userDoc.exists && userDoc.data().fcmToken) {
        const payload = {
          notification: {
            title: message.senderName || "Grevia Message",
            body: message.type === "text" ? message.text : `[${message.type}]`,
          },
          data: {
            chatId: chatId,
            messageId: context.params.messageId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };

        try {
          await admin.messaging().sendToDevice(userDoc.data().fcmToken, payload);
        } catch (err) {
          console.error("Error sending notification to user", recipientId, err);
        }
      }
    }
  });

/**
 * Scheduled Daily Job: Cleanup expired status stories (> 24 hours)
 */
exports.cleanupExpiredStatuses = functions.pubsub
  .schedule("every 1 hours")
  .onRun(async (context) => {
    const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const expiredSnap = await admin
      .firestore()
      .collection("statuses")
      .where("createdAt", "<", admin.firestore.Timestamp.fromDate(cutoff))
      .get();

    const batch = admin.firestore().batch();
    expiredSnap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    console.log(`Cleaned up ${expiredSnap.size} expired status stories.`);
  });
