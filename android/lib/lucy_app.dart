import 'package:android/routes.dart';
import 'package:android/ui/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';

class LucyApp extends StatefulWidget {
  @override
  _LucyAppState createState() {
    return _LucyAppState();
  }
}

class _LucyAppState extends State<LucyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
      ),
      home: DashboardPage(),
      routes: routes
          .map(
            (route) => {route.path: (BuildContext context) => route.target},
          )
          .reduce(
            (map1, map2) => map1..addAll(map2),
          ),
    );
  }
}
