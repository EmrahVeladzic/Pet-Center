import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/form/form_card.dart';
import 'package:pet_center_app/screens/components/form/form_filters.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/form_edit.dart';
import 'package:pet_center_app/screens/form_view.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/form_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class FormSelectionScreen extends StatefulWidget {
  final int maxPage;
  final String? templateId;

  const FormSelectionScreen({
    super.key,
    required this.maxPage,
    required this.templateId,
  });

  @override
  State<StatefulWidget> createState() => _FormSelectionScreenState();
}

class _FormSelectionScreenState extends State<FormSelectionScreen> {
  List<FormDTO> dataSource = [];
  bool _initLoading = true;
  final _pageSelectorKey = GlobalKey<PageSelectorState>();
  late String? templateId;

  @override
  void initState() {
    super.initState();
    templateId = widget.templateId;
    switchPage(0);
  }

  void switchPage(int page) async {
    final newDataSrc = await FormService.get(templateId, page);
    if (newDataSrc != null && mounted) {
      setState(() {
        _initLoading = false;
        dataSource = newDataSrc;
      });
    } else {
      _pageSelectorKey.currentState?.revertPage();
    }
  }

  void resetPages(String? id) async {
    final output = await FormService.count(id);

    if (output != null) {
      if (!mounted) {
        return;
      }

      setState(() {
        templateId = id;
      });
      _pageSelectorKey.currentState?.resetMax(output);
    }
  }

  void createForm() async {
    if (role == Access.business &&
        (templateId == null ||
            templates.where((t) => t.id == templateId).firstOrNull == null)) {
      return;
    }

    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormEditScreen(
          formTemplateId: templateId!,
          fromCurrent: null,
          callback: (value) {
            resetPages(templateId);
          },
        ),
      ),
    );
    if (shouldRefresh == true) {
      resetPages(templateId);
    }
  }

  void viewForm(FormDTO current) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormViewScreen(
          form: current,

          onModify: () {
            resetPages(templateId);
          },
        ),
      ),
    );
    if (shouldRefresh == true) {
      resetPages(templateId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataScreenScaffold<FormFilters, FormDTO>(
      importActions: [
        if (role == Access.business && templateId != null) ...[
          IconButton(icon: Icon(Icons.add), onPressed: createForm),
        ],
      ],
      maxPage: widget.maxPage,
      switchPage: switchPage,
      pageSelectorKey: _pageSelectorKey,
      appTitle: (role == Access.business) ? 'Your forms:' : "Forms:",
      loading: _initLoading,
      filterPrereq:
          ((role == Access.owner || role == Access.admin) &&
          templates.isNotEmpty),
      dataSource: dataSource,
      filter: FormFilters(callback: resetPages),
      itemBuilder: (p0, source) {
        return FormCard(
          form: source,
          onTap: () {
            final id = source.id;

            if (id != null) {
              viewForm(source);
            }
          },
        );
      },
    );
  }
}
