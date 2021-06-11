import 'dart:core';

import 'package:flutter/cupertino.dart';

import 'barcode.dart';
import 'font.dart';

class CpclCommand {
  static const String DEBUG_TAG = "CpclCommand";
  String _command = '';

  ///清空命令
  void clear() {
    this._command = '';
  }

  void addStrToCommand(String str) {
    _command += str;
  }

  String getCommand() {
    return _command;
  }

  ///初始化打印机，所有的打印内容必须以这个为开头
  ///[offset] 打印的横向偏移量
  ///[height] 高度
  ///[qty] 打印的页数
  ///命令里的两个200是横向和纵向的分辨率
  void addInitializePrinter({int offset = 0, int height = 210, int qty = 1}) {
    clear();
    String str = "! $offset 200 200 $height $qty\r\n";
    addStrToCommand(str);
  }

  ///打印内容结尾
  void addPrint() {
    String str = "PRINT\r\n";
    addStrToCommand(str);
  }

  void addText(
      {@required Font font,
      @required int x,
      @required int y,
      @required String text,
      TextRotation rotation = TextRotation.text0}) {
    String r = '';
    switch (rotation) {
      case TextRotation.text0:
        r = 'TEXT';
        break;
      case TextRotation.text90:
        r = 'TEXT90';
        break;
      case TextRotation.text180:
        r = 'TEXT180';
        break;
      case TextRotation.text270:
        r = 'TEXT270';
        break;
    }
    String str = "$r ${font.family} ${font.size} $x $y $text\r\n";
    addStrToCommand(str);
  }

  void addTextConcat(int x, int y, List<String> data) {
    String str = "CONCAT $x $y\r\n";
    for (int i = 0; i < data.length; ++i) {
      str += data[i] + "\r\n";
    }
    str += "ENDCONCAT\r\n";
    addStrToCommand(str);
  }

  ///打印多个标签时，将TEXT/BARCODE中数字数据增加value
  void addCount(String value) {
    String str = "COUNT " + value + "\r\n";
    this.addStrToCommand(str);
  }

  ///缩放字体大小
  void addSetmag(int w, int h) {
    if (w > 16) {
      w = 16;
    } else if (w < 1) {
      w = 1;
    }

    if (h > 16) {
      h = 16;
    } else if (h < 1) {
      h = 1;
    }

    String str = "SETMAG $w $h\r\n";
    this.addStrToCommand(str);
  }

  ///打印条码
  void addBarcode(
      {BarcodeRotation rotation = BarcodeRotation.barcode0,
      @required BarcodeType barcodeType,
      int width = 2,
      BarcodeRatio barcodeRatio = BarcodeRatio.Point2,
      @required int height,
      @required int x,
      @required int y,
      @required String text,
      bool showText = true}) {
    if (showText) {
      addBarcodeText(24, 0);
    }
    String command = '';
    switch (rotation) {
      case BarcodeRotation.barcode0:
        command = 'BARCODE';
        break;
      case BarcodeRotation.barcode90:
        command = 'VBARCODE';
        break;
    }
    String type = '';
    switch (barcodeType) {
      case BarcodeType.CODE128:
        type = '128';
        break;
      case BarcodeType.UPC_A:
        type = 'UPCA';
        break;
      case BarcodeType.UPC_E:
        type = 'UPCE';
        break;
      case BarcodeType.EAN_13:
        type = 'EAN13';
        break;
      case BarcodeType.EAN_8:
        type = 'EAN8';
        break;
      case BarcodeType.CODE39:
        type = '39';
        break;
      case BarcodeType.CODE93:
        type = '93';
        break;
      case BarcodeType.CODABAR:
        type = 'CODABAR';
        break;
    }
    String ratio = '';
    switch (barcodeRatio) {
      case BarcodeRatio.Point0:
        ratio = '0';
        break;
      case BarcodeRatio.Point1:
        ratio = '1';
        break;
      case BarcodeRatio.Point2:
        ratio = '2';
        break;
      case BarcodeRatio.Point3:
        ratio = '3';
        break;
      case BarcodeRatio.Point4:
        ratio = '4';
        break;
      case BarcodeRatio.Point20:
        ratio = '20';
        break;
      case BarcodeRatio.Point21:
        ratio = '21';
        break;
      case BarcodeRatio.Point22:
        ratio = '22';
        break;
      case BarcodeRatio.Point23:
        ratio = '23';
        break;
      case BarcodeRatio.Point24:
        ratio = '24';
        break;
      case BarcodeRatio.Point25:
        ratio = '25';
        break;
      case BarcodeRatio.Point26:
        ratio = '26';
        break;
      case BarcodeRatio.Point27:
        ratio = '27';
        break;
      case BarcodeRatio.Point28:
        ratio = '28';
        break;
      case BarcodeRatio.Point29:
        ratio = '29';
        break;
      case BarcodeRatio.Point30:
        ratio = '30';
        break;
    }
    String str2 = "$command $type $width $ratio $height $x $y $text\r\n";
    addStrToCommand(str2);
    addBarcodeTextOff();
  }

