import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mouvi_map_application/Model/media.dart';

class MediasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createMedia({required Media data}) async {
    String res = 'Erreur lors de la création';
    try {
      await _firestore.collection('medias').add(data.toJson());
      res = 'success';
    } catch (e) {
      res = 'Erreur (createMedia): ${e.toString()}';
    }
    return res;
  }

  Future<List<QueryDocumentSnapshot>> readAllMedias() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('medias').get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Erreur (readAllMedias): ${e.toString()}');
    }
  }

  Future<String> updateMedia({required String id, required Media data}) async {
    String res = 'Erreur lors de la mise à jour';
    try {
      await _firestore.collection('medias').doc(id).update(data.toJson());
      res = 'success';
    } catch (e) {
      res = 'Erreur (updateMedia): ${e.toString()}';
    }
    return res;
  }

  Future<String> deleteMedia({required String id}) async {
    String res = 'Erreur lors de la suppression';
    try {
      await _firestore.collection('medias').doc(id).delete();
      res = 'success';
    } catch (e) {
      res = 'Erreur (deleteMedia): ${e.toString()}';
    }
    return res;
  }
}
