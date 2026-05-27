import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';

import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';

import 'package:pet_center_app/screens/components/individual/medical_record_entry_card.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/individual_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/validators.dart';

class MedicalRecordViewScreen extends StatefulWidget {
  final IndividualResponseDTO src;
  const MedicalRecordViewScreen({super.key, required this.src});

  @override
  State<StatefulWidget> createState() => _MedicalRecordViewScreenState();
}

class _MedicalRecordViewScreenState extends State<MedicalRecordViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  void deleteEntry(String procId) async {
    final output = await IndividualService.removeMedical(
      widget.src.id!,
      procId,
    );

    if (mounted && output) {
      widget.src.medicalRecord.removeWhere(
        (element) => element.procedureId == procId,
      );

      setState(() {});
    }
  }

  void modifyEntry(String procId, int days) async {
    final output = await IndividualService.setMedical(
      widget.src.id!,
      procId,
      days,
    );

    if (mounted && output != null) {
      widget.src.medicalRecord.removeWhere(
        (element) => element.procedureId == procId,
      );
      widget.src.medicalRecord.add(output);

      setState(() {});
    }
  }

  void findTreatment() async {
    final breed = kinds
        .expand((k) => k.breeds)
        .cast<BreedDTO?>()
        .firstWhere((b) => b?.id == widget.src.breedId);

    if (breed == null) {
      return;
    }

    if (procedures.isEmpty) {
      return;
    }

    final proc = procedures.cast<ProcedureDTO?>().firstWhere(
      (p) => p!.specifications.any(
        (s) =>
            s.approximateAge != null &&
            (s.breedId == breed.id || s.kindId == breed.kindId),
      ),
      orElse: () {
        return procedures.firstOrNull;
      },
    );

    if (proc == null) {
      return;
    }

    final count = await ListingService.count(
      ListingType.medical,
      OrderingMethod.id,
      relevantId: proc.id,
      kindSpecific: breed.kindId,
      breedSpecific: breed.id,
      sexSpecific: widget.src.sex,
    );

    if (count == null || !mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingSelectionScreen(
          maxPage: count,
          initType: ListingType.medical,
          initRelevant: proc.id,
          initAnimal: widget.src,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      center: false,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            'Medical records for ${widget.src.name}:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add, color: panelTone),
          ),
        ],
      ),
      body: [
        ...widget.src.medicalRecord.expand(
          (e) => [
            MedicalRecordEntryCard(
              entry: e,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => TextEntryDialog(
                    limit: 4,
                    dialogName: "Days since procedure",
                    inputDecoration: "Days",
                    validation: (value) => validateNumeric(value),
                    callback: (value) {
                      final days = int.tryParse(value);
                      if (days == null) {
                        return;
                      }
                      modifyEntry(e.procedureId, days);
                    },
                  ),
                );
              },
              onDelete: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    confirmAction: () {
                      deleteEntry(e.procedureId);
                    },
                  ),
                );
              },
            ),
            design.verticalGap(1),
          ],
        ),
      ],
      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (role == Access.user) ...[
                ElevatedButton(
                  onPressed: findTreatment,
                  child: design.fittedText("Browse"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
