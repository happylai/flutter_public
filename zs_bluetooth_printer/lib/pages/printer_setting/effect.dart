import 'dart:async';
import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:zs_bluetooth_printer/model/constant.dart';
import 'package:zs_bluetooth_printer/print/blue_stream.dart';
import 'package:zs_bluetooth_printer/print/device_cache.dart';
import 'package:zs_bluetooth_printer/print/printer_setting_device.dart';
import 'package:zs_bluetooth_printer/print/zs_blue.dart';
import 'package:zs_bluetooth_printer/utils/notification_center.dart';
import 'package:zs_permisson/zs_permisson.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'action.dart';
import 'state.dart';

Effect<PrinterSettingState> buildEffect() {
  return combineEffects(<Object, Effect<PrinterSettingState>>{
    Lifecycle.initState: _initState,
    Lifecycle.deactivate: _deactivate,
  });
}

void _initState(Action action, Context<PrinterSettingState> ctx) {
  Future.delayed(Duration(milliseconds: 250), ()async{
    await _init(action, ctx);
    ctx.dispatch(PrinterSettingActionCreator.reload());
  });
}
void _init(Action action, Context<PrinterSettingState> ctx) async{

  // 由于 flutter_blue 底层 定位权限是在扫描的时候添加判断的 没有全局保存在属性中，也没有单独的方法获取，因此需要在此处单独处理
  // ctx.state.blueOpenStute = ZSBlue.instance.state; 需要在下面单独赋值  在state中 可能会出现禁止允许的时候
  if (Platform.isAndroid) {

    localServiceLoop(ctx);

    bool res = await ZSPermissionPlugin.checkLocationPermission();
    if (res == false) {
      ctx.state.locationState = PrinterSettingState.locationStatePermission;
      ctx.dispatch(PrinterSettingActionCreator.reload());
      return;
    }
  }
  zsBlueDeviceHandDisconnected = true;

  ctx.state.blueOpenStute = ZSBlue.instance.state;
  ctx.dispatch(PrinterSettingActionCreator.reload());

  if (ctx.state.blueOpenStute == BluetoothState.on) {
    _startScan(action, ctx);
  }
  ctx.state.bridge.call = (String key, state) {
    if (state == BluetoothState.on) {
      //蓝牙状态 开启
      Future.delayed(Duration(microseconds: 500), () {
        ctx.dispatch(PrinterSettingActionCreator.onBlueStateValue(state));
        _startScan(action, ctx);
      });
    } else {
      //蓝牙状态 关闭
      ctx.dispatch(PrinterSettingActionCreator.onBlueStateValue(state));
      _stopScan();
    }
  };

  ZSNotifcationCenter.addObserveForKey(ctx.state.bridge, Notify_Observe_BlueState_Key);

  // 打印机id存储通知
  ctx.state.printConnectObserveBridge.call = (key, value) {
    ctx.state.lastDeviceId = value;
    ctx.state.autoConnect = false;
    if (ctx.state.autoPop) {
      ctx.state.autoPop = false; // 防止多次触发导致多次pop
      prefix0.Navigator.of(ctx.context).pop();
    }
  };
  ZSNotifcationCenter.addObserveForKey(ctx.state.printConnectObserveBridge, STORE_LAST_PRINTER_ID);

}

void _startScan(Action action, Context<PrinterSettingState> ctx) {
  ctx.state.autoConnect = true;
  ctx.dispatch(PrinterSettingActionCreator.onResetDevice());

  // 主要是在连接后 重新进入页面 如果打印机主动断开 需要监听状态
  if (ZSDeviceCache.currentedDevice() != null) {
    ZSDeviceCache.currentedDevice().connectStateCall = (){
      ctx.dispatch(PrinterSettingActionCreator.onResetDevice());
    };
  }


  ZSBlue.instance.scanResults((ScanResult result) {
    var devices = ctx.state.devices;
    if (false ==
        devices.any((element) {
          return element.name == result.advertisementData.localName;
        })) {

      PrinterSettingDevice device = PrinterSettingDevice(result, () {
        ctx.dispatch(PrinterSettingActionCreator.onResetDevice());
      });
      ctx.dispatch(PrinterSettingActionCreator.onScanDeviceCall(device));
      if (_sameDeviceId(ctx, device)) {
        autoConnectDevice(ctx, device);
      }
    }
  });
}


void localServiceLoop(Context<PrinterSettingState> ctx){
  ctx.state.cancelTimer();
  ctx.state.locationServiceOpenTimer = Timer(Duration(seconds: 2), ()async{

    bool resState = await ZSPermissionPlugin.checkLocationState();
    if (ctx.state.locationServiceOpen != resState) {
      ctx.state.locationServiceOpen = resState;
      ctx.dispatch(PrinterSettingActionCreator.reload());
    }
    localServiceLoop(ctx);
  });
}

bool _sameDeviceId(Context<PrinterSettingState> ctx, PrinterSettingDevice device) {
  String id1 = ctx.state.lastDeviceId ?? "";
  String id2 = device.result.device.id.toString() ?? "";
  return
    ZSDeviceCache.currentedDevice() == null
        && ctx.state.autoConnect == true
        && id1.length > 0
        && id1.toLowerCase() == id2.toLowerCase()
        && device.connectState == BluetoothDeviceState.disconnected;
}
void autoConnectDevice(Context<PrinterSettingState> ctx,PrinterSettingDevice device) {
  ctx.state.autoConnect = false;
  Future.delayed(Duration(milliseconds: 1500),(){
    if (device.connectState == BluetoothDeviceState.disconnected) {
      device.connect();
    }
  });
}

void _deactivate(Action action, Context<PrinterSettingState> ctx) {
  print(" --------_deactivate------------ ");
  _stopScan();
  cancelBlueStreamSubscriptionForKey("BluetoothState");
  ZSNotifcationCenter.removeObserve(ctx.state.bridge);
  ZSNotifcationCenter.removeObserve(ctx.state.printConnectObserveBridge);
  zsBlueDeviceHandDisconnected = false;

  ctx.state.cancelTimer();
}

void _stopScan() {
  ZSBlue.instance.stopScan();
  PrinterSettingDevice.stopScan();
}
