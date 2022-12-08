import 'package:drawer_layout/drawer_layout.dart';
import 'package:example/content_widget.dart';
import 'package:example/left_drawer_widget.dart';
import 'package:example/right_drawer_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DrawerLayout Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: MyHomePage(title: 'Flutter DrawerLayout Home Page')
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late DrawerLayoutController _drawerController;

  @override
  void initState() {
    _drawerController = DrawerLayoutController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: DrawerLayout(
        controller: _drawerController,
        scrimColor: Colors.white.withOpacity(0.8),
        drawerWidthFactor: 0.8,
        content: ContentWidget(_drawerController),
        leftDrawer: LeftDrawerWidget(),
        rightDrawer: RightDrawerWidget(),
      ),
    );
  }
}
