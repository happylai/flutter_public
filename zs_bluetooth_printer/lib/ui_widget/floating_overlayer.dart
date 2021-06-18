import 'package:flutter/material.dart';

class FloatingOverLay {
  OverlayEntry _holder;

  double top;
  bool isLeft = false;

  Widget view;

  bool isRemove() {
    return _holder == null;
  }
  void remove() {
    if (_holder != null) {
      _holder.remove();
      _holder = null;
    }
  }

  void show({@required BuildContext context, @required Widget child}) {

    view = child;

    remove();
    //创建一个OverlayEntry对象
    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {

      if (top == null) top = MediaQuery.of(context).size.height * 0.7;
      return new Positioned(
          top: top,
          left: isLeft ? 0 : null,
          right: isLeft ? null : 0,
          child: _buildDraggable(context));
    });

    //往Overlay中插入插入OverlayEntry
    Overlay.of(context).insert(overlayEntry);

    _holder = overlayEntry;
  }

  _buildDraggable(context) {
    return new Draggable(
      child: view,
      feedback: view,
      onDragStarted: (){
        print('onDragStarted:');
      },
      onDragEnd: (detail) {
        print('onDragEnd:${detail.offset}');
        createDragTarget(offset: detail.offset, context: context);
      },
      childWhenDragging: Container(),
    );
  }

  void refresh() {
    _holder.markNeedsBuild();
  }

  void createDragTarget({Offset offset, BuildContext context}) {
    if (_holder != null) {
      _holder.remove();
    }

    _holder = new OverlayEntry(builder: (context) {
      isLeft = true;
      if (offset.dx + 100 > MediaQuery.of(context).size.width / 2) {
        isLeft = false;
      }

      double maxY = MediaQuery.of(context).size.height - 100;

      top = offset.dy < 50 ? 50 : offset.dy < maxY ? offset.dy : maxY;

      return new Positioned(
          top: top,
          left: isLeft ? 0 : null,
          right: isLeft ? null : 0,
          child: DragTarget(
            onWillAccept: (data) {
              print('onWillAccept: $data');
              return true;
            },
            onAccept: (data) {
              print('onAccept: $data');
              // refresh();
            },
            onLeave: (data) {
              print('onLeave');
            },
            builder: (BuildContext context, List incoming, List rejected) {
              return _buildDraggable(context);
            },
          ));
    });
    Overlay.of(context).insert(_holder);
  }
}