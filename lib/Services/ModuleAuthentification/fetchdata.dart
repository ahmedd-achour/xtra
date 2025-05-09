import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getUserUidByEmail(String email) async {
  try {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Utilisateurs');
    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['uid'];
    } else {
      return null; // User not found
    }
  } catch (e) {
    print("Error fetching user by email: $e");
    return null;
  }
}

Future<String?> getUserUidByPhoneNumber(String phoneNumber) async {
  try {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Utilisateurs');
    QuerySnapshot querySnapshot = await usersCollection
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['uid'];
    } else {
      return null; // User not found
    }
  } catch (e) {
    print("Error fetching user by phone number: $e");
    return null;
  }
}

// Function to get user data
Future<Map<String, dynamic>?> getUserData(String emailOrPhone) async {
  String? uid;
  if (emailOrPhone.contains('@')) {
    // It's an email
    uid = await getUserUidByEmail(emailOrPhone);
  } else {
    // It's a phone number
    uid = await getUserUidByPhoneNumber(emailOrPhone);
  }

  if (uid == null) {
    print("User not found.");
    return null; // User not found
  }

  // Fetch user data from Firestore
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('Utilisateurs')
      .doc(uid)
      .get();

  if (userDoc.exists) {
    return userDoc.data() as Map<String, dynamic>;
  } else {
    print("User document not found.");
    return null;
  }
}

// Function to authenticate user with old password and then update the password
Future<void> updatePasswordForUser(
    String emailOrPhone, String newPassword) async {
  try {
    // Step 1: Get user data
    Map<String, dynamic>? userData = await getUserData(emailOrPhone);

    if (userData == null) {
      print("User data could not be fetched.");
      return;
    }

    String userEmail = userData['email'];
    String oldPassword = userData['password'];

    // Step 2: Authenticate the user with their old password
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: oldPassword,
      );
      print("User authenticated successfully.");

      // Step 3: Update password in Firebase Authentication
      await userCredential.user!.updatePassword(newPassword);
      print("Password updated in Firebase Authentication.");

      // Step 4: Sign out the user after updating password to clear session
      await FirebaseAuth.instance.signOut();
      print("User signed out.");

      // Step 5: Sign in the user with the new password
      UserCredential newUserCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: newPassword,
      );
      print("User signed in with new password.");

      // Step 6: Update password in Firestore
      String uid = newUserCredential.user!.uid;
      await FirebaseFirestore.instance
          .collection('Utilisateurs')
          .doc(uid)
          .update({
        'password':
            newPassword, // Update the password field in the Firestore document
      });

      print("Password updated successfully in Firestore.");
    } on FirebaseAuthException catch (e) {
      print("Authentication failed: ${e.message}");
    }
  } catch (e) {
    print("Error updating password: $e");
  }
}

// tlawej itha email fel base wlee

Future<bool> isEmailInUtilisateurs(String email) async {
  try {
    // Reference to Firestore's "Utilisateurs" collection
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Utilisateurs")
        .where("email", isEqualTo: email)
        .limit(1) // Optimize query performance
        .get();

    return querySnapshot.docs.isNotEmpty; // Returns true if email exists
  } catch (e) {
    print("Error checking email existence: $e");
    return false;
  }
}
// tlawej itha taliphone fel base wlee

Future<bool> isPhoneInUtilisateurs(String phone) async {
  try {
    // Reference to Firestore's "Utilisateurs" collection
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Utilisateurs")
        .where("phoneNumber", isEqualTo: phone)
        .limit(1) // Optimize query performance
        .get();

    return querySnapshot.docs.isNotEmpty; // Returns true if email exists
  } catch (e) {
    print("Error checking email existence: $e");
    return false;
  }
}
