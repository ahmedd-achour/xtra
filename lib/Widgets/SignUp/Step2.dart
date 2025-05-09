import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/fetchdata.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/otp.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';
import 'package:mouvi_map_application/Widgets/SignUp/Step3.dart';

class PhoneScreen extends StatefulWidget {
  final String name;
  final String firstName;
  final String username;

  const PhoneScreen(
      {required this.name, required this.firstName, required this.username});

  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final List<Map<String, String>> countries = [
    {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
    {'code': '+216', 'name': 'Tunisie', 'flag': '🇹🇳'},
    {'code': '+212', 'name': 'Maroc', 'flag': '🇲🇦'},
    {'code': '+213', 'name': 'Algérie', 'flag': '🇩🇿'},
  ];

  String selectedCountryCode = '+216';
  String selectedCountryFlag = '🇹🇳';
  final TextEditingController _phoneNumberController = TextEditingController();
  final TwilioSmsService smsService = TwilioSmsService(
      accountSid: dotenv.env['TWILIO_SID']!,
      authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
      twilioPhoneNumber: dotenv.env['twilioPhoneNumber']!);
  bool isLoading = false;

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
        body: Stack(
          children: [
            LayoutBuilder(
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
                            Row(
                              children: [
                                DropdownButton<String>(
                                  value: selectedCountryCode,
                                  dropdownColor: const Color(0xFF002952),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.white),
                                  underline: const SizedBox(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCountryCode = newValue!;
                                      selectedCountryFlag =
                                          countries.firstWhere(
                                        (country) =>
                                            country['code'] == newValue,
                                      )['flag']!;
                                    });
                                  },
                                  items: countries
                                      .map<DropdownMenuItem<String>>(
                                          (Map<String, String> country) {
                                    return DropdownMenuItem<String>(
                                      value: country['code'],
                                      child: Row(
                                        children: [
                                          Text(country['flag']!),
                                          const SizedBox(width: 8),
                                          Text(country['code']!),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneNumberController,
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
                                      hintText: 'numéro de téléphone',
                                      hintStyle: const TextStyle(
                                          color: Colors.white54),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white54),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: constraints.maxWidth > 600 ? 32 : 16),
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      String phoneNumber = selectedCountryCode +
                                          _phoneNumberController.text;

                                      if (_phoneNumberController.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Veuillez entrer un numéro de téléphone valide"),
                                        ));
                                        return;
                                      }

                                      setState(() {
                                        isLoading = true;
                                      });

                                      try {
                                        bool res = await isPhoneInUtilisateurs(
                                            phoneNumber);
                                        if (res) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "ce numéro existe via utulisé un autre numéro",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OTPVerificationScreen(
                                                        firstName:
                                                            widget.firstName,
                                                        name: widget.name,
                                                        username:
                                                            widget.username,
                                                        phoneNumber:
                                                            phoneNumber,
                                                      )
                                                  /* LoginScreen3(
                                                      firstName:
                                                          widget.firstName,
                                                      name: widget.name,
                                                      userName: widget.username,
                                                      phoneNumber: phoneNumber,
                                                    ))*/
                                                  ));
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "Erreur lors de l'envoi du code : $e"),
                                        ));
                                      } finally {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Make the background transparent
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(double.infinity, 50),
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
                                    ], // Dark red to gold gradient
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.center,
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text('envoyer code',
                                          style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
