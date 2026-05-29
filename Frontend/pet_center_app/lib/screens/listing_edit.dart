import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/pricing.dart';
import 'package:pet_center_app/utils/validators.dart';

class ListingEditScreen extends StatefulWidget {
  final String franchiseId;
  final ListingResponseDTO? fromCurrent;
  final void Function(ListingResponseDTO updated) callback;

  const ListingEditScreen({
    super.key,
    required this.franchiseId,
    required this.callback,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _ListingEditScreenState();
}

class _ListingEditScreenState extends State<ListingEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageKey = GlobalKey<ImageDisplayState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _perListingController = TextEditingController();
  late final ListingRequestDTO data;

  void invokeCallback() async {
    data.name = _nameController.text;
    data.description = _descriptionController.text;
    data.priceMinor = int.tryParse(_priceController.text) ?? 0;

    if (data.type == ListingType.product &&
        data.productListingExtension != null) {
      data.productListingExtension!.perListing =
          int.tryParse(_perListingController.text) ?? 1;
    }

    if (data.type == ListingType.product) {
      data.medicalListingExtension = null;
      data.animalListingExtension = null;
    } else if (data.type == ListingType.medical) {
      data.productListingExtension = null;
      data.animalListingExtension = null;
    } else if (data.type == ListingType.pet) {
      data.productListingExtension = null;
      data.medicalListingExtension = null;
    } else {
      data.productListingExtension = null;
      data.medicalListingExtension = null;
      data.animalListingExtension = null;
    }

    ListingResponseDTO? output;

    if (data.id == null) {
      output = await ListingService.post(data);

      if (output != null && output.mediaCreationToken != null) {
        await _imageKey.currentState?.createExternally(
          output.mediaCreationToken!,
        );
      }
    } else {
      output = await ListingService.put(data, data.id!);
    }

    if (output != null && mounted) {
      Navigator.of(context).pop();
      widget.callback(output);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.fromCurrent != null) {
      final c = widget.fromCurrent!;
      data = ListingRequestDTO(
        id: c.id,
        currentVersion: c.currentVersion,
        name: c.name,
        description: c.description,
        franchiseId: widget.franchiseId,
        priceMinor: c.priceMinor,
        type: c.type,
        productListingExtension: c.productListingExtension?.copy(),
        medicalListingExtension: c.medicalListingExtension?.copy(),
        animalListingExtension: c.animalListingExtension?.copy(),
      );
    } else {
      data = ListingRequestDTO(franchiseId: widget.franchiseId);

      if (items.isNotEmpty) {
        data.productListingExtension = ProductListingSubDTO(
          productId: items.first.id!,
        );
      }
      if (procedures.isNotEmpty) {
        data.medicalListingExtension = MedicalListingSubDTO(
          procedureId: procedures.first.id!,
        );
      }
      final animals =
          self?.workplaces
              ?.where((w) => w.id == widget.franchiseId)
              .expand((w) => w.shelteredAnimals)
              .toList() ??
          [];
      if (animals.isNotEmpty) {
        data.animalListingExtension = AnimalListingSubDTO(
          animalId: animals.first.id!,
          identity: animals.first.identity,
        );
      }
    }

    _nameController.text = data.name;
    _descriptionController.text = data.description;
    _priceController.text = data.priceMinor == 0
        ? 0.toString()
        : data.priceMinor.toString();
    _perListingController.text = (data.productListingExtension?.perListing ?? 1)
        .toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _perListingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final bool isNew = data.id == null;

    final List<IndividualResponseDTO> shelteredAnimals =
        self?.workplaces
            ?.where((w) => w.id == widget.franchiseId)
            .expand((w) => w.shelteredAnimals)
            .toList() ??
        [];

    return BasicScreenScaffold(
      formKey: _formKey,
      center: true,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            isNew ? 'New Listing:' : 'Edit Listing:',
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
            controller: _nameController,
            maxLines: 1,
            maxLength: 75,
            minLines: 1,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: "Name..."),
            validator: (value) => validateGeneric(value),
          ),
        ),
        design.verticalGap(design.spacing),
        ColoredBox(
          color: listTone,
          child: TextFormField(
            controller: _descriptionController,
            maxLines: null,
            maxLength: 1000,
            minLines: dialogMinLines,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(labelText: "Description..."),
            validator: (value) => validateGeneric(value),
          ),
        ),
        design.verticalGap(design.spacing),
        Text(fromMinor(int.tryParse(_priceController.text) ?? 0)),
        ColoredBox(
          color: listTone,
          child: TextFormField(
            controller: _priceController,
            maxLines: 1,
            minLines: 1,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Price (minor)..."),
            onChanged: (_) => setState(() {}),
            validator: (value) => validateNumericInRange(value, 0, 999999999),
          ),
        ),
        if (isNew) ...[
          design.verticalGap(design.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              listingTypeWidget(design.dropdownW, data.type, (value) {
                if (value != null) {
                  setState(() {
                    data.type = value;
                  });
                }
              }),
            ],
          ),
        ],
        if (data.type == ListingType.product) ...[
          design.verticalGap(design.spacing),
          if (isNew) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                itemWidget(design.dropdownW, items, (value) {
                  if (value != null && value.id != null) {
                    setState(() {
                      data.productListingExtension ??= ProductListingSubDTO();
                      data.productListingExtension!.productId = value.id!;
                    });
                  }
                }),
              ],
            ),
            design.verticalGap(design.spacing),
          ],
          ColoredBox(
            color: listTone,
            child: TextFormField(
              controller: _perListingController,
              maxLines: 1,
              minLines: 1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Per listing..."),
              validator: (value) => validateNumericInRange(value, 1, 100),
            ),
          ),
        ],
        if (data.type == ListingType.medical && isNew) ...[
          design.verticalGap(design.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              procedureWidget(design.dropdownW, procedures, (value) {
                if (value != null && value.id != null) {
                  setState(() {
                    data.medicalListingExtension ??= MedicalListingSubDTO();
                    data.medicalListingExtension!.procedureId = value.id!;
                  });
                }
              }),
            ],
          ),
        ],
        if (data.type == ListingType.pet && isNew) ...[
          design.verticalGap(design.spacing),
          if (shelteredAnimals.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: design.dropdownW,

                    child: animalWidget(design.dropdownW, shelteredAnimals, (
                      value,
                    ) {
                      if (value != null && value.id != null) {
                        setState(() {
                          data.animalListingExtension ??= AnimalListingSubDTO();
                          data.animalListingExtension!.animalId = value.id!;
                          data.animalListingExtension!.identity =
                              value.identity;
                        });
                      }
                    }),
                  ),
                ),
              ],
            ),
          ],
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
