import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_dto.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/form_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class FormEditScreen extends StatefulWidget {
  final String formTemplateId;
  final FormDTO? fromCurrent;
  final void Function(FormDTO updated) callback;

  const FormEditScreen({
    super.key,
    required this.formTemplateId,
    required this.callback,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _FormEditScreenState();
}

class _FormEditScreenState extends State<FormEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageKey = GlobalKey<ImageDisplayState>();
  final TextEditingController _franchiseNameController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  late final FormDTO data;
  late final FormTemplateDTO? template;
  late final Map<String, TextEditingController> _entryControllers;

  void invokeCallback() async {
    data.franchiseName = _franchiseNameController.text;
    data.defaultContact = _contactController.text;

    FormDTO? output;

    if (data.id == null) {
      for (final entry in data.entries) {
        final controller = _entryControllers[entry.formTemplateFieldId];
        if (controller != null) {
          entry.serialized = controller.text;
        }
      }

      if (template != null) {
        final optionalFieldIds = template!.fields
            .where((f) => f.optional && f.id != null)
            .map((f) => f.id!)
            .toSet();

        data.entries.removeWhere(
          (e) =>
              optionalFieldIds.contains(e.formTemplateFieldId) &&
              e.serialized.trim().isEmpty,
        );
      }

      output = await FormService.post(data);

      if (output != null && output.mediaCreationToken != null) {
        await _imageKey.currentState?.createExternally(
          output.mediaCreationToken!,
        );
      }
    } else {
      output = await FormService.put(data, data.id!);
    }

    if (output != null && mounted) {
      Navigator.of(context).pop();
      widget.callback(output);
    }
  }

  @override
  void initState() {
    super.initState();

    template = templates.cast<FormTemplateDTO?>().firstWhere(
      (t) => t?.id == widget.formTemplateId,
      orElse: () => null,
    );

    data =
        widget.fromCurrent?.copy() ??
        FormDTO(formTemplateId: widget.formTemplateId, userId: self?.id ?? '');

    _franchiseNameController.text = data.franchiseName;
    _contactController.text = data.defaultContact;

    _entryControllers = {};

    if (template != null) {
      for (final field in template!.fields) {
        if (field.id == null) continue;

        final existing = data.entries.cast<FormEntrySubDTO?>().firstWhere(
          (e) => e?.formTemplateFieldId == field.id,
          orElse: () => null,
        );

        if (existing == null) {
          data.entries.add(
            FormEntrySubDTO(formId: data.id, formTemplateFieldId: field.id!),
          );
        }

        _entryControllers[field.id!] = TextEditingController(
          text: existing?.serialized ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    _franchiseNameController.dispose();
    _contactController.dispose();
    for (final c in _entryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    if (template == null) {
      return BasicScreenScaffold(
        appBar: AppBar(),
        body: [design.fittedText('Template not found.')],
      );
    }

    return BasicScreenScaffold(
      formKey: _formKey,
      center: true,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            widget.fromCurrent != null ? 'Edit Form:' : 'New Form:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: [
        ImageDisplay(
          key: _imageKey,
          dataSource:
              (widget.fromCurrent != null &&
                  widget.fromCurrent!.media.isNotEmpty)
              ? widget.fromCurrent!.media[0]
              : null,
          creationToken: widget.fromCurrent?.mediaCreationToken,
          locked: widget.fromCurrent?.locked ?? false,
          creating: widget.fromCurrent == null,
          editCallback: (value) {
            if (mounted) {
              setState(() {
                widget.fromCurrent?.media.clear();
                if (value != null) {
                  widget.fromCurrent?.media.add(value);
                }
              });
            }
          },
        ),
        design.verticalGap(design.spacing),
        ColoredBox(
          color: listTone,
          child: TextFormField(
            controller: _franchiseNameController,
            maxLines: 1,
            maxLength: 75,
            minLines: 1,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: "Franchise name..."),
            validator: (value) => validateGeneric(value),
          ),
        ),
        design.verticalGap(design.spacing),
        ColoredBox(
          color: listTone,
          child: TextFormField(
            controller: _contactController,
            maxLines: 1,
            maxLength: 255,
            minLines: 1,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: "Contact..."),
            validator: (value) => validateContact(value),
          ),
        ),
        if (widget.fromCurrent == null) ...[
          ...template!.fields.expand((field) {
            if (field.id == null) return <Widget>[];
            final controller = _entryControllers[field.id!];
            if (controller == null) return <Widget>[];
            return [
              design.verticalGap(design.spacing),
              ColoredBox(
                color: listTone,
                child: TextFormField(
                  controller: controller,
                  maxLines: null,
                  maxLength: 255,
                  minLines: dialogMinLines,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText:
                        "${field.description}${field.optional ? ' (optional)' : ''}",
                  ),
                  validator: field.optional
                      ? null
                      : (value) => validateGeneric(value),
                ),
              ),
            ];
          }),
        ],
      ],
      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate() &&
                      _imageKey.currentState != null &&
                      _imageKey.currentState!.validate()) {
                    invokeCallback();
                  }
                },
                child: design.fittedText('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
