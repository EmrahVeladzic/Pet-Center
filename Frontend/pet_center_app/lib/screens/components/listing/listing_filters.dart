import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/models/enums.dart';

import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

class ListingFilters extends StatefulWidget
    with FilterTemplate
    implements PreferredSizeWidget {
  final ListingType initType;
  final OrderingMethod initOrdering;
  final String? initRelevant;
  final bool? initShowApproved;
  final String? initKind;
  final String? initBreed;
  final bool? initSex;
  final AnimalScale? initScale;
  final Access role;

  final void Function(
    ListingType t,
    OrderingMethod o,
    String? r,
    bool? sh,
    String? k,
    String? b,
    bool? s,
    AnimalScale? sc,
  )
  callback;

  const ListingFilters({
    super.key,
    required this.role,
    required this.initType,
    required this.callback,
    this.initOrdering = OrderingMethod.id,
    this.initRelevant,
    this.initScale,
    this.initShowApproved,
    this.initBreed,
    this.initKind,
    this.initSex,
  });

  @override
  int filterRowCount() =>
      (initType == ListingType.product && role == Access.user) ? 2 : 1;

  @override
  Size get preferredSize => const Size.fromHeight(double.infinity);

  @override
  State<StatefulWidget> createState() => _ListingFiltersState();
}

class _ListingFiltersState extends State<ListingFilters> {
  late ListingType type;
  late OrderingMethod ordering;
  String? relevant;
  bool? showApproved;
  String? kind;
  String? breed;
  bool? sex;
  AnimalScale? scale;

  final textCutoff = 20;
  double dropdownW = 250.0;

  @override
  void initState() {
    super.initState();
    type = widget.initType;
    ordering = widget.initOrdering;
    relevant = widget.initRelevant;
    showApproved = widget.initShowApproved;
    kind = widget.initKind;
    breed = widget.initBreed;
    sex = widget.initSex;
    scale = widget.initScale;
  }

  void invokeCallback() {
    widget.callback(
      type,
      ordering,
      relevant,
      showApproved,
      kind,
      breed,
      sex,
      scale,
    );
  }

