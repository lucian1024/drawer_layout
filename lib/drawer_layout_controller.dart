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

  /// Check whether the drawer is opened or opening, exclude dragging to open since
  /// can not forecast dragging is to open or close drawer.
  bool isDrawerOpen(DrawerGravity gravity, {bool includeOpening = false}) {
    if (this.gravity == gravity) {
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
    if (this.gravity != gravity) {
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

  /// Check whether the drawer is closed or closing, exclude drag to close
  // bool isDrawerClosedEx(DrawerGravity gravity) {
  //   if (this.gravity != gravity || ((!isAnimating && value == lowerBound)
  //       || (isAnimating && status == AnimationStatus.reverse))) {
  //     return true;
  //   }
  //
  //   return false;
  // }

  /// Open the drawer
  Future<void> openDrawer(DrawerGravity gravity, {bool animate = true}) async {
    // if the drawer has been opened, do nothing.
    if (isDrawerOpen(gravity)) {
      return;
    }

    // if the other drawer is opened or opening or closing, close it first
    if (this.gravity != null && this.gravity != gravity) {
      stop();
      await closeDrawer();
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
  Future<void> closeDrawer({bool animate = true}) async {
    if (this.gravity == null) {
      // no drawer is opened or opening
      return;
    }

    // if the drawer has been closed, do nothing.
    if (isDrawerClose(this.gravity!)) {
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
    this.gravity = null;
  }
}