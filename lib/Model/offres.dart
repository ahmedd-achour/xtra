/*Collection : offres

Attribut      | Type   | Description
id               | String | ID de l’offre
titre            | String | Titre de l’offre
description | String | Description principale
categorie    | String | "duo" ou "actualité"
prix            | double | Prix de l’offre (si applicable)
datePublication | Timestamp | Date de création
dateExpiration | Timestamp | Date limite d’affichage
utilisateurId | String | ID de l’utilisateur qui a posté


Collection : location_offre

Attribut | Type | Description
offreId | String | ID de l’offre liée
pays | String | Exemple : "Tunisie"
gouvernorat | String | Exemple : "Ariana"
delegation | String | Exemple : "Raoued"
position | GeoPoint | Latitude / longitude  


Collection : medias

Attribut | Type | Description
offreId | String | ID de l’offre liée
images | List<String> | URLs des images
video | String (optionnel) | URL de la vidéo
texteAnnexe | String (optionnel) | Texte complémentaire



Xtra_Map.txt
Affichage de Xtra_Map.txt en cours... */
// mathabina neb3dou ala mot clée user 5ater already defined pourcela e5tart Users

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Offres {
  final String titre;
  final String description;
  final String categorie; // "duo" or "actualité"
  final double prix;
  final Timestamp datePublication;
  final Timestamp dateExpiration;
  final String utilisateurId;

  Offres({
    required this.titre,
    required this.description,
    required this.categorie,
    required this.prix,
    required this.utilisateurId,
  })  : datePublication = Timestamp.now(),
        dateExpiration = Timestamp.fromDate(
          DateTime.now().add(Duration(hours: 24)),
        );

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'categorie': categorie,
      'prix': prix,
      'datePublication': datePublication,
      'dateExpiration': dateExpiration,
      'utilisateurId': utilisateurId,
    };
  }
}
