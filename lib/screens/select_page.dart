import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipezone/domains/location_manager.dart';
import 'package:swipezone/repositories/models/location.dart';
import 'package:swipezone/repositories/models/categories.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectPage extends StatefulWidget {
  final String title;

  const SelectPage({super.key, required this.title});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  List<Location> likedLocations = [];
  Set<Location> selectedLocations = {};
  Categories? selectedCategory;
  String? selectedSortOption;

  @override
  void initState() {
    super.initState();
    _loadLikedLocations();
  }

  void _loadLikedLocations() {
    setState(() {
      likedLocations = LocationManager().getLikedLocations();
    });
  }

  void _applyFilters() {
    List<Location> filteredLocations = LocationManager().getLikedLocations();

    if (selectedCategory != null) {
      filteredLocations =
          filteredLocations.where((location) => location.category ==
              selectedCategory).toList();
    }

    if (selectedSortOption != null) {
      switch (selectedSortOption) {
        case 'Nom (A-Z)':
          filteredLocations.sort((a, b) => a.nom.compareTo(b.nom));
          break;
        case 'Nom (Z-A)':
          filteredLocations.sort((a, b) => b.nom.compareTo(a.nom));
          break;
        case 'Popularité':
          filteredLocations.sort((a, b) =>
              b.popularity.compareTo(a.popularity));
          break;
      }
    }

    setState(() {
      likedLocations = filteredLocations;
    });
  }

  Future<void> _sharePlansViaSMS() async {
    if (selectedLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun lieu sélectionné')),
      );
      return;
    }

    String message = 'Je te partage mes lieux favoris : ${selectedLocations
        .map((l) => l.nom).join(", ")}';
    Uri smsUri = Uri(
        scheme: 'sms', query: 'body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Impossible d\'ouvrir l\'application SMS')),
        );
      }
    }
  }

  void _openMap() {
    GoRouter.of(context).push(
        '/planningpage', extra: selectedLocations.toList());
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filtres"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filtrer par catégorie"),
                  DropdownButton<Categories>(
                    value: selectedCategory,
                    hint: Text("Sélectionnez une catégorie"),
                    items: [
                      DropdownMenuItem<Categories>(
                        value: null,
                        child: Text("Tous les monuments"),
                      ),
                      ...Categories.values.map((Categories category) {
                        return DropdownMenuItem<Categories>(
                          value: category,
                          child: Text(_getCategoryName(category)),
                        );
                      }).toList(),
                    ],
                    onChanged: (Categories? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text("Trier par"),
                  DropdownButton<String>(
                    value: selectedSortOption ?? 'Aucun tri',
                    hint: Text("Sélectionnez une option de tri"),
                    items: <String>[
                      'Aucun tri',
                      'Nom (A-Z)',
                      'Nom (Z-A)',
                      'Popularité'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSortOption = newValue == 'Aucun tri' ? null : newValue;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text("Actions rapides"),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedLocations = likedLocations.toSet();
                          });
                        },
                        child: Text("Sélectionner tout"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedLocations.clear();
                          });
                        },
                        child: Text("Désélectionner tout"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirmation"),
                                content: Text("Es-tu sûr de vouloir supprimer les lieux sélectionnés ?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text("Annuler"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Supprimer"),
                                    onPressed: () {
                                      setState(() {
                                        likedLocations.removeWhere((location) => selectedLocations.contains(location));
                                        selectedLocations.clear();
                                      });
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text("Supprimer les lieux sélectionnés"),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _applyFilters();
                Navigator.of(context).pop();
              },
              child: Text("Appliquer"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: likedLocations.length,
                itemBuilder: (context, index) {
                  Location location = likedLocations[index];
                  bool isSelected = selectedLocations.contains(location);
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(location.photoUrl ??
                            'https://via.placeholder.com/50'),
                      ),
                      title: Text(
                          location.nom, style: TextStyle(fontWeight: FontWeight
                          .bold)),
                      subtitle: Text(
                          location.localization.adress ?? 'Adresse inconnue'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedLocations.add(location);
                                } else {
                                  selectedLocations.remove(location);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Confirmation"),
                                    content: Text(
                                        "Es-tu sûr de vouloir supprimer ce lieu ?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("Annuler"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Supprimer"),
                                        onPressed: () {
                                          setState(() {
                                            LocationManager()
                                                .filters[location] = false;
                                            likedLocations.remove(location);
                                            selectedLocations.remove(location);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: selectedLocations.isNotEmpty ? _openMap : null,
                      icon: Icon(Icons.map,
                          color: selectedLocations.isNotEmpty ? Colors
                              .blueAccent : Colors.grey),
                      label: Text("Carte", style: TextStyle(
                          color: selectedLocations.isNotEmpty ? Colors
                              .blueAccent : Colors.grey)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: selectedLocations.isNotEmpty
                              ? Colors.blue
                              : Colors.grey),
                      ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: selectedLocations.isNotEmpty
                          ? _sharePlansViaSMS
                          : null,
                      icon: Icon(Icons.share,
                          color: selectedLocations.isNotEmpty
                              ? Colors.green
                              : Colors.grey),
                      label: Text("Partager", style: TextStyle(
                          color: selectedLocations.isNotEmpty
                              ? Colors.green
                              : Colors.grey)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: selectedLocations.isNotEmpty
                              ? Colors.green
                              : Colors.grey),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(Categories category) {
    switch (category) {
      case Categories.Museum:
        return 'Musée';
      case Categories.Tower:
        return 'Tour';
      case Categories.Church:
        return 'Église';
      case Categories.HistoricalSite:
        return 'Site historique';
      case Categories.Park:
        return 'Parc';
      default:
        return '';
    }
  }
}