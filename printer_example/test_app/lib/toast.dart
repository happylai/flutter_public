import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class Toast {
  static void showToast(String text,{bool isLongTime=false}) {
    Widget wg = Container(
      decoration: BoxDecoration(
          color: Color(0xB3000000),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      padding: EdgeInsets.only(left: 27, right: 27, bottom: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Offstage(
            offstage: false,
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Image.asset(
                "assets/note_white.png",
                width: 40,
                height: 40,
              ),
            ),
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 13),
          )
        ],
      ),
    );

    showToastWidget(wg,
        duration: Duration(milliseconds:isLongTime?3000: 1300), dismissOtherToast: true);
  }
}
