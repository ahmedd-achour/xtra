// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseSmsService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Send OTP and return the verificationId
//   Future<String> sendOtp(
//       String phoneNumber, Function(String) onCodeSent) async {
//     String res = "err";
//     try {
//       print("Starting OTP verification process for: $phoneNumber");

//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: (PhoneAuthCredential credential) {
//           // Auto-retrieval of OTP
//           print("Auto-retrieved OTP: ${credential.smsCode}");
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           // Log detailed error information
//           print(
//               "Verification failed with code: ${e.code}, message: ${e.message}");
//           if (e.code == 'invalid-phone-number') {
//             throw Exception("The phone number entered is invalid.");
//           } else if (e.code == 'too-many-requests') {
//             throw Exception("Too many attempts. Please try again later.");
//           } else {
//             throw Exception("Failed to verify phone number: ${e.message}");
//           }
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           // Handle OTP sent successfully
//           print(
//               "OTP sent to $phoneNumber. VerificationId: $verificationId. ResendToken: $resendToken");
//           onCodeSent(verificationId);
//           res = verificationId;
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           // Handle auto-retrieval timeout
//           print("Code auto-retrieval timeout. VerificationId: $verificationId");
//         },
//       );

//       print("OTP process completed for: $phoneNumber");
//     } catch (e) {
//       // Centralized error handling
//       print("Error while sending OTP: $e");
//       res = "err";
//     }
//     return res;
//   }

//   // Verify OTP using the verificationId and user-provided OTP
//   Future<bool> verifyOtp(String verificationId, String otp) async {
//     try {
//       print("Starting OTP verification for VerificationId: $verificationId");

//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: otp,
//       );

//       // Attempt to sign in using the credential
//       final userCredential = await _auth.signInWithCredential(credential);
//       print("User signed in: ${userCredential.user?.uid}");

//       // Immediately sign out to prevent Firebase user persistence
//       await _auth.signOut();
//       print("User signed out after verification.");

//       print("OTP verified successfully!");
//       return true;
//     } catch (e) {
//       // Log detailed errors for troubleshooting
//       print(
//           "Failed to verify OTP for VerificationId: $verificationId. Error: $e");
//       return false;
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioSmsService {
  final String accountSid; // Twilio Account SID
  final String authToken; // Twilio Auth Token
  final String twilioPhoneNumber; // Twilio Phone Number
  final Map<String, String> _otpStorage =
      {}; // Temporary storage for OTPs (demo purposes only)

  TwilioSmsService({
    required this.accountSid,
    required this.authToken,
    required this.twilioPhoneNumber,
  });

  // Send OTP and store it with the phone number for verification
  Future<String> sendOtp(String phoneNumber) async {
    try {
      final otp = _generateOtp();
      print("Generated OTP for $phoneNumber: $otp");

      // Compose Twilio API request
      final url = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
      final response = await http.post(
        url,
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': phoneNumber,
          'From': twilioPhoneNumber,
          'Body': 'Your verification code is: $otp',
        },
      );

      // Check for successful response
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("OTP sent to $phoneNumber successfully.");
        _otpStorage[phoneNumber] = otp; // Store OTP for later verification
        return otp;
      } else {
        print("Failed to send OTP: ${response.body}");
        throw Exception("Failed to send OTP: ${response.body}");
      }
    } catch (e) {
      print("Error while sending OTP: $e");
      return "err";
    }
  }

  // Verify the OTP entered by the user
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      print("Verifying OTP for $phoneNumber");

      if (_otpStorage.containsKey(phoneNumber) &&
          _otpStorage[phoneNumber] == otp) {
        print("OTP verified successfully for $phoneNumber.");
        _otpStorage
            .remove(phoneNumber); // Clear OTP after successful verification
        return true;
      } else {
        print("Invalid OTP for $phoneNumber.");
        return false;
      }
    } catch (e) {
      print("Error while verifying OTP: $e");
      return false;
    }
  }

  // Generate a 6-digit OTP
  String _generateOtp() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0');
  }

  String generateOTP() {
    // Generate a 4-digit OTP
    return (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
  }

  // Send OTP and store it with the phone number for verification
  Future<String> sendfourOtp(String phoneNumber) async {
    try {
      final otp = generateOTP();
      print("Generated OTP for $phoneNumber: $otp");

      // Compose Twilio API request
      final url = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
      final response = await http.post(
        url,
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': phoneNumber,
          'From': twilioPhoneNumber,
          'Body': 'Your verification code is: $otp',
        },
      );

      // Check for successful response
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("OTP sent to $phoneNumber successfully.");
        _otpStorage[phoneNumber] = otp; // Store OTP for later verification
        return otp;
      } else {
        print("Failed to send OTP: ${response.body}");
        throw Exception("Failed to send OTP: ${response.body}");
      }
    } catch (e) {
      print("Error while sending OTP: $e");
      return "err";
    }
  }
}
