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
