/*
 * The controller for [DrawerLayout]
 */

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// The gravity of the drawer, which is used to indicate the current drawer.
enum DrawerGravity {
  left,
  right,
}

/// Lock mode of the drawer. The drawer can not open or close after it is locked.
enum DrawerLockMode {
  /// lock with current state
  lock,
  /// lock with left drawer opened
  lockLeft,
  /// lock with right drawer opened
  lockRight,
  /// unlock with current state
  unlock
}

/// Callback when the drawer is opened or closed.
///
/// @param gravity: which drawer
/// @param isOpen: true for opened and false for closed
/// @param userScroll: whether is it opened or closed by user scroll
typedef DrawerStatusCallback = void Function(DrawerGravity gravity, bool isOpen, bool userScroll);

/// The value of [DrawerLayoutController] changes from 0 to 1, the drawer changes from
/// closed state to opened state.
class DrawerLayoutController extends AnimationController {
  DrawerLayoutController({
    required TickerProvider vsync,
    this.speed = 1,
    DrawerLockMode lockMode = DrawerLockMode.unlock,
    Duration duration = const Duration(milliseconds: 246),
  }) : super(
    value: 0,
    duration: duration,
    vsync: vsync
  ) {
    _lockMode = lockMode;
    _notifyLockMode();
  }

  /// The speed to open or close the drawer
  final double speed;

  /// The min fling velocity to open or close the drawer directly
  final double _minFlingVelocity = 365.0;

  /// Indicate which drawer is opening or opened, null means all drawers are closed
  /// This is only used in the package
  @internal
  DrawerGravity? innerGravity;

  /// Indicate which drawer is opening or opened, null means all drawers are closed
  /// This is only provided for users.
  DrawerGravity? get gravity => innerGravity;

  /// Drawer status changed callbacks
  final List<DrawerStatusCallback> _drawerStatusListeners = <DrawerStatusCallback>[];

  late DrawerLockMode _lockMode;
  set lockMode(DrawerLockMode lockMode) {
    if (_lockMode == lockMode) {
      return;
    }

    _lockMode = lockMode;
    _notifyLockMode();
  }
  DrawerLockMode get lockMode => _lockMode;
  bool get isLocked => _lockMode == DrawerLockMode.lockLeft
      || _lockMode == DrawerLockMode.lockRight || _lockMode == DrawerLockMode.lock;
  void _notifyLockMode() {
    if (_lockMode == DrawerLockMode.lockLeft) {
      innerGravity = DrawerGravity.left;
      value = 1;
    } else if (_lockMode == DrawerLockMode.lockRight) {
      innerGravity = DrawerGravity.right;
      value = 1;
    }
  }

  /// The width of the drawers.
  double? _drawerWidth;
  double? get drawerWidth => _drawerWidth;
  @internal
  set drawerWidth(double? width) {
    _drawerWidth = width;
  }

  /// Whether has left drawer.
  bool _hasLeftDrawer = false;
  bool get hasLeftDrawer => _hasLeftDrawer;
  @internal
  set hasLeftDrawer(bool hasLeftDrawer) {
    _hasLeftDrawer = hasLeftDrawer;
  }

  /// Whether has right drawer.
  bool _hasRightDrawer = false;
  bool get hasRightDrawer => _hasRightDrawer;
  @internal
  set hasRightDrawer(bool hasRightDrawer) {
    _hasRightDrawer = hasRightDrawer;
  }

  /// Check whether the drawer is opened or opening, exclude dragging to open since
  /// can not forecast dragging is to open or close drawer.
  bool isDrawerOpen(DrawerGravity gravity, {bool includeOpening = false}) {
    if (this.innerGravity == gravity) {
      if (value == upperBound && !isAnimating) {
        // the drawer is opened
        return true;
      }

      if (includeOpening && isAnimating && status == AnimationStatus.forward) {
        // the drawer is opening
        return true;
      }
    }

    return false;
  }

  /// Check whether the drawer is closed or closing, exclude dragging to close since
  /// can not forecast dragging is to open or close drawer.
  bool isDrawerClose(DrawerGravity gravity, {bool includeClosing = false}) {
    if (this.innerGravity != gravity) {
      // the drawer is closed
      return true;
    }

    if (value == lowerBound && !isAnimating) {
      // the drawer is closed
      return true;
    }

    if (includeClosing && isAnimating && status == AnimationStatus.reverse) {
      // the drawer is closing
      return true;
    }

    return false;
  }

