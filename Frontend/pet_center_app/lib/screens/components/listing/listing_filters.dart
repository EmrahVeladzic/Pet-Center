import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';

import 'package:pet_center_app/screens/components/filter_bar.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

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
    final fields = <Widget>[
      FilterField(
        child: orderingWidget(double.infinity, ordering, (newValue) {
          if (newValue != null) {
            setState(() => ordering = newValue);
            invokeCallback();
          }
        }),
      ),
    ];

    if (widget.role == Access.user) {
      if (type == ListingType.medical) {
        fields.add(
          FilterField(
            child: procedureWidget(double.infinity, procedures, (newValue) {
              if (newValue != null) {
                setState(() => relevant = newValue.id);
                invokeCallback();
              }
            }),
          ),
        );
      } else if (type == ListingType.product) {
        fields.addAll([
          FilterField(
            child: categoryWidget(double.infinity, categories, (newValue) {
              if (newValue != null) {
                setState(() => relevant = newValue.id);
                invokeCallback();
              }
            }),
          ),
          FilterField(
            child: kindWidget(double.infinity, kinds, (newValue) {
              if (newValue != null) {
                setState(() => kind = newValue.id);
                invokeCallback();
              }
            }),
          ),
          FilterField(
            child: scaleWidget(double.infinity, scale, (newValue) {
              if (newValue != null) {
                setState(() => scale = newValue);
                invokeCallback();
              }
            }),
          ),
        ]);
      } else if (type != ListingType.pet) {
        fields.add(
          FilterToggle(
            label: 'Show products',
            value: type == ListingType.product,
            onChanged: (value) {
              setState(() {
                type = value ? ListingType.product : ListingType.generic;
              });
              invokeCallback();
            },
          ),
        );
      }
    } else {
      fields.add(
        FilterToggle(
          label: 'Include already evaluated',
          value: showApproved ?? false,
          onChanged: (value) {
            setState(() => showApproved = value);
            invokeCallback();
          },
        ),
      );
    }

    return FilterBar(children: fields);
  }
}
