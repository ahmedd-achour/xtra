import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mouvi_map_application/Model/location_offre.dart';
import 'package:mouvi_map_application/Model/media.dart';
import 'package:mouvi_map_application/Model/offres.dart';

Position pointsPicked = Position(36.436488753803374, 10.195425455401363);
Position duoPics = Position(36.436488753803374, 10.195425455401363);

Future<String> getAddressFromLatLng(Position pos) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.lat.toDouble(),
      pos.lng.toDouble(),
    );

    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      return address;
    } else {
      return "No address found";
    }
  } catch (e) {
    print('Error for position (${pos.lat}, ${pos.lng}): $e');
    return "Error getting address";
  }
}

Future<String> getStreet(Position pos) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.lat.toDouble(),
      pos.lng.toDouble(),
    );

    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks[0];
      String address = '${place.street}';
      return address;
    } else {
      return "No address found";
    }
  } catch (e) {
    print('Error for position (${pos.lat}, ${pos.lng}): $e');
    return "Error getting address";
  }
}

Future<String> getGovernorat(Position pos) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.lat.toDouble(),
      pos.lng.toDouble(),
    );

    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks[0];
      String address = '${place.locality}, ${place.postalCode}';
      return address;
    } else {
      return "No address found";
    }
  } catch (e) {
    print('Error for position (${pos.lat}, ${pos.lng}): $e');
    return "Error getting address";
  }
}

Future<String> getCountry(Position pos) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.lat.toDouble(),
      pos.lng.toDouble(),
    );

    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks[0];
      String address = '${place.country}';
      return address;
    } else {
      return "No address found";
    }
  } catch (e) {
    print('Error for position (${pos.lat}, ${pos.lng}): $e');
    return "Error getting address";
  }
}

Future<List<String>> getAddressesFromLatLngList(
    List<Position> positions) async {
  List<String> addresses = [];

  for (Position pos in positions) {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.lat.toDouble(), pos.lng.toDouble());

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
        addresses.add(address);
      } else {
        addresses.add("No address found");
      }
    } catch (e) {
      print('Error for position (${pos.lat}, ${pos.lng}): $e');
      addresses.add("Error getting address");
    }
  }

  return addresses;
}

Future<List<String>> getLastTwoAddressesFromLatLngList(
    List<Position> positions) async {
  List<String> addresses = [];

  if (positions.isEmpty) {
    return [];
  }

  // Pick the last two positions
  List<Position> lastPositions = positions.length >= 2
      ? positions.sublist(positions.length - 2)
      : [positions.last];

  for (Position pos in lastPositions) {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.lat.toDouble(), pos.lng.toDouble());

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        String address = [
          place.street?.isNotEmpty == true ? place.street : null,
          place.locality?.isNotEmpty == true ? place.locality : null,
          place.postalCode?.isNotEmpty == true ? place.postalCode : null,
          place.country?.isNotEmpty == true ? place.country : null,
        ].whereType<String>().join(', '); // Only join non-null values

        addresses.add(address.isNotEmpty ? address : "Unknown address");
      } else {
        addresses.add("No address found");
      }
    } catch (e) {
      print('Error for position (${pos.lat}, ${pos.lng}): $e');
      addresses.add("Error getting address");
    }
  }

  return addresses;
}

Future<String> createOfferFull({
  required Timestamp time,
  required String titre,
  required String description,
  required String categorie,
  required double prix,
  required String utilisateurId,
  required String pays,
  required String gouvernorat,
  required String delegation,
  required GeoPoint position, // Use this instead of lat/long
  required List<String> images,
  String? videoUrl,
  String? texteAnnexe,
}) async {
  String res = 'Problem while creating offer';
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Step 1: Create the offer
    final offerRef = await firestore.collection('offres').add(Offres(
            categorie: categorie,
            titre: titre,
            description: description,
            prix: prix,
            utilisateurId: utilisateurId)
        .toJson());

    final offerId = offerRef.id;

    // Step 2: Save the location
    await firestore.collection('location_offre').doc(offerId).set(
        location_offre(
                offreId: offerId,
                delegation: delegation,
                gouvernorat: gouvernorat,
                pays: pays,
                dateExpiration: time,
                position: position)
            .toJson());

    // Step 3: Save media
    await firestore.collection('medias').doc(offerId).set({
      'offreId': offerId,
      'images': images,
      if (videoUrl != null) 'video': videoUrl,
      if (texteAnnexe != null) 'texteAnnexe': texteAnnexe,
    });

    res = 'success';
  } catch (e) {
    res = 'An error occurred: ${e.toString()}';
  }

  return res;
}

Future<GeoPoint?> getGovernorateGeoPoint(String governorateName) async {
  try {
    final String query = Uri.encodeComponent('$governorateName, Tunisia');
    final Uri url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');

    final response = await http.get(url, headers: {
      'User-Agent':
          'FlutterApp (achourahmed709@gmail.com)' // Required by Nominatim
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final double lat = double.parse(data[0]['lat']);
        final double lon = double.parse(data[0]['lon']);
        return GeoPoint(lat, lon);
      } else {
        print('No results found for $governorateName');
      }
    } else {
      print('Failed to fetch geolocation. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while fetching GeoPoint: $e');
  }

  return null; // Return null if anything fails
}

Future<List<String>> getUniqueGovernorates() async {
  try {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('location_offre').get();

    final Set<String> uniqueGovernorates = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String? gouvernorat = data['gouvernorat'];

      if (gouvernorat != null && gouvernorat.trim().isNotEmpty) {
        uniqueGovernorates.add(gouvernorat.trim());
      }
    }

    return uniqueGovernorates.toList();
  } catch (e) {
    print('Error fetching governorates: $e');
    return [];
  }
}
