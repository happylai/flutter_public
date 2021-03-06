import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:zs_bluetooth_printer/model/constant.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';
import 'package:zs_bluetooth_printer/print_util/print_cpcl_api.dart';
import 'package:zs_bluetooth_printer/ui_widget/img.dart';
import 'package:zs_bluetooth_printer/ui_widget/zs_color.dart';

class SmallLabelPrintTemple extends StatelessWidget {

  const SmallLabelPrintTemple({
    Key key,
    this.printSize,
  }) : super(key: key);

  final PrintTemplateList printSize;

  @override
  Widget build(BuildContext context) {

    if (printSize == null || printSize.printJson == null) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    PrintTemplate temple = PrintTemplate.fromJson(printSize.printJson);

    List<Widget> children = [];
    for(PrintTemplateElement element in temple.layout) {

      Widget child;
      if (element.fieldType == "barcode") {

        child = Row(
          children: [
            Image(
              width: templeSize(element.width)*0.7,
              height: templeSize(element.height),
              image: AssetImage(
                ZSImage.smallLabelBarcode,
                package: Package_Name
              ),
              color: Colors.black,
              fit: BoxFit.fill,
            )
          ]
        );
      }

      if (element.fieldType == "text" && !element.bgBlack) {
        child = Container(
          alignment: getTextAlign(element),
          child: Text(
            "["+ (element.description ?? element.field) +"]",
            style: TextStyle(
              fontSize: getTextFont(element.fontSize),
              fontWeight: FontWeight.w500
            ),
          ),
        );
      }

      if(element.fieldType == "text" && element.bgBlack){
        child = Container(
          alignment: getTextAlign(element),
          color: Colors.black,
          child: Text(
            (element.description ?? element.field) ?? "",
            style: TextStyle(
                fontSize: getTextFont(element.fontSize),
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFFFFF)
            ),
          ),
        );
      }

      if (child != null) {
        Widget elementWidght = Positioned(
            left: templeSize(element.left),
            top: templeSize(element.top),
            width: templeSize(element.width),
            height: templeSize(element.height),
            child: child
        );
        children.add(elementWidght);
      }
    }

    double width = templeSize(temple.width);
    double height = templeSize(temple.height);
    double leftOffset = 5;

    // ????????????????????? ?????????????????????
    // ??????60?????????????????? ???????????????????????????????????? ??????????????????width???????????? ????????????????????????
    double scal = ScreenUtil().setWidth(600) / templeSize("60");

    Widget card = Transform.scale(
        scale: scal,
        origin: Offset(0, 0-templeSize(temple.height)/2),
        child: Container(
            padding: EdgeInsets.only(
              left: leftOffset,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: ZSColors.COLOR_DEV_LINE,
                      offset: Offset(0.0, 2.0), //??????xy????????????
                      blurRadius: 2.0, //??????????????????
                      spreadRadius: 2.0 //??????????????????
                  )
                ]
            ),
            child: Container(
              width: width-leftOffset,
              height: height,
              child: Stack(
                children: children,
              ),
            )
        ),
    );

    return Stack(
        overflow: Overflow.visible,
        children: [
          Container(
            width: width * scal,
            height: height * scal,
          ),
          Positioned(
            top: 0,
            left: 0-width*(1-scal)/2,
            child: card
          )
        ],
    );

  }

}

//?????????????????? ???????????????????????????
double templeSize(String f) {
  double v = ScreenUtil().setWidth(double.parse(f));
  return v * 17.5;
}
double getTextFont(String fontSize) {
  double f = double.parse(fontSize);
  return ScreenUtil().setSp(f*11.6);
}

AlignmentGeometry getTextAlign(PrintTemplateElement element) {

  if(element.textAlignVertical == TextAlignVertical.top) {
    if (element.textAlign == TextAlign.left){
      return Alignment.topLeft;
    }
    if (element.textAlign == TextAlign.center){
      return Alignment.topCenter;
    }
    if (element.textAlign == TextAlign.right){
      return Alignment.topRight;
    }
  }
  if(element.textAlignVertical == TextAlignVertical.center) {
    if (element.textAlign == TextAlign.left){
      return Alignment.centerLeft;
    }
    if (element.textAlign == TextAlign.center){
      return Alignment.center;
    }
    if (element.textAlign == TextAlign.right){
      return Alignment.centerRight;
    }
  }
  if(element.textAlignVertical == TextAlignVertical.bottom) {
    if (element.textAlign == TextAlign.left){
      return Alignment.bottomLeft;
    }
    if (element.textAlign == TextAlign.center){
      return Alignment.bottomCenter;
    }
    if (element.textAlign == TextAlign.right){
      return Alignment.bottomRight;
    }
  }

  return Alignment.topLeft;
}
