// mathabina neb3dou ala mot clée user 5ater already defined pourcela e5tart Users

import 'package:firebase_auth/firebase_auth.dart';

class Users {
  late final String name;
  late final String firstName;
  late final String userName;
  late final String email;
  late final String phoneNumber;
  late final String password;

  // si vous desidez de stocker les info du carte prochainement

  Users({
    required this.name,
    required this.password,
    required this.userName,
    required this.firstName,
    required this.email,
    required this.phoneNumber,
  });

  toJson() {
    return {
      'name': name,
      'password': password,
      'firstName': firstName,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'uid': FirebaseAuth.instance.currentUser!.uid,
    };
  }
}
