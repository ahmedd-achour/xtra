import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeposerOffreScreen(),
    );
  }
}

class DeposerOffreScreen extends StatefulWidget {
  @override
  _DeposerOffreScreenState createState() => _DeposerOffreScreenState();
}

class _DeposerOffreScreenState extends State<DeposerOffreScreen> {
  final TextEditingController _titre = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _media = TextEditingController();
  String? _selectedOption;

  late MapboxMap _mapController;

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
        resizeToAvoidBottomInset: false, // Prevent resizing

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: sharedappbar.leading,
          title: sharedappbar.title,
          actions: [
            _buildSearchIcon(),
            const SizedBox(width: 10),
            _buildCountryIcon(),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_titre, "Titre"),
                  const SizedBox(height: 12),
                  _buildTextField(_description, "Description"),
                  const SizedBox(height: 12),
                  _buildTextField(_media, "Media",
                      suffixIcon: const Icon(Icons.upload_file_rounded,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  _buildRadioButtons(),
                  const SizedBox(height: 12),
                  _buildTextField(_description, "Localisation",
                      suffixIcon:
                          const Icon(Icons.location_city, color: Colors.white)),
                  const SizedBox(height: 57),
                  _buildGlobe(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white54),
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
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre $label';
        }
        return null;
      },
    );
  }

  Widget _buildRadioButtons() {
    return Row(
      children: [
        Radio<String>(
          value: "Actualités",
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value;
            });
          },
          activeColor: Colors.white,
        ),
        const Text("Actualités", style: TextStyle(color: Colors.white)),
        const SizedBox(width: 12),
        Radio<String>(
          value: "Duo",
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value;
            });
          },
          activeColor: Colors.white,
        ),
        const Text("Duo", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildGlobe() {
    return Container(
      height: 250,
      width: double.infinity,
      child: MapWidget(
        onMapCreated: _onMapCreated,
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(0.0, 10.0)),
          zoom: 0, // Set default zoom level
          pitch: 0.0,
          bearing: 0.0,
        ),
        styleUri: MapboxStyles.STANDARD_SATELLITE,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer()), // Enable gestures
        },
      ),
    );
  }

  void _onMapCreated(MapboxMap controller) {
    _mapController = controller;

    _mapController.logo.updateSettings(LogoSettings(enabled: false));
    _mapController.attribution
        .updateSettings(AttributionSettings(enabled: false));

    // Enable zoom controls
    _mapController.gestures.updateSettings(GesturesSettings(
      pinchToZoomEnabled: true, // Enable pinch zoom
      doubleTapToZoomInEnabled: true, // Enable double-tap zoom
      quickZoomEnabled: true, // Enable quick zoom
      scrollEnabled: true, // Enable scrolling (panning)
      rotateEnabled: true, // Enable rotation
    ));
  }

  Widget _buildSearchIcon() {
    return IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      onPressed: () {},
    );
  }

  Widget _buildCountryIcon() {
    return IconButton(
      icon: const Icon(Icons.map_rounded, color: Colors.white),
      onPressed: () {},
    );
  }
}
