import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:url_launcher/url_launcher.dart';

class NfcPage extends StatefulWidget {
  @override
  _NfcPageState createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  String? tagId;

  Future<void> _scanNfc() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous pouvez maintenant scanner la carte NFC.")),
      );
      NFCTag tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      setState(() {
        tagId = tag.id;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur NFC : $e")),
      );
    }
  }

  void _openUrl() async {
    if (tagId != null) {
      String url = "https://www.toureiffel.paris/fr/le-monument/histoire?id=$tagId";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir l'URL")),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Aide"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Voici comment scanner une carte NFC :"),
              SizedBox(height: 10),
              Image.network('https://www.productivix.com/images/nfc-smart-icon.png'),
              SizedBox(height: 10),
              Text("1. Appuyez sur le bouton 'Scanner NFC'.\n2. Approchez la carte NFC de votre téléphone en le posant sur la partie haute de votre téléphone.\n3. Vous aurez des informations sur le lieu."),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner NFC"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _scanNfc,
                icon: Icon(Icons.nfc, color: Colors.blueAccent),
                label: const Text("Scanner", style: TextStyle(color: Colors.blueAccent)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              tagId != null
                  ? Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "Carte NFC scannée avec succès!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _openUrl,
                    icon: Icon(Icons.open_in_browser, color: Colors.blueAccent),
                    label: const Text("Ouvrir le site", style: TextStyle(color: Colors.blueAccent)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              )
                  : const Text(
                "Aucun scan effectué",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showHelpDialog,
                icon: Icon(Icons.help_outline, color: Colors.blueAccent),
                label: const Text("Aide", style: TextStyle(color: Colors.blueAccent)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}