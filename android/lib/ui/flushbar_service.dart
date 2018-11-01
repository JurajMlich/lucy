import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum FlushType { INFO, SUCCESS, WARNING, ERROR }

class FlushbarService {
  static final FlushbarService _singleton = new FlushbarService._internal();

  factory FlushbarService() {
    return _singleton;
  }

  FlushbarService._internal();

  void show(
    FlushType flushType,
    String title,
    BuildContext context, {
    Duration duration,
    Icon icon,
    String subtitle,
    Function tapAction,
  }) {
    var flushbar = Flushbar(
      backgroundColor: Colors.transparent,
      forwardAnimationCurve: Curves.bounceIn,
      reverseAnimationCurve: Curves.linear,
    );

    flushbar.userInputForm = Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            child: new Card(
              color: _getColorByFlushType(flushType),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: icon == null ? _getIconByFlushType(flushType) : icon,
                    title: Text(title, style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            onTap: () {
              if (tapAction == null) {
                Navigator.maybePop(context);
              } else {
                tapAction();
              }
            },
          )
        ],
      ),
    );
    flushbar.duration = duration ?? _getDurationByFlushType(flushType);
    flushbar.show(context);
  }

  Icon _getIconByFlushType(FlushType type) {
    switch (type) {
      case FlushType.INFO:
        return Icon(Icons.info_outline, color: Colors.white);
      case FlushType.SUCCESS:
        return Icon(Icons.check_circle, color: Colors.white);
      case FlushType.WARNING:
        return Icon(Icons.warning, color: Colors.white);
      case FlushType.ERROR:
        return Icon(Icons.error_outline, color: Colors.white);
      default:
        throw Exception('Unrecognized FlushType: $type');
    }
  }

  Color _getColorByFlushType(FlushType type) {
    switch (type) {
      case FlushType.INFO:
        return Colors.grey[600];
      case FlushType.SUCCESS:
        return Colors.green[900];
      case FlushType.WARNING:
        return Colors.yellow[900];
      case FlushType.ERROR:
        return Colors.red[900];
      default:
        throw Exception('Unrecognized FlushType: $type');
    }
  }

  Duration _getDurationByFlushType(FlushType type) {
    switch (type) {
      case FlushType.INFO:
        return const Duration(seconds: 3);
      case FlushType.SUCCESS:
        return const Duration(seconds: 3);
      case FlushType.WARNING:
        return const Duration(seconds: 4);
      case FlushType.ERROR:
        return const Duration(seconds: 4);
      default:
        throw Exception('Unrecognized FlushType: $type');
    }
  }
}
