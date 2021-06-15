import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';
import 'package:zs_bluetooth_printer/print/device_cache.dart';
import 'package:zs_bluetooth_printer/print/printer_setting_device.dart';


class PrintConfigState implements Cloneable<PrintConfigState> {

  PrintTemplateList currentPrintTemplate;


  String printerName;
  Timer timer;

  void cancelTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  @override
  PrintConfigState clone() {
    return PrintConfigState()
    ..currentPrintTemplate = currentPrintTemplate
    ..timer = timer
    ..printerName = printerName;
  }
}

PrintConfigState initState(Map<String, dynamic> args) {
  PrintConfigState state = PrintConfigState();

  state.currentPrintTemplate = PrintTemplateList.currentTemp;

  PrinterSettingDevice device = ZSDeviceCache.currentedDevice();
  if (device != null) {
    state.printerName = device.name;
  }
  return state;
}
