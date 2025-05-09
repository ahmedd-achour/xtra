/*Collection : medias

Attribut | Type | Description
offreId | String | ID de l’offre liée
images | List<String> | URLs des images
video | String (optionnel) | URL de la vidéo
texteAnnexe | String (optionnel) | Texte complémentaire
 */

class Media {
  late final String offreId;
  late final List<String> images;
  late final String video;
  late final double texteAnnexe;

  // si vous desidez de stocker les info du carte prochainement

  Media({
    required this.offreId,
    required this.images,
  });

  toJson() {
    return {
      'offreId': offreId,
      'images': images,
      'video': video,
      'texteAnnexe': texteAnnexe,
    };
  }
}