  Widget _orderingWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: dropdownW,
        child: DropdownMenu<OrderingMethod>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: ordering,
          requestFocusOnTap: false,
          label: const Text('Sort:'),
          onSelected: (OrderingMethod? newValue) {
            if (newValue != null) {
              setState(() {
                ordering = newValue;
              });
              invokeCallback();
            }
          },
          dropdownMenuEntries: OrderingMethod.values
              .map<DropdownMenuEntry<OrderingMethod>>((OrderingMethod method) {
                return DropdownMenuEntry<OrderingMethod>(
                  value: method,
                  label: method.displayName,
                  labelWidget: Text(
                    method.displayName.length > textCutoff
                        ? '${method.displayName.substring(0, textCutoff)}...'
                        : method.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              })
              .toList(),
        ),
      ),
    );
  }

  Widget _scaleWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: dropdownW,
        child: DropdownMenu<AnimalScale>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: scale ?? AnimalScale.medium,
          requestFocusOnTap: false,
          label: const Text('Scale:'),
          onSelected: (AnimalScale? newValue) {
            if (newValue != null) {
              setState(() {
                scale = newValue;
              });
              invokeCallback();
            }
          },
          dropdownMenuEntries: AnimalScale.values
              .map<DropdownMenuEntry<AnimalScale>>((AnimalScale method) {
                return DropdownMenuEntry<AnimalScale>(
                  value: method,
                  label: method.displayName,
                  labelWidget: Text(
                    method.displayName.length > textCutoff
                        ? '${method.displayName.substring(0, textCutoff)}...'
                        : method.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              })
              .toList(),
        ),
      ),
    );
  }

  Widget _procedureWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: dropdownW,
        child: DropdownMenu<ProcedureDTO>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: procedures.isNotEmpty ? procedures.first : null,
          enableFilter: true,
          label: const Text('Procedure:'),
          onSelected: (ProcedureDTO? newValue) {
            if (newValue != null) {
              setState(() => relevant = newValue.id);
              invokeCallback();
            }
          },
          dropdownMenuEntries: procedures
              .map(
                (dto) => DropdownMenuEntry<ProcedureDTO>(
                  value: dto,
                  label: dto.description,
                  labelWidget: Text(
                    dto.description.length > textCutoff
                        ? '${dto.description.substring(0, textCutoff)}...'
                        : dto.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _categoryWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: dropdownW,
        child: DropdownMenu<CategoryDTO>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: categories.isNotEmpty ? categories.first : null,
          enableFilter: true,
          label: const Text('Category:'),
          onSelected: (CategoryDTO? newValue) {
            if (newValue != null) {
              setState(() => relevant = newValue.id);
              invokeCallback();
            }
          },
          dropdownMenuEntries: categories
              .map(
                (dto) => DropdownMenuEntry<CategoryDTO>(
                  value: dto,
                  label: dto.title,
                  labelWidget: Text(
                    dto.title.length > textCutoff
                        ? '${dto.title.substring(0, textCutoff)}...'
                        : dto.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _kindWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: dropdownW,
        child: DropdownMenu<KindDTO>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: kinds.isNotEmpty ? kinds.first : null,
          enableFilter: true,
          label: const Text('Kind:'),
          onSelected: (KindDTO? newValue) {
            if (newValue != null) {
              setState(() => kind = newValue.id);
              invokeCallback();
            }
          },
          dropdownMenuEntries: kinds
              .map(
                (dto) => DropdownMenuEntry<KindDTO>(
                  value: dto,
                  labelWidget: Text(
                    dto.title.length > textCutoff
                        ? '${dto.title.substring(0, textCutoff)}...'
                        : dto.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  label: dto.title,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    dropdownW = (design.bodyWMult * design.screenWidth) / 2;

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(color: filterTone),
        padding: EdgeInsets.symmetric(horizontal: design.spacing / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.role == Access.user) ...[
              if (type == ListingType.pet) ...[
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Expanded(flex: 9, child: _orderingWidget())],
                  ),
                ),
              ] else if (type == ListingType.medical) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 9, child: _orderingWidget()),
                    Expanded(
                      flex: 1,
                      child: design.horizontalGap(design.spacing / 2),
                    ),
                    Expanded(flex: 9, child: _procedureWidget()),
                  ],
                ),
              ] else if (type == ListingType.product) ...[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 9, child: _orderingWidget()),
                                  Expanded(
                                    flex: 1,
                                    child: design.horizontalGap(
                                      design.spacing / 2,
                                    ),
                                  ),
                                  Expanded(flex: 9, child: _categoryWidget()),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 9, child: _kindWidget()),
                                  Expanded(
                                    flex: 1,
                                    child: design.horizontalGap(
                                      design.spacing / 2,
                                    ),
                                  ),
                                  Expanded(flex: 9, child: _scaleWidget()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      design.horizontalGap(design.spacing),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            design.fittedText("Generic"),
                            Checkbox(
                              value: false,
                              onChanged: (value) {
                                type = ListingType.generic;
                                invokeCallback();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 9, child: _orderingWidget()),
                    Expanded(
                      flex: 1,
                      child: design.horizontalGap(design.spacing / 2),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          design.fittedText("Generic"),
                          Checkbox(
                            value: true,
                            onChanged: (value) {
                              type = ListingType.product;
                              invokeCallback();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 9, child: _orderingWidget()),
                    Expanded(
                      flex: 1,
                      child: design.horizontalGap(design.spacing / 2),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          design.fittedText("Show all"),
                          Checkbox(
                            value: showApproved ?? false,
                            onChanged: (value) {
                              showApproved = value;
                              invokeCallback();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
