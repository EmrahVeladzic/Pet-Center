import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_request_dto.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

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

  void _toggleBusiness() {
    setState(() {
      businessPurposes = !businessPurposes;
    });
  }

  void _toggleMode() {
    setState(() {
      registerMode = !registerMode;
    });
  }

  void _sendRequest() async {
    if (registerMode) {
    } else {
      await AccountService.logIn(
        AccountRequestDTO(contact: contact, password: password),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<ReactiveDesignSystem>()!;
    final isLandscape = design.layoutDirection == Axis.horizontal;

    final wMult = isLandscape ? 0.65 : 1.0;
    final hMult = isLandscape ? 0.6 : 0.75;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 60, 50, 75),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: wMult,
          heightFactor: hMult,
          child: Container(
            padding: EdgeInsets.all(design.spacing),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: design.spacing, color: Colors.black26),
              ],
            ),
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
                            registerMode ? 'Register' : 'Login',
                            style: TextStyle(fontSize: design.fontSize * 2),
                          ),

                          const Spacer(flex: 1),

                          SizedBox(height: design.spacing),

                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Contact',
                              labelStyle: TextStyle(fontSize: design.fontSize),
                            ),
                            style: TextStyle(fontSize: design.fontSize),
                            onChanged: (v) => contact = v,
                          ),
                          SizedBox(height: design.spacing),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(fontSize: design.fontSize),
                            ),
                            style: TextStyle(fontSize: design.fontSize),
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
                                Text(
                                  'Business account',
                                  style: TextStyle(fontSize: design.fontSize),
                                ),
                              ],
                            ),
                          ],
                          const Spacer(flex: 2),

                          SizedBox(height: design.spacing),

                          ElevatedButton(
                            onPressed: _sendRequest,
                            child: Text(
                              registerMode ? 'Register' : 'Login',
                              style: TextStyle(fontSize: design.fontSize),
                            ),
                          ),

                          SizedBox(height: design.spacing),

                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              registerMode
                                  ? 'Already have an account? Login'
                                  : 'No account? Register',
                              style: TextStyle(fontSize: design.fontSize),
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