  ///打印pdf数据，有需要可以适配
//  void addPdf417(CpclCommand.COMMAND command, int x, int y, int xd, int yd,
//      int c, int s, String data) {
//    String str = command.getValue() + " PDF417 " + x + " " + y + " XD " + xd +
//        " YD " + yd + " C " + c + " S " + s + "\r\n" + data + "\r\n" +
//        "ENDPDF\r\n";
//    this.addStrToCommand(str);
//  }

  ///条码增加文字注释
  void addBarcodeText(int font, int offset) {
    String str = "BARCODE-TEXT $font 0 $offset\r\n";
    addStrToCommand(str);
  }

  ///取消条码文字注释
  void addBarcodeTextOff() {
    String str = "BARCODE-TEXT OFF\r\n";
    addStrToCommand(str);
  }

  void addQrCode(
      {@required int x,
      @required int y,
      int u = 6,
      @required String text,
      QRLevel level = QRLevel.M,
      BarcodeRotation rotation = BarcodeRotation.barcode0}) {
    if (u > 32) {
      u = 32;
    } else if (u < 1) {
      u = 1;
    }
    String l = level.toString().split('.').last;
    String command = '';
    switch (rotation) {
      case BarcodeRotation.barcode0:
        command = 'BARCODE';
        break;
      case BarcodeRotation.barcode90:
        command = 'VBARCODE';
        break;
    }
    String str = "$command QR $x $y M 2 U $u\r\n${l}A,$text\r\nENDQR\r\n";
    addStrToCommand(str);
  }

  ///绘制矩形
  void addBox(int x, int y, int xend, int yend, int thickness) {
    String str = "BOX $x $y $xend $yend $thickness\r\n";
    addStrToCommand(str);
  }

  ///绘制线
  void addLine(int x, int y, int xend, int yend, int width, bool fullLine) {
    String t = fullLine ? 'LF' : 'LPLINE';
    String str = "$t $x $y $xend $yend $width\r\n";
    addStrToCommand(str);
  }

  ///绘制反色线
  void addInverseLine(int x, int y, int xend, int yend, int width) {
    String str = "INVERSE-LINE $x $y $xend $yend $width\r\n";
    addStrToCommand(str);
  }

