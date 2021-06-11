import 'package:fish_redux/fish_redux.dart';

//TODO replace with your own action
enum PrinterSettingAction {
  action,
  scanDeviceCall,
  resetDevice,
  blueStateValue,
  reload,
}

class PrinterSettingActionCreator {
  static Action onScanDeviceCall(res) =>
      Action(PrinterSettingAction.scanDeviceCall, payload: res);

  static Action onResetDevice() => Action(PrinterSettingAction.resetDevice);

  static Action onBlueStateValue(value) =>
      Action(PrinterSettingAction.blueStateValue, payload: value);

  static Action reload() => Action(PrinterSettingAction.reload);
}
