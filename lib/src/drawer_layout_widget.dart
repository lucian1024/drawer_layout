/*
 * According to [DrawerController], implement a widget supports left and right drawer
 * which is similar to Android's DrawerLayout.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'drawer_layout_controller.dart';

class DrawerLayout extends StatefulWidget {
  const DrawerLayout({
    required this.content,
    this.leftDrawer,
    this.rightDrawer,
    this.drawerWidthFactor = 0.8,
    this.drawerWidthOffset,
    this.controller,
    this.scrimColor,
    Key? key,
  }) : assert(leftDrawer != null || rightDrawer != null),
       assert(drawerWidthFactor >= 0 && drawerWidthFactor <= 1),
       assert(drawerWidthOffset == null || drawerWidthOffset >= 0),
       super(key: key);

  /// The content widget
  final Widget content;

  /// The left drawer widget
  final Widget? leftDrawer;

  /// The right drawer widget
  final Widget? rightDrawer;

  /// The factor of the opened drawer's width relative to the content's width, which means
  /// the opened drawer's width is the content's width multiplied by [drawerWidthFactor].
  /// If the [drawerWidthOffset] is set, [drawerWidthFactor] will be ignored.
  /// It should be null or in [0, 1] and the default factor is 0.8.
  ///
  /// @see [drawerWidthOffset]
  final double drawerWidthFactor;

  /// The offset of the opened drawer's width relative to the content's width, which means
  /// the opened drawer's width is the content's width minus [drawerWidthOffset].
  /// If the [drawerWidthOffset] is set, [drawerWidthFactor] will be ignored.
  /// If it is grater than the content's width, the drawer's width will be 0.
  /// It should be null or non-negative.
  ///
  /// @see [drawerWidthFactor]
  final double? drawerWidthOffset;

  /// The color to use for the scrim that obscures primary content while a drawer is open.
  ///
  /// By default, the color used is [Colors.black54]
  final Color? scrimColor;

  /// The controller to control the [DrawerLayout]
  final DrawerLayoutController? controller;

  @override
  DrawerLayoutState createState() => DrawerLayoutState();
}

class DrawerLayoutState extends State<DrawerLayout> with SingleTickerProviderStateMixin {
  /// The min fling velocity to open or close the drawer directly
  final double _minFlingVelocity = 365.0;

  /// The controller to control the [DrawerLayout]
  late DrawerLayoutController controller;
  late ColorTween _scrimColorTween;

  /// The width of the content
  double? _contentWidth;

  /// The width of the drawer
  double? _drawerWidth;

  /// The [FocusScopeNode] to control focus for content and drawers
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    controller = widget.controller ?? DrawerLayoutController(vsync: this);
    controller..addListener(_animationChanged);

    _scrimColorTween = ColorTween(begin: Colors.transparent, end: widget.scrimColor ?? Colors.black54);
    
    super.initState();
  }

  /// Refresh with with animation.
  void _animationChanged() {
    setState(() {
      // The animation controller's state is our build state, and it changed already.
    });
  }

  void _handleDragDown(DragDownDetails details) {
    if (controller.isLocked()) {
      return;
    }

    // if the drawers are closed when drag start, reset gravity to null
    if (controller.value == controller.lowerBound) {
      controller.innerGravity = null;
    }

    controller.stop();
  }

  void _move(DragUpdateDetails details) {
    if (controller.isLocked()) {
      return;
    }

    if (controller.innerGravity == null) {
      // the direction of the first movement determines which drawer to open
      final gravity = details.delta.dx < 0 ? DrawerGravity.right: DrawerGravity.left;

      // check whether the drawer is existed or not.
      if ((gravity == DrawerGravity.left && widget.leftDrawer == null)
          || (gravity == DrawerGravity.right && widget.rightDrawer == null)) {
        return;
      }

      controller.innerGravity = gravity;
    }

    double delta = details.delta.dx / _drawerWidth!;
    // for the right drawer, slide to the left means opening the drawer. Thus,
    // the delta should be reverse.
    if (controller.innerGravity == DrawerGravity.right) {
      delta = -delta;
    }

    controller.value += delta;
  }

  void _settle({DragEndDetails? details}) {
    if (controller.isLocked()) {
      return;
    }

    if (controller.value == controller.lowerBound
      || controller.value == controller.upperBound) {
      return;
    }

    // if sliding velocity is very fast, open or close the drawer directly.
    if (details != null && details.velocity.pixelsPerSecond.dx.abs() >= _minFlingVelocity) {
      double visualVelocity = (details.velocity.pixelsPerSecond.dx) / _drawerWidth!;

      // for the right drawer, slide to the left means opening the drawer. Thus,
      // the delta should be reverse.
      if (controller.innerGravity == DrawerGravity.right) {
        visualVelocity = -visualVelocity;
      }

      controller.fling(velocity: visualVelocity);
    } else if (controller.value > (controller.upperBound - controller.lowerBound) / 2) {
      controller.openDrawer(controller.innerGravity!);
    } else {
      controller.closeDrawer();
    }
  }

  /// Calculate the content width and drawer width
  void _calculateWidth(BoxConstraints constraints) {
    _contentWidth = constraints.maxWidth;

    if (widget.drawerWidthOffset != null) {
      _drawerWidth = _contentWidth! - widget.drawerWidthOffset!;
      _drawerWidth = (_drawerWidth! < 0) ? 0 : _drawerWidth;
    } else {
      _drawerWidth = _contentWidth! * widget.drawerWidthFactor;
    }
  }

  /// Build the content and drawer widgets.
  /// The content widget and the drawer widgets are layout in a Stack widget, and the
  /// content widget is upper to the drawer widgets. When the value of [controller]
  /// is changed, the position of the content widget is changed synchronously with a [Align]
  /// widget in order to show the drawer.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _calculateWidth(constraints);

        return Container(
          child: Stack(
            children: <Widget>[
              FocusScope(
                node: _focusScopeNode,
                child: Align(
                  alignment: controller.innerGravity == DrawerGravity.left ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: _drawerWidth,
                    child: GestureDetector(
                      onHorizontalDragUpdate: _move,
                      onHorizontalDragEnd: (details) { _settle(details: details); },
                      onHorizontalDragCancel: _settle,
                      child: NotificationListener(
                        onNotification: (notification) {
                          if (notification is ScrollStartNotification) {
                          }
                          if (notification is OverscrollNotification) {
                            if (notification.dragDetails != null) {
                              _move(notification.dragDetails!);
                            }
                          }
                          if (notification is ScrollEndNotification) {
                              _settle(details: notification.dragDetails);
                          }
                          return true;
                        },
                        child: controller.innerGravity == DrawerGravity.left ? widget.leftDrawer! : widget.rightDrawer!,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.value == controller.upperBound ? controller.closeDrawer : null,
                onHorizontalDragDown: _handleDragDown,
                onHorizontalDragUpdate: _move,
                onHorizontalDragEnd: (details) { _settle(details: details); },
                onHorizontalDragCancel: _settle,
                excludeFromSemantics: true,
                child: RepaintBoundary(
                  child: Align(
                    alignment: controller.innerGravity == DrawerGravity.left ? Alignment.centerRight : Alignment.centerLeft,
                    child: Align(
                      widthFactor: (_contentWidth! - _drawerWidth! * controller.value) / _contentWidth!,
                      alignment: controller.innerGravity == DrawerGravity.left ? Alignment.centerLeft : Alignment.centerRight,
                      child: RepaintBoundary(
                          child: Stack(
                            children: [
                              NotificationListener(
                                  onNotification: (notification) {
                                    if (notification is ScrollStartNotification) {
                                    }
                                    if (notification is OverscrollNotification) {
                                      if (notification.dragDetails != null) {
                                        _move(notification.dragDetails!);
                                      }
                                    }
                                    if (notification is ScrollEndNotification) {
                                      _settle(details: notification.dragDetails);
                                    }
                                    return true;
                                  },
                                  child: widget.content
                              ),
                              if (controller.value > controller.lowerBound)
                                Container(
                                  color: _scrimColorTween.evaluate(controller),
                                ),
                            ]
                          )
                      )
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
  
  @override
  void dispose() {
    controller.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }
}