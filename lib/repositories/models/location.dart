import 'package:swipezone/repositories/models/contact.dart';
import 'package:swipezone/repositories/models/localization.dart';
import 'package:swipezone/repositories/models/categories.dart';

class Location {
  final String nom;
  final String description;
  final Contact? contact;
  final String? photoUrl;
  final Categories category;
  final List<String>? tags;
  final Localization localization;
  final String popularity;

  Location(
      this.nom,
      this.description,
      this.contact,
      this.photoUrl,
      this.category,
      this.tags,
      this.localization,
      this.popularity,
      );

  String get rue => localization.adress ?? 'Adresse inconnue';
}