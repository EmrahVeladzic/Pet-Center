import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/form/form_card.dart';
import 'package:pet_center_app/screens/components/form/form_filters.dart';
import 'package:pet_center_app/screens/components/app_data_table.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/form_edit.dart';
import 'package:pet_center_app/screens/form_view.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/form_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/tokens.dart';

class FormSelectionScreen extends StatefulWidget {
  final int maxPage;
  final String? templateId;
  final bool eval;

  const FormSelectionScreen({
    super.key,
    required this.maxPage,
    required this.templateId,
    required this.eval,
  });

  @override
  State<StatefulWidget> createState() => _FormSelectionScreenState();
}

class _FormSelectionScreenState extends State<FormSelectionScreen> {
  List<FormDTO> dataSource = [];
  bool _initLoading = true;
  final _pageSelectorKey = GlobalKey<PageSelectorState>();
  late String? templateId;
  late bool eval;

  @override
  void initState() {
    super.initState();
    templateId = widget.templateId;
    eval = widget.eval;
    switchPage(0);
  }

  void switchPage(int page) async {
    final newDataSrc = await FormService.get(templateId, page, eval);
    if (newDataSrc != null && mounted) {
      setState(() {
        _initLoading = false;
        dataSource = newDataSrc;
      });
    } else {
      _pageSelectorKey.currentState?.revertPage();
    }
  }

  void resetPages(String? id, bool ev) async {
    final output = await FormService.count(id, ev);

    if (output != null) {
      if (!mounted) {
        return;
      }

      setState(() {
        templateId = id;
        eval = ev;
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
            resetPages(templateId, eval);
          },
        ),
      ),
    );
    if (shouldRefresh == true) {
      resetPages(templateId, eval);
    }
  }

  void viewForm(FormDTO current) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormViewScreen(
          form: current,

          onModify: () {
            resetPages(templateId, eval);
          },
        ),
      ),
    );
    if (shouldRefresh == true) {
      resetPages(templateId, eval);
    }
  }

  List<DataColumnSpec<FormDTO>> get columns => [
    DataColumnSpec<FormDTO>(
      label: 'Form',
      flex: 5,
      cell: (context, form) => Row(
        children: [
          FormThumbnail(form: form),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  form.franchiseName.isEmpty
                      ? 'Unnamed franchise'
                      : form.franchiseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  form.defaultContact.isEmpty
                      ? 'No contact provided'
                      : form.defaultContact,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    DataColumnSpec<FormDTO>(
      label: 'Status',
      flex: 3,
      cell: (context, form) => EvaluationChip(status: form.status),
    ),
    DataColumnSpec<FormDTO>(
      label: 'Evaluated',
      flex: 3,
      hideOnMedium: true,
      cell: (context, form) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedEvalDate(form),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (form.evalContact != null && form.evalContact!.isNotEmpty)
            Text(
              form.evalContact!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    ),
    DataColumnSpec<FormDTO>(
      label: 'Actions',
      flex: 2,
      alignment: Alignment.centerRight,
      cell: (context, form) => IconButton(
        tooltip: 'Open form',
        icon: const Icon(Icons.arrow_forward),
        onPressed: () {
          if (form.id != null) {
            viewForm(form);
          }
        },
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final canFilter =
        (role == Access.owner || role == Access.admin) && templates.isNotEmpty;

    return DataScreenScaffold<FormFilters, FormDTO>(
      appTitle: (role == Access.business) ? 'Your forms' : 'Forms',
      description: (role == Access.business)
          ? 'Adoption forms you have submitted, and their evaluation status.'
          : 'Adoption forms submitted by providers, awaiting or holding a decision.',
      columns: columns,
      emptyTitle: 'No forms yet',
      emptyMessage: (role == Access.business)
          ? 'You have not submitted any forms yet. Create one to get started.'
          : 'No forms have been submitted yet. They will appear here once providers send them in.',
      onResetFilters: canFilter ? () => resetPages(null, false) : null,
      onRowTap: (form) {
        if (form.id != null) {
          viewForm(form);
        }
      },
      primaryAction: (role == Access.business && templateId != null)
          ? FilledButton.icon(
              onPressed: createForm,
              icon: const Icon(Icons.add, size: IconSizes.md),
              label: const Text('New form'),
            )
          : null,
      maxPage: widget.maxPage,
      switchPage: switchPage,
      pageSelectorKey: _pageSelectorKey,
      loading: _initLoading,
      filterPrereq: canFilter,
      dataSource: dataSource,
      filter: FormFilters(callback: resetPages, initEval: false),
      itemBuilder: (context, source) {
        return FormCard(
          form: source,
          onTap: () {
            if (source.id != null) {
              viewForm(source);
            }
          },
        );
      },
    );
  }
}
