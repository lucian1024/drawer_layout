
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeftDrawerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LeftDrawerWidgetState();
}

class LeftDrawerWidgetState extends State<LeftDrawerWidget> {

  @override
  void initState() {
    debugPrint("left drawer init state");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("left drawer build");
    return Container(
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
    );
  }

  @override
  void dispose() {
    debugPrint("left drawer dispose");
    super.dispose();
  }
}
