import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/screens/dashboard.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/static_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({super.key});
  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  String contact = '';
  String password = '';
  bool businessPurposes = false;
  bool registerMode = false;
  bool unverified = false;
  int verificationCode = 0;

  void _toggleBusiness() {
    setState(() {
      businessPurposes = !businessPurposes;
    });
  }

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
      });
    }
  }

  void _linkForgotPassword() async {
    if (contact.isNotEmpty) {
      final output = await AccountService.forgotPassword(contact);
      if (output != null && output.isNotEmpty) {
        showSnackbar(output);
      }
    } else {
      showSnackbar("Please provide the contact in the appropriate field.");
    }
  }

  void onLogin() async {
    await StaticDataService.updateStaticData();

    if (self == null) {
      return;
    }

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
            business: businessPurposes,
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
          AccountRequestDTO(contact: contact.trim(), password: password.trim()),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            unverified
                                ? "Account verification"
                                : registerMode
                                ? 'Register'
                                : 'Login',
                            style: TextStyle(fontSize: design.fontSize * 2),
                          ),

                          const Spacer(flex: 1),

                          SizedBox(height: design.spacing),

                          if (!unverified) ...[
                            TextField(
                              key: const ValueKey('contact'),
                              decoration: InputDecoration(labelText: 'Contact'),

                              onChanged: (v) => contact = v,
                            ),
                            SizedBox(height: design.spacing),
                            TextField(
                              key: const ValueKey('pwd'),
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),

                              obscureText: true,
                              onChanged: (v) => password = v,
                            ),

                            if (registerMode) ...[
                              SizedBox(height: design.spacing),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: businessPurposes,
                                    onChanged: (_) => _toggleBusiness(),
                                  ),
                                  Text('Business account'),
                                ],
                              ),
                            ] else ...[
                              const Spacer(flex: 1),
                              TextButton(
                                onPressed: _linkForgotPassword,
                                child: Text('Forgot password?'),
                              ),
                            ],
                          ] else ...[
                            TextField(
                              key: const ValueKey('code'),
                              decoration: InputDecoration(
                                labelText: 'Verification Code',
                              ),

                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  verificationCode = int.tryParse(v) ?? 0,
                            ),
                          ],

                          const Spacer(flex: 2),

                          SizedBox(height: design.spacing),

                          ElevatedButton(
                            onPressed: _sendRequest,
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
                            child: Text(
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
