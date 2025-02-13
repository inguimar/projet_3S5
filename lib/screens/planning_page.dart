import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:swipezone/repositories/models/location.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanningPage extends StatefulWidget {
  final String title;
  final List<Location> selectedLocations;

  const PlanningPage({super.key, required this.title, required this.selectedLocations});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
  }

  Future<void> _launchGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(48.8566, 2.3522), // Centré sur Paris
              zoom: 11.0,
              onTap: (_, __) => _popupController.hideAllPopups(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  markers: _createMarkers(),
                  popupController: _popupController,
                  popupBuilder: (BuildContext context, Marker marker) {
                    final location = (marker.key as ValueKey<Location>).value;
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              location.nom,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              location.localization.adress ?? 'Adresse inconnue',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              child: Text('Itinéraire'),
                              onPressed: () => _launchGoogleMaps(location.localization.lat!, location.localization.lng!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(color: Colors.blueAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _zoomIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.blueAccent),
                    ),
                    padding: EdgeInsets.all(12),
                  ),
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _zoomOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.blueAccent),
                    ),
                    padding: EdgeInsets.all(12),
                  ),
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _createMarkers() {
    return widget.selectedLocations.map((location) {
      return Marker(
        key: ValueKey(location),
        width: 40.0,
        height: 40.0,
        point: LatLng(location.localization.lat!, location.localization.lng!),
        builder: (ctx) => Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40.0,
        ),
      );
    }).toList();
  }
}