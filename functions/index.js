const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.cleanupOldStories = functions.https.onRequest(async (req, res) => {
  const now = new Date();
  const cutoffTime = new Date(now.getTime() - 24 * 60 * 60 * 1000); // 24 hours ago

  const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoffTime);

  try {
    const storiesRef = admin.firestore().collection('stories');
    const querySnapshot = await storiesRef.where('timestamp', '<', cutoffTimestamp).get();

    if (querySnapshot.empty) {
      res.status(200).send('No old stories found.');
      return;
    }

    const batch = admin.firestore().batch();
    querySnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    res.status(200).send(`Deleted ${querySnapshot.size} old stories.`);
  } catch (error) {
    console.error('Error deleting old stories:', error);
    res.status(500).send('Error deleting old stories');
  }
});
