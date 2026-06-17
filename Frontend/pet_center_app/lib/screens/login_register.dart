import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/radio_button_component.dart';
import 'package:pet_center_app/screens/dashboard.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

import 'package:pet_center_app/utils/hive_cache.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/validators.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({super.key});
  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  String contact = '';
  String password = '';
  String newPwd = '';
  Access regRole = Access.user;
  bool registerMode = false;
  bool unverified = false;
  bool forgot = false;
  int verificationCode = 0;

  void _linkAction() async {
    if (unverified) {
      final output = await AccountService.requestVerification();
      if (!mounted) {
        return;
      }
      if (output != null) {
        showSnackbar(output);
      }
    } else {
      setState(() {
        registerMode = !registerMode;
        if (registerMode) {
          forgot = false;
          newPwd = '';
        }
      });
    }
  }

  void _linkForgotPassword() async {
    setState(() {
      forgot = !forgot;
      newPwd = '';
    });
    if (contact.isNotEmpty && forgot) {
      final output = await AccountService.forgotPassword(contact);
      if (output != null && output.isNotEmpty) {
        showSnackbar(output);
      }
    } else {
      showSnackbar("Please provide the contact in the appropriate field.");
    }
  }

  void onLogin() async {
    bool valid = await StaticAndUserDataService.updateData();

    if (!valid) {
      return;
    }

    visitedAnnouncementIndices = await CacheManager.getAll(
      CacheEntityType.announcement,
    );

    visitedReportIndices = await CacheManager.getAll(CacheEntityType.report);

    visitedListingIndices = await CacheManager.getAll(CacheEntityType.listing);

    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _sendRequest() async {
    if (!unverified) {
      if (registerMode) {
        final output = await AccountService.register(
          AccountRequestDTO(
            contact: contact,
            password: password,
            role: regRole,
          ),
        );
        if (!mounted) {
          return;
        }
        if (output != null) {
          showSnackbar("Registration successful!");
          setState(() {
            registerMode = false;
          });
        }
      } else {
        final output = await AccountService.logIn(
          AccountRequestDTO(
            contact: contact.trim(),
            password: password.trim(),
            newPassword: newPwd,
          ),
        );
        if (!mounted) {
          return;
        }
        if (output != null) {
          parseJwt(output);
        }
        setState(() {
          if (userToken != null) {
            unverified = !(userToken?.verified ?? false);
          }
        });
        if (!unverified && userToken != null) {
          onLogin();
        }
      }
    } else {
      final output = await AccountService.verify(verificationCode);
      if (!mounted) {
        return;
      }
      if (output != null) {
        rawToken = output;
        parseJwt(rawToken);
        onLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;
    final bool isLandscape = design.layoutDirection == Axis.horizontal;

    final double wMult = isLandscape ? 0.65 : 1.0;
    final double hMult = isLandscape ? 0.6 : 0.75;

    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: wMult,
          heightFactor: hMult,
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
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            design.textMarquee(
                              (unverified
                                  ? "Account verification"
                                  : registerMode
                                  ? 'Register'
                                  : 'Login'),
                              null,
                              1.0,
                              2.0,
                            ),

                            const Spacer(flex: 1),

                            SizedBox(height: design.spacing),

                            if (!unverified) ...[
                              TextFormField(
                                key: const ValueKey('contact'),
                                decoration: InputDecoration(
                                  labelText: 'Contact',
                                ),
                                validator: (value) {
                                  return validateContact(value);
                                },
                                onChanged: (v) => contact = v,
                              ),
                              SizedBox(height: design.spacing),
                              TextFormField(
                                key: const ValueKey('pwd'),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                ),
                                validator: (value) {
                                  return validateGeneric(value);
                                },
                                obscureText: true,
                                onChanged: (v) => password = v,
                              ),

                              if (forgot) ...[
                                SizedBox(height: design.spacing),
                                TextFormField(
                                  key: const ValueKey('newPwd'),
                                  decoration: InputDecoration(
                                    labelText: 'New password',
                                  ),
                                  validator: (value) {
                                    return validatePassword(value);
                                  },
                                  obscureText: true,
                                  onChanged: (v) => newPwd = v,
                                ),
                              ],

                              if (registerMode) ...[
                                SizedBox(height: design.spacing),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    design.fittedText('Role:'),
                                    RadioButtonComponent<Access>(
                                      groupValue: regRole,
                                      onChanged: (value) {
                                        if (value == null) {
                                          return;
                                        }
                                        setState(() {
                                          regRole = value;
                                        });
                                      },
                                      options: [
                                        RadioOption<Access>(
                                          value: Access.user,
                                          label: "End user",
                                        ),
                                        RadioOption<Access>(
                                          value: Access.business,
                                          label: "Employee",
                                        ),
                                        RadioOption<Access>(
                                          value: Access.admin,
                                          label: "Administrator",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const Spacer(flex: 1),
                                TextButton(
                                  onPressed: _linkForgotPassword,
                                  child: forgot
                                      ? design.fittedText(
                                          'Remembered password?',
                                        )
                                      : design.fittedText('Forgot password?'),
                                ),
                              ],
                            ] else ...[
                              TextFormField(
                                key: const ValueKey('code'),
                                decoration: InputDecoration(
                                  labelText: 'Verification Code',
                                ),

                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    verificationCode = int.tryParse(v) ?? 0,

                                validator: (value) => validateNumeric(value),
                              ),
                            ],

                            const Spacer(flex: 2),

                            SizedBox(height: design.spacing),

                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState != null &&
                                    _formKey.currentState!.validate()) {
                                  _sendRequest();
                                }
                              },
                              child: design.fittedText(
                                unverified
                                    ? "Verify"
                                    : registerMode
                                    ? 'Register'
                                    : 'Login',
                              ),
                            ),

                            SizedBox(height: design.spacing),

                            TextButton(
                              onPressed: _linkAction,
                              child: design.fittedText(
                                unverified
                                    ? "Send a new code."
                                    : registerMode
                                    ? 'Already have an account? Login'
                                    : 'No account? Register',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
