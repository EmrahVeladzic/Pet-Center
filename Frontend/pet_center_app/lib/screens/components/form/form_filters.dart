import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/screens/components/filter_bar.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

class FormFilters extends StatefulWidget
    with FilterTemplate
    implements PreferredSizeWidget {
  final String? initTemplateId;
  final bool initEval;

  final void Function(String?, bool) callback;

  const FormFilters({
    super.key,
    this.initTemplateId,
    required this.initEval,
    required this.callback,
  });

  @override
  Size get preferredSize => const Size.fromHeight(double.infinity);

  @override
  State<StatefulWidget> createState() => _FormFiltersState();
}

class _FormFiltersState extends State<FormFilters> {
  late String? templateId;
  late bool eval;

  bool get filterByTemplate => templateId != null;

  @override
  void initState() {
    super.initState();
    eval = widget.initEval;
    templateId = widget.initTemplateId;
  }

  void change(String? id, bool e) {
    if (!mounted) {
      return;
    }
    setState(() {
      eval = e;
      templateId = id;
    });
    widget.callback(id, e);
  }

  @override
  Widget build(BuildContext context) {
    final templateField = DropdownMenu<FormTemplateDTO>(
      key: ValueKey<String?>(templateId),
      enabled: filterByTemplate,
      expandedInsets: EdgeInsets.zero,
      enableFilter: true,
      requestFocusOnTap: false,
      label: const Text('Template'),
      initialSelection: templates.where((t) => t.id == templateId).firstOrNull,
      onSelected: (value) {
        if (value != null) {
          change(value.id, eval);
        }
      },
      dropdownMenuEntries: templates
          .map(
            (dto) => DropdownMenuEntry<FormTemplateDTO>(
              value: dto,
              label: dto.description,
            ),
          )
          .toList(),
    );

    return FilterBar(
      children: [
        FilterField(minWidth: 220, maxWidth: 320, child: templateField),
        FilterToggle(
          label: 'Filter by template',
          value: filterByTemplate,
          onChanged: (value) {
            change(value ? templates.firstOrNull?.id : null, eval);
          },
        ),
        FilterToggle(
          label: 'Show evaluated',
          value: eval,
          onChanged: (value) => change(templateId, value),
        ),
      ],
    );
  }
}
