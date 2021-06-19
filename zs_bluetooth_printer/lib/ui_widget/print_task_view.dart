import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zs_bluetooth_printer/zs_bluetooth_printer.dart';
import 'floating_overlayer.dart';
import '../utils/global.dart';
import '../print_util/print_util.dart';

// 再就是需要存储一下当前已经打印的数量 来计量  这样可以当多个任务叠加的时候 也计算之前的
// 只有当任务全部结束的时候 再去清空已打印计量

void initPrintTaskEvent() {
  printTaskCountEvent = ZSPrintTaskViewCount;
}

FloatingOverLay zsPrintTaskViewLayer = FloatingOverLay();
// 不能用 隐藏 会出现在延时到点后 点击view和隐藏view 会导致点击后响应 但是却崩溃了
void ZSPrintTaskViewCount(TaskCount taskCount) {
  if (false == ZsBluetoothPrinterManager.printerApi.showPrintTaskOverlay()) {
    return;
  }
  if (zsPrintTaskViewLayer.isRemove()) {
    ZSPrintTaskView view = ZSPrintTaskView(model: taskCount);
    zsPrintTaskViewLayer.show(context: Global.appContext, child: view);
  } else {
    ZSPrintTaskView view = zsPrintTaskViewLayer.view;
    view.setNewValue(taskCount);
  }
}

class ZSPrintTaskView extends StatefulWidget {
  TaskCount model;

  Function _setValue;

  ZSPrintTaskView({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ZSPrintTaskViewState();
  }

  void setNewValue(TaskCount value) {
    if (this._setValue != null) {
      this._setValue(value);
    } else {
      model = value;
    }
  }
}

class _ZSPrintTaskViewState extends State<ZSPrintTaskView> {
  @override
  void initState() {
    super.initState();

    widget._setValue = (obj) {
      setState(() {
        widget.model = obj;
      });

      // 当数据更新时候 为了连接上次的打印 对隐藏添加延迟
      if (widget.model.unPrinted == 0) {
        Future.delayed(Duration(seconds: 2), () async {
          if (widget.model.unPrinted == 0) {
            zsPrintTaskViewLayer.remove();
          }
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {

    Widget child = ZsBluetoothPrinterManager.printerApi.printTaskOverlayWidget(widget.model);
    if (child == null) {
      child = _defaultContainer();
    }

    return Material(
      color: Color(0x00000000),
      child: child,
    );
  }

  Widget _defaultContainer() {
    return Container(
        height: 40,
        padding: EdgeInsets.only(left: 20, right: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              widget.model.printed.toString() + " 已打印",
              style: TextStyle(
                fontSize: 13,
              ),
            ),
            Text(
              widget.model.unPrinted.toString() + " 未打印",
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ));
  }
}
