import 'dart:core';

class Font {
  ///字体编号
  final String family;

  ///字体型号
  final String size;

  ///宽度放大倍数
  final String w;

  ///高度放大倍数
  final String h;

  ///点阵高度
  final String lattice;

  const Font({
    this.family = '55',
    this.size = '0',
    this.w = '1',
    this.h = '1',
    this.lattice = '16',
  });
}

class Fonts {
  Fonts._();

  // font16表示 16表示lattice 字体所占高度点阵
  static const Font font16 = Font();
  static const Font font20 = Font(family: '3', lattice: '20');
  static const Font font24 = Font(family: '24', lattice: '24');
  static const Font font32 = Font(family: '4', lattice: '32');
  static const Font font40 = Font(family: '42', w: '2', h: '2', lattice: '40');

  static const Font font48 = Font(family: '24', w: '2', h: '2', lattice: '48');
  static const Font font56 = Font(family: '7', size: '3', lattice: '56');
  static const Font font64 = Font(family: '4', w: '2', h: '2', lattice: '64');
  static const Font font72 = Font(family: '24', w: '3', h: '3', lattice: '72');
}

///文字旋转角度
enum TextRotation { text0, text90, text180, text270 }
