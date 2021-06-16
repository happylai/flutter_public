
import 'dart:async';
import 'dart:io';

import 'package:flutter_blue/flutter_blue.dart';
import '../model/constant.dart';
import 'device_cache.dart';
import 'printer_setting_device.dart';
import '../utils/notification_center.dart';

import 'blue_stream.dart';

const BLUE_CTS_UUID_WRITE = "49535343-8841-43F4-A8D4-ECBE34729BB3";
const BLUE_CTS_UUID_NOTIFY = "49535343-1E4D-4BD9-BA61-23C647249616";

/*
* 外部对于需要监听打印机返回数据的可以使用下面的回调方式
* */
Function zsBlueHeartListen;
Function zsBlueWriteCharacteristicEvent;

class ZSBlue {

  BluetoothState _state;
  BluetoothCharacteristic _bluetoothCharacteristic;

  ZSBlue._() {
    blueiInitState();
  }

  static ZSBlue _instance = new ZSBlue._();
  static ZSBlue get instance => _instance;

  BluetoothState get state {
    return _state;
  }

  BluetoothCharacteristic get bluetoothCharacteristic {
    return _bluetoothCharacteristic;
  }

  void blueiInitState() {
    FlutterBlue.instance.state.listen((state) {
      _state = state;
      if (state != BluetoothState.on) {
        _bluetoothCharacteristic = null;
        ZSDeviceCache.cleanAll();
      }
      ZSNotifcationCenter.sendNotifyForKey(Notify_Observe_BlueState_Key, state);
    });
  }

  void scanResults(deviceListCallBack) {
    FlutterBlue manager = FlutterBlue.instance;
    manager.connectedDevices;
    manager.startScan();
    var managerScanResultsListen = manager.scanResults.listen((event) {
      for (ScanResult result in event) {
        /// 如果设备名字为空不显示
        if (result.advertisementData.localName.isEmpty){
          continue;
        }
        deviceListCallBack(result);
      }
    });

    addBlueStreamSubscriptionForKey(Stream_Manager_ScanResults_Listen_Key, managerScanResultsListen);
  }


  void stopScan() async{
    FlutterBlue manager = FlutterBlue.instance;
    await manager.stopScan();

    // 需要移除监听
    cancelBlueStreamSubscriptionForKey(Stream_Manager_ScanResults_Listen_Key);
  }

  void disconnnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  void connect(BluetoothDevice device) async{

    /// 连接设备 result = ScanResult
    await device.connect(autoConnect: false, timeout: Duration(seconds: 10));

    if (false == matchCurrentDevice(device)) {
      return;
    }

    /// 查找服务
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service)  {
//      print("蓝牙服务uuid ${service.uuid.toString()}");
      _findCharacteristics(service);
//      if (service.uuid.toString() == UUID){//这里可以通过service的UUID属性来辨识你要的服务
//        _findCharacteristics(service);
//      }
    });
  }

  // 查找特征值
  void _findCharacteristics(BluetoothService service) {
    List<BluetoothCharacteristic> characteristics =
        service.characteristics;
    characteristics.forEach((characteristic) {

      var uuid = characteristic.uuid.toString();
      // 大小写都需判断
      if (uuid == BLUE_CTS_UUID_WRITE || uuid == BLUE_CTS_UUID_WRITE.toLowerCase()) {
        _bluetoothCharacteristic = characteristic;
        print("-存储特征服务--");
        if (zsBlueWriteCharacteristicEvent != null) {
          zsBlueWriteCharacteristicEvent();
        }
      }
      else if (uuid == BLUE_CTS_UUID_NOTIFY || uuid == BLUE_CTS_UUID_NOTIFY.toLowerCase()) {
        _blurHeartListen(characteristic);
      }
    });
  }

  void _blurHeartListen (BluetoothCharacteristic mNotifyCharacteristic) {
    if (mNotifyCharacteristic != null) {
      mNotifyCharacteristic.setNotifyValue(true);
      
      cancelListBlueStreamSubscriptionForKey(Stream_NotifyCharacteristic_Listen_Key);
      StreamSubscription stream = mNotifyCharacteristic.value.listen((value) {
        if (zsBlueHeartListen != null) {
          zsBlueHeartListen(value);
        }
      });
      addBlueStreamSubscriptionForKey(Stream_NotifyCharacteristic_Listen_Key, stream);
    }
  }

  // 写之前 需要判断是否需要重新连接
  /*
  * 延时超时异常 应该不会再出现
  *   之前主要是由于数据过长导致无法回调，目前在外层已经分段发送 不会在出现数据过长问题。
  *
  * await _bluetooth_characteristic.write
  *     经过测试会走10毫秒左右 可能在加上异步的时间长度 所以总的时间 改为2.5m则任务异常
  * */
  void write(List<int> comd) async {
    if (_bluetoothCharacteristic != null) {
       if (Platform.isAndroid) {
         await Future.delayed(Duration(milliseconds: 50));
       }

      int event = 0;
      int maxCount =  250; // 2.5秒 n*100
      int loopTime =  10; // 10

       Future(() async{
          try{
            if (_bluetoothCharacteristic != null) {
              await _bluetoothCharacteristic.write(comd);
            }
            event = 1;
          }catch(e){
            event = 1;
          }
        });

      while (event == 0) {
        await Future.delayed(Duration(milliseconds: loopTime));
        maxCount -=1;
        if (maxCount <= 0) {
          print("发送数据 _bluetooth_characteristic.write 超时异常");
          event = 1;
        }
      }
    }
  }

  void cleanBluetoothCharacteristic() {
    _bluetoothCharacteristic = null;
  }

  bool matchCurrentDevice(BluetoothDevice device) {
    PrinterSettingDevice settingDevice = ZSDeviceCache.currentedDevice();
    if (settingDevice != null) {
      return zsBlueDeviceSame(device, settingDevice.result.device);
    }
    return false;
  }
}

// 判断两个设备是否相同
bool zsBlueDeviceSame(BluetoothDevice device1, BluetoothDevice device2) {

  if (device1 == null || device2 == null) {
    return false;
  }

  String deviceId = device1.id.toString();
  String elementId  = device2.id.toString();

  return deviceId != null && deviceId.length > 0 && elementId.toLowerCase()  == deviceId.toLowerCase();
}
// 判断两个PrinterSettingDevice中的 device 是否相同
bool zsBluePrinterDeviceSame(PrinterSettingDevice device1, PrinterSettingDevice device2) {
  if (device1 == null || device2 == null) {
    return false;
  }

  return zsBlueDeviceSame(device1.result.device, device2.result.device);
}