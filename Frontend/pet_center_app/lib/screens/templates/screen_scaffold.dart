import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';

class BasicScreenScaffold extends StatelessWidget {
  final bool center;
  final List<Widget> body;
  final AppBar? appBar;
  final BottomAppBar? bottomNavigationBar;
  final GlobalKey<FormState>? formKey;

  const BasicScreenScaffold({
    super.key,
    this.center = false,
    this.body = const [],
    this.appBar,
    this.bottomNavigationBar,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: appBar ?? AppBar(),
      body: Center(
        child: Form(
          key: formKey,
          child: FractionallySizedBox(
            widthFactor: design.bodyWMult,
            heightFactor: 1.0,
            child: Container(
              decoration: design.panelDecoration(),

              child: center
                  ? Padding(
                      padding: EdgeInsets.all(design.spacing),
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
                                children: body,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : ListView(children: body),
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar ?? BottomAppBar(),
    );
  }
}
