import 'dart:async';
import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mouvi_map_application/Services/ModuleOffres/GeoPoint.dart';
import 'package:mouvi_map_application/Widgets/SignIn/Authentify.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/Step2.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/country_Slection.dart';
import 'package:mouvi_map_application/Widgets/Users_interface/profile.dart';
import 'package:mouvi_map_application/data/xtradata.dart';
import 'package:http/http.dart' as http;

class homePge1 extends StatefulWidget {
  final bool isLogedIn;
  const homePge1({required this.isLogedIn});
  @override
  State<homePge1> createState() => _MapboxExampleState();
}

class _MapboxExampleState extends State<homePge1>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> data = [];
  void _onStyleLoaded() async {
    print("Map style loaded successfully!");
    List<GeoPoint> geoPointss = await fetchGeoPointsFromFirebase();
    print(
        "azerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrttyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
    print(geoPointss);

    List<Map<String, dynamic>> features = geoPointss.map((point) {
      return {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [point.longitude, point.latitude],
        },
        "properties": {}
      };
    }).toList();
    String geoJsonString = jsonEncode({
      "type": "FeatureCollection",
      "features": features,
    });

    await _mapController.style
        .addSource(GeoJsonSource(id: "geo-points-source", data: geoJsonString));

    await _mapController.style.addLayer(CircleLayer(
      id: "geo-points-layer",
      sourceId: "geo-points-source",
      circleColor: const Color.fromARGB(255, 0, 30, 129).value,
      circleRadius: 5.0,
    ));
  }

