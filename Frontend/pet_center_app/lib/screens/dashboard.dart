import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/feed.dart';
import 'package:pet_center_app/screens/franchise_view.dart';
import 'package:pet_center_app/screens/kind_selection.dart';
import 'package:pet_center_app/screens/user_view.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Access role = userToken?.role ?? Access.user;

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            "${(self?.userName != null) ? self?.userName : 'PetCenter'}",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => KindSelectionScreen(),
                                  ),
                                );
                              },
                              child: design.fittedText('Adopt a pet'),
                            ),
                          ),
                          SizedBox(height: design.spacing),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: design.fittedText('Market'),
                            ),
                          ),
                          SizedBox(height: design.spacing),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: design.fittedText('My pets'),
                            ),
                          ),
                        ] else if (role == Access.business) ...[
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FranchiseViewScreen(),
                                  ),
                                );
                              },
                              child: design.fittedText('My workplaces'),
                            ),
                          ),

                          SizedBox(height: design.spacing),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: design.fittedText('My pets'),
                            ),
                          ),
                        ],
                        SizedBox(height: design.spacing),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => FeedScreen()),
                              );
                            },
                            child: design.fittedText('Messages'),
                          ),
                        ),
                        SizedBox(height: design.spacing),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserViewScreen(),
                                ),
                              );
                            },
                            child: design.fittedText('User'),
                          ),
                        ),
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
