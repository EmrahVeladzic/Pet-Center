import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';

import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

class FormFilters extends StatefulWidget
    with FilterTemplate
    implements PreferredSizeWidget {
  final String? initTemplateId;

  final void Function(String?) callback;

  const FormFilters({super.key, this.initTemplateId, required this.callback});

  @override
  Size get preferredSize => const Size.fromHeight(double.infinity);

  @override
  State<StatefulWidget> createState() => _FormFiltersState();
}

class _FormFiltersState extends State<FormFilters> {
  late String? templateId;
  late bool isNull;

  void change(String? id) {
    if (!mounted) {
      return;
    }
    setState(() {
      templateId = id;
      isNull = id == null;
    });
    widget.callback(id);
  }

  @override
  void initState() {
    super.initState();

    templateId = widget.initTemplateId;
    isNull = templateId == null;
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(color: filterTone),
        padding: EdgeInsets.symmetric(horizontal: design.spacing),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      if (templates.isNotEmpty) ...[
                        if (templateId != null) ...[
                          Expanded(
                            flex: 3,
                            child: templateWidget(design.dropdownW, templates, (
                              value,
                            ) {
                              if (value != null) {
                                setState(() {
                                  templateId = value.id;
                                });
                                widget.callback(templateId);
                              }
                            }),
                          ),
                          Expanded(
                            flex: 1,
                            child: design.horizontalGap(design.spacing / 2),
                          ),
                        ],

                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              design.fittedText("Filter by template"),
                              Checkbox(
                                value: !isNull,
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    isNull = !value;
                                    templateId = isNull
                                        ? null
                                        : templates.firstOrNull?.id;
                                  });
                                  widget.callback(templateId);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