  ///绘制图片
//  void addEGraphics(int x, int y, int nWidth, Bitmap bitmap) {
//    if (bitmap != null) {
//      int width = (nWidth + 7) / 8 * 8;
//      int height = bitmap.getHeight() * width / bitmap.getWidth();
//      Bitmap grayBitmap = GpUtils.toGrayscale(bitmap);
//      Bitmap rszBitmap = GpUtils.resizeImage(grayBitmap, width, height);
//      byte[] src = GpUtils.bitmapToBWPix(rszBitmap);
//      height = src.length / width;
//      byte[] codecontent = GpUtils.pixToEscRastBitImageCmd(src);
//      String data = this.toHexString1(codecontent);
//      String str = "EG " + width / 8 + " " + height + " " + x + " " + y + " " +
//          data + "\r\n";
//      this.addStrToCommand(str);
//    }
//  }

//  String toHexString1(byte[] b) {
//  StringBuffer buffer = new StringBuffer();
//
//  for(int i = 0; i < b.length; ++i) {
//  buffer.append(this.toHexString2(b[i]));
//  }
//  return buffer.toString();
//  }

//  String toHexString2(byte b) {
//    String s = Integer.toHexString(b & 255);
//    return s.length() == 1 ? "0" + s.toUpperCase() : s.toUpperCase();
//  }

//  void addCGraphics(int x, int y, int nWidth, Bitmap bitmap) {
//    if (bitmap != null) {
//      int width = (nWidth + 7) / 8 * 8;
//      int height = bitmap.getHeight() * width / bitmap.getWidth();
//      Bitmap grayBitmap = GpUtils.toGrayscale(bitmap);
//      Bitmap rszBitmap = GpUtils.resizeImage(grayBitmap, width, height);
//      byte[] src = GpUtils.bitmapToBWPix(rszBitmap);
//      height = src.length / width;
//      String str = "CG " + width / 8 + " " + height + " " + x + " " + y + " ";
//      this.addStrToCommand(str);
//      byte[] codecontent = GpUtils.pixToEscRastBitImageCmd(src);
//
//      for (int k = 0; k < codecontent.length; ++k) {
//        this.Command.add(codecontent[k]);
//      }
//
//      this.addStrToCommand("\r\n");
//    }
//  }

  void addJustification(Justification align) {
    String t = '';
    switch (align) {
      case Justification.CENTER:
        t = 'CENTER';
        break;
      case Justification.LEFT:
        t = 'LEFT';
        break;
      case Justification.RIGHT:
        t = 'RIGHT';
        break;
    }
    String str = "$t \r\n";
    this.addStrToCommand(str);
  }

//
//  void addJustification(CpclCommand.ALIGNMENT align, int end) {
//    String str = align.getValue() + " " + end + "\r\n";
//    this.addStrToCommand(str);
//  }

  ///设置宽度
  void addPageWidth(int width) {
    String str = "PAGE-WIDTH $width\r\n";
    addStrToCommand(str);
  }

  void addSpeed(int level) {
    String str = "SPEED $level\r\n";
    this.addStrToCommand(str);
  }

//  void addCountry(CpclCommand.COUNTRY name) {
//    String str = "COUNTRY " + name.getValue() + "\r\n";
//    this.addStrToCommand(str);
//  }

  void addBeep(int beepLength) {
    String str = "BEEP $beepLength\r\n";
    this.addStrToCommand(str);
  }

  void addForm() {
    String str = "FORM\r\n";
    this.addStrToCommand(str);
  }

//  void addNote(String text) {
//    String str = ";" + text + "\r\n";
//    this.addStrToCommand(str);
//  }

  void addEnd() {
    String str = "END\r\n";
    this.addStrToCommand(str);
  }

  void addSetsp(int spacing) {
    String str = "SETSP $spacing\r\n";
    this.addStrToCommand(str);
  }

  void addBold(bool bold) {
    String str = "SETBOLD ${bold ? '1' : '0'}\r\n";
    this.addStrToCommand(str);
  }

  void addUnderLine(bool b) {
    String str = "UNDERLINE ${b ? 'ON' : 'OFF'}\r\n";
    addStrToCommand(str);
  }

  void addSetlf(int height) {
    String str = "!U1 SETLF $height\r\n";
    this.addStrToCommand(str);
  }

  void addSetlp(int font, int size, int spacing) {
    String str = "!U1 SETLP $font $size $spacing\r\n";
    this.addStrToCommand(str);
  }

  void addPREtension(int length) {
    String str = "PRE-TENSION $length\r\n";
    this.addStrToCommand(str);
  }

  void addPOSTtension(int length) {
    String str = "POST-TENSION $length\r\n";
    this.addStrToCommand(str);
  }

  void addWait(int time) {
    String str = "WAIT $time\r\n";
    this.addStrToCommand(str);
  }
}

enum Justification {
  CENTER,
  LEFT,
  RIGHT,
}
