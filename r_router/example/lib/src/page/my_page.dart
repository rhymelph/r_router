import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_router/r_router.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onNavigateToOne() {
    RRouter.myRouter.navigateTo('/one');
  }

  void onNavigateToTwo() {
    RRouter.myRouter.navigateTo('/two', arguments: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToTree() {
    RRouter.myRouter.navigateTo('/three', arguments: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToFour() {
    RRouter.myRouter.navigateTo('/four');
  }

  void onNavigateToNotFound() {
    RRouter.myRouter.navigateTo('/home', arguments: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToInterceptor() {
    RRouter.myRouter.navigateTo('/other');
  }

  void onShowDialog() {
    showRDialog(
        builder: (BuildContext context) => AlertDialog(
              title: Text('标题'),
              content: Text('内容'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'),
                ),
              ],
            ));
  }

  void onShowCupertinoDialog() {
    showRCupertinoDialog(
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('标题'),
              content: Text('内容'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'),
                ),
              ],
            ));
  }

  void onShowDatePickerDialog() {
    showRDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime(1990, 1, 1),
        lastDate: DateTime(2050, 12, 31));
  }

  void onShowDateTimeDialog() {
    showRTimePicker(
      initialTime: TimeOfDay.now(),
    );
  }

  void onShowDateTimeRangeDialog() {
    showRDateRangePicker(
        firstDate: DateTime(1990, 1, 1),
        lastDate: DateTime(2050, 12, 31),
        initialEntryMode: DatePickerEntryMode.calendarOnly);
  }

  void onShowBottomDialog() {
    showRModalBottomSheet(
        builder: (BuildContext context) => Center(
              child: RaisedButton(
                child: Text('按钮A'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ));
  }

  void onShowCupertinoBottomDialog() {
    showRCupertinoModalPopup(
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text('标题'),
              message: Text('内容'),
              actions: [
                CupertinoButton(
                    child: Text('按钮1'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
              cancelButton: CupertinoButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ));
  }

  void onShowLicensePage() {
    showRLicensePage();
  }

  void onShowAboutPage() {
    showRAboutDialog();
  }

  void onShowMenu() {
    //获取点击的button
    final RenderBox btnBox = _menuKey.currentContext.findRenderObject();
    //获取父布局的位置
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        btnBox.localToGlobal(Offset.zero, ancestor: overlay),
        btnBox.localToGlobal(btnBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showRMenu(position: position, items: <PopupMenuEntry>[
      PopupMenuItem(
        child: Text('Item 1'),
      ),
      PopupMenuItem(
        child: Text('Item 2'),
      ),
      PopupMenuDivider(),
      PopupMenuItem(
        child: Text('Item 3'),
      ),
      CheckedPopupMenuItem(
        child: Text('Item 4'),
        value: false,
        checked: true,
      ),
    ]);
  }

  GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          RaisedButton(onPressed: onNavigateToOne, child: Text('普通跳转')),
          RaisedButton(onPressed: onNavigateToTwo, child: Text('带参数')),
          RaisedButton(
              onPressed: onNavigateToTree, child: Text('自定义跳转动画（Cupertino）')),
          RaisedButton(
              onPressed: onNavigateToFour, child: Text('自定义跳转动画（Zoom）')),
          RaisedButton(onPressed: onNavigateToNotFound, child: Text('404')),
          RaisedButton(onPressed: onNavigateToInterceptor, child: Text('拦截跳转')),
          RaisedButton(onPressed: onShowDialog, child: Text('对话框')),
          RaisedButton(
              onPressed: onShowCupertinoDialog, child: Text('Cupertino对话框')),
          RaisedButton(onPressed: onShowDatePickerDialog, child: Text('日历选择')),
          RaisedButton(onPressed: onShowDateTimeDialog, child: Text('时间选择')),
          RaisedButton(
              onPressed: onShowDateTimeRangeDialog, child: Text('时间范围选择')),
          RaisedButton(onPressed: onShowBottomDialog, child: Text('底部弹出')),
          RaisedButton(
              onPressed: onShowCupertinoBottomDialog,
              child: Text('Cupertino底部弹出')),
          RaisedButton(onPressed: onShowLicensePage, child: Text('显示开源库')),
          RaisedButton(onPressed: onShowAboutPage, child: Text('显示关于页面')),
          RaisedButton(
              key: _menuKey, onPressed: onShowMenu, child: Text('弹出菜单')),
        ],
      ),
    );
  }
}
