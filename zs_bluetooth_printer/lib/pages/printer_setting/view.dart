
import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:zs_bluetooth_printer/ui_widget/img.dart';
import 'package:zs_bluetooth_printer/ui_widget/over_scroll_behavior.dart';
import 'package:zs_bluetooth_printer/print/printer_setting_device.dart';
import 'package:zs_bluetooth_printer/ui_widget/zs_color.dart';
import 'package:zs_permisson/zs_permisson.dart';
import 'state.dart';


Widget buildView(
    PrinterSettingState state, Dispatch dispatch, ViewService viewService) {
  Widget _body = Container();

  bool deviceShow = false;
  if (state.locationState != PrinterSettingState.locationStateOk) {
    _body = blueStateOpenAlertWidget(state,dispatch,viewService);
  }
  else if (null == state.blueOpenStute) {
    _body = Container(width: 0, height: 0);
  }
  else if (BluetoothState.on == state.blueOpenStute) {
    _body = buildDevice(state, dispatch, viewService);
    deviceShow = true;
  } else {
    _body = blueStateOpenAlertWidget(state,dispatch,viewService);
  }


  Widget _locationServiceText = Container();
  if (state.locationServiceOpen == false && deviceShow) {
    _locationServiceText = locationServiceOpenWidget();
  }

  return Scaffold(
    backgroundColor: ZSColors.BG_MAIN,
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "打印机设置",
        style: TextStyle(
            fontSize: 18,
            color: Colors.black
        ),
      ),
      iconTheme: IconThemeData(color: Colors.black),
      brightness: Brightness.light,
      elevation: 0,
      leading: IconButton(
        onPressed: () => {Navigator.of(viewService.context).pop()},
        icon: Container(
          alignment: Alignment.center,
          child: Image(
            width: ScreenUtil().setWidth(36),
            height: ScreenUtil().setWidth(36),
            image: AssetImage(ZSImage.icBack),
            color: Color(0xFF000000),
          ),
        ),
      ),
    ),
    body: Column(
      children: [
        Expanded(
            flex: 1,
            child: _body
        ),
        _locationServiceText
      ],
    ),
  );
}

Widget buildDevice(
    PrinterSettingState state, Dispatch dispatch, ViewService viewService) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      state.devicesConnected.length > 0
          ? buildSectionHeader("已连接设备")
          : Container(height: 0),
      buildItem(null, 0, state, dispatch, true),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildSectionHeader("可连接设备"),
          loaddingWidget(),
        ],
      ),
      Expanded(
          flex: 6,
          child: ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                return buildItem(context, index, state, dispatch, false);
              }
            )
          )
      ),
    ],
  );
}

Widget buildSectionHeader(String title) {
  return Container(
    padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
    child: Text(
      title,
      style: TextStyle(color: Color.fromRGBO(102, 102, 102, 1), fontSize: 14),
    ),
  );
}

Widget loaddingWidget() {
  return Container(
      margin: EdgeInsets.only(left: 10, right: 4),
      child: Theme(
        data: ThemeData(
            cupertinoOverrideTheme:
            CupertinoThemeData(brightness: Brightness.light)),
        child: CupertinoActivityIndicator(
          radius: 6,
        ),
      ));
}

Widget buildItem(BuildContext context, int index, PrinterSettingState state,
    Dispatch dispatch, bool connectted) {
  if (connectted == true && state.devicesConnected.length < 1) {
    return Container(
      height: 0,
    );
  }

  var _textColor = connectted == true
      ? ZSColors.COLOR_CONTENT_HINT_TEXT
      : ZSColors.COLOR_TEXT_CONTENT;
  List<PrinterSettingDevice> _datas =
      connectted == true ? state.devicesConnected : state.devices;
  Map deviceViewMap = deviceConnected(_datas[index]);

  Widget loading = Container(width: 10);
  if (_datas[index].connectState == BluetoothDeviceState.connecting) {
    loading = loaddingWidget();
  }

  return GestureDetector(
    onTap: connectted == true ? null : deviceViewMap["onPressed"],
    child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 15),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      _datas[index].name,
                      style: TextStyle(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  loading,
                  Container(
                    child: Text(
                      deviceViewMap["text"],
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: index == _datas.length - 1 ? 0 : 0.5,
              color: Color(0xFFEEEEEE),
              width: double.infinity,
            ),
          ],
        )),
  );
}

Map deviceConnected(PrinterSettingDevice device) {
  VoidCallback onPressed;
  String text;
  switch (device.connectState) {
    case BluetoothDeviceState.connected:
      onPressed = () => device.disconnect();
      text = '已连接';
      break;
    case BluetoothDeviceState.disconnecting:
    case BluetoothDeviceState.disconnected:
      onPressed = () => device.connect();
      text = '未连接';
      break;
    case BluetoothDeviceState.connecting:
      text = "正在连接...";
      break;
    default:
      onPressed = null;
      text = "未知";
      break;
  }

  return {
    "text": text,
    "onPressed": onPressed,
  };
}

