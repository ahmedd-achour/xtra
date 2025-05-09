import 'package:flutter/material.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';
import 'package:mouvi_map_application/Widgets/SignUp/Step2.dart';

class RegistrationScreen1 extends StatefulWidget {
  @override
  _RegistrationScreen1State createState() => _RegistrationScreen1State();
}

class _RegistrationScreen1State extends State<RegistrationScreen1> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for form fields
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

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
                          CircleAvatar(
                            radius: constraints.maxWidth > 600 ? 80 : 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                const AssetImage('assets/logo.png'),
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600 ? 32 : 16),
                          TextFormField(
                            controller: _nomController,
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
                              label: const Text("nom"),
                              hintText: 'nom',
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
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600 ? 24 : 16),
                          TextFormField(
                            controller: _prenomController,
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
                              label: const Text("prenom"),
                              hintText: 'prenom',
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
                                return 'Veuillez entrer votre prénom';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600 ? 24 : 16),
                          TextFormField(
                            controller: _usernameController,
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
                              label: const Text('nom d\'utilisateur'),
                              hintText: 'nom d\'utilisateur',
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
                                return 'Veuillez entrer votre nom d\'utilisateur';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height: constraints.maxWidth > 600 ? 32 : 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end, // Align to the right
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 32.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Check if the form is valid before navigating
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => PhoneScreen(
                                                    name: _nomController.text,
                                                    firstName:
                                                        _prenomController.text,
                                                    username:
                                                        _usernameController
                                                            .text,
                                                  )));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    // Remove the solid backgroundColor and use a gradient
                                    backgroundColor: Colors
                                        .transparent, // Make the background transparent to apply gradient
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets
                                        .zero, // Remove padding for precise size
                                    minimumSize: const Size(120,
                                        40), // Adjust the size of the button
                                  ).copyWith(
                                    // Apply gradient
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2E1F0A),
                                            Color(0xFF94651F)
                                          ], // The gradient from dark red to gold
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'suivant',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
}
