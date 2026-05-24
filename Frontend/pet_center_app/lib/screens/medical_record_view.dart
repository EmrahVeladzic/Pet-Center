import 'package:flutter/material.dart';

import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';

import 'package:pet_center_app/screens/components/individual/medical_record_entry_card.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';

import 'package:pet_center_app/utils/app_style.dart';

class MedicalRecordViewScreen extends StatefulWidget {
  final IndividualResponseDTO src;
  const MedicalRecordViewScreen({super.key, required this.src});

  @override
  State<StatefulWidget> createState() => _MedicalRecordViewScreenState();
}

class _MedicalRecordViewScreenState extends State<MedicalRecordViewScreen> {
  late List<MedicalEntrySubDTO> dataSource;

  @override
  void initState() {
    super.initState();

    dataSource = widget.src.medicalRecord;
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
      ),
      body: [
        ...dataSource.expand(
          (e) => [
            MedicalRecordEntryCard(entry: e, onTap: () {}, onDelete: () {}),
            design.verticalGap(1),
          ],
        ),
      ],
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