// 全局 有两个问题 1 oktoast需要设置实际拿 然后自动消失2 无法回调点击时间消失
Widget blueStateOpenAlertWidget(PrinterSettingState state, Dispatch dispatch, ViewService viewService) {
  TextStyle titleStyle =
      TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(36), fontWeight: FontWeight.w600);

  BluetoothState bluetoothState = state.blueOpenStute;
  int locationState = state.locationState;
  Map json = blueStateMapJson(state.blueOpenStute, state.locationState);

  bool rightAction = json["right_action"] == 1;

  return Center(
    child: Container(
      margin: EdgeInsets.only(bottom: 64),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                offset: Offset(0,0),
                blurRadius: ScreenUtil().setWidth(9),
                spreadRadius: ScreenUtil().setWidth(6)
            ),
          ]),
      width: ScreenUtil().setWidth(644),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(100)),
              child: Text(json["title_1"], style: titleStyle),
            ),
            Container(
              margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(76)),
              child: Text(
                json["title_2"],
                style: titleStyle,
              ),
            ),
            Container(
              color: Color(0xFFE4E4E4),
              height: ScreenUtil().setWidth(1),
            ),
            Container(
              height: ScreenUtil().setWidth(104),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: MaterialButton(
                        height: double.infinity,
                        onPressed: () => Navigator.pop(viewService.context),
                        child: Text(
                          "取消",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(32), color: ZSColors.COLOR_TEXT_CONTENT),
                        ),
                      )),
                  Container(
                    color: Color(0xFFE4E4E4),
                    width: ScreenUtil().setWidth(1),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                        height: double.infinity,
                        color: rightAction ? null : Color(0x18000000),
                        child: MaterialButton(
                          onPressed: rightAction ? () {
                            blueStatePermissionClick(bluetoothState, locationState);
                          } : null,
                          child: Text(
                            "确定",
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(32),
                              color: rightAction ? ZSColors.COLOR_CONTENT_HINT_TEXT : Colors.white,
                            ),
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


Map blueStateMapJson(BluetoothState state, int locationState) {

  if (locationState & PrinterSettingState.locationStatePermission == PrinterSettingState.locationStatePermission) {
    return {
      "title_1": "定位权限未打开",
      "title_2": "允许“发得快”获取定位权限",
      "right_action" : 1,
    };
  }
  if (locationState & PrinterSettingState.locationStateService == PrinterSettingState.locationStateService) {
    return {
      "title_1": "定位服务未打开",
      "title_2": "请检查“位置信息”是否打开",
      "right_action" : 1,
    };
  }

  if (state == BluetoothState.off) {
    return {
      "title_1": "打开蓝牙来允许",
      "title_2": "“发得快”连接蓝牙设备",
      "right_action" : 1,
    };
  }
  if (state == BluetoothState.unauthorized) {
    return {
      "title_1": "打开蓝牙权限",
      "title_2": "允许“发得快”获取蓝牙权限",
      "right_action" : 1,
    };
  }

  if (state == BluetoothState.unavailable) {
    return {
      "title_1": "蓝牙不可用",
      "title_2": "",
    };
  }

  if (state == BluetoothState.turningOff) {
    return {
      "title_1": "蓝牙关闭中...",
      "title_2": "",
    };
  }

  if (state == BluetoothState.turningOn) {
    return {
      "title_1": "蓝牙开启中...",
      "title_2": "",
    };
  }

  if (state == BluetoothState.unknown) {
    return {
      "title_1": "蓝牙未知状态",
      "title_2": "",
    };
  }

  return {
    "title_1": "未知状态",
    "title_2": "",
  };
}

void blueStatePermissionClick(BluetoothState state, int locationState) {

  // android下的
  if (locationState & PrinterSettingState.locationStatePermission == PrinterSettingState.locationStatePermission) {
    ZSPermissionPlugin.openLocationPermission();
    return;
  }
  if (locationState & PrinterSettingState.locationStateService == PrinterSettingState.locationStateService) {
    ZSPermissionPlugin.openLocationState();
    return;
  }

  if (state == BluetoothState.off) {
    ZSPermissionPlugin.openBluetooth();
    return;
  }
  if (state == BluetoothState.unauthorized) {
    ZSPermissionPlugin.openBluetoothPmission();
    return;
  }
}


Widget locationServiceOpenWidget() {
  return Center(
    child: GestureDetector(
      onTap: (){
        ZSPermissionPlugin.openLocationState();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.only(bottom: 10),
        child: Text.rich(
          TextSpan(
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: ScreenUtil().setSp(26),
            ),
            children: [
              TextSpan(text: "若未能搜到设备,请开启定位服务 "),
              TextSpan(
                text: "前往开启>",
                style: TextStyle(
                  color: ZSColors.CHECK_BOX_SELECT,
                ),
              )
            ]
          ),
        ),
      ),
    ),
  );
}
