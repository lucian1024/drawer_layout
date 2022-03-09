import 'package:drawer_layout/drawer_layout.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              SizedBox(height: 15,),
              Flexible(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Container(
                        height: 44,
                        color: Colors.deepPurple,
                        child: TabBar(
                          tabs: List.generate(3, (index) => Container(
                            child: Text("Tab ${index + 1}")
                          )),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: List.generate(3, (index) => Container(
                            alignment: Alignment.center,
                            child: Text("TabView ${index + 1}"),
                          )),
                        )
                      ),
                    ],
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
              Container(
                height: 44,
                alignment: Alignment.center,
                child: Text(
                  "left drawer"
                ),
              ),
              Flexible(
                child: DefaultTabController(
                    key: UniqueKey(),
                    length: 3,
                    child: Column(
                      children: [
                        Container(
                          height: 44,
                          color: Colors.deepPurple,
                          child: TabBar(
                            tabs: List.generate(3, (index) => Container(
                                child: Text("Tab ${index + 1}")
                            )),
                          ),
                        ),
                        Expanded(
                            child: TabBarView(
                              children: List.generate(3, (index) => Container(
                                alignment: Alignment.center,
                                child: Text("TabView ${index + 1}"),
                              )),
                            )
                        ),
                      ],
                    )
                ),
              ),
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
              Container(
                height: 44,
                alignment: Alignment.center,
                child: Text(
                  "right drawer"
                ),
              ),
              Flexible(
                child: DefaultTabController(
                    key: UniqueKey(),
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          height: 44,
                          color: Colors.deepPurple,
                          child: TabBar(
                            tabs: List.generate(2, (index) => Container(
                                child: Text("Tab ${index + 1}")
                            )),
                          ),
                        ),
                        Expanded(
                            child: TabBarView(
                              children: List.generate(2, (index) => Container(
                                alignment: Alignment.center,
                                child: Text("TabView ${index + 1}"),
                              )),
                            )
                        ),
                      ],
                    )
                ),
              ),
            ]
          ),
        ),
      ),

      // body: Container(
      //   alignment: Alignment.center,
      //   decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //           begin: Alignment.centerLeft,
      //           end: Alignment.centerRight,
      //           colors: [Colors.red, Colors.white])),
      //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Container(
      //             color: Colors.green,
      //             child: TextButton(
      //                 onPressed: () {
      //                   _drawerController.openDrawer(DrawerGravity.left);
      //                 },
      //                 child: Text(
      //                   "Open left drawer",
      //                   style: TextStyle(fontSize: 14, color: Colors.white),
      //                 )),
      //           ),
      //           Container(
      //             color: Colors.green,
      //             child: TextButton(
      //                 onPressed: () {
      //                   _drawerController.openDrawer(DrawerGravity.right);
      //                 },
      //                 child: Text(
      //                   "Open right drawer",
      //                   style: TextStyle(fontSize: 14, color: Colors.white),
      //                 )),
      //           ),
      //         ],
      //       ),
      //       SizedBox(
      //         height: 15,
      //       ),
      //       Flexible(
      //         child: DefaultTabController(
      //             length: 3,
      //             child: Column(
      //               children: [
      //                 Container(
      //                   height: 44,
      //                   color: Colors.deepPurple,
      //                   child: TabBar(
      //                     tabs: List.generate(
      //                         3,
      //                         (index) =>
      //                             Container(child: Text("Tab ${index + 1}"))),
      //                   ),
      //                 ),
      //                 Expanded(
      //                     child: TabBarView(
      //                   children: List.generate(
      //                       3,
      //                       (index) => Container(
      //                             alignment: Alignment.center,
      //                             child: Text("TabView ${index + 1}"),
      //                           )),
      //                 )),
      //               ],
      //             )),
      //       ),
      //     ],
      //   ),
      // ),
      // drawer: Container(
      //   width: 300,
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //         begin: Alignment.centerLeft,
      //         end: Alignment.centerRight,
      //         colors: [Colors.green, Colors.white]),
      //   ),
      //   alignment: Alignment.center,
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Text("left drawer"),
      //       TextField(),
      //     ],
      //   ),
      // ),
      // drawerEdgeDragWidth: 300,
    );
  }
}
