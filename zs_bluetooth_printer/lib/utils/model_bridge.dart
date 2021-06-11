class ZSModelBridge {
  Function call;

  // 监听通知类型的 主要是在 fish_redux 中
  void observeNotify(String key, dynamic param) {
    call(key, param);
  }
}