import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mouvi_map_application/Services/ModuleAuthentification/otp.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';
import 'package:mouvi_map_application/Widgets/SignUp/Step4.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String name;
  final String firstName;
  final String username;
  final String phoneNumber;

  OTPVerificationScreen({
    required this.name,
    required this.firstName,
    required this.username,
    required this.phoneNumber,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final TwilioSmsService smsService = TwilioSmsService(
      accountSid: dotenv.env['TWILIO_SID']!,
      authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
      twilioPhoneNumber: dotenv.env['twilioPhoneNumber']!);

  String? verificationId;
  bool isLoading = false;

  String getOtpFromFields() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool validateOtp() {
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    resendOtp();
    super.initState();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> resendOtp() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await smsService.sendOtp(widget.phoneNumber);
      if (result != "err") {
        showSnackBar("OTP sent successfully!");
      } else {
        showSnackBar("Failed to send OTP. Please try again later.");
      }
    } catch (e) {
      showSnackBar("Error resending OTP: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Enter OTP sent to ${widget.phoneNumber}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 40,
                      child: TextField(
                        controller: _controllers[index],
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context)
                                .nextFocus(); // Move to next field
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .previousFocus(); // Move to previous field
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!validateOtp()) {
                            showSnackBar("Please enter the full OTP");
                            return;
                          }

                          String otp = getOtpFromFields();

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            bool isVerified = await smsService.verifyOtp(
                                widget.phoneNumber, otp);
                            if (isVerified) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginScreen3(
                                  userName: widget.username,
                                  name: widget.name,
                                  firstName: widget.firstName,
                                  phoneNumber: widget.phoneNumber,
                                ),
                              ));
                            } else {
                              showSnackBar("Invalid OTP. Please try again.");
                            }
                          } catch (e) {
                            showSnackBar(
                                "Error verifying OTP: ${e.toString()}");
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF94651F), // Gold color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Verify OTP",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await resendOtp();
                        },
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
