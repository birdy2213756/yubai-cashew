import 'package:flutter/material.dart';

/// Run once after this route has entered, rather than opening another route
/// while its container transform is still resizing. The owner cancels on dispose.
VoidCallback afterRouteTransition(BuildContext context, VoidCallback callback) {
  bool cancelled = false;
  Animation<double>? animation;
  late AnimationStatusListener listener;

  void cancel() {
    cancelled = true;
    animation?.removeStatusListener(listener);
    animation = null;
  }

  void run() {
    if (cancelled || !context.mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    cancel();
    callback();
  }

  listener = (status) {
    if (status == AnimationStatus.completed) {
      animation?.removeStatusListener(listener);
      animation = null;
      // OpenContainer reparents its content when the animation completes.
      // Wait until that frame is committed before pushing the input sheet.
      WidgetsBinding.instance.addPostFrameCallback((_) => run());
      WidgetsBinding.instance.ensureVisualUpdate();
    } else if (status == AnimationStatus.dismissed) {
      cancel();
    }
  };

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (cancelled || !context.mounted) return;
    animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation!.status == AnimationStatus.completed) {
      run();
    } else {
      animation!.addStatusListener(listener);
    }
  });
  return cancel;
}
