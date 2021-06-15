import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';
import 'package:zs_bluetooth_printer/pages/print_config/print_config_view.dart';
import 'package:zs_bluetooth_printer/print/device_cache.dart';
import 'package:zs_bluetooth_printer/print/printer_setting_device.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:zs_bluetooth_printer/zs_bluetooth_printer.dart';
import 'print_config_action.dart';
import 'print_config_state.dart';

Effect<PrintConfigState> buildEffect() {
  return combineEffects(<Object, Effect<PrintConfigState>>{
    PrintConfigAction.action: _onAction,
    Lifecycle.initState: _init,
    Lifecycle.deactivate: _deactivate,
    PrintConfigAction.onBack: _onBack,
    PrintConfigAction.onTapPrintChoose: _onTapPrintChoose,
    PrintConfigAction.onTapPrintListItem: _onTapPrintListItem,
  });
}

void _init(Action action, Context<PrintConfigState> ctx) async{
  _timeStartLoop(ctx);

  if (PrintTemplateList.currentTemp != null && PrintTemplateList.currentTemp.printJson == null) {
    bool res = await ctx.state.currentPrintTemplate.loadPrintData();
    if (res) {
      ctx.dispatch(PrintConfigActionCreator.updateCurrentPrintTemplate(ctx.state.currentPrintTemplate));
    }
  }
}
void _deactivate(Action action, Context<PrintConfigState> ctx) {
  ctx.state.cancelTimer();
}


void _onAction(Action action, Context<PrintConfigState> ctx) {
}

void _onBack(Action action, Context<PrintConfigState> ctx) {

  if (ZSDeviceCache.currentedDevice() != null && PrintTemplateList.currentTemp == null) {
    ZsBluetoothPrinterManager.printerApi.showToast("请选择小标签模板");
    return;
  }

  prefix0.Navigator.of(ctx.context).pop();
}
void _onTapPrintChoose(Action action, Context<PrintConfigState> ctx) {

  ZsBluetoothPrinterManager.printerApi.loadPrintTempList().then((value){
    showSheetTempList(value, ctx);
  });
}
void _onTapPrintListItem(Action action, Context<PrintConfigState> ctx)async {

  PrintTemplateList temp = action.payload;
  if(await temp.loadPrintData()) {
    PrintTemplateList.saveCurrentTemp(temp);
    // 存储更新当前模版 并刷新UI
    ctx.dispatch(PrintConfigActionCreator.updateCurrentPrintTemplate(temp));
  }
}




void _timeStartLoop(Context<PrintConfigState> ctx){
  ctx.state.cancelTimer();
  ctx.state.timer = Timer(Duration(seconds: 2), (){
    PrinterSettingDevice device = ZSDeviceCache.currentedDevice();
    String name = null;
    if (device != null) {
      name = device.name;
    }
    if (name != ctx.state.printerName) {
      ctx.dispatch(PrintConfigActionCreator.changePrinterName(name));
    }
    _timeStartLoop(ctx);
  });
}
