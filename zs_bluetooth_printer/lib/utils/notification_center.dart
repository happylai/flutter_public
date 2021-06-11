/*
* 广播模式
*
* 监听者 需要实现下面方法
* observeNotify(String key, dynamic param)
*
* */

Map <String, List> _observeMap = {};

class ZSNotifcationCenter {

  static void addObserveForKey(dynamic observe, String key) {
    if (_observeMap[key] == null) {
      _observeMap[key] = [];
    }
    if (_observeMap[key].contains(observe) == false) {
      _observeMap[key].add(observe);
    }
  }

  static void removeObserve(dynamic observe) {
    _observeMap.keys.toList().forEach((key) {
      removeObserveForKey(key, observe);
    });
  }
  static void removeObserveForKey(String key, dynamic observe) {
    if (_observeMap[key].contains(observe) == true) {
      _observeMap[key].remove(observe);
    }
    if (_observeMap[key].length <= 0) {
      _observeMap.remove(key);
    }
  }

  /*
  * 监听这 通过实现下面的方法 回调
  * observeNotify(String key, dynamic param)
  * */
  static void sendNotifyForKey(String key, dynamic value) {
    if (_observeMap[key] != null) {
      for(dynamic observe in _observeMap[key]) {
        observe.observeNotify(key,value);
      }
    }
  }
}

observeNotify(String key, dynamic param) {

}