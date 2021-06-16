import 'notification_center.dart';

class ZSModelBridge implements ZSNotifcationCenterDelegate{
  Function call;

  @override
  // 监听通知类型的 主要是在 fish_redux 中 也可以直接在this监听
  void observeNotify(String key, dynamic param) {
    call(key, param);
  }
}