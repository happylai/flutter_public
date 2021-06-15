import 'package:fish_redux/fish_redux.dart';
import 'package:zs_bluetooth_printer/pages/printer_setting/page.dart';
import 'package:zs_bluetooth_printer/pages/print_config/print_config_page.dart';

class Pages {
  //打印机设置
  static const printerSetting = "zs_bluetooth_printer_setting";

  // 打印机配置
  static const printConfig = "zs_bluetooth_printer_config";
}

final AbstractRoutes htRoutes = PageRoutes(pages: {
  Pages.printerSetting: PrinterSettingPage(),
  Pages.printConfig: PrintConfigPage(),
});
