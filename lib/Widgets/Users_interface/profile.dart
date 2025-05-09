import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mouvi_map_application/Model/Users.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _retypePasswordController = TextEditingController();

  String? currentPassword;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  void _listenToUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('Utilisateurs')
          .doc(uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          setState(() {
            _nameController.text = doc['name'] ?? '';
            _firstNameController.text = doc['firstName'] ?? '';
            _userNameController.text = doc['userName'] ?? '';
            _emailController.text = doc['email'] ?? '';
            _phoneNumberController.text = doc['phoneNumber'] ?? '';
            currentPassword = doc['password'] ?? ''; // Store current password
          });
        }
      });
    }
  }

  Future<void> _updateUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Check if current password matches retyped password
      if (_currentPasswordController.text != currentPassword) {
        // Show error if passwords don't match
        _showErrorDialog('The current password does not match.');
        return;
      }

      // If password is correct, proceed with updating other fields
      final userData = Users(
        name: _nameController.text,
        firstName: _firstNameController.text,
        userName: _userNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneNumberController.text,
        password: currentPassword!, // Don't update the password
      ).toJson();

      await FirebaseFirestore.instance
          .collection('Utilisateurs')
          .doc(uid)
          .set(userData, SetOptions(merge: true));

      // Show success message or navigate
      _showSuccessDialog();
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF94651F),
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF94651F),
        title: const Text('Success'),
        content: const Text('Profile updated successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF001D3D), Color(0xFF002952)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: sharedappbar,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF94651F),
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt,
                              size: 15, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('Nom', controller: _nameController),
                _buildTextField('Prénom', controller: _firstNameController),
                _buildTextField(
                  'Numéro de téléphone',
                  controller: _phoneNumberController,
                ),
                _buildTextField('E-mail', controller: _emailController),
                _buildTextField('Mot de passe actuel',
                    controller: _currentPasswordController, obscureText: true),
                _buildTextField('Confirmer mot de passe',
                    controller: _retypePasswordController, obscureText: true),
                GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Text("Logout")),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildButton('Annuler', const Color(0xFF94651F), () {}),
                    _buildButton(
                        'Confirmer', const Color(0xFF94651F), _updateUserData),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText,
      {bool obscureText = false,
      String? prefixText,
      TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ).copyWith(
        shadowColor: MaterialStateProperty.all(Colors.transparent),
      ),
      onPressed: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E1F0A), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: 50,
          width: 120,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
