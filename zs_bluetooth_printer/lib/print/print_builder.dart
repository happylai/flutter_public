import 'package:flutter/cupertino.dart';

mixin PrintBuilder {
  ///获取打印命令
  String getPrintCommand();

  ///绘制文字
  drawText(
      {@required int width,
      @required int height,
      @required String data,
      @required int startX,
      @required int startY,
      String fontSize,
      bool underline = false,
      int bold = 0,
      int rotation = 0});

  ///绘制条码
  drawBarCode(
      {@required int cellWidth,
      @required int height,
      @required String data,
      @required int startX,
      @required int startY,
      String type,
      int rotation,
      bool showText});

  ///绘制反色线
  addInverseLine({@required int x,@required  int y,@required  int xend,@required  int yend,@required  int width});
  ///绘制线
  drawLine(
    int startX,
    int startY,
    int endX,
    int endY,
    int lineWidth,
    bool fullline,
  );

  ///初始化打印机
  pageSetup({int width, int height});

  ///绘制二维码
  drawQrCode({
    @required String data,
    @required int startX,
    @required int startY,
    int ecc,
    int rotation,
    int version,
  });

  ///设置速度 1-5
  setSpeed(int speed);

  ///完成构建
  finish();
}
