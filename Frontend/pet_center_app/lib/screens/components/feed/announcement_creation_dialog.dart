import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/services/user_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class AnnouncementCreationDialog extends StatefulWidget {
  final VoidCallback callback;

  const AnnouncementCreationDialog({super.key, required this.callback});

  @override
  State<StatefulWidget> createState() => _AnnouncementCreationDialogState();
}

class _AnnouncementCreationDialogState
    extends State<AnnouncementCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool userVisible = false;
  bool employeeVisible = false;
  int days = 7;

  void post() async {
    final output = await UserService.addAnnouncement(
      _controller.text,
      userVisible,
      employeeVisible,
      days,
    );

    if (output != null && mounted) {
      setState(() {
        announcements.add(output);
      });
      widget.callback();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Form(
        key: _formKey,
        child: AlertDialog(
          title: Row(
            children: [
              Expanded(child: design.textMarquee('Enter:')),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: design.dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _controller,
                      maxLines: 1,
                      maxLength: 75,
                      minLines: 1,
                      keyboardType: TextInputType.text,

                      decoration: InputDecoration(labelText: "Message..."),
                      validator: (value) {
                        return validateGeneric(value);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: userVisible,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            userVisible = value;
                          });
                        },
                      ),
                      design.fittedText('User visible'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: employeeVisible,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            employeeVisible = value;
                          });
                        },
                      ),
                      design.fittedText('Business visible'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [design.fittedText("Visible for $days days.")],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: mainTone),
                        onPressed: () => setState(() {
                          if (days > 1) {
                            days--;
                          }
                        }),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: mainTone),
                        onPressed: () => setState(() {
                          if (days < 31) {
                            days++;
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  post();
                }
              },
              child: design.fittedText('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
