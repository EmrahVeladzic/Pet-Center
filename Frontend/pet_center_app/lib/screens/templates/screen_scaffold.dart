import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/page_header.dart';
import 'package:pet_center_app/screens/components/shell/app_shell.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

class BasicScreenScaffold extends StatelessWidget {
  final bool center;
  final List<Widget> body;
  final AppBar? appBar;
  final BottomAppBar? bottomNavigationBar;
  final GlobalKey<FormState>? formKey;
  final String? title;
  final String? description;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  const BasicScreenScaffold({
    super.key,
    this.center = false,
    this.body = const [],
    this.appBar,
    this.bottomNavigationBar,
    this.formKey,
    this.title,
    this.description,
    this.actions = const [],
    this.floatingActionButton,
  });

  static Widget? shellLeading(BuildContext context) {
    final shell = AppShellScope.maybeOf(context);
    if (shell == null || !shell.showsDrawerButton) return null;
    if (ModalRoute.of(context)?.isFirst != true) return null;
    return IconButton(
      tooltip: 'Open navigation menu',
      icon: const Icon(Icons.menu),
      onPressed: shell.openDrawer,
    );
  }

  PreferredSizeWidget _appBar(
    BuildContext context,
    ReactiveDesignSystem design,
  ) {
    final leading = shellLeading(context);
    final provided = appBar;

    if (provided != null) {
      return AppBar(
        leading: provided.leading ?? leading,
        automaticallyImplyLeading: provided.automaticallyImplyLeading,
        title: provided.title,
        actions: provided.actions,
        bottom: provided.bottom,
        backgroundColor: provided.backgroundColor,
        foregroundColor: provided.foregroundColor,
        elevation: provided.elevation,
      );
    }

    return AppBar(leading: leading, title: null, actions: actions);
  }

  @override
  Widget build(BuildContext context) {
    final design = context.design;
    final gutter = Spacing.gutter.resolve(design.windowClass);
    final maxWidth = center
        ? Breakpoints.maxFormWidth
        : Breakpoints.maxContentWidth;

    final showHeader = title != null;

    return Scaffold(
      appBar: _appBar(context, design),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: gutter,
                vertical: design.isShort ? Spacing.sm : gutter,
              ),
              child: Form(
                key: formKey,
                child: CustomScrollView(
                  slivers: [
                    if (showHeader)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: gutter),
                          child: PageHeader(
                            title: title!,
                            description: description,
                            actions: actions,
                          ),
                        ),
                      ),
                    if (center)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: body,
                        ),
                      )
                    else
                      SliverList(delegate: SliverChildListDelegate(body)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
