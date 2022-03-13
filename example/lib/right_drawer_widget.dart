
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RightDrawerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RightDrawerWidgetState();
}

class RightDrawerWidgetState extends State<RightDrawerWidget> {

  @override
  void initState() {
    debugPrint("right drawer init state");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("right drawer build");
    return Container(
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
    );
  }

  @override
  void dispose() {
    debugPrint("right drawer dispose");
    super.dispose();
  }
}
