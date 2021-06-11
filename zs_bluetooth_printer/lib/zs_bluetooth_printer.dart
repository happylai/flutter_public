library zs_bluetooth_printer;

import 'package:flutter/cupertino.dart';
import 'package:zs_bluetooth_printer/model/routes.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';

import 'model/shared_cache.dart';

/**
 * 还需要考虑
 *  1. 当前对 路由管理的设置
 *  2. 本地存储的内容交给外部
 *
 *
 */

abstract class ZsBluetoothPrinterApi {

  // 请求模版列表
  Future<List<PrintTemplateList>> loadPrintTempList();

  // 根据id 请求数据模版
  Future<bool> loadPrintData(PrintTemplateList temp);

  // 全局key
  GlobalKey<NavigatorState> globalNavigatorKey();
}


class ZsBluetoothPrinterManager {

  static ZsBluetoothPrinterApi _zsBluetoothPrinterApi;

  static initPrinter(ZsBluetoothPrinterApi obj)async{
    await localStore.init();
    _zsBluetoothPrinterApi = obj;
  }

  static ZsBluetoothPrinterApi get printerApi {
    return _zsBluetoothPrinterApi;
  }

  // 需要外部在mian中 监听 onGenerateRoute
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name.startsWith("zs_bluetooth_printer")) {
      return CupertinoPageRoute<Object>(builder: (BuildContext context) {
        return htRoutes.buildPage(settings.name, settings.arguments);
      });
    }
    return null;
  }
}