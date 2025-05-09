import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/fetchdata.dart';
import 'package:mouvi_map_application/Widgets/SignIn/Authentify.dart';
import 'package:mouvi_map_application/Widgets/SignUp/passwordRecovery/recoveryCode.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/otp.dart';

class Withphone extends StatefulWidget {
  @override
  State<Withphone> createState() => _WithphoneState();
}

class _WithphoneState extends State<Withphone> {
  final TwilioSmsService smsService = TwilioSmsService(
      accountSid: dotenv.env['TWILIO_SID']!,
      authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
      twilioPhoneNumber: dotenv.env['twilioPhoneNumber']!);
  String codeSent = "";
  void code(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: VerificationScreen(
              credential: selectedCountryCode + _phoneNumberController.text,
              code: codeSent),
        );
      },
    );
  }

  Future<void> resendOtp() async {
    try {
      codeSent = await smsService
          .sendfourOtp(selectedCountryCode + _phoneNumberController.text);
      if (codeSent != "err") {
      } else {}
    } catch (e) {}
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(0, 245, 245, 245), // Light background color
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mot de passe oublié',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Pour réinitialiser votre mot de passe, veuillez entrer votre numéro de téléphone associé à votre compte.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  DropdownButton<String>(
                    value: selectedCountryCode,
                    dropdownColor: Colors.white, // Light dropdown background
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                    underline: const SizedBox(), // No underline
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCountryCode = newValue!;
                        selectedCountryFlag = countries.firstWhere(
                          (country) => country['code'] == newValue,
                        )['flag']!;
                      });
                    },
                    items: countries.map<DropdownMenuItem<String>>((country) {
                      return DropdownMenuItem<String>(
                        value: country['code'],
                        child: Row(
                          children: [
                            Text(country['flag']!), // Show flag
                            const SizedBox(width: 8),
                            Text(
                              country['code']!, // Show code
                              style: const TextStyle(color: Colors.black),
                            ),
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
                        hintText: 'numéro de téléphone',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.6)),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.05),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await resendOtp();
                    bool res = await isPhoneInUtilisateurs(
                        selectedCountryCode + _phoneNumberController.text);
                    if (res == true) {
                      Navigator.of(context).pop(context);
                      code(context);
                    } else if (res == false) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'this Phone number is not registred',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ));
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Authentify()),
                        (route) => false, // Remove all previous routes
                      );
                    }

                    // Add your action here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB88A38),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'envoyer code',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
