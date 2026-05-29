import 'package:flutter/material.dart';
import 'package:signals/signals_core.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldKey =
    GlobalKey<ScaffoldMessengerState>();

final apiServiceBusy = signal<bool>(false);
