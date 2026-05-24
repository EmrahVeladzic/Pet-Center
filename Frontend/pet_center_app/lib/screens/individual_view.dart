import 'package:flutter/material.dart';

import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';

import 'package:pet_center_app/screens/components/individual/individual_card.dart';
import 'package:pet_center_app/screens/medical_record_view.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';

import 'package:pet_center_app/utils/app_style.dart';

class IndividualViewScreen extends StatefulWidget {
  final List<IndividualResponseDTO>? src;
  const IndividualViewScreen({super.key, this.src});

  @override
  State<StatefulWidget> createState() => _IndividualViewScreenState();
}

class _IndividualViewScreenState extends State<IndividualViewScreen> {
  late List<IndividualResponseDTO> dataSource;

  @override
  void initState() {
    super.initState();

    dataSource = widget.src ?? [];
  }

  void viewMedical(IndividualResponseDTO src) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicalRecordViewScreen(src: src)),
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
            'Individuals:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: [
        ...dataSource.expand(
          (e) => [
            IndividualCard(
              individual: e,
              onTap: () {},
              onMedical: () {
                viewMedical(e);
              },
            ),
            design.verticalGap(1),
          ],
        ),
      ],
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
