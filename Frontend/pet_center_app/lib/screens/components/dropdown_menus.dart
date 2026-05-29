import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

Widget accessWidget(
  double w,
  Access? src,
  void Function(Access? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<Access>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src ?? Access.user,
        requestFocusOnTap: false,
        label: const Text('Role:'),
        onSelected: onChange,
        dropdownMenuEntries: Access.values.map<DropdownMenuEntry<Access>>((
          Access method,
        ) {
          return DropdownMenuEntry<Access>(
            value: method,
            label: method.displayName,
          );
        }).toList(),
      ),
    ),
  );
}

Widget orderingWidget(
  double w,
  OrderingMethod? src,
  void Function(OrderingMethod? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<OrderingMethod>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src ?? OrderingMethod.id,
        requestFocusOnTap: false,
        label: const Text('Sort:'),
        onSelected: onChange,
        dropdownMenuEntries: OrderingMethod.values
            .map<DropdownMenuEntry<OrderingMethod>>((OrderingMethod method) {
              return DropdownMenuEntry<OrderingMethod>(
                value: method,
                label: method.displayName,
              );
            })
            .toList(),
      ),
    ),
  );
}

Widget scaleWidget(
  double w,
  AnimalScale? src,
  void Function(AnimalScale? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<AnimalScale>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src ?? AnimalScale.medium,
        requestFocusOnTap: false,
        label: const Text('Scale:'),
        onSelected: onChange,
        dropdownMenuEntries: AnimalScale.values
            .map<DropdownMenuEntry<AnimalScale>>((AnimalScale method) {
              return DropdownMenuEntry<AnimalScale>(
                value: method,
                label: method.displayName,
              );
            })
            .toList(),
      ),
    ),
  );
}

Widget listingTypeWidget(
  double w,
  ListingType? src,
  void Function(ListingType? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<ListingType>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src ?? ListingType.generic,
        requestFocusOnTap: false,
        label: const Text('Type:'),
        onSelected: onChange,
        dropdownMenuEntries: ListingType.values
            .map<DropdownMenuEntry<ListingType>>((ListingType method) {
              return DropdownMenuEntry<ListingType>(
                value: method,
                label: method.displayName,
              );
            })
            .toList(),
      ),
    ),
  );
}

Widget procedureWidget(
  double w,
  List<ProcedureDTO> src,
  void Function(ProcedureDTO? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<ProcedureDTO>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src.isNotEmpty ? src.first : null,
        enableFilter: true,
        label: const Text('Procedure:'),
        onSelected: onChange,
        dropdownMenuEntries: src
            .map(
              (dto) => DropdownMenuEntry<ProcedureDTO>(
                value: dto,
                label: dto.description,
              ),
            )
            .toList(),
      ),
    ),
  );
}

Widget itemWidget(
  double w,
  List<ItemDTO> src,
  void Function(ItemDTO? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<ItemDTO>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src.isNotEmpty ? src.first : null,
        enableFilter: true,
        label: const Text('Product:'),
        onSelected: onChange,
        dropdownMenuEntries: src.map((dto) {
          final kind = kinds.where((k) => k.id == dto.kindId).firstOrNull;

          final List<String> details = [];

          if (dto.mass != null) {
            details.add('${dto.mass}g');
          }
          if (kind?.title != null && kind!.title.isNotEmpty) {
            details.add(kind.title);
          }
          if (dto.scale?.displayName != null &&
              dto.scale!.displayName.isNotEmpty) {
            details.add(dto.scale!.displayName);
          }

          final String entryLabel = details.isEmpty
              ? dto.title
              : '${dto.title} (${details.join(' - ')})';

          return DropdownMenuEntry<ItemDTO>(value: dto, label: entryLabel);
        }).toList(),
      ),
    ),
  );
}

Widget templateWidget(
  double w,
  List<FormTemplateDTO> src,
  void Function(FormTemplateDTO? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<FormTemplateDTO>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src.isNotEmpty ? src.first : null,
        enableFilter: true,
        label: const Text('Template:'),
        onSelected: onChange,
        dropdownMenuEntries: src
            .map(
              (dto) => DropdownMenuEntry<FormTemplateDTO>(
                value: dto,
                label: dto.description,
              ),
            )
            .toList(),
      ),
    ),
  );
}

Widget categoryWidget(
  double w,
  List<CategoryDTO> src,
  void Function(CategoryDTO? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<CategoryDTO>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src.isNotEmpty ? src.first : null,
        enableFilter: true,
        label: const Text('Category:'),
        onSelected: onChange,
        dropdownMenuEntries: src
            .map(
              (dto) =>
                  DropdownMenuEntry<CategoryDTO>(value: dto, label: dto.title),
            )
            .toList(),
      ),
    ),
  );
}

Widget animalWidget(
  double w,
  List<IndividualResponseDTO> src,
  void Function(IndividualResponseDTO? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<IndividualResponseDTO>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src.isNotEmpty ? src.first : null,
        enableFilter: true,
        label: const Text('Pet:'),
        onSelected: onChange,
        dropdownMenuEntries: src.map((dto) {
          final breed = kinds
              .expand((k) => k.breeds)
              .where((b) => b.id == dto.breedId)
              .firstOrNull;

          String lbl = dto.name;

          if (breed != null) {
            lbl += " - ${breed.title}";
          }

          return DropdownMenuEntry<IndividualResponseDTO>(
            value: dto,
            label: lbl,
          );
        }).toList(),
      ),
    ),
  );
}

Widget breedWidget(
  double w,
  List<BreedDTO> src,
  void Function(BreedDTO? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<BreedDTO>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src.isNotEmpty ? src.first : null,
        enableFilter: true,
        label: const Text('Breed:'),
        onSelected: onChange,
        dropdownMenuEntries: src.map((dto) {
          final kindTitle = kinds
              .where((k) => k.breeds.any((b) => b.id == dto.id))
              .firstOrNull
              ?.title;

          return DropdownMenuEntry<BreedDTO>(
            value: dto,
            label: "${dto.title}${kindTitle != null ? " - $kindTitle" : ""}",
          );
        }).toList(),
      ),
    ),
  );
}

Widget kindWidget(
  double w,
  List<KindDTO> src,
  void Function(KindDTO? newValue) onChange, {
  bool enable = true,
  Key? key,
}) {
  return FittedBox(
    key: key,
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: w,
      child: DropdownMenu<KindDTO>(
        enabled: enable,
        expandedInsets: EdgeInsets.zero,
        initialSelection: src.isNotEmpty ? src.first : null,
        enableFilter: true,
        label: const Text('Kind:'),
        onSelected: onChange,
        dropdownMenuEntries: src
            .map(
              (dto) => DropdownMenuEntry<KindDTO>(value: dto, label: dto.title),
            )
            .toList(),
      ),
    ),
  );
}
