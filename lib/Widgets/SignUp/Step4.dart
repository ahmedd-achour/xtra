import 'package:flutter/material.dart';
import 'package:mouvi_map_application/Model/Users.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/authentification.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/fetchdata.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';
import 'package:mouvi_map_application/Widgets/SignIn/Authentify.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/home.dart';

class LoginScreen3 extends StatefulWidget {
  final String name;
  final String firstName;
  final String phoneNumber;
  final String userName;
  LoginScreen3(
      {required this.firstName,
      required this.name,
      required this.phoneNumber,
      required this.userName});
  @override
  _LoginScreen3State createState() => _LoginScreen3State();
}

class _LoginScreen3State extends State<LoginScreen3> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool result = await isEmailInUtilisateurs(_emailController.text);

      if (result == false) {
        Users currentUser = Users(
            firstName: widget.firstName,
            userName: widget.userName,
            name: widget.name,
            phoneNumber: widget.phoneNumber,
            password: _passwordController.text,
            email: _emailController.text);
        String res =
            await Auth().createUsersWithEmailAndPassword(users: currentUser);

        // Handle form submission

        setState(() {
          _isLoading = false;
        });
        if (res == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Account created successfully !',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MapboxExample()),
            (route) => false, // Remove all previous routes
          );
        }
      } else if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'this email is already in use',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Authentify()),
          (route) => false, // Remove all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'An internal err occured verrify ',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
      }

      print('Password: ${_passwordController.text}');
      print('Confirm Password: ${_confirmPasswordController.text}');
    }
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
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 600 ? 100 : 24.0,
                      vertical: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          CircleAvatar(
                            radius: constraints.maxWidth > 600 ? 80 : 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                const AssetImage('assets/logo.png'),
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600 ? 32 : 16),

                          // Email TextField
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              errorStyle: const TextStyle(
                                color: Color(0xFF94651F),
                              ),
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
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.white),
                              label: const Text('E-mail'),
                              hintText: 'E-mail',
                              hintStyle: const TextStyle(color: Colors.white54),
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
                              // Check if the email is empty
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre email';
                              }
                              // Check if the email matches the pattern
                              String pattern =
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),

                          SizedBox(
                              height: constraints.maxWidth > 600 ? 24 : 16),

                          // Password TextField
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
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
                              label: const Text('Mot de passe'),
                              hintText: 'Mot de passe',
                              hintStyle: TextStyle(color: Colors.white54),
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
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600 ? 24 : 16),

                          // Confirm Password TextField
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
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
                              label: const Text('Confirmer mot de passe'),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                              hintText: 'Confirmer mot de passe',
                              hintStyle: const TextStyle(color: Colors.white54),
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
                                return 'Veuillez confirmer votre mot de passe';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600 ? 32 : 16),

                          // Sign Up Button
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // Make transparent to show gradient
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets
                                  .zero, // Remove padding for accurate sizing
                            ).copyWith(
                              shadowColor:
                                  MaterialStateProperty.all(Colors.transparent),
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
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'S\'inscrire',
                                        style: TextStyle(
                                          fontSize:
                                              18, // Larger font for better appearance
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
