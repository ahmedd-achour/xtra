import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mouvi_map_application/SharedWidgets/Appbar.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/Step3.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/Step2.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/Step1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeposserC(),
    );
  }
}

class DeposserC extends StatefulWidget {
  @override
  _DeposserCState createState() => _DeposserCState();
}

class _DeposserCState extends State<DeposserC> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titre = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _media = TextEditingController();

  late MapboxMap _mapController;
  String? _selectedOption;
  String? selectedFlag;

  @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF001D3D), Color(0xFF002952)],
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //       ),
  //     ),
  //     child: Scaffold(
  //       backgroundColor: Colors.transparent,
  //       resizeToAvoidBottomInset: false,
  //       appBar: AppBar(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         leading: sharedappbar.leading,
  //         title: sharedappbar.title,
  //         actions: [
  //           _buildSearchIcon(),
  //           SizedBox(width: 10),
  //           _buildCountryIcon(),
  //         ],
  //       ),
  //       body: Stack(

  //         children: [
  //           SizedBox(height: 12),

  //           Positioned.fill(child: _buildGlobe()), // La carte en full screen
  //           Column(
  //             children: [
  //               _buildTextField(_titre, "Titre"),
  //               SizedBox(height: 12),
  //               _buildTextField(_description, "Description"),
  //               SizedBox(height: 12),
  //               _buildTextField(_media, "Media",
  //                   suffixIcon:
  //                       Icon(Icons.upload_file_rounded, color: Colors.white)),
  //               _buildNextButton(),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
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
          resizeToAvoidBottomInset: false, // Preven
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: sharedappbar.leading,
            title: sharedappbar.title,
            actions: [
              // _buildSearchIcon(),
              SizedBox(width: 10),
              _buildCountryIcon(),
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context)
                .unfocus(), // Ferme le clavier en tapant ailleurs
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Évite les coupures quand le clavier apparaît
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        _buildRadioButtons(),
                        SizedBox(height: 12),
                        _buildTextField(_description, "Localisation",
                            suffixIcon:
                                Icon(Icons.location_city, color: Colors.white)),
                        SizedBox(height: 57),
                        SizedBox(height: 20),
                        _buildNextButton(),
                      ],
                    ),
                  ),
                ),
                _buildGlobe(), // Prend tout l’espace restant après le bouton
              ],
            ),
          ),
        ));
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
        Text("Actualités", style: TextStyle(color: Colors.white)),
        SizedBox(width: 12),
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
        Text("Duo", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildGlobe() {
    return Expanded(
      child: Container(
        width: double.infinity,
        child: MapWidget(
          onMapCreated: _onMapCreated,
          cameraOptions: CameraOptions(
            center: Point(coordinates: Position(0.0, 10.0)),
            zoom: 1,
            pitch: 0.0,
            bearing: 0.0,
          ),
          styleUri: MapboxStyles.STANDARD_SATELLITE,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer()),
          },
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
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: suffixIcon,
      ),
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre $label';
        }
        return null;
      },
    );
  }

  void _onMapCreated(MapboxMap controller) {
    _mapController = controller;
    _mapController.logo.updateSettings(LogoSettings(enabled: false));
    _mapController.attribution
        .updateSettings(AttributionSettings(enabled: false));

    _mapController.gestures.updateSettings(GesturesSettings(
      pinchToZoomEnabled: true,
      doubleTapToZoomInEnabled: true,
      quickZoomEnabled: true,
      scrollEnabled: true,
      rotateEnabled: true,
    ));
  }

  Widget _buildSearchIcon() {
    return IconButton(
      icon: Icon(Icons.search, color: Colors.white),
      onPressed: () {},
    );
  }

  Widget _buildCountryIcon() {
    List<Map<String, String>> countries = [
      {"flag": "🇹🇳", "name": "Tunisia"},
      {"flag": "🇫🇷", "name": "France"},
    ];

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedFlag,
        dropdownColor: Colors.black87,
        hint: Icon(Icons.map_rounded, color: Colors.white, size: 25),
        items: countries.map((country) {
          return DropdownMenuItem<String>(
            value: country["flag"],
            child: Text(
              country["flag"]!,
              style: TextStyle(fontSize: 26),
            ),
          );
        }).toList(),
        onChanged: (flag) {
          setState(() {
            selectedFlag = flag;
          });
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E1F0A),
                Color(0xFF94651F),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: () {
              // Naviguer vers l'écran suivant
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeposerOffreScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.transparent, // Permet d'afficher le dégradé
              shadowColor: Colors.transparent, // Évite une ombre non voulue
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Suivant",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
