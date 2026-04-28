import 'package:flutter/material.dart';

/// Pushes [widget] onto the navigator stack using a standard [MaterialPageRoute].
Future<T?> pushView<T>(BuildContext context, Widget widget) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(builder: (_) => widget),
  );
}
