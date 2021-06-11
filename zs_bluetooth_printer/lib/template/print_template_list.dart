
// 当前的类型
import 'dart:convert';

import '../model/constant.dart';
import '../model/shared_cache.dart';

PrintTemplateList _currentPrintTemplate = null;

class PrintTemplateList {
  String name;
  String id;

  Map<String, dynamic> printJson;

  /**
   * 全局模版对象
   * 添加Map判断 是为了兼容上一个版本的内容 防止本地冲突异常
   */
  static PrintTemplateList get currentTemp {
    if (_currentPrintTemplate == null) {
      dynamic json = localStore.getValue(Stock_Small_Label_Temple);
      if (json != null && json is Map) {
        _currentPrintTemplate = PrintTemplateList.fromJson(json);
      }
    }
    return _currentPrintTemplate;
  }

  static saveCurrentTemp(PrintTemplateList type) {
    _currentPrintTemplate = type;
    localStore.setValue(Stock_Small_Label_Temple, type.toJson());
  }



  PrintTemplateList({
    this.name,
    this.id,
  });
  PrintTemplateList.fromJson(Map<String, dynamic> json) {
    name = json["templateName"] ?? "";
    id = json["id"] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['templateName'] = this.name;
    data['id'] = this.id;
    return data;
  }

  // 根据id 请求数据模版
  Future<bool> loadPrintData() async{
   return false;
  }
}