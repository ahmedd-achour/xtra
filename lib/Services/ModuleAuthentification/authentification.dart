import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mouvi_map_application/Model/Users.dart';

class Auth {
  //creating the global instance of firebase to manage the auth logic ;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;
  // sign up users (creation of the acc) ;

  createUsersWithEmailAndPassword({required Users users}) async {
    String res = 'Problem while signing up';
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: users.email,
        password: users.password,
      );
      await _firebaseFireStore
          .collection('Utilisateurs')
          .doc(user.user!.uid)
          .set(
            users.toJson(),
          );
      res = 'success';
    } on FirebaseAuthException catch (e) {
      // FirebaseAuth-specific errors
      if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        res = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        res = 'The email address is not valid.';
      } else {
        res = 'Authentication error: ${e.message}';
      }
    } catch (e) {
      // General errors
      res = 'An error occurred: ${e.toString()}';
    }
    return res;
  }

  // signing in users ;
  loginUsersWithEmailAndPasswords(
      {required String email, required String password}) async {
    String res = 'there is a problem when logging in';
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      res = 'success';
    } catch (e) {
      res = 'err ${e.toString()}';
    }
    return res;
  }

  logout() async {
    await _firebaseAuth.signOut();
  }
}

// les algorithmes de sécurité des moot de passe  etc

String hashPassword(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

bool verifyPassword(String password, String hashedPassword) {
  return BCrypt.checkpw(password, hashedPassword);
}
