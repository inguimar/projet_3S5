import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:swipezone/domains/location_manager.dart';
import 'package:swipezone/domains/locations_usecase.dart';
import 'package:swipezone/screens/widgets/location_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: HomePage(title: 'SwipeZone'),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  void _loadLocations() async {
    final locations = await LocationUseCase().getLocation();
    LocationManager().locations = locations;
    setState(() {
      _swipeItems = locations
          .map((location) => SwipeItem(
        content: location,
        likeAction: () {
          LocationManager().Iwant();
        },
        nopeAction: () {
          LocationManager().Idontwant();
        },
      ))
          .toList();
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  Future<void> _shareAppViaSMS() async {
    const message = 'Découvrez cette application incroyable : [lien de l\'application]';
    Uri smsUri = Uri(scheme: 'sms', query: 'body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'application SMS')),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Aide"),
          content: Text(
            "Pour utiliser l'application :\n\n"
                "1. Swipez vers la droite pour aimer un lieu.\n"
                "2. Swipez vers la gauche pour ne pas aimer un lieu.\n"
                "3. Utilisez les boutons 'Oui' et 'Non' si vous préférez ne pas swiper.\n"
                "4. Cliquez sur l'icône de partage pour partager l'application par SMS.\n"
                "5. Cliquez sur 'Favoris' pour voir vos lieux favoris.\n"
                "6. Cliquez sur 'Scanner NFC' pour scanner des tags NFC.",
          ),
          actions: [
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

  void _editProfile() {
    // Ajoutez ici la navigation vers la page de personnalisation du profil
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
              onTap: _editProfile,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Paramètres'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Partager'),
              onTap: _shareAppViaSMS,
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Aide'),
              onTap: _showHelpDialog,
            ),
          ],
        ),
      ),
      body: _swipeItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
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
              child: _isFinished
                  ? Center(
                child: Text(
                  "Vous avez atteint la fin de la liste",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
                  : SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    child: LocationCard(
                      location: _swipeItems[index].content,
                    ),
                  );
                },
                onStackFinished: () {
                  setState(() {
                    _isFinished = true;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _matchEngine.currentItem?.nope();
                        },
                        icon: Icon(Icons.thumb_down, color: Colors.white),
                        label: Text("Non", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _matchEngine.currentItem?.like();
                        },
                        icon: Icon(Icons.thumb_up, color: Colors.white),
                        label: Text("Oui", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => GoRouter.of(context).go('/selectpage'),
                      icon: Icon(Icons.favorite, color: Colors.pink),
                      label: Text("Favoris", style: TextStyle(color: Colors.pink)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.pink),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => GoRouter.of(context).go('/nfcpage'),
                      icon: Icon(Icons.nfc, color: Colors.green),
                      label: Text("Scanner NFC", style: TextStyle(color: Colors.green)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.green),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
  }

  void _changeLanguage() {

  }

  void _editProfile() {

  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Aide"),
          content: Text(
            "Pour utiliser l'application :\n\n"
                "1. Swipez vers la droite pour aimer un lieu.\n"
                "2. Swipez vers la gauche pour ne pas aimer un lieu.\n"
                "3. Utilisez les boutons 'Oui' et 'Non' si vous préférez ne pas swiper.\n"
                "4. Cliquez sur l'icône de partage pour partager l'application par SMS.\n"
                "5. Cliquez sur 'Favoris' pour voir vos lieux favoris.\n"
                "6. Cliquez sur 'Scanner NFC' pour scanner des tags NFC.",
          ),
          actions: [
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

  Future<void> _shareAppViaSMS() async {
    const message = 'Découvrez cette application incroyable : [lien de l\'application]';
    Uri smsUri = Uri(scheme: 'sms', query: 'body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'application SMS')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Mode sombre'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Langue'),
            onTap: _changeLanguage,
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Partager'),
            onTap: _shareAppViaSMS,
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Aide'),
            onTap: _showHelpDialog,
          ),
        ],
      ),
    );
  }
}