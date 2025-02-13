import 'package:isar/isar.dart';

@embedded
class Localization {
  String? adress;
  double? lat;
  double? lng;
  Localization(this.adress, this.lat, this.lng);
}