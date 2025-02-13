import 'package:swipezone/repositories/models/location.dart';

class LocationManager {
  static final LocationManager _instance = LocationManager._internal();

  LocationManager._internal();

  factory LocationManager() {
    return _instance;
  }

  List<Location> locations = [];
  List<Location> unwantedLocations = [];
  Map<Location, bool> filters = {};

  int currentIndex = 0;

  void Iwant() {
    if (currentIndex < locations.length) {
      filters[locations[currentIndex]] = true;
      next();
    }
  }

  void Idontwant() {
    if (currentIndex < locations.length) {
      unwantedLocations.add(locations[currentIndex]);
      filters[locations[currentIndex]] = false;
      next();
    }
  }

  void next() {
    if (currentIndex < locations.length - 1) {
      currentIndex++;
    } else {
      currentIndex = locations.length; // Set to length to indicate end of list
    }
  }

  List<Location> getLikedLocations() {
    return filters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}

