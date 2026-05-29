import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/screens/components/normalized_input.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/breed_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class BreedEditScreen extends StatefulWidget {
  final String kindId;
  final BreedDTO? fromCurrent;
  final VoidCallback callback;

  const BreedEditScreen({
    super.key,
    required this.kindId,
    required this.callback,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _BreedEditScreenState();
}

class _BreedEditScreenState extends State<BreedEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageKey = GlobalKey<ImageDisplayState>();
  final TextEditingController _titleController = TextEditingController();
  late final BreedDTO data;

  void invokeCallback() async {
    data.title = _titleController.text;

    BreedDTO? output;

    if (data.id == null) {
      output = await BreedService.post(data);
    } else {
      output = await BreedService.put(data.id!, data);
    }

    if (output != null && output.mediaCreationToken != null) {
      await _imageKey.currentState?.createExternally(
        output.mediaCreationToken!,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      widget.callback();
    }
  }

  @override
  void initState() {
    super.initState();
    data = widget.fromCurrent?.copy() ?? BreedDTO(kindId: widget.kindId);
    _titleController.text = data.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      formKey: _formKey,
      center: true,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            widget.fromCurrent != null ? 'Edit Breed:' : 'New Breed:',
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
            widget.callback();
          },
        ),

        design.verticalGap(design.spacing),
        ColoredBox(
          color: listTone,
          child: TextFormField(
            controller: _titleController,
            maxLines: 1,
            maxLength: 75,
            minLines: 1,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: "Title..."),
            validator: (value) => validateGeneric(value),
          ),
        ),
        design.verticalGap(design.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            scaleWidget(design.dropdownW, data.scale, (value) {
              if (value != null) {
                setState(() {
                  data.scale = value;
                });
              }
            }),
          ],
        ),
        design.verticalGap(design.spacing),
        Text('Investment:'),
        NormalizedInput(
          bothAxis: false,
          initValue: data.investment,
          changeCallback: (val) => data.investment = val,
        ),
        design.verticalGap(design.spacing),
        Text('Territory:'),
        NormalizedInput(
          bothAxis: false,
          initValue: data.territory,
          changeCallback: (val) => data.territory = val,
        ),
        design.verticalGap(design.spacing),
        Text('Pricing:'),
        NormalizedInput(
          bothAxis: false,
          initValue: data.pricing,
          changeCallback: (val) => data.pricing = val,
        ),
        design.verticalGap(design.spacing),
        Text('Longevity:'),
        NormalizedInput(
          bothAxis: false,
          initValue: data.longevity,
          changeCallback: (val) => data.longevity = val,
        ),
        design.verticalGap(design.spacing),
        Text('Cohabitation:'),
        NormalizedInput(
          bothAxis: false,
          initValue: data.cohabitation,
          changeCallback: (val) => data.cohabitation = val,
        ),
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
