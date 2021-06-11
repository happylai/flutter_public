///条码方向
enum BarcodeRotation { barcode0, barcode90 }

///条码类型
enum BarcodeType {
  CODE128,
  UPC_A,
  UPC_E,
  EAN_13,
  EAN_8,
  CODE39,
  CODE93,
  CODABAR,
}

///条码宽条与窄条的比率
enum BarcodeRatio {
  Point0, //1.5:1
  Point1, //2.0:1
  Point2, //2.5:1
  Point3, //3.0:1
  Point4, //3.5:1
  Point20, //2.0:1
  Point21, //2.1:1
  Point22, //2.2:1
  Point23, //2.3:1
  Point24, //2.4:1
  Point25, //2.5:1
  Point26, //2.6:1
  Point27, //2.7:1
  Point28, //2.8:1
  Point29, //2.9:1
  Point30, //3.0:1
}

///二维码纠错等级
enum QRLevel {
  H, //极高可靠性
  Q, //高可靠性
  M, //标准
  L, //高密度
}
