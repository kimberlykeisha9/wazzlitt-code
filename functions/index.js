/* eslint-disable linebreak-style */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

exports.createUserDocument = functions.auth.user().onCreate((user) => {
  const {uid} = user;

  // Set the user data you want to store in the Firestore document.
  const userData = {
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Create the user document in Firestore.
  return firestore.collection("users").doc(uid).set(userData);
});

exports.createPatroneAccount = functions.firestore
    .document("users/{userId}/account_type/patrone")
    .onCreate((snap, context) => {
      const userId = context.params.userId;
      const docRef = admin.firestore()
          .doc(`users/${userId}/account_type/patrone`);
      return docRef.update({
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

exports.createIgniterAccount = functions.firestore
    .document("users/{userId}/account_type/igniter")
    .onCreate((snap, context) => {
      const userId = context.params.userId;
      const docRef = admin.firestore()
          .doc(`users/${userId}/account_type/igniter`);
      return docRef.update({
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

exports.updateUserInfo = functions.firestore
    .document("users/{userId}/account_type/patrone")
    .onUpdate(async (change, context) => {
      const newData = change.after.data();
      const previousData = change.before.data();

      const userId = context.params.userId;
      const {email, username} = newData;

      if (email !== previousData.email) {
        try {
          await admin.auth().updateUser(userId, {email});
          console.log(`Updated email for user ${userId}`);
        } catch (error) {
          console.error(`Error updating email: ${error}`);
        }
      }

      if (username !== previousData.username) {
        try {
          await admin.auth().updateUser(userId, {displayName: username});
          console.log(`Updated display name for user ${userId}`);
        } catch (error) {
          console.error(`Error updating display name: ${error}`);
        }
      }
    });

exports.updateFollowers = functions.firestore
    .document("users/{userId}/account_type/patrone")
    .onUpdate(async (change, context) => {
      const patroneData = change.after.data();
      const previousPatroneData = change.before.data();

      const followingList = patroneData.following || [];
      const previousFollowingList = previousPatroneData.following || [];

      // Get the follower"s user ID
      const followerId = context.params.userId;

      // Get a batch reference
      const batch = admin.firestore().batch();

      // Iterate through the following list and update their followers
      for (const followingUserId of followingList) {
        if (!previousFollowingList.includes(followingUserId)) {
          const followingUserRef = admin.firestore()
              .doc(`users/${followingUserId}/account_type/patrone`);
          batch.update(followingUserRef, {
            followers: admin.firestore.FieldValue.arrayUnion(followerId),
          });
          console.log(`Updated followers list for user ${followingUserId}`);
        }
      }

      // Commit the batch
      await batch.commit();
    });

