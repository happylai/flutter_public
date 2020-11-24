
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class ZsFlutterData {
  static const MethodChannel _channel =
      const MethodChannel('zs_flutter_data');

  static Future<Uint8List> gb2312(String string) async {
    Uint8List list = await _channel.invokeMethod('GB2312', string);
    return list;
  }
}
