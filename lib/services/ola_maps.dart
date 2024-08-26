import 'dart:developer';

import 'package:flutter/services.dart';

class OlaMaps {
  static const MethodChannel _channel = MethodChannel('ola_maps');

  static Future<void> showMap() async {
    try {
      await _channel.invokeMethod('showMap');
    } on PlatformException catch (e) {
      log("Failed to show map: '${e.message}'.");
    }
  }
}
