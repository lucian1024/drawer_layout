/*
 * The controller for [DrawerLayout]
 */

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// The gravity of the drawer, which is used to indicate the current drawer.
enum DrawerGravity {
  left,
  right,
}

/// The value of [DrawerLayoutController] changes from 0 to 1, the drawer changes from
/// closed state to opened state.
class DrawerLayoutController extends AnimationController {
  DrawerLayoutController({
    required TickerProvider vsync,
    this.speed = 1,
    Duration duration = const Duration(milliseconds: 246),
  }) : super(
    value: 0,
    duration: duration,
    vsync: vsync
  );

  /// The speed to open or close the drawer
  final double speed;

  /// Indicate which drawer is opening or opened, null means all drawers are closed
  DrawerGravity? gravity;

  /// Check whether the drawer is opened
  bool isDrawerOpen(DrawerGravity gravity) {
    if (this.gravity == gravity && value == upperBound && !isAnimating) {
      return true;
    }

    return false;
  }

  /// Check whether the drawer is opened or opening
  bool isDrawerOpenEx(DrawerGravity gravity) {
    if (this.gravity == gravity && ((!isAnimating && value == upperBound)
        || (isAnimating && status == AnimationStatus.forward))) {
      return true;
    }

    return false;
  }

  /// Check whether the drawer is closed
  bool isDrawerClosed(DrawerGravity gravity) => this.gravity == null;

  /// Check whether the drawer is closed or closing
  bool isDrawerClosedEx(DrawerGravity gravity) {
    if (this.gravity == null || (this.gravity == gravity
        && isAnimating && status == AnimationStatus.reverse)) {
      return true;
    }

    return false;
  }

  /// Open the drawer
  Future<void> openDrawer(DrawerGravity gravity, {bool animate = true}) async {
    // if the drawer has been opened or is opening, do nothing.
    if (isDrawerOpenEx(gravity)) {
      return;
    }

    // if the drawer is closing, stop.
    if (isAnimating) {
      stop();
    }

    this.gravity = gravity;
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
  Future<void> closeDrawer(DrawerGravity gravity, {bool animate = true}) async {
    // if the drawer has been closed or is closing, do nothing.
    if (isDrawerClosedEx(gravity)) {
      return;
    }

    // if the drawer is opening, stop.
    if (isAnimating) {
       stop();
    }

    if (animate) {
      await fling(velocity: -speed);
    } else {
      value = 0;
    }
  }
}