import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pet_center_app/screens/login_register.dart';
import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_lock.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/app_theme.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  runApp(const PetCenterApp());
}

class PetCenterApp extends StatelessWidget {
  const PetCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLock(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pet Center',
        scaffoldMessengerKey: rootScaffoldKey,
        navigatorKey: navigatorKey,

        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final Size size = constraints.biggest.isFinite
                  ? constraints.biggest
                  : MediaQuery.sizeOf(context);

              final WindowClass windowClass = Breakpoints.of(size.width);
              final ThemeData base = buildAppTheme(windowClass);

              final theme = base.copyWith(
                extensions: [
                  ReactiveDesignSystem.fromSize(size, base.colorScheme),
                ],
              );

              return Theme(data: theme, child: child!);
            },
          );
        },

        home: const CredentialsScreen(),
      ),
    );
  }
}