// Function to get the GeoNames ID of a country
  Future<String?> getGeoNamesCountryId(String countryName) async {
    try {
      final encodedCountryName = Uri.encodeComponent(countryName);
      final apiUrl =
          'http://api.geonames.org/searchJSON?q=$encodedCountryName&maxRows=1&username=ahmedd';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // More thorough null checking
        if (data == null ||
            data['geonames'] == null ||
            data['geonames'].isEmpty) {
          debugPrint('GeoNames API returned no results for $countryName');
          return null;
        }

        final geonameId = data['geonames'][0]['geonameId']?.toString();
        if (geonameId == null) {
          debugPrint('GeoNames ID was null for $countryName');
        }
        return geonameId;
      } else {
        debugPrint(
            'GeoNames API error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'API request failed with status ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint('GeoNames API request timed out');
      throw Exception('Request timed out');
    } on http.ClientException catch (e) {
      debugPrint('Network error: $e');
      throw Exception('Network error occurred');
    } on FormatException catch (e) {
      debugPrint('JSON parsing error: $e');
      throw Exception('Failed to parse API response');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

// Function to fetch delegations (administrative divisions) from GeoNames API

  Future<List<Map<String, String>>> getDelegations(
      String countryName, String searchQuery) async {
    // Get the GeoNames country ID for the selected country
    String? countryGeoNamesId = await getGeoNamesCountryId(countryName);

    if (countryGeoNamesId == null) {
      throw Exception('Failed to retrieve GeoNames ID for country');
    }

    // Fetch the delegations (administrative divisions) using the GeoNames ID
    final apiUrl =
        'http://api.geonames.org/childrenJSON?geonameId=$countryGeoNamesId&username=ahmedd';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("yaaaaaaaaaaaaaaaaa bhiiiiiiiiiim this is the data ");
      print(data.toString());
      List<Map<String, String>> delegations = [];
      for (var item in data['geonames']) {
        // Filter or search based on the searchQuery
        if (item['name'].toLowerCase().contains(searchQuery.toLowerCase())) {
          delegations.add({
            'name': item['name'],
            'country': countryName,
            'lat': item['lat'].toString(),
            'long': item['lng'].toString()
          });
        }
      }
      return delegations;
    } else {
      throw Exception('Failed to load delegations');
    }
  }

  late MapboxMap _mapController;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isRotating = true;
  bool _showUI = false; // Controls when to show UI elements/
  bool _showSearchBar = false;

  String? selectedFlag = "🇹🇳";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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

  void _zoomToSelectedCountry(String flag) {
    final country = countries.firstWhere(
      (element) => element['flag'] == flag,
      orElse: () => {'lat': '0.0', 'long': '0.0'}, // Default if not found
    );

    double latitude = double.parse(country['lat']!);
    double longitude = double.parse(country['long']!);

    _mapController.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 5.3,
        bearing: 0.0,
        pitch: 0.0,
      ),
      MapAnimationOptions(duration: 2400, startDelay: 0),
    );
  }

  void _zoomToSelectedDelegation(String lat, String long) {
    double latitude = double.parse(lat);
    double longitude = double.parse(long);

    _mapController.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 9.0,
        bearing: 0.0,
        pitch: 0.0,
      ),
      MapAnimationOptions(duration: 2400, startDelay: 0),
    );
  }

  String getCountryNameFromFlag(String flag) {
    // Search the countries list for the country with the selected flag
    final country = countries.firstWhere(
      (element) => element['flag'] == flag,
      orElse: () => {'name': 'Unknown'}, // Return a default value if not found
    );
    return country['name'] ?? 'Unknown';
  }

  Future<Map<String, double>> getCountryCoordinates(String countryName) async {
    final apiUrl =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$countryName.json?access_token=pk.eyJ1IjoiYWhtZWQ3MDkiLCJhIjoiY20zbGczcDl0MHJmODJqczdlMmdkdDcxaiJ9.at6AxThyq4iJokPBfo-FBw';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];
      final lat = coordinates[1]; // Latitude
      final lon = coordinates[0]; // Longitude
      return {'lat': lat, 'lon': lon};
    } else {
      throw Exception('Failed to load coordinates');
    }
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
              top: 50,
              left: _showSearchBar ? 10 : null, // Align to the left when active
              right: _showSearchBar ? null : 55, // Keep it right when inactive
              child: _showSearchBar ? _buildSearchField() : _buildSearchIcon(),
            ),

            // Country Icon
            Positioned(
              top: 47,
              right: 10,
              child: _buildCountryIcon(),
            ),

            // Bottom Button
          ],
        ],
      ),
    ));
  }

  int _selectedIndex = 0; // To track the selected item
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

  // Function to create icons with tap functionality
  Widget _buildIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white, size: 25),
      ),
    );
  }

  void showCountryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF94651F),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: CountrySelectionPopup(onCountrySelected: (flag) {
            setState(() {
              selectedFlag = flag;
              _zoomToSelectedCountry(flag);
            });
          }),
        );
      },
    );
  }

  // Function to build the country icon (changes dynamically)
  Widget _buildCountryIcon() {
    return GestureDetector(
      onTap: () => showCountryPopup(context),
      child: Container(
        padding: EdgeInsets.only(right: 35, top: 5),
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
    _onStyleLoaded();
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

  Widget _buildSearchIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: () => setState(() => _showSearchBar = true),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(),
          child: const Icon(Icons.search, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      width: 290,
      decoration: BoxDecoration(
        color: const Color(0xFF94651F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: "Rechercher offre",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) async {
                    setState(() {
                      searchQuery = value;
                    });
                    data = await getDelegations(
                        getCountryNameFromFlag(selectedFlag!), searchQuery);
                  },
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showSearchBar = false),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),

          // Simple query display
          if (searchQuery.isNotEmpty && data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: data.map((item) {
                  return ListTile(
                    title: Text(
                      item['name']!,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        searchQuery = item[
                            'name']!; // Update search query with selected suggestion
                        _showSearchBar = false;
                      });
                      _zoomToSelectedDelegation(item['lat']!, item["long"]!);
                    },
                  );
                }).toList(),
              ),
            ),
          if (searchQuery.isNotEmpty && data.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No suggestions found',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
