import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:test_app/test_data.dart';
import 'package:test_app/toast.dart';
import 'package:zs_bluetooth_printer/model/routes.dart';
import 'package:zs_bluetooth_printer/print_util/print_util.dart';
import 'package:zs_bluetooth_printer/template/print_template_list.dart';
import 'package:zs_bluetooth_printer/utils/global.dart';
import 'package:zs_bluetooth_printer/zs_bluetooth_printer.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await ZsBluetoothPrinterManager.initPrinter(MyPrinter());
  runApp(MyApp());
  if (Platform.isAndroid) {
    //设置Android头部的导航栏透明
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

}

class MyPrinter extends ZsBluetoothPrinterApi {
  @override
  GlobalKey<NavigatorState> globalNavigatorKey() {
    return navigatorKey;
  }

  @override
  Future<bool> loadPrintData(PrintTemplateList temp) async{
    if (temp.id == "0") {
      temp.printJson = TempletaJSon.size60();
    }else {
      temp.printJson = TempletaJSon.size50();
    }
    var res = temp.printJson != null;
    return temp.printJson != null;
  }

  @override
  Future<List<PrintTemplateList>> loadPrintTempList() async{
    List<PrintTemplateList>list = [];
    return [
      PrintTemplateList(
        name: "60*40",
        id: "0",
      ),
      PrintTemplateList(
        name: "20*30",
        id: "1",
      ),
    ];
  }

  @override
  showToast(String title) {
    print(" 弹窗 $title");
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
          child: MaterialApp(
                title: 'Flutter Demo',
                navigatorKey: navigatorKey,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                routes: {
                  "/": (context) => MyHomePage(),
                },
                builder: (context, child) {
                  ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
                  return child;
                },
                onGenerateRoute: (RouteSettings settings){
                  var route = ZsBluetoothPrinterManager.onGenerateRoute(settings);
                  if (route != null) {
                    return route;
                  }
                },
              ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试打印"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: ()async {
                bool res = PrintUtil.checkPrinterConnect();
                if (res) {
                  Toast.showToast("打印机 已连接");
                }else {
                  Toast.showToast("打印机 未连接");
                }
              },
              child: item("检测打印机连接"),
            ),
            GestureDetector(
              onTap: ()async {
                bool res = await PrintUtil.checkSmallPrintTemple();
                if (res) {
                  Toast.showToast("模版 已存在");
                }else {
                  Toast.showToast("模版 未设置");
                }
              },
              child: item("检测小标签模版连接"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(Global.navigatorKey.currentContext, Pages.printConfig);
              },
              child: item("跳转打印配置页面"),
            ),

            GestureDetector(
              onTap: ()async {
                if (false == PrintUtil.checkPrinterConnect()) return;
                if (!(await PrintUtil.checkSmallPrintTemple())) return;
                PrintUtil(printJson: TempletaJSon.dataJson()).addTask();
              },
              child: item("打印小标签"),
            ),
          ],
        ),
      ),
    );
  }
}

Widget item(text) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        )
    ),
    child: Center(
      child: Text(text ?? "-"),
    ),
  );
}
