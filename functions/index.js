const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Cloud Function to send special notifications once a week
 */
exports.sendSpecialNotification = functions.pubsub
  .schedule("every 1 week")
  .onRun(async (context) => {
    const db = admin.firestore();
    const usersRef = db.collection("users");

    try {
      // Query users with userType "Rent" or "Both"
      const querySnapshot = await usersRef
        .where("userType", "in", ["Rent", "Both"])
        .get();

      // Generate the special notification for each user
      querySnapshot.forEach((doc) => {
        const userId = doc.id;
        const notificationId = generateRandomId();
        const title = "Nice! You want to offer a parking spot.";
        const timestamp = admin.firestore.Timestamp.now();

        // Create a new document in the userNotifications collection
        db.collection("notifications")
          .doc(userId)
          .collection("userNotifications")
          .doc(notificationId)
          .set({
            id: notificationId,
            title: title,
            timestamp: timestamp,
            // Add other necessary fields
          });
      });

      console.log("Special notifications sent successfully.");
    } catch (error) {
      console.error("Error sending special notifications:", error);
    }
  });

/**
 * Helper function to generate a random notification id
 */
function generateRandomId() {
  // Implement your logic to generate a random id
}
