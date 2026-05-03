import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_request_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/login_register.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/static_data_service.dart';
import 'package:pet_center_app/services/user_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/hive_cache.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class UserViewScreen extends StatefulWidget {
  const UserViewScreen({super.key});
  @override
  State<StatefulWidget> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  void logOut() async {
    await AccountService.logOut();
    clearToken();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => CredentialsScreen()),
        (route) => false,
      );
    }
  }

  void changeUsername(String usr) async {
    final response = await UserService.update(UserRequestDTO(userName: usr));
    if (response != null) {
      setState(() {
        self?.userName = response.userName;
      });
    }
  }

  void changePassword(String pwd) async {
    final response = await AccountService.update(
      AccountRequestDTO(password: pwd),
    );
    if (response != null) {
      showSnackbar("Updated password.");
    }
  }

  void clearCache() async {
    await CacheManager.clear();
  }

  void resetUser() async {
    final response = await UserService.reset();

    if (mounted && response) {
      logOut();
    }
  }

  void deleteAccount() async {
    final id = self?.id;

    if (id == null) return;

    await AccountService.delete(id);

    if (!mounted) return;

    logOut();
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
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => TextEntryDialog(
                                  callback: (value) {
                                    changeUsername(value);
                                  },
                                  dialogName: "Enter new username:",
                                ),
                              );
                            },
                            child: design.textMarquee('Change username'),
                          ),
                        ),
                        SizedBox(height: design.spacing),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => TextEntryDialog(
                                  callback: (value) {
                                    changePassword(value);
                                  },
                                  hideText: true,
                                  dialogName: "Enter password:",
                                ),
                              );
                            },
                            child: design.textMarquee('Change password'),
                          ),
                        ),
                        SizedBox(height: design.spacing),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmationDialog(
                                  confirmAction: logOut,
                                  title: "Log out",
                                  body: "Are you sure you wish to log out?",
                                ),
                              );
                            },
                            child: design.textMarquee('Log out'),
                          ),
                        ),
                        SizedBox(height: design.spacing),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmationDialog(
                                  confirmAction: clearCache,
                                  title: "Clear cache",
                                  body:
                                      "Are you sure you wish to clear your cache?",
                                ),
                              );
                            },
                            child: design.textMarquee(
                              'Clear cache for this user',
                            ),
                          ),
                        ),
                        SizedBox(height: design.spacing),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmationDialog(
                                  confirmAction: resetUser,
                                  title: "Reset",
                                  body:
                                      "Are you sure you wish to reset your profile?",
                                ),
                              );
                            },
                            child: design.textMarquee('Clear user data'),
                          ),
                        ),
                        SizedBox(height: design.spacing),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmationDialog(
                                  confirmAction: deleteAccount,
                                  title: "Deactivate account",
                                  body:
                                      "Are you sure you wish to deactivate your account?",
                                ),
                              );
                            },
                            child: design.textMarquee('Delete account'),
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
