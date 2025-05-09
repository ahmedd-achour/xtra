/*Collection : location_offre

Attribut | Type | Description
offreId | String | ID de l’offre liée
pays | String | Exemple : "Tunisie"
gouvernorat | String | Exemple : "Ariana"
delegation | String | Exemple : "Raoued"
position | GeoPoint | Latitude / longitude
 */

import 'package:cloud_firestore/cloud_firestore.dart';

class location_offre {
  late final String offreId;
  late final String pays;
  late final String gouvernorat;
  late final String delegation;
  late final GeoPoint position;
  late final dateExpiration;

  // si vous desidez de stocker les info du carte prochainement

  location_offre(
      {required this.offreId,
      required this.delegation,
      required this.gouvernorat,
      required this.pays,
      required this.dateExpiration,
      required this.position});

  toJson() {
    return {
      'offreId': offreId,
      'pays': pays,
      'gouvernorat': gouvernorat,
      'delegation': delegation,
      'position': position,
      'dateExpiration': dateExpiration,
    };
  }
}
