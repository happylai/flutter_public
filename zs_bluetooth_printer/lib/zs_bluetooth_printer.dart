library zs_bluetooth_printer;

import 'package:flutter/cupertino.dart';
import 'package:zs_bluetooth_printer/model/routes.dart';
import 'package:zs_bluetooth_printer/print_util/print_util.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';
import 'package:zs_bluetooth_printer/ui_widget/print_task_view.dart';
import 'package:zs_bluetooth_printer/utils/global.dart';

import 'model/shared_cache.dart';

/**
 * 还需要考虑
 *  1. 当前对 路由管理的设置
 *  2. 本地存储的内容交给外部
 *
 *
 */

abstract class ZsBluetoothPrinterApi {

  //  字体单位是否是 毫米为单位
  bool fontSizeUnitMillimeter = true;

  //  是否展示悬浮窗 默认不展示
  bool showPrintTaskOverlay = false;

  // 请求模版列表
  Future<List<PrintTemplateList>> loadPrintTempList();

  // 根据id 请求数据模版
  Future<bool> loadPrintData(PrintTemplateList temp);

  // 全局key
  GlobalKey<NavigatorState> globalNavigatorKey();

  // 实现相关提示
  showToast(String title) {

  }

  // font size 映射到毫米单位
  String fontSizeMapToMillimeter(String font) {
    if (fontSizeUnitMillimeter) return font;
    return _fontSizeMapToMillimeterWithPixel(font);
  }

  // font size 映射到毫米单位  使用css像素
  String _fontSizeMapToMillimeterWithPixel(String font) {
    double f = 0;
    try {
      f = double.parse(font);
    }catch(e){
      return "3";
    }
    if (f <= 6)   return "2";
    if (f <= 7)   return "2.5";
    if (f <= 9)   return "3";
    if (f <= 15)  return "4";
    if (f <= 17)  return "5";
    if (f <= 18)  return "6";
    if (f <= 20)  return "7";
    if (f <= 22)  return "8";
    //if (f <= 24)  return "9";
    return "9";
  }

  // 悬浮窗所展示的widget
  Widget printTaskOverlayWidget(TaskCount taskCount){
    return null;
  }
}


class ZsBluetoothPrinterManager {

  static ZsBluetoothPrinterApi _zsBluetoothPrinterApi;

  static initPrinter(ZsBluetoothPrinterApi obj)async{
    initPrintTaskEvent();
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

  static setAppContext(BuildContext context) {
    Global.appContext = context;
  }
}