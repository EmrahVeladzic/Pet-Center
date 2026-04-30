import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/feed.dart';
import 'package:pet_center_app/services/static_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class UserViewScreen extends StatefulWidget {
  const UserViewScreen({super.key});
  @override
  State<StatefulWidget> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  Access role = userToken?.role ?? Access.user;

  void adoptionScreen() {}

  void feedScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FeedScreen()));
  }

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
            "${(self?.userName != null) ? self?.userName : 'User details'}",
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
                      children: [],
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
