import 'package:emailjs/emailjs.dart' as emailjs;

String generateOTP() {
  // Generate a 4-digit OTP
  return (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
}

void sendEmail(String email, String code) async {
  try {
    await emailjs.send(
      'service_v47wm99', // Your service ID
      'template_8c1es53', // Your template ID
      {
        'from_name': 'mouvimap', // Your name or the sender's name
        'code': code, // OTP or message
        'reply_to': email, // Receiver's email
      },
      const emailjs.Options(
          publicKey: 'RIhDo151l5Xj3AZrS', // Your public key
          privateKey: 'Jllz-ntim3LLO58ys9w6d', // Your private key
          limitRate: const emailjs.LimitRate(
            id: 'app',
            throttle: 10000,
          )),
    );
    print('SUCCESS! Email sent!');
  } catch (error) {
    if (error is emailjs.EmailJSResponseStatus) {
      print('ERROR... $error');
    }
    print('Error: ${error.toString()}');
  }
}
