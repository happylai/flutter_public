
import 'dart:async';

import 'package:flutter/services.dart';

class ZsPermisson {
  static const MethodChannel _channel =
      const MethodChannel('zs_permisson');


  static Future<bool> checkLocationPermission() async{
    int res = await _channel.invokeMethod("checkLocationPermission");
    return res == 0;
  }
  static Future<bool> checkLocationState() async{
    int res = await _channel.invokeMethod("checkLocationState");
    return res == 0;
  }

  static openLocationState() {
    _channel.invokeMethod("openLocationState");
  }
  static openLocationPermission() {
    _channel.invokeMethod("openLocationPermission");
  }
  static openBluetoothPmission() {
    _channel.invokeMethod("openBluetoothPmission");
  }
  static openBluetooth() {
    _channel.invokeMethod("openBluetooth");
  }
}
