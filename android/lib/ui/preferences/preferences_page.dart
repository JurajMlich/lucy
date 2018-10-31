import 'package:android/lucy_container.dart';
import 'package:flutter/material.dart';

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() {
    return _PreferencesPageState();
  }
}

class _PreferencesPageState extends State<PreferencesPage> {
  // todo:
  // 1. user credentials
  // 2. force full sync
  // 3. month spending goal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
        actions: <Widget>[],
      ),
      body: Column(
        children: <Widget>[
          FlatButton(
            child: Text('Force full sync'),
            onPressed: () =>
                LucyContainer().syncManager.synchronize(forceFullSync: true),
          ),
          TextField()
        ],
      ),
    );
  }
}
