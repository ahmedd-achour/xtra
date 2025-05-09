import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/authentification.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';
import 'package:mouvi_map_application/Widgets/SignUp/Step1.dart';
import 'package:mouvi_map_application/Widgets/SignUp/passwordRecovery/forgotpass.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/Step1.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/homecurved.dart';

class Authentify extends StatefulWidget {
  @override
  _AuthentifyState createState() => _AuthentifyState();
}

class _AuthentifyState extends State<Authentify> {
  void showForgotPasswordPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ForgotPasswordPopup(),
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _stayConnected = false;
  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Perform login logic here
      String email = _emailController.text;
      String password = _passwordController.text;

      final res = await Auth()
          .loginUsersWithEmailAndPasswords(email: email, password: password);

      // Example: Print credentials (replace with actual login logic)
      if (res == 'success') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageC(), // Replace with your screen
          ),
          (route) => false, // This removes all previous routes
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login successful!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        await FirebaseFirestore.instance
            .collection('Utilisateurs')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"isLogedIn": _stayConnected});
        // you will be redirected to the page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Verrify your informations',
            ),
            backgroundColor: Colors.redAccent.shade200,
          ),
        );
      }
      // Navigate to the next screen or show a success message
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth > 600 ? 24 : 8.0,
                        vertical: 12.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: constraints.maxWidth > 600 ? 110 : 72,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  const AssetImage('assets/logo.png'),
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                label: const Text("E-mail"),
                                prefixIcon: const Icon(Icons.email,
                                    color: Colors.white),
                                hintText: 'E-mail',
                                errorStyle: const TextStyle(
                                  color: Color(0xFF94651F),
                                ), // 🟡 Gold error text
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94651F),
                                      width: 2), // 🟡 Gold error border
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94651F),
                                      width:
                                          2), // 🟡 Gold error border when focused
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white54),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                                height: constraints.maxWidth > 600 ? 24 : 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                label: const Text("Mot de passe"),
                                prefixIcon:
                                    const Icon(Icons.lock, color: Colors.white),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white54,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                hintText: 'Mot de passe',
                                errorStyle: const TextStyle(
                                  color: Color(0xFF94651F),
                                ), // 🟡 Gold error text
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94651F),
                                      width: 2), // 🟡 Gold error border
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF94651F),
                                      width:
                                          2), // 🟡 Gold error border when focused
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white54),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _stayConnected,
                                  onChanged: (value) {
                                    setState(() {
                                      _stayConnected = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.white,
                                  checkColor: Colors.black,
                                ),
                                const Text(
                                  'Rester connecté',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    showForgotPasswordPopup(context);
                                  },
                                  child: const Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: constraints.maxWidth > 600 ? 32 : 16),
                            SizedBox(
                              width: double.infinity, // Max width
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Make transparent to show gradient
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets
                                      .zero, // Remove padding for accurate sizing
                                ).copyWith(
                                  shadowColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2E1F0A),
                                        Color(0xFF94651F),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    height: 60, // Adjust the height as needed
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize:
                                            18, // Larger font for better appearance
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: constraints.maxWidth > 600 ? 32 : 16),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        RegistrationScreen1()));
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: const Color(0xFF94651F),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Créer un nouveau compte',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
