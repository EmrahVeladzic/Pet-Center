import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_request_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/dual_text_entry_dialog.dart';
import 'package:pet_center_app/screens/components/password_change_dialog.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/login_register.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/services/user_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/hive_cache.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/validators.dart';

class UserViewScreen extends StatefulWidget {
  const UserViewScreen({super.key});
  @override
  State<StatefulWidget> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  void logOut() async {
    await AccountService.logOut();
    clearToken();
    StaticAndUserDataService.clearObtainedData();
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

  void transferAccount(String oldCode, String newCode) async {
    int? oldC = int.tryParse(oldCode);
    int? newC = int.tryParse(newCode);

    if (oldC == null || newC == null) {
      showSnackbar("Please make sure both codes are valid.");
      return;
    }
    final response = await AccountService.transferAccount(oldC, newC);
    if (response != null) {
      showSnackbar(response);
    }
  }

  void requestNewCodes() async {
    final response = await AccountService.requestTransfer();
    if (response != null) {
      showSnackbar(response);
    }
  }

  void setupAccountTransfer(String contact) async {
    final response = await AccountService.update(
      AccountRequestDTO(contact: contact),
    );
    if (response != null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => DualTextEntryDialog(
            callback: (oldCode, newCode) {
              transferAccount(oldCode, newCode);
            },
            dialogName: "Enter your transfer codes:",
            linkCallback: requestNewCodes,
            linkName: "Send new codes.",
            firstDecor: "First code...",
            secondDecor: "Second code...",
            sharedValidation: (value) => validateNumeric(value),
          ),
        );
      }
    }
  }

  void changePassword(String pwd, String newPwd) async {
    final response = await AccountService.update(
      AccountRequestDTO(password: pwd, newPassword: newPwd),
    );
    if (response != null) {
      showSnackbar("Updated password.");
    }
  }

  void clearCache() async {
    await CacheManager.clear();

    visitedAnnouncementIndices.clear();
    visitedReportIndices.clear();
    visitedListingIndices.clear();
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

    final success = await AccountService.delete(id);
    if (success) {
      logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      center: true,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            "${(self?.userName != null) ? self?.userName : 'User details'}",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: [
        design.textMarquee(
          "Account details:",
          design.bodyWMult * design.screenWidth,
          1.0,
          1.5,
        ),
        design.verticalGap(design.spacing),
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
                  inputDecoration: "Username...",
                  validation: (value) => validateGeneric(value),
                ),
              );
            },
            child: design.fittedText('Change username'),
          ),
        ),
        design.verticalGap(design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => PasswordChangeDialog(
                  callback: (value, confirm) {
                    changePassword(value, confirm);
                  },
                ),
              );
            },
            child: design.fittedText('Change password'),
          ),
        ),
        design.verticalGap(design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TextEntryDialog(
                  callback: (value) {
                    setupAccountTransfer(value);
                  },
                  dialogName: "Enter new contact:",
                  inputDecoration: "Contact...",
                  validation: (value) => validateContact(value),
                ),
              );
            },
            child: design.fittedText('Transfer account'),
          ),
        ),
        design.verticalGap(design.spacing),
        design.textMarquee(
          "Session and cache:",
          design.bodyWMult * design.screenWidth,
          1.0,
          1.5,
        ),
        design.verticalGap(design.spacing),
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
            child: design.fittedText('Log out'),
          ),
        ),
        design.verticalGap(design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ConfirmationDialog(
                  confirmAction: clearCache,
                  title: "Clear user cache",
                  body: "Are you sure you wish to clear your cache?",
                ),
              );
            },
            child: design.fittedText('Clear cache'),
          ),
        ),
        design.verticalGap(design.spacing),
        design.textMarquee(
          "Advanced:",
          design.bodyWMult * design.screenWidth,
          1.0,
          1.5,
        ),
        design.verticalGap(design.spacing),
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
                  body: "Are you sure you wish to reset your profile?",
                ),
              );
            },
            child: design.fittedText('Wipe user data'),
          ),
        ),
        design.verticalGap(design.spacing),
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
                  body: "Are you sure you wish to deactivate your account?",
                ),
              );
            },
            child: design.fittedText('Delete account'),
          ),
        ),
      ],
    );
  }
}
