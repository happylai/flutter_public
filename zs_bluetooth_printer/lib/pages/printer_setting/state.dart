import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:zs_bluetooth_printer/model/constant.dart';
import 'package:zs_bluetooth_printer/model/shared_cache.dart';
import 'package:zs_bluetooth_printer/print/printer_setting_device.dart';
import 'package:zs_bluetooth_printer/utils/model_bridge.dart';

class PrinterSettingState implements Cloneable<PrinterSettingState> {

  // android下 定位权限和服务的开启判断 两者都没有就是"3"
  static int locationStateOk = 0; // 正常
  static int locationStatePermission = 1; // 定位权限未开启
  static int locationStateService = 2; // 定位服务未开启

  List<PrinterSettingDevice> devices;
  List<PrinterSettingDevice> devicesConnected;
  BluetoothState blueOpenStute; // 未初始化   1：打开 ，2：关闭
  int locationState = PrinterSettingState.locationStateOk; // android下 定位权限和服务的开启判断
  bool locationServiceOpen = true; // android下 定位服务的开启判断
  Timer locationServiceOpenTimer;

  ZSModelBridge bridge = ZSModelBridge();

  ZSModelBridge printConnectObserveBridge = ZSModelBridge();
  bool autoConnect = true; // 自动连接上一次的连接过的设备
  String lastDeviceId; // 上次连接过的设备的id
  bool autoPop = true; // 只有在我的设置页面的时候 不会撤销 其他跳转进来的都会在连接后 自动隐藏


  void cancelTimer() {
    if (locationServiceOpenTimer != null) {
      locationServiceOpenTimer.cancel();
      locationServiceOpenTimer = null;
    }
  }

  @override
  PrinterSettingState clone() {
    return PrinterSettingState()
      ..autoPop = autoPop
      ..printConnectObserveBridge = printConnectObserveBridge
      ..lastDeviceId = lastDeviceId
      ..autoConnect = autoConnect
      ..locationServiceOpenTimer = locationServiceOpenTimer
      ..locationServiceOpen = locationServiceOpen
      ..locationState = locationState
      ..devices = devices
      ..bridge = bridge
      ..devicesConnected = devicesConnected
      ..blueOpenStute = blueOpenStute;
  }
}

PrinterSettingState initState(Map<String, dynamic> args) {
  PrinterSettingState state = PrinterSettingState();
  state.devices = [];
  state.devicesConnected = [];
  state.lastDeviceId = localStore.getValue(STORE_LAST_PRINTER_ID);
  if (args != null && args["autoPop"] != null) {
    state.autoPop = args["autoPop"];
  }
  return state;
}
