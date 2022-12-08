/*
 * According to [DrawerController], implement a widget supports left and right drawer
 * which is similar to Android's DrawerLayout.
 */

import 'package:flutter/material.dart';

import 'drawer_layout_controller.dart';

enum DrawerShowType {
  /// The drawer will push the content when it is shown
  push,
  /// The drawer will over the content when it is shown
  overlay,
}

class DrawerLayout extends StatefulWidget {
  const DrawerLayout({
    required this.content,
    this.leftDrawer,
    this.rightDrawer,
    this.drawerWidthFactor = 0.8,
    this.drawerWidthOffset,
    this.controller,
    this.scrimColor,
    this.drawerEnableOpenDragGesture = true,
    this.showType = DrawerShowType.push,
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

  /// Determines if the [DrawerLayout] can be opened with a drag
  /// gesture.
  ///
  /// By default, the drag gesture is enabled.
  final bool drawerEnableOpenDragGesture;

  /// The show type of the drawer
  /// @see [DrawerShowType]
  ///
  /// By default, the type is [DrawerShowType.push].
  final DrawerShowType showType;

  @override
  DrawerLayoutState createState() => DrawerLayoutState();
}

class DrawerLayoutState extends State<DrawerLayout> with SingleTickerProviderStateMixin {
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
    controller..addListener(_animationChanged)
      ..hasLeftDrawer = (widget.leftDrawer != null)
      ..hasRightDrawer = (widget.rightDrawer != null);

    _scrimColorTween = ColorTween(begin: Colors.transparent, end: widget.scrimColor ?? Colors.black54);
    
    super.initState();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.textDirection = Directionality.of(context);
  }

  @override
  void didUpdateWidget(DrawerLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      controller..hasLeftDrawer = (widget.leftDrawer != null)
        ..hasRightDrawer = (widget.rightDrawer != null);
    }
  }

  /// Refresh with with animation.
  void _animationChanged() {
    setState(() {
      // The animation controller's state is our build state, and it changed already.
    });
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
    controller.drawerWidth = _drawerWidth;
  }

  Widget _getDrawer(DrawerGravity gravity, bool visible) {
    final drawer = RepaintBoundary(
      child: Container(
        width: _drawerWidth,
        child: GestureDetector(
          onHorizontalDragStart: controller.dragStart,
          onHorizontalDragUpdate: controller.dragUpdate,
          onHorizontalDragEnd: controller.dragEnd,
          child: gravity == DrawerGravity.left ? widget.leftDrawer! : widget.rightDrawer!,
        ),
      ),
    );

    return PositionedDirectional(
      start: gravity == DrawerGravity.left ? 0 : null,
      end: gravity == DrawerGravity.right ? 0 : null,
      top: 0,
      bottom: 0,
      child: Visibility(
        visible: visible,
        maintainState: true,
        child: FocusScope(
          node: _focusScopeNode,
          child: widget.showType == DrawerShowType.push ? drawer : Align(
            widthFactor: controller.value,
            alignment: gravity == DrawerGravity.left ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
            child: drawer,
          ),
        ),
      ),
    );
  }

  Widget get content {
    final content = RepaintBoundary(
      child: Stack(
        children: [
          widget.content,
          Visibility(
            visible: controller.value > controller.lowerBound,
            child: Container(
              color: _scrimColorTween.evaluate(controller),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: controller.value == controller.upperBound ? () { controller.innerCloseDrawer(userScroll: true); } : null,
      onHorizontalDragStart: widget.drawerEnableOpenDragGesture ? controller.dragStart : null,
      onHorizontalDragUpdate: widget.drawerEnableOpenDragGesture ? controller.dragUpdate : null,
      onHorizontalDragEnd: widget.drawerEnableOpenDragGesture ? controller.dragEnd : null,
      excludeFromSemantics: true,
      child: widget.showType == DrawerShowType.overlay ? content : RepaintBoundary(
        child: Align(
          alignment: controller.innerGravity == DrawerGravity.left ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: Align(
              widthFactor: (_contentWidth! - _drawerWidth! * controller.value) / _contentWidth!,
              alignment: controller.innerGravity == DrawerGravity.left ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
              child: content,
          ),
        ),
      ),
    );
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

        return Stack(
          children: <Widget>[
            if (widget.leftDrawer != null && widget.showType == DrawerShowType.push)
              _getDrawer(DrawerGravity.left, controller.gravity == DrawerGravity.left),
            if (widget.rightDrawer != null && widget.showType == DrawerShowType.push)
              _getDrawer(DrawerGravity.right, controller.gravity == DrawerGravity.right),
            content,
            if (widget.leftDrawer != null && widget.showType == DrawerShowType.overlay)
              _getDrawer(DrawerGravity.left, controller.gravity == DrawerGravity.left),
            if (widget.rightDrawer != null && widget.showType == DrawerShowType.overlay)
              _getDrawer(DrawerGravity.right, controller.gravity == DrawerGravity.right),
          ],
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