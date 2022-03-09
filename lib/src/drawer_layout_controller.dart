/*
 * The controller for [DrawerLayout]
 */

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// The gravity of the drawer, which is used to indicate the current drawer.
enum DrawerGravity {
  left,
  right,
}

enum DrawerLockMode {
  left,
  right,
  unlock
}

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

  /// Indicate which drawer is opening or opened, null means all drawers are closed
  /// This is only used in the package
  @internal
  DrawerGravity? innerGravity;

  /// Indicate which drawer is opening or opened, null means all drawers are closed
  /// This is only provided for users.
  DrawerGravity? get gravity => innerGravity;

  late DrawerLockMode _lockMode;
  set lockMode(DrawerLockMode lockMode) {
    if (_lockMode == lockMode) {
      return;
    }

    _lockMode = lockMode;
    _notifyLockMode();
  }
  DrawerLockMode get lockMode => _lockMode;
  bool isLocked() => _lockMode == DrawerLockMode.left
      || _lockMode == DrawerLockMode.right;
  void _notifyLockMode() {
    if (_lockMode == DrawerLockMode.left) {
      innerGravity = DrawerGravity.left;
      value = 1;
    } else if (_lockMode == DrawerLockMode.right) {
      innerGravity = DrawerGravity.right;
      value = 1;
    }
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
    if (isLocked()) {
      return;
    }

    // if the drawer has been opened, do nothing.
    if (isDrawerOpen(gravity)) {
      return;
    }

    // if the other drawer is opened or opening or closing, close it first
    if (this.innerGravity != null && this.innerGravity != gravity) {
      stop();
      await closeDrawer();
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
  }

  /// Close the current drawer
  ///
  /// @param gravity: The drawer to close. If null, try to close the opened
  ///                 or opening drawer currently.
  Future<void> closeDrawer({bool animate = true}) async {
    if (isLocked()) {
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
    this.innerGravity = null;
  }
}