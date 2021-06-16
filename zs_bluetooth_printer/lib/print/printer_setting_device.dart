import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../model/constant.dart';
import '../model/shared_cache.dart';
import 'device_cache.dart';
import 'zs_blue.dart';
import '../utils/notification_center.dart';
import 'blue_stream.dart';

/*
*
* streamSubscription:
*     因为使用统一的key管理，因此页面取消的时候 会取消状态监听，导致如果断开打印机，下次进入页面，设备的状态是无法监听的，
*     因此需要在取消管理的时候，重新对当前选中的状态监听
*
*     后期如果在非打印设置页面操作的，导致断开连接，可以优化 - 自动连接打印机，
*     所以如果在其他调用的地方 如果发现状态不可用，可以自动连接后重新在处理
*     同时需要注意 当非设置页面 需要在断开连接的时候，不要清除 当前选中的设备 或者 记录一下设备id 重新自动搜索
*
* */
class PrinterSettingDevice {

  PrinterSettingDevice (ScanResult result, connectStateCall) {
    this.result = result;
    this.connectStateCall = connectStateCall;
    this.name = this.result.advertisementData.localName;

    this.streamStateInit();
  }

  @required ScanResult result;
  @required Function connectStateCall;

  String name;
  BluetoothDeviceState connectState = BluetoothDeviceState.disconnected;
  StreamSubscription<BluetoothDeviceState> streamSubscription;


  /*
  * 对于页面中的 需要监听设备数据的 则需要重新设置 监听 因为上次返回已经撤销了监听
  * 其他时候不处理是因为可以做错误记录 对于断开的 可以后面实现自动连接
  * */
  void streamStateInit() {
    this.streamStateCancel();

    this.streamSubscription = this.result.device.state.listen((s) {
      // 会出现自动断开连接的情况 也需要测试一下 如果连接后 手动断开蓝牙 是否能够还是正常的判断
      switch (s) {
        case BluetoothDeviceState.connected:
          ZSDeviceCache.connectedDevice(this);
          break;

      // 如果在连接后 多次通知移除 则会导致缓存移除，无法存储，
      // 因此只有调用一次的时候才可以正常使用 或者添加当前状态的判断
        case BluetoothDeviceState.disconnected:
          ZSDeviceCache.failConnectDevice(this);
          break;
        default:
          break;
      }
      this.setConnectState(s);
    });
    addListBlueStreamSubscriptionForKey(Stream_Device_ScanResults_Listen_Key, this.streamSubscription);
  }
  // 取消设备状态监听
  void streamStateCancel() {
    if (this.streamSubscription != null) {
      this.streamSubscription.cancel();
      this.streamSubscription = null;
    }
  }


  // set state
  void setConnectState(BluetoothDeviceState value) {
    if (this.connectState != value) {
      this.connectState = value;
      this.notiConnectStateChange();

      if (value == BluetoothDeviceState.connected) {
        localStore.setValue(STORE_LAST_PRINTER_ID, this.result.device.id.toString());
        ZSNotifcationCenter.sendNotifyForKey(Notify_Observe_StoreBluetooth_Key, this.result.device.id.toString());
        return;
      }
    }
  }

  // 注意使用 ZSBlue 管理连接和断开部分
  void connect() {
    ZSBlue.instance.disconnnect(this.result.device);
    this.setConnectState(BluetoothDeviceState.connecting);
    ZSBlue.instance.connect(this.result.device);

    ZSDeviceCache.willConnectedDevice(this);
  }
  void disconnect() {
    ZSBlue.instance.disconnnect(this.result.device);
    ZSDeviceCache.failConnectDevice(this);
    this.setConnectState(BluetoothDeviceState.disconnected);
  }

  // 状态变化通知 刷新
  void notiConnectStateChange() {
    if (this.connectStateCall != null) {
      this.connectStateCall();
    }
  }

  static void stopScan() {
    cancelListBlueStreamSubscriptionForKey(Stream_Device_ScanResults_Listen_Key);
    ZSDeviceCache.cleanCache();

    // 对 当前设备重新监听状态
    ZSDeviceCache.currentedDevice() != null ? ZSDeviceCache.currentedDevice().streamStateInit() : '';
  }
}