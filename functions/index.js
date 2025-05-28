const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendAnnouncementNotification = functions.firestore
    .document("Announcements/{announcementId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();

      const payload = {
        notification: {
          title: "📢 New Announcement",
          body: `${data.Title} - ${data.Location}`,
        },
        topic: "allUsers",
      };

      try {
        await admin.messaging().send(payload);
        console.log("✅ Notification sent to topic: allUsers");
      } catch (error) {
        console.error("❌ Error sending notification:", error);
      }
    });
