import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:zs_bluetooth_printer/model/constant.dart';
import '../ui_widget/img.dart';
import '../ui_widget/dialog.dart';
import 'device_cache.dart';
import 'zs_blue.dart';
import 'package:zs_flutter_data/zs_flutter_data.dart';

// 暂时还没有对小标签添加相应的指令
enum ZSPrinterCommandType {
  CPCL,
  ESC,
}
// 全局指令 暂时还没有用
ZSPrinterCommandType _currentCommond = ZSPrinterCommandType.CPCL;

ZSBluePrinterState zsPrinteState = ZSBluePrinterState.unKnow;

// 记录读取打印机器状态之前的 用来判断是否读取成功
bool zsPrinteStateReading= false;

// 是否读取打印机器状态
bool _readStatuesCommond = true;

// 打印机状态
enum ZSBluePrinterState {
  ok,         // 正常
  converOpen, // 开盖
  noPage,     // 没纸
  printing,   // 打印中
  battreyLow, // 电量低
  noDevice,   // 未连接打印机
  notWrite,   // 不可用 （连接蓝牙设备了 但是没有写入功能的）
  unKnow,     // 未知
}

class ZSPrinter {

  // 是否读取状态
  static setReadStatuesCommond(bool v) {
    _readStatuesCommond = v;
  }

  // 指令集的
  static ZSPrinterCommandType get currentCommond {
    return _currentCommond;
  }
  static setCurrentCommond(ZSPrinterCommandType type) {
    _currentCommond = type;
  }

  static init() {
    zsBlueHeartListen = setStateByBytes;
  }

  /*
  * 设置打印机状态
  * */
  static ZSBluePrinterState setStateByBytes(List<int> bytes) {
    zsPrinteState = getStateByBytes(bytes);
    zsPrinteStateReading = false;
    return zsPrinteState;
  }

  /*
  * 将打印机接受的数据 转换为 对应的状态枚举
  * */
  static ZSBluePrinterState getStateByBytes(List<int> bytes) {
    if (bytes == null || bytes.length == 0) {
      return ZSBluePrinterState.unKnow;
    }

    int state = bytes[0];
    if (state == 0x00) {
      return ZSBluePrinterState.ok;
    }
    if (state & 1 == 0x01) {
      return ZSBluePrinterState.printing;
    }
    if (state & 4 == 0x04) {
      return ZSBluePrinterState.converOpen;
    }
    if (state & 2 == 0x02) {
      return ZSBluePrinterState.noPage;
    }
    if (state & 8 == 0x08) {
      return ZSBluePrinterState.battreyLow;
    }

    return ZSBluePrinterState.unKnow;
  }

  /*
  * 清除打印机状态  主要是在设备断开的时候或者重新连接的时候先初始化 或者清除
  * */
  static clean() {
    zsPrinteState = ZSBluePrinterState.unKnow;
  }

  /*
  * 获取打印机状态
  * */
  static ZSBluePrinterState get printerState {
    if (ZSDeviceCache.currentedDevice() == null) {
      return ZSBluePrinterState.noDevice;
    }
    if (ZSBlue.instance.bluetoothCharacteristic == null) {
      return ZSBluePrinterState.notWrite;
    }
    return zsPrinteState;
  }


  /*
  * 读取打印机状态 佳博便携式
  *
  *  var zsPrinteStateReading每次查询之前 先重置回调标记
  *  var zsPrinteStateReading:
  *     之所以不直接用 zsPrinteState 因为考虑到其他地方需要使用的话 每次都更新容易引起UI错乱变化
  *  var endFun:
  *     过期时间结束的时候，只能使用 局部变量进行判断，
  *     zsPrinteStateReading 为全局设置，直接用会出现在过期时间结束回调后又重新刷新了状态异常
  * */
  static Future<ZSBluePrinterState> readStatues() async {
    if (printerState == ZSBluePrinterState.noDevice || printerState == ZSBluePrinterState.notWrite) {
      return printerState;
    }

    if (!_readStatuesCommond) {
      return ZSBluePrinterState.ok;
    }

    init();
    zsPrinteStateReading = true;
    await ZSBlue.instance.write([0x1B, 0x68]);

    bool endFun = false;

    // Timer t = Timer(Duration(milliseconds: 500), () {
    //   if (endFun == false) {
    //     print(" ----------- 读取状态 超时了 -------- ");
    //     setStateByBytes([]);
    //   }
    // });

    while (zsPrinteStateReading == true) {
      await Future.delayed(Duration(milliseconds: 1));
    }

    // t.cancel();
    endFun = true;
    return printerState;
  }


