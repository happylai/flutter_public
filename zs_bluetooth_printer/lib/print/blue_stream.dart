
import 'dart:async';


/*
* 管理蓝牙监听 需要存储使用的地方 在不用的时候移除相关监听
* */

const Stream_Manager_ScanResults_Listen_Key = "manager_scanResults_listen_key";
const Stream_Device_ScanResults_Listen_Key  = "device_scanResults_listen_key";
// 接受打印机消息的监听
const Stream_NotifyCharacteristic_Listen_Key = "manager_notifyCharacteristic_listen_key";

// 单个StreamSubcription 使用一个key
Map <String, StreamSubscription> _blueStreamMap = {};

// 一组StreamSubcription 使用同一个key
Map <String, List<StreamSubscription>> _blueStreamListMap = {};



/*
* 存储监听
* */
void addBlueStreamSubscriptionForKey(String key, streamSubscription) {
  if (_blueStreamMap[key] != null) {
    _blueStreamMap[key].cancel();
  }
  _blueStreamMap[key] = streamSubscription;
}

/*
* 取消监听
* */
void cancelBlueStreamSubscriptionForKey(String key) {
  if (_blueStreamMap[key] != null) {
    _blueStreamMap[key].cancel();
    _blueStreamMap.remove(key);
  }
}

/*
* 列表添加的方式
* 将StreamSubscription 添加在一个列表中 使用同一个key
* */
void addListBlueStreamSubscriptionForKey(String key, streamSubscription) {
  if (_blueStreamListMap[key] == null) {
    _blueStreamListMap[key] = [];
  }
  _blueStreamListMap[key].add(streamSubscription);
}

/*
* 取消同一个列表的所有监听
* */
void cancelListBlueStreamSubscriptionForKey(String key) {
  if (_blueStreamListMap[key] != null) {
    for(StreamSubscription stream in _blueStreamListMap[key]) {
      stream.cancel();
    }
    _blueStreamListMap[key] = [];
    _blueStreamListMap.remove(key);
  }
}