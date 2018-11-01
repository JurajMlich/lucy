import 'package:android/ui/finance/finance_overview_page.dart';
import 'package:android/ui/preferences/preferences_page.dart';
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
    name: 'Finance',
    icon: Icons.euro_symbol,
    path: '/finance',
    target: FinanceOverviewPage(),
  ),
  LucyRoute(
    name: 'Preferences',
    icon: Icons.settings,
    path: '/preferences',
    target: PreferencesPage(),
  ),
];
