import 'dart:convert';

import '../print_builder.dart';
import 'barcode.dart';
import 'cpcl_commond.dart';
import 'font.dart';

class CpclBuilder with PrintBuilder {
  CpclCommand _command = CpclCommand();

  @override
  drawBarCode({
    int cellWidth,
    int height,
    String data,
    int startX,
    int startY,
    String type,
    int rotation,
    bool showText = true,
  }) {
    _command.addBarcode(
      barcodeType: BarcodeType.CODE128,
      height: height,
      x: startX,
      y: startY,
      text: data,
      rotation:
          rotation == 0 ? BarcodeRotation.barcode0 : BarcodeRotation.barcode90,
      width: cellWidth,
      showText: showText,
    );
  }

  @override
  drawLine(
    int startX,
    int startY,
    int endX,
    int endY,
    int lineWidth,
    bool fullLine,
  ) {
    _command.addLine(startX, startY, endX, endY, lineWidth, fullLine);
  }
  @override
  addInverseLine({ int x,  int y,  int xend,  int yend,  int width}){
    _command.addInverseLine(x, y, xend, yend, width);
  }

  @override
  drawText(
      {int width,
      int height,
      String data,
      int startX,
      int startY,
      String fontSize,
      bool underline = false,
      int bold = 0,
      int rotation = 0}) {
    _command.addBold(bold == 1);
    _command.addUnderLine(underline);
    TextRotation r;
    switch (rotation) {
      case 0:
        r = TextRotation.text0;
        break;
      case 1:
        r = TextRotation.text90;
        break;
      case 2:
        r = TextRotation.text180;
        break;
      case 3:
        r = TextRotation.text270;
        break;
    }
    Font font = sizeToFont(fontSize);
    double lineWidth = 0;
    String text = '';
    _command.addSetmag(int.parse(font.w), int.parse(font.h));
    for (int i = 0; i < data.length; i++) {
      String str = data[i];

      double strWidth = 0;
      if (utf8.encode(str).length != 1) {
        //中文
        strWidth = int.parse(font.lattice)/1;
      } else {
        //英文
        strWidth = int.parse(font.lattice) / 2;
      }

      if (lineWidth + strWidth >= width) {
        _command.addText(
            font: font, x: startX, y: startY, text: text, rotation: r);
        text = "";
        lineWidth = 0;
        startY += int.parse(font.lattice) + 6;
      }
      text += str;
      lineWidth += strWidth;
    }
    if (text.length != 0) {
      _command.addText(
          font: font, x: startX, y: startY, text: text, rotation: r);
    }
  }

  @override
  String getPrintCommand() {
    return _command.getCommand();
  }

  @override
  pageSetup({int width, int height}) {
    _command.addInitializePrinter(height: height, offset: 0, qty: 1);
    _command.addJustification(Justification.LEFT);
    return null;
  }

  @override
  drawQrCode({
    String data,
    int startX,
    int startY,
    int ecc,
    int rotation,
    int version,
  }) {
    _command.addQrCode(text: data, x: startX, y: startY);
  }

  @override
  finish() {
    _command.addForm();
    _command.addPrint();
  }

  ///映射字体大小 ，单位毫米
  Font sizeToFont(String size) {
    String t;
    try {
      t = ''+size;
    } catch (e) {
      t = '2';
    }

    switch(t) {
      case '2':
        return Fonts.font16;
      case '2.5':
        return Fonts.font20;
      case '3':
        return Fonts.font24;
      case '4':
        return Fonts.font32;
      case '5':
        return Fonts.font40;
      case '6':
        return Fonts.font48;
      case '7':
        return Fonts.font56;
      case '8':
        return Fonts.font64;
      case '9':
        return Fonts.font72;
      default:
        return Fonts.font16;
    }
  }

  @override
  setSpeed(int speed) {
    _command.addSpeed(speed);
  }
}
