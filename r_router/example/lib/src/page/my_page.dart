import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchDelegate;
import 'package:r_router/r_router.dart';

class MyHomePage extends StatefulWidget {
  final String? title;

  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onNavigateToOne() async {
    final result = await RRouter.navigateTo('/one');
    if (result != null) {
      RRouter.showDialog(
          builder: (BuildContext context) => AlertDialog(
                title: Text('返回值'),
                content: Text('我的返回值:$result'),
              ));
      // ScaffoldMessenger.of(context).showMaterialBanner(
      //     MaterialBanner(content: Text('我的返回值:$result'), actions: [
      //   TextButton(
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      //       },
      //       child: Text('确定')),
      // ]));
    }
  }

  void onNavigateToTwo() {
    RRouter.navigateTo('/two', body: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToTree() {
    RRouter.navigateTo('/three', body: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToFour() {
    RRouter.navigateTo('/four');
  }

  void onNavigateToNotFound() {
    RRouter.navigateTo('/home', body: {'param': '我是参数(支持实体类)'});
  }

  void onNavigateToInterceptor() async {
    final result = await RRouter.navigateTo('/other');
    print('finish: $result');
  }

  void onShowDialog() {
    RRouter.showDialog(
        builder: (BuildContext context) => AlertDialog(
              title: Text('标题'),
              content: Text('内容'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'),
                ),
              ],
            ));
  }

  void onShowCupertinoDialog() {
    RRouter.showCupertinoDialog(
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('标题'),
              content: Text('内容'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'),
                ),
              ],
            ));
  }

  void onShowDatePickerDialog() {
    RRouter.showDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(1990, 1, 1),
            lastDate: DateTime(2050, 12, 31))
        .then((value) {
      print(value);
    });
  }

  void onShowDateTimeDialog() {
    RRouter.showTimePicker(
      initialTime: TimeOfDay.now(),
    ).then((value) {
      print(value);
    });
  }

  void onShowDateTimeRangeDialog() {
    RRouter.showDateRangePicker(
        firstDate: DateTime(1990, 1, 1),
        lastDate: DateTime(2050, 12, 31),
        initialEntryMode: DatePickerEntryMode.calendarOnly);
  }

  void onShowBottomDialog() {
    RRouter.showModalBottomSheet(
        builder: (BuildContext context) => SizedBox(
              height: 100,
              child: Center(
                child: ElevatedButton(
                  child: Text('按钮A'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ));
  }

  void onShowCupertinoBottomDialog() {
    RRouter.showCupertinoModalPopup(
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
    RRouter.showLicensePage();
  }

  void onShowAboutPage() {
    RRouter.showAboutDialog();
  }

  void onUsePrint() async {
    final result = await RRouter.navigateTo('/print');
    print(result);
  }

  void onShowNavigatorDialog() async {
    final result = await RRouter.navigateTo('/showDialog');
    print(result);
  }

  void onShowMenu() {
    //获取点击的button
    final RenderBox? btnBox =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    //获取父布局的位置
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        btnBox!.localToGlobal(Offset.zero, ancestor: overlay),
        btnBox.localToGlobal(btnBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay!.size,
    );
    RRouter.showMenu(position: position, items: <PopupMenuEntry>[
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

  void onShowSearchDialog() {
    RRouter.showSearch(delegate: MySearchDelegate());
  }

  GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: ListView(
        children: <Widget>[
          ElevatedButton(onPressed: onNavigateToOne, child: Text('普通跳转')),
          ElevatedButton(onPressed: onNavigateToTwo, child: Text('带参数')),
          ElevatedButton(
              onPressed: onNavigateToTree, child: Text('自定义跳转动画（Cupertino）')),
          ElevatedButton(
              onPressed: onNavigateToFour, child: Text('自定义跳转动画（Zoom）')),
          ElevatedButton(onPressed: onNavigateToNotFound, child: Text('404')),
          ElevatedButton(
              onPressed: onNavigateToInterceptor, child: Text('拦截跳转')),
          ElevatedButton(onPressed: onShowDialog, child: Text('对话框')),
          ElevatedButton(
              onPressed: onShowCupertinoDialog, child: Text('Cupertino对话框')),
          ElevatedButton(
              onPressed: onShowDatePickerDialog, child: Text('日历选择')),
          ElevatedButton(onPressed: onShowDateTimeDialog, child: Text('时间选择')),
          ElevatedButton(
              onPressed: onShowDateTimeRangeDialog, child: Text('时间范围选择')),
          ElevatedButton(onPressed: onShowBottomDialog, child: Text('底部弹出')),
          ElevatedButton(
              onPressed: onShowCupertinoBottomDialog,
              child: Text('Cupertino底部弹出')),
          ElevatedButton(onPressed: onShowLicensePage, child: Text('显示开源库')),
          ElevatedButton(onPressed: onShowAboutPage, child: Text('显示关于页面')),
          ElevatedButton(
              key: _menuKey, onPressed: onShowMenu, child: Text('弹出菜单')),
          ElevatedButton(onPressed: onUsePrint, child: Text('调用打印')),
          ElevatedButton(onPressed: onShowNavigatorDialog, child: Text('弹窗路由')),
          ElevatedButton(onPressed: onShowSearchDialog, child: Text('弹出搜索框')),
          ElevatedButton(onPressed: onShowOverlay, child: Text('Overlay')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('initState');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
  }

  OverlayEntry? _entry;

  void onShowOverlay() {
    Overlay.of(RRouter.overlayContext!).insert(_entry = OverlayEntry(
        builder: (BuildContext context) => Center(
              child: Material(
                child: Container(
                  color: Colors.blue,
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _entry?.remove();
                    },
                  ),
                ),
              ),
            )));
  }
}

class MySearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () {}, icon: Icon(Icons.clear)),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Text('result'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      child: Text('suggestions'),
    );
  }
}
