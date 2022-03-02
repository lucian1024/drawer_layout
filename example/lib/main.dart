
import 'package:drawer_layout/drawer_layout.dart';
import 'package:drawer_layout/drawer_layout_controller.dart';
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
      home: MyHomePage(title: 'Flutter DrawerLayout Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
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
        drawerWidthFactor: 0.6,
        content: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.red,
                Colors.white
              ]
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.green,
                child: TextButton(
                  onPressed: () {
                    _drawerController.openDrawer(DrawerGravity.left);
                  },
                  child: Text(
                    "Open left drawer",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white
                    ),
                  )
                ),
              ),
              SizedBox(height: 30,),
              Container(
                color: Colors.green,
                child: TextButton(
                    onPressed: () {
                      _drawerController.openDrawer(DrawerGravity.right);
                    },
                    child: Text(
                      "Open right drawer",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white
                      ),
                    )
                ),
              ),

            ],
          ),
        ),
        leftDrawer: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.green,
                  Colors.white
                ]
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "left drawer"
              ),
              TextField(),
            ],
          ),
        ),
        rightDrawer: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blue,
                    Colors.white
                  ]
              )
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "right drawer"
              ),
              TextField(),
            ]
          ),
        ),
      ),
    );
  }
}
