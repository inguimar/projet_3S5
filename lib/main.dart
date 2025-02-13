import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipezone/domains/location_manager.dart';
import 'package:swipezone/screens/planning_page.dart';
import 'package:swipezone/screens/home_page.dart';
import 'package:swipezone/screens/select_page.dart';
import 'package:swipezone/screens/nfc_page.dart';
import 'package:swipezone/repositories/models/location.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(title: 'SwipeZone'),
            routes: [
              GoRoute(
                path: 'planningpage',
                builder: (context, state) {
                  final selectedLocations = (state.extra is List<Location>)
                      ? state.extra as List<Location>
                      : <Location>[];
                  return PlanningPage(
                    title: "Ma carte",
                    selectedLocations: selectedLocations,
                  );
                },
              ),
              GoRoute(
                path: 'selectpage',
                builder: (context, state) => const SelectPage(title: "Mes favoris"),
              ),
              GoRoute(
                path: 'nfcpage',
                builder: (context, state) => NfcPage(),
              ),
            ],
          ),
        ],
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