  /// Open the drawer
  Future<void> openDrawer(DrawerGravity gravity, {bool animate = true}) async {
    if (isLocked) {
      return;
    }

    // if the drawer has been opened, do nothing.
    if (isDrawerOpen(gravity)) {
      return;
    }

    // if the other drawer is opened or opening or closing, close it first
    if (this.innerGravity != null && this.innerGravity != gravity) {
      stop();
      await innerCloseDrawer(dispatchDrawerStatus: false);
    }

    // if the drawer is closing, stop.
    if (isAnimating) {
      stop();
    }

    this.innerGravity = gravity;
    if (animate) {
      await fling(velocity: speed);
    } else {
      value = 1;
    }

    dispatchDrawerStatusEvent(false);
  }

  Future<void> closeDrawer({bool animate = true}) async {
    await innerCloseDrawer(animate: animate);
  }

  /// Close the current drawer
  ///
  /// @param gravity: The drawer to close. If null, try to close the opened
  ///                 or opening drawer currently.
  @internal
  Future<void> innerCloseDrawer({bool animate = true, bool dispatchDrawerStatus = true, bool userScroll = false}) async {
    if (isLocked) {
      return;
    }

    if (this.innerGravity == null) {
      // no drawer is opened or opening
      return;
    }

    // if the drawer has been closed, do nothing.
    if (isDrawerClose(this.innerGravity!)) {
      return;
    }

    // if the drawer is opening or closing, stop.
    if (isAnimating) {
       stop();
    }

    if (animate) {
      await fling(velocity: -speed);
    } else {
      value = 0;
    }

    if (dispatchDrawerStatus) {
      dispatchDrawerStatusEvent(userScroll);
    }

    this.innerGravity = null;
  }

  @internal
  @override
  set value(double newValue) {
    super.value = newValue;
  }

  void dragStart(DragStartDetails details) {
    if (isLocked) {
      return;
    }

    // if the drawers are closed when drag start, reset gravity to null
    if (value == lowerBound) {
      innerGravity = null;
    }

    stop();
  }

  void dragUpdate(DragUpdateDetails details) {
    if (isLocked) {
      return;
    }

    if (innerGravity == null) {
      // the direction of the first movement determines which drawer to open
      final gravity = details.delta.dx < 0 ? DrawerGravity.right: DrawerGravity.left;

      // check whether the drawer is existed or not.
      if ((gravity == DrawerGravity.left && !_hasLeftDrawer)
          || (gravity == DrawerGravity.right && !_hasRightDrawer)) {
        return;
      }

      innerGravity = gravity;
    }

    double delta = details.delta.dx / drawerWidth!;
    // for the right drawer, slide to the left means opening the drawer. Thus,
    // the delta should be reverse.
    if (innerGravity == DrawerGravity.right) {
      delta = -delta;
    }

    value += delta;
  }

  Future<void> dragEnd(DragEndDetails details) async {
    if (isLocked) {
      return;
    }

    double velocity;
    // if sliding velocity is very fast, open or close the drawer directly.
    if (details.velocity.pixelsPerSecond.dx.abs() >= _minFlingVelocity) {
      double visualVelocity = (details.velocity.pixelsPerSecond.dx) / drawerWidth!;

      // for the right drawer, slide to the left means opening the drawer. Thus,
      // the delta should be reverse.
      if (innerGravity == DrawerGravity.right) {
        visualVelocity = -visualVelocity;
      }

      velocity = visualVelocity;
      fling(velocity: visualVelocity);
    } else if (value > (upperBound - lowerBound) / 2) {
      velocity = speed;
    } else {
      velocity = -speed;
    }

    await fling(velocity: velocity);


    dispatchDrawerStatusEvent(true);

    if (value == lowerBound){
      innerGravity = null;
    }
  }

  void addDrawerStatusListener(DrawerStatusCallback callback) {
    if (!_drawerStatusListeners.contains(callback)) {
      _drawerStatusListeners.add(callback);
    }
  }

  void removeDrawerStatusListener(DrawerStatusCallback callback) {
    _drawerStatusListeners.remove(callback);
  }

  @internal
  void dispatchDrawerStatusEvent(bool userScroll) {
    if (innerGravity == null) {
      return;
    }

    for (final listener in _drawerStatusListeners) {
      listener.call(innerGravity!, value == upperBound, userScroll);
    }
  }

  bool _dispose = false;
  @override
  void dispose() {
    if (_dispose) {
      return;
    }
    _dispose = true;
    super.dispose();
  }
}