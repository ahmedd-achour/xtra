import 'package:cloud_firestore/cloud_firestore.dart';

class GeoPoint {
  List<GeoPoint> geoPoints = [];
  final double latitude;
  final double longitude;

  GeoPoint({required this.latitude, required this.longitude});
}

late FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Example list of points:
List<GeoPoint> geoPoints = [
  GeoPoint(latitude: 39.5, longitude: -98.0),
  GeoPoint(latitude: 38.0, longitude: -90.0),
  GeoPoint(latitude: 37.5, longitude: -95.0),
];
Future<List<GeoPoint>> fetchGeoPointsFromFirebasee() async {
  try {
    // Get all documents from the "sensors" collection
    QuerySnapshot querySnapshot =
        await _firestore.collection('location_offre').get();

    // Extract GeoPoints from the documents
    List<GeoPoint> points = [];
    for (var doc in querySnapshot.docs) {
      var location = doc[
          'position']; // Assuming 'location' is a GeoPoint field in the document
      print("the value is : ");
      print(location);

      points.add(
          GeoPoint(latitude: location.latitude, longitude: location.longitude));
    }

    geoPoints = points; // Store the GeoPoints in the state
    return geoPoints;
  } catch (e) {
    print("Error fetching GeoPoints: $e");
  }
  return [];
}

Future<List<GeoPoint>> fetchGeoPointsFromFirebase() async {
  try {
    // Get the current date for comparison
    final now = DateTime.now();

    // Get all documents from the "location_offre" collection
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('location_offre').get();

    // Extract GeoPoints from the documents, filtering by valid dateExpiration
    List<GeoPoint> points = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Check if dateExpiration exists and is valid
      if (data['dateExpiration'] != null) {
        final dateExpiration = (data['dateExpiration'] as Timestamp).toDate();
        if (dateExpiration.isAfter(now)) {
          var location = doc['position'];
          print("the value is : ");
          print(location);
          points.add(GeoPoint(
              latitude: location.latitude, longitude: location.longitude));
        }
      }
    }

    geoPoints = points; // Store the GeoPoints in the state
    return geoPoints;
  } catch (e) {
    print("Error fetching GeoPoints: $e");
    return [];
  }
}

Stream<List<GeoPoint>> getPoints() {
  try {
    // Get real-time snapshots from the "location_offre" collection
    return FirebaseFirestore.instance
        .collection('location_offre')
        .snapshots()
        .map((querySnapshot) {
      // Get the current date for comparison
      final now = DateTime.now();

      // Extract GeoPoints from the documents, filtering by valid dateExpiration
      List<GeoPoint> points = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Check if dateExpiration exists and is valid
        if (data['dateExpiration'] != null) {
          final dateExpiration = (data['dateExpiration'] as Timestamp).toDate();
          if (dateExpiration.isAfter(now)) {
            var location = doc['position'];
            print("the value is : ");
            print(location);
            points.add(GeoPoint(
                latitude: location.latitude, longitude: location.longitude));
          }
        }
      }

      geoPoints = points; // Store the GeoPoints in the state
      return points;
    });
  } catch (e) {
    print("Error fetching GeoPoints: $e");
    return Stream.value([]); // Return an empty stream in case of error
  }
}
