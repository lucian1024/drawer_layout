
import 'package:drawer_layout/drawer_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentWidget extends StatefulWidget {
  ContentWidget(this._drawerController);

  final DrawerLayoutController _drawerController;

  @override
  State<StatefulWidget> createState() => ContentWidgetState();
}

class ContentWidgetState extends State<ContentWidget> {

  @override
  void initState() {
    debugPrint("content init state");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("content build");
    return Container(
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
                      widget._drawerController.openDrawer(DrawerGravity.left);
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
                      widget._drawerController.openDrawer(DrawerGravity.right);
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
    );
  }

  @override
  void dispose() {
    debugPrint("content dispose");
    super.dispose();
  }
}
