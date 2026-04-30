import 'package:flutter/material.dart';
import 'package:pet_center_app/providers/app_state.dart';
import 'package:pet_center_app/screens/login_register.dart';
import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: PetCenterApp()),
  );
}

class PetCenterApp extends StatelessWidget {
  const PetCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Center',
      scaffoldMessengerKey: rootScaffoldKey,

      builder: (context, child) {
        final media = MediaQuery.of(context);
        final design = ReactiveDesignSystem.fromMediaQuery(media);

        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: mainTone),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: secondaryTone,
            titleTextStyle: TextStyle(
              fontSize: design.fontSize * 1.25,
              color: panelTone,
            ),
            iconTheme: IconThemeData(color: panelTone),
          ),
          bottomAppBarTheme: BottomAppBarThemeData(color: secondaryTone),
          scaffoldBackgroundColor: mainTone,
          textTheme: TextTheme(
            bodyMedium: TextStyle(fontSize: design.fontSize, color: mainTone),
          ),
          tabBarTheme: TabBarThemeData(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: tabTone),
            labelColor: panelTone,
            unselectedLabelColor: mainTone,
          ),

          extensions: [ReactiveDesignSystem.fromMediaQuery(media)],
        );

        return Theme(data: theme, child: child!);
      },

      home: const CredentialsScreen(),
    );
  }
}
