import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:zs_bluetooth_printer/zs_bluetooth_printer.dart';
import '../template/print_template_list.dart';
import '../print/cpcl/cpcl_builder.dart';
import '../print/cpcl/font.dart';
import '../print/print_builder.dart';
import '../utils/stringUtils.dart';

const printBitScal = 8;

class ZSPrintCmdApi {
  static String getPrintCommand(Map jsonData) {

    if (PrintTemplateList.currentTemp == null || PrintTemplateList.currentTemp.printJson == null) {
      return "";
    }
    Map newJson = {};
    newJson.addAll(jsonData);

    PrintTemplate template = PrintTemplate.fromJson(PrintTemplateList.currentTemp.printJson);
    PrintBuilder builder = CpclBuilder();
    //打印纸大小
    builder.pageSetup(width: _printerSize(template.width), height: _printerSize(template.height));
    // 佳博型号GP-M322打印机最快的速度 2 ；
    builder.setSpeed(2);

    for (PrintTemplateElement element in template.layout) {

      if (!StringUtils.empty(element.fieldHidden)) {
        if (newJson[element.fieldHidden] != 1) {
          // 隐藏当前内容
          continue;
        }
      }

      if (element.fieldType == "text") {
        PrintTemplateElement copy = element.copy();
        autoAdjustPrintTemplateText(element, element.dataValueForJson(newJson));
        setBuildWithTemplete(builder, element, newJson);

        if (element.bgBlack) {
          copy.fieldType = "inverse";
          setBuildWithTemplete(builder, copy, newJson);
        }
        continue;
      }

      setBuildWithTemplete(builder, element, newJson);
    }
    builder.finish();
    String command = builder.getPrintCommand();
    return command;
  }

  /*
  * scale_mm / scale_ui 表示实际每个单位占据的mm
  * 乘以 8 表示的是点阵（1英寸=25.4毫米 203dpi=8dpmm 每毫米8个点）
  * */
  static int _printerSize(String f) {
    try {
      return (double.parse(f) * 8).toInt();
    } catch (e) {
      return 0;
    }
  }

  /*
  * element 模版类
  * json 打印的数据
  * */
  static void setBuildWithTemplete(PrintBuilder builder, PrintTemplateElement element, Map json) {
    String data = element.dataValueForJson(json);

    switch (element.fieldType) {
      case "barcode":
        builder.drawBarCode(
          cellWidth: 1,
          height: _printerSize(element.height),
          data: data,
          startX: _printerSize(element.left),
          startY: _printerSize(element.top),
          rotation: element.rotation,
          showText: element.hideText == 1,
        );
        return;
      case "inverse":
        builder.addInverseLine(
            x: _printerSize(element.left),
            y: _printerSize(element.top),
            xend: _printerSize(element.left) + _printerSize(element.width),
            yend: _printerSize(element.top),
            width: _printerSize(element.height));
        return;
      case "text":
        builder.drawText(
            width: _printerSize(element.width),
            height: _printerSize(element.height),
            data: data,
            startX: _printerSize(element.left),
            startY: _printerSize(element.top),
            fontSize: element.fontSize,
            rotation: element.rotation,
            bold: int.parse(element.fontWeight) == 1 ? 1 : 0,
            underline: false);
        return;
      default:
        return;
    }
  }
}

