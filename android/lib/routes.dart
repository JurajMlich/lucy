import 'package:android/ui/finances/finances_page.dart';
import 'package:flutter/material.dart';

class LucyRoute {
  String name;
  IconData icon;
  String path;
  Widget target;

  LucyRoute({
    @required this.name,
    @required this.icon,
    @required this.path,
    @required this.target,
  });
}

var routes = [
  LucyRoute(
    name: 'Finances',
    icon: Icons.euro_symbol,
    path: '/finances',
    target: FinancesPage(),
  ),
  LucyRoute(
    name: 'Preferences',
    icon: Icons.settings,
    path: '/preferences',
    target: FinancesPage(),
  ),
];
