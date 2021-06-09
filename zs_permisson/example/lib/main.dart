import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zs_permisson/zs_permisson.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              var res = await ZsPermisson.checkLocationPermission();
              print("定位权限 $res");
            },
            child: item("checkLocationPermission"),
          ),
          GestureDetector(
            onTap: ()async {
              var res = await ZsPermisson.checkLocationState();
              print("定位状态 $res");
            },
            child: item("checkLocationState"),
          ),
          GestureDetector(
            onTap: () {
              ZsPermisson.openLocationState();
            },
            child: item("openLocationState"),
          ),
          GestureDetector(
            onTap: () {
              ZsPermisson.openLocationPermission();
            },
            child: item("openLocationPermission"),
          ),
          GestureDetector(
            onTap: () {
              ZsPermisson.openBluetoothPmission();
            },
            child: item("openBluetoothPmission"),
          ),
          GestureDetector(
            onTap: () {
              ZsPermisson.openBluetooth();
            },
            child: item("openBluetooth"),
          ),
        ],
      ),
    ));
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