  /*
  * 发送打印指令
  * */
  static Future<bool> sendData(String cmd) async{
    //var comd_bytes = Utf8Encoder().convert(cmd); 汉字编码不一致
    Uint8List cmdBytes = await ZsFlutterData.gb2312(cmd);
    return sendDataIntList(cmdBytes);
  }

  /*
  * 发送打印指令
  * */
  static Future<bool> sendDataIntList(List<int> cmdBytes) async{

    List <List<int>> cmdList = separatorBytes(cmdBytes);
    for (var i = 0; i < cmdList.length; i++) {
      await ZSBlue.instance.write(cmdList[i]);
    }
    if (!_readStatuesCommond) {
      return true;
    }
    return await printerSuccess();
  }


  /*
  * 将数据 按照最大长度分段
  *
  * n 表示按照最大max_length 可以分隔成的段数
  * m 表示余数
  * */
  static List <List<int>> separatorBytes(List<int> bytes) {
    List <List<int>>list =[];
    // 每次传输最大的字节数 超过600可能会导致打印不出来
    int maxLength = 146;
    if (Platform.isAndroid) {
      maxLength = 500;
    }
    int length = bytes.length;

    int n = length ~/ maxLength;
    int m = length % maxLength;
    if (m > 0){
      n += 1;
    }

    for (var i = 0; i < n; i++) {
      int start = i * maxLength;
      int end = start + maxLength;
      if (end > length) {
        end = length;
      }
      list.add(bytes.sublist(start, end));
    }
    return list;
  }

  /*
  * ****** 此功能暂时不稳定，容易出现查询打印机状态异常 但实际上是正常的! ****
  *
  * 开启轮训查询 是否正常
  *
  * stateNotStart   : 未开始
  * statePrintting  : 打印中
  * stateSuccess    : 成功
  * stateFail       : 失败
  *
  * 默认为 3秒后 还没有打印 则任务失败 主要是防止while死循环 或者 后续联系打印的比较多，也不会影响之前的
  * 因为一开始打印 但实际并不会开始，因此刚开始状态还是0，因此添加了延迟200ms 毕竟打印不是获取状态，不需要一直获取
  * 也可以注释 200ms的延迟 加快判断
  * */
  static Future<bool> printerSuccess() async {
    final int stateNotStart = 0;
    final int statePrintting = 1;
    final int stateSuccess = 2;
    final int stateFail = 3;

    int flag = stateNotStart;

    Timer t = Timer(Duration(seconds: 10), () {
      if (flag == stateNotStart) {
        flag = stateFail;
      }
    });

    while(flag == stateNotStart || flag == statePrintting){
      //await Future.delayed(Duration(milliseconds: 200));
      ZSBluePrinterState state = await readStatues();

      if (ZSBluePrinterState.printing == state) {
        flag = statePrintting;
      }
      else if (ZSBluePrinterState.ok == state) {
        if (flag != stateNotStart){
          //有可能一开始 还没有打印 所以初始状态可能还会是0
          flag = flag == statePrintting ? stateSuccess : stateFail;
        }
      }
      else {
        flag = stateFail;
      }
    }

    t.cancel();
    return flag == stateSuccess;
  }


  /*
  * 对状态异常的弹窗提示
  * */
  static showWidget({
    BuildContext context,
    String title,
    Function clickBack,
    Function cancelBack,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            canDismissByClickBack: false,
            body: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    ZSImage.dialogError,
                    package: Package_Name,
                    width: 55,
                    height: 55,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              DialogAction(
                  text: "取消",
                  style: DialogActionStyle.gray,
                  onClickListener: () {
                    Navigator.of(context).pop();
                    if (cancelBack != null) {
                      cancelBack();
                    }
                  }),
              DialogAction(
                  text: "确定",
                  onClickListener: () {
                    Navigator.of(context).pop();
                    if (clickBack != null) {
                      clickBack();
                    }
                  }),
            ],
          );
        });
  }

  static String getTitleByState(ZSBluePrinterState state) {
    Map data = {
      "ok": "正常",
      "converOpen": "打印机已开盖 请先合盖",
      "noPage": "没纸了",
      "battreyLow": "电量低 请及时充电",
      "noDevice": "未配置打印机",
      "notWrite": "设备不可用",
      "unKnow": "打印机异常",
    };
    var key = state.toString().split('.').last;
    return data[key] ?? data["unKnow"];
  }
}
