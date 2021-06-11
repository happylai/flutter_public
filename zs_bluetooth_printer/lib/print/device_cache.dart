import 'printer_setting_device.dart';
import 'zs_blue.dart';

/*
* 目的实现连接成功后 断开上次一连接的
* 自己加了一个缓存策略 将点击连接的的设备按先后顺序加入队列中
* 连接成功后 查找缓存是否存在，不存在 - 则丢弃；存在 - 则删除前面的队列
* 如果最后还有缓存 可以在一定时间后 清除缓存的device
*
* 状态变更的地方 添加缓存的校验 清除特征值和设备。
* */

List _zsBlueConnecttingDevice = []; // 需要连接的设备
var zsBlueConnectedDevice = null; // 已经连接的device 只会有一个

// 在清空当前数据的时候 需要判断不是手动断开，来方便后续重新记录或者自动连接
var zsBlueDeviceHandDisconnected = false; //是否手动断开

/*
* ------------ 缓存设备 ------------
* 不设置 device类型 主要是后面可以在缓存类型变化的话，可以方便修改
* 目前默认device 使用 PrinterSettingDevice类型
*
* 其中 clean方法开头的 主要是清除数据 不做其他逻辑处理，数据清除和关闭分开是为了防止循环调用
* implement clean 可以看作是实现断开连接的相关逻辑
*
* 注意对当前存储的 需要一直监听，所以需要在页面的消失时候 处理一下
* */
class ZSDeviceCache {
  // 缓存需要连接的deivce
  // 移除 但不能clean 因为同一个设备 如果执行clean 会断开连接， 成功则无法回调
  static void willConnectedDevice(device) {
    int index = implementCacheFindDevice(device);
    if (index >= 0) {
      _zsBlueConnecttingDevice.removeAt(index);
    }
    _zsBlueConnecttingDevice.insert(0, device);
  }

  // device成功后 如果是最后一个加入进来的 则删除之前的 如果不是则不删除
  static void connectedDevice(device) {
    if (true == implementDeviceSame(device, zsBlueConnectedDevice)) {
      zsBlueConnectedDevice = device;
      return;
    }
    // 查找device
    int index = implementCacheFindDevice(device);
    if (index < 0) {
      implementCleanDevice(device);
      return;
    }

    cleanCacheStart(index: index); // 清除后面的
    if (zsBlueConnectedDevice != null) {
      implementCleanDevice(zsBlueConnectedDevice);
      implementCurrentedDeviceClean();
    }
    cleanCurrentDevice();
    zsBlueConnectedDevice = device;
  }

  // 连接失败 清除缓存 可以加入延时 对于部分超过时间 或者底层报错导致 加try catch 然后处理
  // 不会造成死循环 因为先会移除 移除后 就不会在存储 不会在执行clean
  static void failConnectDevice(device) {
    int index = implementCacheFindDevice(device);
    if (index >= 0) {
      _zsBlueConnecttingDevice.removeAt(index);
    } else if (true == implementDeviceSame(device, zsBlueConnectedDevice)) {
      if (false == zsBlueDeviceHandDisconnected) {
        // 非手动断开的  存储设备信息 方便重新连接
        implementSaveLastDevice(zsBlueConnectedDevice);
      }
      cleanCurrentDevice();
      implementCurrentedDeviceClean();
    }
  }

  // 获取当前连接的设备
  static PrinterSettingDevice currentedDevice() {
    return zsBlueConnectedDevice;
  }

  // 主要是对外部方便
  static void cleanAll() {
    cleanCacheStart(index: 0);
    cleanCurrentDevice();
  }

  // 主要是对外部方便
  static void cleanCache() {
    cleanCacheStart(index: 0);
  }

  /*
  * 清除数据 但是不触发断开连接 因为在断开连接回调的时候，会重新判断是否缓存，此时已经没有缓存了，
  * 所以不需要在断开，即使有缓存，当前是断开连接的，也不需要触发断开
  * 同时也避免循环回调，触法断开连接， 又回触发当前failConnectDevice回调
  * */
  static void cleanCacheStart({int index}) {
    int n = 0;
    if (index != null) {
      n = index;
    }
    // 清空所有device 并且断开连接
    int length = _zsBlueConnecttingDevice.length;
    _zsBlueConnecttingDevice.removeRange(index, length);
  }

  // 清除当前连接的
  static void cleanCurrentDevice() {

    if (zsBlueConnectedDevice != null) {
      zsBlueConnectedDevice = null;
    }
  }
}

/*
* 实现 清除device 所需的动作
* 因为只会在连接成功中回调 所以不需要添加条件判断是否连接 在执行 不会造成循环 切记不能在fail中调用
* */
void implementCleanDevice(PrinterSettingDevice device) {
  device.disconnect();
}

/*
* 实现 匹配缓存中的数据
* */
int implementCacheFindDevice(PrinterSettingDevice device) {
  return _zsBlueConnecttingDevice.indexWhere((element) {
    return implementDeviceSame(element, device);
  });
}

/*
* 实现 两个device是否是同一个
* */
bool implementDeviceSame(
    PrinterSettingDevice device1, PrinterSettingDevice device2) {
  return zsBluePrinterDeviceSame(device1, device2);
}

void implementCurrentedDeviceClean() {
  // 清除选中的特征值
  ZSBlue.instance.cleanBluetoothCharacteristic();
}

/*
* 实现设备断开的时候 存储相关信息
* */
void implementSaveLastDevice(PrinterSettingDevice device) {
//存储连接的设备信息 可以自动连接
}
