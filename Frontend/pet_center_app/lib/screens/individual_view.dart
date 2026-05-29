import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_request_dto.dart';

import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';

import 'package:pet_center_app/screens/components/individual/individual_card.dart';
import 'package:pet_center_app/screens/components/individual/individual_dialog.dart';
import 'package:pet_center_app/screens/medical_record_view.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/individual_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

class IndividualViewScreen extends StatefulWidget {
  final List<IndividualResponseDTO>? src;
  final String? onBehalf;
  const IndividualViewScreen({super.key, this.src, this.onBehalf});

  @override
  State<StatefulWidget> createState() => _IndividualViewScreenState();
}

class _IndividualViewScreenState extends State<IndividualViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  void removeAnimal(String id) async {
    final output = await IndividualService.delete(id);

    if (mounted && output == true) {
      setState(() {
        widget.src?.removeWhere((i) => i.id == id);
      });
    }
  }

  void viewMedical(IndividualResponseDTO src) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicalRecordViewScreen(src: src)),
    );
  }

  void addAnimal(IndividualRequestDTO req) async {
    final output = await IndividualService.post(req);

    if (output != null && mounted) {
      setState(() {
        widget.src?.add(output);
      });
    }
  }

  void editAnimal(String id, IndividualRequestDTO req) async {
    final output = await IndividualService.put(req, id);

    if (output != null && mounted) {
      setState(() {
        widget.src?.removeWhere((s) => s.id == id);
        widget.src?.add(output);
      });
    }
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
            'Individuals:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          if ((widget.src ?? []).length < 50) ...[
            IconButton(
              icon: const Icon(Icons.add),

              onPressed: () {
                if (!mounted || kinds.isEmpty || kinds.first.breeds.isEmpty) {
                  return;
                }
                showDialog(
                  context: context,
                  builder: (_) => IndividualCreationDialog(
                    callback: (value) {
                      addAnimal(value);
                    },

                    shelterId: widget.onBehalf,
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: [
        ...(widget.src ?? []).expand(
          (e) => [
            IndividualCard(
              individual: e,
              onTap: () {
                if (e.id == null ||
                    kinds.isEmpty ||
                    kinds.first.breeds.isEmpty) {
                  return;
                }
                showDialog(
                  context: context,
                  builder: (_) => IndividualCreationDialog(
                    callback: (value) {
                      editAnimal(e.id!, value);
                    },
                    fromCurrent: e,
                    shelterId: widget.onBehalf,
                  ),
                );
              },
              onMedical: () {
                viewMedical(e);
              },
              onDelete: () {
                if (e.id == null) {
                  return;
                }
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    confirmAction: () {
                      removeAnimal(e.id!);
                    },
                  ),
                );
              },
            ),
            design.verticalGap(1),
          ],
        ),
      ],
    );
  }
}
