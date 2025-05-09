import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mouvi_map_application/Model/offres.dart';

class OffresService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOffre({required Offres offre}) async {
    String res = 'Une erreur est survenue';
    try {
      await _firestore.collection('offres').add(offre.toJson());
      res = 'success';
    } catch (e) {
      res = 'Erreur (createOffre): ${e.toString()}';
    }
    return res;
  }

  Future<List<QueryDocumentSnapshot>> readAllOffres() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('offres').get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Erreur (readAllOffres): ${e.toString()}');
    }
  }

  Future<String> updateOffre({required String id, required Offres data}) async {
    String res = 'Erreur lors de la mise à jour';
    try {
      await _firestore.collection('offres').doc(id).update(data.toJson());
      res = 'success';
    } catch (e) {
      res = 'Erreur (updateOffre): ${e.toString()}';
    }
    return res;
  }

  Future<String> deleteOffre({required String id}) async {
    String res = 'Erreur lors de la suppression';
    try {
      await _firestore.collection('offres').doc(id).delete();
      res = 'success';
    } catch (e) {
      res = 'Erreur (deleteOffre): ${e.toString()}';
    }
    return res;
  }
}
