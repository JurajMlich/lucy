import 'package:android/lucy_app.dart';
import 'package:android/lucy_container.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  await LucyContainer().init();

  runApp(LucyApp());
}
