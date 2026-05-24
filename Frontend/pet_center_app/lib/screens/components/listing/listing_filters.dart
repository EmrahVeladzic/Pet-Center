import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';

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

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

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
                    children: [
                      Expanded(
                        flex: 9,
                        child: orderingWidget(design.dropdownW, ordering, (
                          OrderingMethod? newValue,
                        ) {
                          if (newValue != null) {
                            setState(() {
                              ordering = newValue;
                            });
                            invokeCallback();
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ] else if (type == ListingType.medical) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 9,
                      child: orderingWidget(design.dropdownW, ordering, (
                        OrderingMethod? newValue,
                      ) {
                        if (newValue != null) {
                          setState(() {
                            ordering = newValue;
                          });
                          invokeCallback();
                        }
                      }),
                    ),
                    Expanded(
                      flex: 1,
                      child: design.horizontalGap(design.spacing / 2),
                    ),
                    Expanded(
                      flex: 9,
                      child: procedureWidget(design.dropdownW, procedures, (
                        ProcedureDTO? newValue,
                      ) {
                        if (newValue != null) {
                          setState(() => relevant = newValue.id);
                          invokeCallback();
                        }
                      }),
                    ),
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
                                  Expanded(
                                    flex: 9,
                                    child: orderingWidget(
                                      design.dropdownW,
                                      ordering,
                                      (OrderingMethod? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            ordering = newValue;
                                          });
                                          invokeCallback();
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: design.horizontalGap(
                                      design.spacing / 2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: categoryWidget(
                                      design.dropdownW,
                                      categories,
                                      (CategoryDTO? newValue) {
                                        if (newValue != null) {
                                          setState(
                                            () => relevant = newValue.id,
                                          );
                                          invokeCallback();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 9,
                                    child: kindWidget(design.dropdownW, kinds, (
                                      KindDTO? newValue,
                                    ) {
                                      if (newValue != null) {
                                        setState(() => kind = newValue.id);
                                        invokeCallback();
                                      }
                                    }),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: design.horizontalGap(
                                      design.spacing / 2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: scaleWidget(
                                      design.dropdownW,
                                      scale,
                                      (AnimalScale? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            scale = newValue;
                                          });
                                          invokeCallback();
                                        }
                                      },
                                    ),
                                  ),
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
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  type = ListingType.generic;
                                });
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
                    Expanded(
                      flex: 9,
                      child: orderingWidget(design.dropdownW, ordering, (
                        OrderingMethod? newValue,
                      ) {
                        if (newValue != null) {
                          setState(() {
                            ordering = newValue;
                          });
                          invokeCallback();
                        }
                      }),
                    ),
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
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                type = ListingType.product;
                              });
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
                    Expanded(
                      flex: 9,
                      child: orderingWidget(design.dropdownW, ordering, (
                        OrderingMethod? newValue,
                      ) {
                        if (newValue != null) {
                          setState(() {
                            ordering = newValue;
                          });
                          invokeCallback();
                        }
                      }),
                    ),
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
