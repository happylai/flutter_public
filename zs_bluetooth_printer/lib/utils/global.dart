
import 'package:flutter/cupertino.dart';
import 'package:zs_bluetooth_printer/zs_bluetooth_printer.dart';

class Global {
  /// 跳转到登录界面   全局context
  static GlobalKey<NavigatorState> get navigatorKey {
    return ZsBluetoothPrinterManager.printerApi.globalNavigatorKey();
  }
}