import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mouvi_map_application/Services/ModuleOffres/GeoPoint.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/homecurved.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/homecurvedN.dart';
import 'package:mouvi_map_application/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // pour la sécuritée des api keys , passwords etc..
  await dotenv.load(fileName: ".env");
  // Subscribe to the real-time stream of GeoPoints
  getPoints().listen((dynamic points) {
    print("Received updated GeoPoints: $points");
    // Handle the updated list of GeoPoints here
    // For example, update UI or state in your app
  }, onError: (error) {
    print("Error in stream: $error");
  }, onDone: () {
    print("Stream closed");
  });

  String ACCESS_TOKEN = dotenv.env['ACCESS_TOKEN']!;
  MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  User? _user;
  bool _isCheckingSession = true; // Add loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check for existing session on app start
    await _checkPersistedSession();
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isTemporary = prefs.getBool('temporarySession') ?? false;

    if (isTemporary) {
      await FirebaseAuth.instance.signOut();
      await prefs.remove('temporarySession');
    }
    setState(() => _isCheckingSession = false);
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Update Firestore session status
        await _updateSessionStatus(user);
      }
      setState(() => _user = user);
    });
  }

  Future<void> _updateSessionStatus(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userDoc = await FirebaseFirestore.instance
        .collection('Utilisateurs')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final isLoggedIn = userDoc.get('isLogedIn') ?? false;

      // Set session persistence based on Firestore value
      if (isLoggedIn) {
        await prefs.remove('temporarySession');
      } else {
        await prefs.setBool('temporarySession', true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.transparent,
                  backgroundImage: const AssetImage('assets/logo.png'),
                ),
              ],
            ),
          ));
    }

    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: FirebaseAuth.instance.currentUser == null
            ? HomePageN()
            : HomePageC()
        //home: HomePageC(),
        );
  }
}
