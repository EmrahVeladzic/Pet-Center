import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Access role = userToken?.role ?? Access.user;

  void adoptionScreen() {}

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final bool isLandscape = design.layoutDirection == Axis.horizontal;
    final double hMult = isLandscape ? 0.5 : 1.0;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        title: Text(
          "${(userToken?.username != null) ? userToken?.username : 'PetCenter'}",
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: hMult,
          heightFactor: 1.0,
          child: Container(
            padding: EdgeInsets.all(design.spacing),
            decoration: design.panelDecoration(),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: boxConstraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (role == Access.user) ...[
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: adoptionScreen,
                              child: Text('Adopt a pet'),
                            ),
                          ),
                          SizedBox(height: design.spacing),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Market'),
                            ),
                          ),
                          SizedBox(height: design.spacing),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('My pets'),
                            ),
                          ),
                          SizedBox(height: design.spacing),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Messages'),
                            ),
                          ),
                          SizedBox(height: design.spacing),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('User'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
