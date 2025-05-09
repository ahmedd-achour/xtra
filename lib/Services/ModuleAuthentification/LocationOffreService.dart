import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mouvi_map_application/Model/location_offre.dart';

class LocationOffreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createLocation({required location_offre data}) async {
    String res = 'Erreur lors de la création';
    try {
      await _firestore.collection('location_offre').add(data.toJson());
      res = 'success';
    } catch (e) {
      res = 'Erreur (createLocation): ${e.toString()}';
    }
    return res;
  }

  Future<List<QueryDocumentSnapshot>> readAllLocations() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('location_offre').get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Erreur (readAllLocations): ${e.toString()}');
    }
  }

  Future<String> updateLocation(
      {required String id, required location_offre data}) async {
    String res = 'Erreur lors de la mise à jour';
    try {
      await _firestore
          .collection('location_offre')
          .doc(id)
          .update(data.toJson());
      res = 'success';
    } catch (e) {
      res = 'Erreur (updateLocation): ${e.toString()}';
    }
    return res;
  }

  Future<String> deleteLocation({required String id}) async {
    String res = 'Erreur lors de la suppression';
    try {
      await _firestore.collection('location_offre').doc(id).delete();
      res = 'success';
    } catch (e) {
      res = 'Erreur (deleteLocation): ${e.toString()}';
    }
    return res;
  }
}
