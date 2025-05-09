import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mouvi_map_application/Services/variables.dart';

class CapPosition extends StatefulWidget {
  bool isDuo;
  CapPosition({required this.isDuo});
  @override
  State<CapPosition> createState() => _CapPositionState();
}

class _CapPositionState extends State<CapPosition> {
  late MapboxMap _mapController;
  Position? _currentPosition;
  final GlobalKey _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            MapWidget(
              key: _mapKey,
              onMapCreated: _onMapCreated,
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(9.0, 34.0)),
                zoom: 6.0,
              ),
              styleUri: MapboxStyles.STANDARD_SATELLITE,
            ),
            // Fixed center marker
            Center(
              child: Icon(Icons.place_rounded, size: 40, color: Colors.red),
            ),
            // Buttons at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _getCenterCoordinates,
                      child: Text("Select"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap controller) {
    _mapController = controller;
    _updateCenterCoordinates();
  }

  void _onCameraChanged() {
    _updateCenterCoordinates();
  }

  Future<void> _updateCenterCoordinates() async {
    final screenSize = MediaQuery.of(context).size;
    final centerPoint = screenSize.center(Offset.zero);

    final widgetPosition = _getWidgetPosition();
    final absolutePoint = centerPoint + widgetPosition;

    final coordinates = await _mapController.coordinateForPixel(
      ScreenCoordinate(
        x: absolutePoint.dx,
        y: absolutePoint.dy,
      ),
    );

    setState(() {
      _currentPosition =
          coordinates.coordinates; // 🛠️ FIX: use the real geo coordinates here
    });
  }

  Offset _getWidgetPosition() {
    final renderBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Future<void> _getCenterCoordinates() async {
    try {
      final screenSize = MediaQuery.of(context).size;
      final centerPoint = screenSize.center(Offset.zero);

      final widgetPosition = _getWidgetPosition();
      final absolutePoint = centerPoint + widgetPosition;

      final coordinate = await _mapController.coordinateForPixel(
        ScreenCoordinate(
          x: absolutePoint.dx,
          y: absolutePoint.dy,
        ),
      );

      final Position position = coordinate.coordinates; // Correctly extracted

      print("Selected real geo position: ${position.lat}, ${position.lng}");
      if (widget.isDuo) {
        setState(() {
          duoPics = position;
        });
      } else if (widget.isDuo == false) {
        setState(() {
          pointsPicked = position;
        });
      }
      Navigator.of(context).pop();
    } catch (e) {
      print("Error selecting coordinates: $e");
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