// 设置 文本自适应 大小和居中对齐方式
void autoAdjustPrintTemplateText(PrintTemplateElement element, String text) {
  if (StringUtils.empty(text)) {
    return;
  }

  PrintTextLabel label = PrintTextLabel.getTextWidthLine(
    printTemplateElement: element,
    text: text,
  );

  // 转换点阵到计量

  double left = double.parse(element.left) * printBitScal;
  double width = double.parse(element.width) * printBitScal;
  element.fontSize = label.fontSize;

  // 设置x
  if (element.textAlign == TextAlign.center) {
    element.left = ((left + width / 2 - label.width / 2) / printBitScal).toString();
  } else if (element.textAlign == TextAlign.right) {
    element.left = ((left + width - label.width) / printBitScal).toString();
  } else {
    // left 不需要设置
  }
  // 重置宽度 可以做相对运算处理
   //element.width = (label.width / printBitScal).toString();

  // 设置top
  double top = double.parse(element.top) * printBitScal;
  double height = double.parse(element.height) * printBitScal;

  if (element.textAlignVertical == TextAlignVertical.center) {
    double newTop = top + height / 2 - label.height / 2;
    element.top = (newTop / printBitScal).toString();
  } else if (element.textAlignVertical == TextAlignVertical.bottom) {
    double newTop = top + height - label.height;
    element.top = (newTop / printBitScal).toString();
  } else {
    // top 不需要设置
  }
}



/*
* 打印模版
*
* 注意打印纸张 即使 x = 0; 左边也会有两毫米的间距 这时候需要模版设置中 不能太靠右，右边流出两毫米的间距
* */
class PrintTemplate {
  String width; // 纸张宽度
  String height; // 纸张高度
  List<PrintTemplateElement> layout = [];

  PrintTemplate({
    this.width,
    this.height,
    this.layout,
  });


  PrintTemplate.fromJson(Map<String, dynamic> json) {
    width = json["width"] ?? "";
    height = json["height"] ?? "";
    if (json["layout"] != null) {
      json["layout"].forEach((item){
        layout.add(PrintTemplateElement.fromJson(item));
      });
    }
  }
}

class PrintTemplateElement {
  String fieldType; // 打印类型 text 还是 barcode
  String field; // 内容对应的key
  String fieldHidden; // 隐藏标签的key  json[fieldHidden] == 1 显示 否则不显示 用来动态显示PrintTemplateElement
  String text; // 标题 实际不同 对应菜鸟别名 (当 field 空的时候 展示的内容)
  String description; // 描述 用于展示模版的信息
  String left; // 定位 左
  String top; // 定位  上
  String width; // 控件所占宽度
  String height; // 控件所占高度
  String fontSize; // 字体大小
  String fontWeight; // 字体是否加粗 0 不加粗 1加粗
  int rotation; // 旋转角度 90度
  int hideText; // 是否隐藏barcode的文字: 0不隐藏 1隐藏
  bool bgBlack; // 背景是否黑色 默认否

  TextAlign textAlign; //水平方向有效 只需要设置 left center right
  TextAlignVertical textAlignVertical;

  PrintTemplateElement(
      {this.fieldType = "text",
      this.field,
      this.fieldHidden,
      this.text,
      this.description,
      this.left,
      this.top,
      this.width,
      this.height,
      this.fontSize = "3",
      this.fontWeight = "0",
      this.rotation = 0,
      this.hideText = 1,
      this.bgBlack = false,
      this.textAlign = TextAlign.left,
      this.textAlignVertical = TextAlignVertical.top});

  PrintTemplateElement copy() {
    return PrintTemplateElement(
      fieldType: fieldType,
      field: field,
      fieldHidden: fieldHidden,
      text: text,
      description: description,
      left: left,
      top: top,
      width: width,
      height: height,
      fontSize: fontSize,
      fontWeight: fontWeight,
      rotation: rotation,
      hideText: hideText,
      bgBlack: bgBlack,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical
    );
  }

