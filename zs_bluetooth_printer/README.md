# zs_bluetooth_printer

A new Flutter package.

## Getting Started

使用步骤
    
    引入:
    
    zs_bluetooth_printer:
      git:
        url: https://github.com/xiyuxiaoxiao/flutter_public.git
        path: zs_bluetooth_printer
        

    配置项目 添加蓝牙相关权限

        Android
                <uses-permission android:name="android.permission.READ_PHONE_STATE" />
                <uses-permission android:name="android.permission.BLUETOOTH"/>
                <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
                <uses-permission-sdk-23 android:name="android.permission.ACCESS_FINE_LOCATION"/>

            如果SDK报错 ：
            android/build.gradle 下修改 minSdkVersion：19  compileSdkVersion  targetSdkVersion 为 28；  

        Ios
            -- info.plist
                Privacy - Bluetooth Always Usage Description
                Privacy - Bluetooth Peripheral Usage Description
            -- Background Modes
                  Uses Bluetooth LE accessories
            需要录制打印视频上传优酷或者直接在appstore附件中添加视频说明

    1. 继承ZsBluetoothPrinterApi 实现相关方法 ( class MyPrinter extends ZsBluetoothPrinterApi )
       在mian中初始化
        await ZsBluetoothPrinterManager.initPrinter(MyPrinter());

    2. MaterialApp 中对 ScreenUtil 初始化 （因为内部使用了比例布局计算）
        builder: (context, child) {
            ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
            return child;
        },
    3. 路由中监听 判断是否是插件内部的页面 是的话直接使用插件的onGenerateRoute
        onGenerateRoute: (RouteSettings settings){
                var route = ZsBluetoothPrinterManager.onGenerateRoute(settings);
                if (route != null) {
                  return route;
                }
        },

    4. 在assets: 添加包内部资源文件
            - packages/zs_bluetooth_printer/img/dialog_error.png
            - packages/zs_bluetooth_printer/img/small_label_barcode.png
            - packages/zs_bluetooth_printer/img/ic_back.png

    5. 使用打印方法
        // 检测是否有连接了打印
        var res = PrintUtil.checkPrinterConnect();

        // 检测模版是否配置
        awiat PrintUtil.checkSmallPrintTemple();

        // 加入打印队列
        PrintUtil(printJson: {}).addTask();


    6. 监听蓝牙通知用
        需要监听对象实现接口 ZSNotifcationCenterDelegate
        abstract class ZSNotifcationCenterDelegate {
          observeNotify(String key, dynamic param); // observeNotify为通知回调
        }
        // 添加监听
        ZSNotifcationCenter.addObserveForKey(observe, Notify_Observe_StoreBluetooth_Key);
        // 移除监听
        ZSNotifcationCenter.removeObserve(observe);

        通知相关Key
            Notify_Observe_BlueState_Key;       // 蓝牙状态变化
            Notify_Observe_StoreBluetooth_Key;  // 存储连接的设备

二. 显示浮窗显示任务个数
    1.  重写 ZsBluetoothPrinterApi 的 showPrintTaskOverlay 返回true
    2.  需要在Page build中设置 appContent
        ZsBluetoothPrinterManager.setAppContext(context);
    3.  自定义浮窗Widget 否则使用默认的
            重写 ZsBluetoothPrinterApi 的 printTaskOverlayWidget

具体可参考案例
    https://github.com/xiyuxiaoxiao/flutter_public/tree/main/printer_example/test_app

    ![image](https://github.com/xiyuxiaoxiao/flutter_public/blob/main/printer_example/任务悬浮.jpg)

小标签打印结果：
![image](https://github.com/xiyuxiaoxiao/flutter_public/blob/main/printer_example/小标签.jpg)


