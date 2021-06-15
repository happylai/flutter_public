# zs_bluetooth_printer

A new Flutter package.

## Getting Started

使用步骤
    1. 自定义类 class MyApp extends StatelessWidget
       在mian中初始化
        await ZsBluetoothPrinterManager.initPrinter(MyPrinter());

    2. MaterialApp 中对 ScreenUtil 初始化
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

    4. 在assets: 添加资源文件
        - packages/zs_bluetooth_printer/img/dialog_error.png

    5. 使用打印方法
        // 检测是否有连接了打印
        var res = PrintUtil.checkPrinterConnect();

        // 加入打印队列
        PrintUtil().addTask();