  PrintTemplateElement.fromJson(Map<String, dynamic> json) {
    fieldType = json["fieldType"] ?? "text";
    field = json["field"];
    fieldHidden = json["fieldHidden"];
    text = json["text"];
    description = json["description"];
    left = json["left"];
    top = json["top"];
    width = json["width"];
    height = json["height"];
    fontSize = ZsBluetoothPrinterManager.printerApi.fontSizeMapToMillimeter(json["fontSize"]) ?? "3";
    fontWeight = json["fontWeight"] ?? "0";
    rotation = json["rotation"] ?? 0;
    hideText = json["hideText"] ?? 1;

    bgBlack = json["bgBlack"] == 1 ? true : false;

    if (json["textAlign"] == "right") {
      this.textAlign = TextAlign.right;
    }
    else if (json["textAlign"] == "center") {
      this.textAlign = TextAlign.center;
    }
    else {
      this.textAlign = TextAlign.left;
    }

    if (json["textAlignVertical"] == "bottom") {
      this.textAlignVertical = TextAlignVertical.bottom;
    }
    else if (json["textAlignVertical"] == "center") {
      this.textAlignVertical = TextAlignVertical.center;
    }
    else {
      this.textAlignVertical = TextAlignVertical.top;
    }
  }

  String dataValueForJson(Map json) {
    var data = StringUtils.empty(field) ? text : json[field];
    if (StringUtils.empty(data)) {
      data = "";
    }
    return data;
  }
}

// 主要是用于传输
class PrintTextLabel {
  int line;
  double width;
  double height;
  String fontSize;

  PrintTextLabel({
    this.line,
    this.width,
    this.height,
    this.fontSize,
  });

  /*
  * 获取text的高度、行
  *
  * 会单独计算最小的  3和2.5 在设备上没有区别
  * 最后必须返回最后一个最小的 所以有 i == sizeList.length-1
  * */
  static PrintTextLabel getTextWidthLine({
    PrintTemplateElement printTemplateElement,
    String text,
  }) {
    double maxWidth = ZSPrintCmdApi._printerSize(printTemplateElement.width) * 1.0;
    double maxHeight = ZSPrintCmdApi._printerSize(printTemplateElement.height) * 1.0;

    List<String> sizeList = ["9", "8", "7", "6", "5", "4", "3", "2.5", "2"];

    int indexStart = sizeList.indexOf(printTemplateElement.fontSize);
    if (indexStart < 0) {
      indexStart = sizeList.length - 1;
    }

    for (var i = indexStart; i < sizeList.length; i++) {
      PrintTextLabel result = stringFontLineWidth(
        data: text,
        fontSize: sizeList[i],
        width: maxWidth,
      );
      if (result.height <= maxHeight || i == sizeList.length - 1) {
        return result;
      }
    }
    return null;
  }

  /*
  * 计算文字需要的宽度 以及高度和行
  *
  * 需要和cpcl_builder 中 drawText 打印text的方法计算一致
  * 注意 最后加 1 的逻辑 (1.0/printBitScal) 不用加 8 是因为使用的double计算
  * */
  static PrintTextLabel stringFontLineWidth({
    String data,
    String fontSize,
    double width,
  }) {
    Font font = CpclBuilder().sizeToFont(fontSize);

    int lineNum = 0;

    double lineWidth = 0;
    String text = '';
    for (int i = 0; i < data.length; i++) {
      String str = data[i];

      double strWidth = 0;
      if (utf8.encode(str).length != 1) {
        //中文
        strWidth = int.parse(font.lattice) / 1;
      } else {
        //英文
        strWidth = int.parse(font.lattice) / 2;
      }

      if (lineWidth + strWidth >= width) {
        text = "";
        lineWidth = 0;

        lineNum += 1;
      }
      text += str;
      lineWidth += strWidth;
    }
    if (text.length != 0) {
      lineNum += 1;
    }

    if (lineNum > 1) {
      lineWidth = width;
    } else {
      // 是为了防止后面在转为int的时候 由于上面 >= 导致最后一个放不下 所以需要加上一个点阵
      lineWidth += 1;
    }

    int oneLineHeight = int.parse(font.lattice);
    double height = 1.0 * oneLineHeight * lineNum + (lineNum - 1) * 6;

    return PrintTextLabel(line: lineNum, width: lineWidth, height: height, fontSize: fontSize);
  }
}
