import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

final localStore = ZSLocalStore();

const LocalStoreKeyPathName = "key";

class ZSLocalStore {
  var _sharedPreferences;

  init() async {
    if (null == _sharedPreferences) {
      _sharedPreferences = await SharedPreferences.getInstance();
      return _sharedPreferences;
    }
  }

  // 获取某个数据
  getValue(String key, {dynamic defaultValue}) {
    String result = _sharedPreferences.getString(key);
    if (result == null) {
      if (defaultValue != null) {
        return defaultValue;
      }
      return null;
    }
    var json = jsonDecode(result);
    return json[LocalStoreKeyPathName];
  }

  // 存储某个数据
  setValue(String key, dynamic value) {
    var obj = {LocalStoreKeyPathName: value};
    var json = jsonEncode(obj);
    _sharedPreferences.setString(key, json);
  }
}
