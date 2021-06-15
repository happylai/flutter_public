import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:zs_bluetooth_printer/model/constant.dart';
import 'package:zs_bluetooth_printer/pages/print_view/small_label_print_temple.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';
import 'package:zs_bluetooth_printer/model/routes.dart';
import 'package:zs_bluetooth_printer/ui_widget/img.dart';
import 'package:zs_bluetooth_printer/ui_widget/over_scroll_behavior.dart';
import 'package:zs_bluetooth_printer/ui_widget/zs_color.dart';
import 'dart:math' as math;
import 'print_config_action.dart';
import 'print_config_state.dart';

Widget buildView(
    PrintConfigState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    backgroundColor: ZSColors.BG_MAIN,
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "打印设置",
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
      iconTheme: IconThemeData(color: Colors.black),
      brightness: Brightness.light,
      elevation: 0,
      leading: IconButton(
        onPressed: () => dispatch(PrintConfigActionCreator.onBack()),
        icon: Container(
          alignment: Alignment.center,
          child: Image(
            width: ScreenUtil().setWidth(36),
            height: ScreenUtil().setWidth(36),
            image: AssetImage(ZSImage.icBack,package: Package_Name),
            color: Color(0xFF000000),
          ),
        ),
      ),
    ),
    body: ScrollConfiguration(
        behavior: OverScrollBehavior(),
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return _body(state, dispatch, viewService);
            })),
  );
}

Widget _body(
    PrintConfigState state, Dispatch dispatch, ViewService viewService) {

  Widget smallTemple = Center(
    child: SmallLabelPrintTemple(
      printSize: state.currentPrintTemplate,
    ),
  );

  return Container(
    child: Column(
      children: [
        SizedBox(
          height: ScreenUtil().setWidth(20),
        ),
        buildItem(
            text: "打印机连接",
            onTap: () {
              Navigator.pushNamed(viewService.context, Pages.printerSetting,
                  arguments: {"autoPop": false});
            },
            right: Container(
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(20),
              ),
              child: Text(
                state.printerName ?? "未连接",
                style: TextStyle(
                  color: ZSColors.COLOR_CONTENT_HINT_TEXT,
                  fontSize: ScreenUtil().setSp(26),
                ),
              ),
            )),

        buildItem(
            text: "小标签模版",
            onTap: () {
              dispatch(PrintConfigActionCreator.onTapPrintChoose());
            },
            bgColor: null,
            right: Container(
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(20),
              ),
              child: Text(
                state.currentPrintTemplate != null ? state.currentPrintTemplate.name : "请选择",
                style: TextStyle(
                  color: ZSColors.COLOR_TEXT_CONTENT,
                  fontSize: ScreenUtil().setSp(26),
                ),
              ),
            )),

        // 小标签模版
        smallTemple,
      ],
    ),
  );
}

Widget buildItem({
  String text,
  String leftIcon,
  Widget right,
  Widget rightIcon,
  Color color = Colors.black,
  Color bgColor = Colors.white,
  bool line = true,
  Function onTap,
}) {
  Widget leftWidget = SizedBox(width: 0);
  if (null != leftIcon) {
    leftWidget = Image(
      image: AssetImage(leftIcon),
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setWidth(30),
      fit: BoxFit.fill,
    );
  }

  Widget titleWidget = Container(
    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(2)),
    child: Text(
      text,
      style: TextStyle(fontSize: ScreenUtil().setSp(30), color: color),
    ),
  );

  Widget rightArrow = Transform.rotate(
    angle: math.pi,
    child: Image(
      image: AssetImage(ZSImage.icBack, package: Package_Name),
      color: Color(0xFFB0B0B0),
      width: ScreenUtil().setWidth(22),
      height: ScreenUtil().setWidth(22),
    ),
  );

  return GestureDetector(
    onTap: onTap,
    child: Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(30),
            right: ScreenUtil().setWidth(30),
            bottom: ScreenUtil().setWidth(30)),
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: line == true ? ScreenUtil().setWidth(1) : 0,
              color: Color(0xFFF1F1F1),
            ),
            Container(
              padding: EdgeInsets.only(top: ScreenUtil().setWidth(30)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                leftWidget,
                titleWidget,
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                right ?? SizedBox(width: 0),
                rightIcon ?? rightArrow,
              ]),
            ),
          ],
        )),
  );
}

void showSheetTempList(
    List<PrintTemplateList> list,
    Context<PrintConfigState> ctx,
  ) {
  Widget buildItem(index) {
    PrintTemplateList temp = list[index];
    return GestureDetector(
      onTap: () {
        Navigator.of(ctx.context).pop();
        ctx.dispatch(PrintConfigActionCreator.onTapPrintListItem(temp));
      },
      child: Container(
        alignment: Alignment.center,
        height: ScreenUtil().setWidth(120),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Color(0xffEDEDED),
            ),
          ),
        ),
        child: Text(
          temp.name,
          style: TextStyle(fontSize: ScreenUtil().setSp(34)),
        ),
      ),
    );
  }

  showModalBottomSheet(
    context: ctx.context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (BuildContext context) {
      return ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
        child: ScrollConfiguration(
          behavior: OverScrollBehavior(),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return buildItem(index);
            },
          ),
        ),
      );
    },
  );
}
