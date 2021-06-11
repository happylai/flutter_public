import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/global.dart';
import '../ui_widget/zs_color.dart';

typedef OnDismissListener = void Function();
typedef OnClickListener = Function();

enum DialogLocation {
  top,
  bottom,
  center,
}

//基础弹窗
class BaseDialog extends StatelessWidget {
  ///内容
  final Widget body;

  ///点击背景是否可以取消弹窗
  final bool canDismissByClickBack;

  ///是否可以通过点击背景与按返回键的方式退出弹框
  final bool canCancel;

  ///遮罩颜色
  final Color maskColor;

  ///背景颜色
  final Color backGroundColor;

  ///边界形状
  final ShapeBorder shape;

  ///边界弧度
  final BorderRadius borderRadius;

  ///弹窗消失监听
  final OnDismissListener onDismissListener;

  ///弹框位置
  final DialogLocation location;

  ///弹框边缘间距
  final EdgeInsetsGeometry edge;

  ///显示弹框
  ///[duration]弹框的显示时间
  show(BuildContext context, {Duration duration}) async {
    //标记框是否显示
    bool showing = true;
    Navigator.of(context).push(TransparentRouter(this)).then((value) {
      showing = false;
      if (onDismissListener != null) {
        onDismissListener();
      }
    });
    if (duration != null) {
      await Future.delayed(duration).then((value) {
        if (!showing) {
          //只有弹框正在显示且再最上方的时候才会自动关闭
          return;
        }
        Navigator.of(context).pop();
      });
    }
  }

  BaseDialog({
    @required this.body,
    this.maskColor = ZSColors.COLOR_DIALOG_BACK,
    this.canDismissByClickBack = true,
    this.onDismissListener,
    this.canCancel = true,
    this.shape,
    this.location = DialogLocation.center,
    this.edge,
    this.backGroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!canCancel) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (canDismissByClickBack && canCancel) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: maskColor,
              margin: edge,
              child: GestureDetector(
                onTap: () {},
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 9 / 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: location == DialogLocation.center
                        ? CrossAxisAlignment.center
                        : location == DialogLocation.bottom
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width),
                            child: ClipRRect(
                              borderRadius: borderRadius ?? BorderRadius.zero,
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: Material(
                                  color: backGroundColor ?? Colors.white,
                                  shape: shape,
                                  child: body,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  ///内容
  final Widget body;

  ///弹窗底部按钮
  final List<DialogAction> actions;

  ///点击背景是否可以取消弹窗
  final bool canDismissByClickBack;

  ///是否可以通过点击背景与按返回键的方式退出弹框
  final bool canCancel;

  ///弹窗消失监听
  final OnDismissListener onDismissListener;

  // body间距
  final EdgeInsetsGeometry bodyPadding;

  final double widthScal;

  const ConfirmDialog({
    Key key,
    @required this.body,
    this.actions,
    this.canDismissByClickBack = true,
    this.canCancel = true,
    this.onDismissListener,
    this.bodyPadding,
    this.widthScal = 0.85,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _actions = List();
    actions.forEach((w) {
      if (_actions.isNotEmpty) {
        _actions.add(Container(
          height: 52,
          width: 1,
          color: ZSColors.COLOR_DEV_LINE,
        ));
      }
      _actions.add(
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (w.onClickListener != null) {
                w.onClickListener();
              }
            },
            child: w,
          ),
        ),
      );
    });
    Widget _body = Container(
      width: MediaQuery.of(context).size.width * widthScal,
      child: Column(
        children: <Widget>[
          Container(
            padding: this.bodyPadding ??
                EdgeInsets.only(bottom: 21, left: 0, right: 0, top: 18),
            child: body,
          ),
          Container(
            width: double.infinity,
            height: _actions.isEmpty ? 0 : 1,
            color: ZSColors.COLOR_DEV_LINE,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _actions,
          )
        ],
      ),
    );
    return BaseDialog(
      body: _body,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      canCancel: canCancel,
      canDismissByClickBack: canDismissByClickBack,
      onDismissListener: onDismissListener,
    );
  }
}

///弹窗交互控件样式
enum DialogActionStyle {
  normal,
  gray,
  dark,
}

///弹窗交互控件
class DialogAction extends StatelessWidget {
  final String text;
  final DialogActionStyle style;
  final OnClickListener onClickListener;

  const DialogAction({
    Key key,
    @required this.text,
    this.style = DialogActionStyle.normal,
    this.onClickListener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color backColor;
    switch (style) {
      case DialogActionStyle.normal:
        textColor = ZSColors.COLOR_CONTENT_HINT_TEXT;
        backColor = Colors.white;
        break;
      case DialogActionStyle.dark:
        textColor = Colors.white;
        backColor = ZSColors.COLOR_CONTENT_HINT_TEXT;
        break;
      case DialogActionStyle.gray:
        textColor = ZSColors.COLOR_TEXT_CONTENT;
        backColor = Colors.white;
        break;
    }

    return Container(
      alignment: Alignment.center,
      height: 45,
      color: backColor,
      child: Text(
        '$text',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class TransparentRouter extends PageRouteBuilder {
  final Widget page;

  TransparentRouter(this.page)
      : super(
          barrierColor: Color(0x00000001),
          transitionDuration: Duration(seconds: 0),
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        );
}

showCustomerDialog(BuildContext context, Widget widget) {
  Navigator.of(context).push(TransparentRouter(widget));
}

class OverlayerDialog {

  final Widget child;
  OverlayEntry entry;

  OverlayerDialog({
    this.child,
  });

  void show(){
    OverlayEntry entry;
    entry = OverlayEntry(
        builder: (BuildContext context) {
          return Scaffold(
              backgroundColor:  Color(0x55000000),
              body: child
          );
        }
    );

    Overlay.of(Global.navigatorKey.currentContext).insert(entry);

    this.entry = entry;
  }

  void remove() {
    if (this.entry != null) {
      this.entry.remove();
      this.entry = null;
    }
  }
}
showDialogOfOverlayer(Widget child) {
  OverlayEntry entry;
  entry = OverlayEntry(
      builder: (BuildContext context) {
          return Scaffold(
              backgroundColor:  Color(0x55000000),
              body: child
          );
      }
  );

  Overlay.of(Global.navigatorKey.currentContext).insert(entry);

  return entry;
}
