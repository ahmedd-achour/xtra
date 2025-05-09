import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/country_Slection.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/deposer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapboxExample(),
  ));
}

class MapboxExample extends StatefulWidget {
  @override
  State<MapboxExample> createState() => _MapboxExampleState();
}

class _MapboxExampleState extends State<MapboxExample>
    with SingleTickerProviderStateMixin {
  late MapboxMap _mapController;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isRotating = true;
  bool _showUI = false; // Controls when to show UI elements/
  bool _showSearchBar = false;

  String? selectedFlag;
  String searchQuery = "";
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _rotationAnimation =
        Tween<double>(begin: 0.0, end: 360.0).animate(_animationController)
          ..addListener(() {
            if (_isRotating) {
              _mapController.setCamera(
                CameraOptions(
                  bearing: _rotationAnimation.value,
                  pitch: 30.0,
                ),
              );
            }
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _isRotating = false;
              _zoomToTunisia();
            }
          });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          // Mapbox Map
          MapWidget(
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                  coordinates:
                      Position(0.0, 80.0)), // Move towards the North Pole
              zoom: 0, // Adjust zoom level
              pitch: 0.0, // Set to 0 for an overhead view
              bearing: 0.0,
            ),
            styleUri: MapboxStyles.STANDARD_SATELLITE,
          ),

          // UI elements shown after rotation completes
          if (_showUI) ...[
            // Top-right icons
            // Search Bar
            Positioned(
              top: 47,
              left: _showSearchBar ? 10 : null, // Align to the left when active
              right: _showSearchBar ? null : 40, // Keep it right when inactive
              child: _showSearchBar ? _buildSearchField() : _buildSearchIcon(),
            ),

            // Country Icon
            Positioned(
              top: 47,
              right: 5,
              child: _buildCountryIcon(),
            ),

            // Bottom Button
          ],
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        letIndexChange: (i) {
          return true; // Allow index change
        },
        color: Colors.black,
        backgroundColor: Colors.grey,
        buttonBackgroundColor: Colors.black,
        height: 60,
        index: 1, // Set the selected index
        onTap: (index) {
          setState(() {
            _selectedIndex = index;

            if (_selectedIndex == 1) {} // Update the selected index
          });
        },
        items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.add, 1),
          _buildNavItem(Icons.person, 2),
        ],
      ),
    ));
  }

  int _selectedIndex = 1; // To track the selected item
  // Helper to build navigation items with dynamic colors
  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected
              ? Colors.amber
              : Colors.white, // Amber for selected, white for unselected
          size: index == 1 ? 48 : 30, // Fixed size for center icon
        ),
        if (isSelected && index != 1) // Add an optional indicator
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  // Function to build the country icon (changes dynamically)
  Widget _buildCountryIcon() {
    return GestureDetector(
      onTap: () => showCountryPopup(context),
      child: Container(
        padding: EdgeInsets.all(10),
        child: selectedFlag != null
            ? Text(
                selectedFlag!, // Show selected flag emoji
                style: TextStyle(fontSize: 25),
              )
            : const Icon(
                Icons.map_rounded, // Default map icon if no country is selected
                color: Colors.white,
                size: 25,
              ),
      ),
    );
  }

  void _onMapCreated(MapboxMap controller) {
    _mapController = controller;
    print("Mapbox map has been created!");

    // Hide Mapbox logo
    _mapController.logo.updateSettings(LogoSettings(enabled: false));

    // Hide Mapbox attribution
    _mapController.attribution
        .updateSettings(AttributionSettings(enabled: false));
  }

  void _zoomToTunisia() {
    var tunisiaCenter = Point(
      coordinates: Position(9.5375, 33.8869),
    );

    _mapController.flyTo(
      CameraOptions(
        center: tunisiaCenter,
        zoom: 5.0,
        bearing: 0.0,
        pitch: 0.0,
      ),
      MapAnimationOptions(duration: 3000, startDelay: 0),
    );

    // Show UI elements after zoom completes
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showUI = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // FUNCTION TO SHOW COUNTRY SELECTION POPUP
  void showCountryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: CountrySelectionPopup(onCountrySelected: (flag) {
            setState(() {
              selectedFlag = flag;
            });
          }),
        );
      },
    );
  }

  Widget _buildSearchIcon() {
    return GestureDetector(
      onTap: () => setState(() => _showSearchBar = true),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(),
        child: const Icon(Icons.search, color: Colors.amber, size: 28),
      ),
    );
  }

  List<String> searchResults = [];

  Widget _buildSearchField() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 45,
          width: 290, // Increase width for better appearance
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Rechercher offre",
                    border: InputBorder.none,
                  ),
                  onChanged: (value) async {
                    setState(() {
                      searchQuery = value;
                    });
                    await fetchLocationData(searchQuery);
                  },
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showSearchBar = false),
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ],
          ),
        ),

        // Display search results
        if (searchResults.isNotEmpty)
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            width: 290,
            child: Column(
              children: searchResults
                  .map((result) => ListTile(
                        title:
                            Text(result, style: TextStyle(color: Colors.black)),
                        onTap: () {
                          print("Selected: $result");
                        },
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  String mapboxAccessToken =
      "pk.eyJ1IjoiYWhtZWQ3MDkiLCJhIjoiY20zbGczcDl0MHJmODJqczdlMmdkdDcxaiJ9.at6AxThyq4iJokPBfo-FBw";

  Future<void> fetchLocationData(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    final String url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$mapboxAccessToken";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List features = data['features'];

        setState(() {
          searchResults = features
              .map((feature) => feature['place_name'] as String)
              .toList();
        });

        print(searchResults);
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }
}
