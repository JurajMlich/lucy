import 'package:android/redux/app/app_action.dart';
import 'package:android/redux/app/app_state.dart';
import 'package:android/routes.dart';
import 'package:android/ui/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class LucyApp extends StatefulWidget {
  final Store<AppState> store;

  LucyApp(this.store);

  @override
  _LucyAppState createState() {
    return _LucyAppState();
  }
}

class _LucyAppState extends State<LucyApp> {
  @override
  void initState() {
    super.initState();
    widget.store.dispatch(AppInitializeAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
        title: 'Lucy',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
        ),
        home: DashboardPage(widget.store),
        routes: routes
            .map(
              (route) => {route.path: (BuildContext context) => route.target},
            )
            .reduce(
              (map1, map2) => map1..addAll(map2),
            ),
      ),
    );
  }
}
