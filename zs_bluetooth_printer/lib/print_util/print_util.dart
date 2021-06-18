import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../template/print_template_list.dart';
import '../model/routes.dart';
import '../print/device_cache.dart';
import '../print/zs_blue.dart';
import '../print/zs_printer.dart';
import 'print_cpcl_api.dart';

import '../utils/global.dart';

void Function(TaskCount obj) printTaskCountEvent;

class TaskCount {
  int printed;
  int unPrinted;

  TaskCount({
    this.printed = 0,
    this.unPrinted = 0,
  });

  TaskCount copy(){
    return TaskCount(
      printed: printed,
      unPrinted: unPrinted,
    );
  }

  void _add() {
    printed += 1;
    unPrinted -= 1;

    // 防止数据在最后清空的 导致任务无法体验最后一个提示 里层加判断是为了防止在延迟到了后 之前又有任务加入
    if (unPrinted <= 0) {
      Future.delayed(Duration(seconds: 1),(){
        if (unPrinted == 0) {
          printed = 0;
        }
      });
    }
  }
}


class PrintUtil{

  /*
  * 检测打印机是否配置
  *
  *   当有打印任务的时候 ，判断当前状态 不使用命令读取 避免连续调用write方法
  * 后去可以改为 添加读取状态 使用异步，但是需要考虑当前和写入队列冲突
  * */
  static bool checkPrinterConnect() {
    ZSBluePrinterState state = ZSPrinter.printerState;
    if (state == ZSBluePrinterState.noDevice || state == ZSBluePrinterState.notWrite) {
      showWidget(
          title: ZSPrinter.getTitleByState(state),
          clickBack: (){
            if (state == ZSBluePrinterState.noDevice) {
              Navigator.pushNamed(_buildContext, Pages.printerSetting);
              return;
            }
          }
      );
      return false;
    }
    return true;
  }

  /**
   *  检测打印小标签是否设置模板
   */
  static Future<bool> checkSmallPrintTemple() async{
    if (PrintTemplateList.currentTemp == null) {
      showWidget(
          title: "未设置小标签模板",
          clickBack: (){
              Navigator.pushNamed(_buildContext, Pages.printConfig);
          }
      );
      return false;
    }
    if (PrintTemplateList.currentTemp.printJson == null) {
      return PrintTemplateList.currentTemp.loadPrintData();
    }
    return true;
  }

  static failLoopPrintState() async{

    if (ZSDeviceCache.currentedDevice() == null) {
      return;
    }

    ZSBluePrinterState state = await ZSPrinter.readStatues();
    if (state == ZSBluePrinterState.ok) {
      _start();

      if (true == _showDialog) {
        // 移除当前弹窗
        _showDialog = false;
        Navigator.of(_buildContext).pop();
      }

      return;
    }

    await Future.delayed(Duration(seconds: 2));
    failLoopPrintState();
  }

  /*
  * 对于涉及到 读取状态的 需要加个延迟在处理 否则可能出现常态异常提示
  * */
  static _blueWriteCharacteristicEvent() {
    Future.delayed(Duration(milliseconds: 300),(){
      PrintUtil._start();
    });
  }

  /*
  * 打印任务队列 存储需要的打印的命令
  * 先进先出
  * */
  static List<PrintUtil> _taskList = [];

  // 已打印数量  未打印数量 可以通过查询_taskList 来返回 也可以通过记录来返回
  static TaskCount _taskCount = TaskCount();

  /*
  * 判断队列是否正在进行中
  * */
  static bool _taskListRunning = false;

  // 是否正在弹窗
  static bool _showDialog = false;

  static BuildContext get _buildContext {
    return Global.navigatorKey.currentContext;
  }

  // 添加 _taskList.length <= 0 是为了防止出错
  static void _onPrintSuccess(){
    _taskCount._add();
    notifyTaskCount();
  }

  static void _onTaskListAdd(){
    int noPrintCount = 0;
    _taskList.forEach((element) {
      if (element.cmd == null) {
        noPrintCount += element.maxCount;
      }
    });
    _taskCount.unPrinted = noPrintCount;
    notifyTaskCount();
  }
  static void notifyTaskCount() {
    if (printTaskCountEvent != null) {
      printTaskCountEvent(_taskCount.copy());
    }
  }

