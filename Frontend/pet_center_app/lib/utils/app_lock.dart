import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:signals/signals_flutter.dart';

class AppLock extends StatelessWidget {
  final Widget child;

  const AppLock({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final locked = apiServiceBusy.value;

      return AbsorbPointer(absorbing: locked, child: child);
    });
  }
}
