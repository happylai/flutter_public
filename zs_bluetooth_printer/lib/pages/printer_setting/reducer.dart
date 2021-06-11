import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:zs_bluetooth_printer/print/device_cache.dart';
import 'action.dart';
import 'state.dart';

Reducer<PrinterSettingState> buildReducer() {
  return asReducer(
    <Object, Reducer<PrinterSettingState>>{
      PrinterSettingAction.scanDeviceCall: _onScanDeviceCall,
      PrinterSettingAction.resetDevice: _onResetDevice,
      PrinterSettingAction.blueStateValue: _onBlueStateValue,
      PrinterSettingAction.reload: _reload,

    },
  );
}

PrinterSettingState _onScanDeviceCall(
    PrinterSettingState state, Action action) {
  final PrinterSettingState newState = state.clone();
  newState.devices.add(action.payload);
  return newState;
}

// 设备状态变化刷新
PrinterSettingState _onResetDevice(PrinterSettingState state, Action action) {
  final PrinterSettingState newState = state.clone();
  newState.devicesConnected = ZSDeviceCache.currentedDevice() != null
      ? [ZSDeviceCache.currentedDevice()]
      : [];
  return newState;
}

PrinterSettingState _onBlueStateValue(
    PrinterSettingState state, Action action) {
  final PrinterSettingState newState = state.clone();
  newState.blueOpenStute = action.payload;

  if (BluetoothState.off == action.payload) {
    newState.devices = [];
    newState.devicesConnected = [];
  }

  return newState;
}
PrinterSettingState _reload(PrinterSettingState state, Action action) {
  PrinterSettingState newState = state.clone();
  return newState;
}