  /*
  * 添加队列
  * */
  static void _addTask(task) {
    _taskList.add(task);

    _onTaskListAdd();

    // 绑定监听 数据
    zsBlueWriteCharacteristicEvent = PrintUtil._blueWriteCharacteristicEvent;
  }
  /*
  * 移除当前任务
  * */
  static _removeCurrentTask() {
    if (_taskList.length > 0) {
      _taskList.removeAt(0);
    }
  }

  /*
  * 开始打印
  * */
  static void _start() {
    start();
  }

  /*
  *
  *
  * _taskListRunning 作为令牌
  *   注意使用顺序，在 start 异步中，需要注意使用顺序否则会导致多个异步同时获取到
  * */
  static void start()async {

    if (_taskListRunning == true) {
      return;
    }

    if (_taskList.length < 1) {
      _taskListRunning = false;
      return;
    }

    // 不能放在 await后面 由于其他异步也会回调 因此需要在 await之前 令牌控制
    // 否则会出现多个异步都在等待中，如果任务清空 后面取出任务会报错，并且可能出现任务重复
    _taskListRunning = true;

    // 每次重置是否读取状态
    ZSPrinter.setReadStatuesCommond(_taskList[0].readStatus);

    ZSBluePrinterState state = await ZSPrinter.readStatues();
    if (state != ZSBluePrinterState.ok) {
      _taskListRunning = false;
      failDio();
      failLoopPrintState();
      return;
    }

    // 正常的话 继续打印
    PrintUtil task = _taskList[0];

    // 如果确实出现异常 可以在失败的时候 在读取一次状态，如果打印机状态正常ok，则删除当前任务
    // 让后面的任务继续打印 否则此次异常有可能一直异常，后面的任务便无法执行

    bool res = true;
    if (task.cmd != null) {
      res = await ZSPrinter.sendDataIntList(task.cmd);
    }else {
      res = await ZSPrinter.sendData(task.printCmd);
    }
    _taskListRunning = false;

    print("打印结果 $res");
    if (res == true) {
      task.maxCount -= 1;
      if (task.maxCount <= 0) {
        _removeCurrentTask();
      }
      if (task.cmd == null) {
        _onPrintSuccess();
      }
      _start();
      if (task.success != null){
        task.success();
      }
    }
    else {
      if (task.failed != null){
        task.failed();
      }
      failDio();
      failLoopPrintState();
    }
  }

  /*
  * - 打印失败的时候的提示
  *
  * 在失败的时候 再去弹窗提示 不在打印前面判断 否则影响打印速度；
  * 并且执行打印的时候 会读取状态，如果失败，则此处能获取到失败的状态 不重新读取否则会加重延迟
  * */
  static failDio() {

    ZSBluePrinterState state = ZSPrinter.printerState;
    if (state != ZSBluePrinterState.ok) {
      showWidget(
          title: ZSPrinter.getTitleByState(state),
          clickBack: (){
            if (state == ZSBluePrinterState.noDevice) {
              Navigator.pushNamed(_buildContext, Pages.printerSetting);
              return;
            }
            Future.delayed(Duration(milliseconds: 100),(){
              _start();
            });
          }
      );
    }
  }

  static void showWidget({
    String title,
    Function clickBack,
  }) {

    if (_showDialog == true) {
      return;
    }

    _showDialog = true;
    ZSPrinter.showWidget(
        context:_buildContext,
        title: title,
        cancelBack:(){
          _showDialog = false;
        },
        clickBack: (){
          if (clickBack != null){
            _showDialog = false;
            clickBack();
          }
        },
    );
  }



  /*
  * ----------------- 非静态属性 ---------------------------------
  * */


  Function failed;
  Function success;
  Map printJson;
  int maxCount; // 打印最大数量

  // 不需要转化
  List<int> cmd; //直接使用指令
  bool readStatus; //是否读取打印机状态

  PrintUtil({
    this.printJson,
    this.cmd,
    this.success,
    this.failed,
    this.maxCount = 1,
    this.readStatus = true,
  });

  void addTask() {
    _addTask(this);
    start();
  }

  String get printCmd {
    return ZSPrintCmdApi.getPrintCommand(this.printJson);
  }
}