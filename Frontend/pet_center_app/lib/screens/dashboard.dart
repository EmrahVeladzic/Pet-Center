import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/account_page.dart';
import 'package:pet_center_app/screens/feed.dart';
import 'package:pet_center_app/screens/form_selection.dart';
import 'package:pet_center_app/screens/franchise_view.dart';
import 'package:pet_center_app/screens/individual_view.dart';
import 'package:pet_center_app/screens/kind_selection.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/static_data_editor.dart';
import 'package:pet_center_app/screens/supplies_view.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/screens/user_view.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/form_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final knd = (kinds.isNotEmpty) ? kinds.first.id : null;
  final rlv = (categories.isNotEmpty) ? categories.first.id : null;

  void _go(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void enterMarket() async {
    final count = await ListingService.count(
      ListingType.product,
      OrderingMethod.id,
      scaleSpecific: AnimalScale.medium,
      kindSpecific: knd,
      relevantId: rlv,
    );

    if (count != null && mounted) {
      _go(ListingSelectionScreen(
        maxPage: count,
        initType: ListingType.product,
        initOrdering: OrderingMethod.id,
        initKind: knd,
        initRelevant: rlv,
      ));
    }
  }

  void accountPage() async {
    final count = await AccountService.count(Access.user, "");

    if (count != null && mounted) {
      _go(AccountPageScreen(
        maxPage: count,
        initContact: "",
        initRole: Access.user,
      ));
    }
  }

  void staticDataEditor() {
    _go(StaticDataEditorScreen());
  }

  void evaluateListings() async {
    final count = await ListingService.count(
      ListingType.generic,
      OrderingMethod.id,
      showEvaluated: false,
    );

    if (count != null && mounted) {
      _go(ListingSelectionScreen(
        maxPage: count,
        initType: ListingType.generic,
        initOrdering: OrderingMethod.id,
        initShowApproved: false,
      ));
    }
  }

  void viewForms() async {
    final output = await FormService.count(null, false);
    if (output != null && mounted) {
      _go(FormSelectionScreen(
        maxPage: output,
        templateId: null,
        eval: false,
      ));
    }
  }

  List<Widget> _actionsFor(ReactiveDesignSystem design) {
    final actions = <Widget>[];

    if (role == Access.user) {
      actions.addAll([
        design.navAction('Adopt a pet',
            () => _go(KindSelectionScreen()), icon: Icons.favorite),
        design.navAction('Market',
            enterMarket, icon: Icons.storefront),
        design.navAction('Pets',
            () => _go(IndividualViewScreen(src: self?.ownedAnimals)),
            icon: Icons.pets),
        design.navAction('Supplies and wishlist',
            () => _go(SuppliesViewScreen()), icon: Icons.checklist),
      ]);
    } else if (role == Access.business) {
      actions.add(
        design.navAction('My workplaces',
            () => _go(FranchiseViewScreen()), icon: Icons.store),
      );
    } else {
      actions.addAll([
        design.navAction('Evaluate listings',
            evaluateListings, icon: Icons.fact_check),
        design.navAction('Evaluate forms',
            viewForms, icon: Icons.assignment),
        design.navAction('Manage users',
            accountPage, icon: Icons.manage_accounts),
        design.navAction('Manage static data',
            staticDataEditor, icon: Icons.dataset),
      ]);
    }

  
    actions.addAll([
      design.navAction('Messages', () => _go(FeedScreen()), icon: Icons.mail),
      design.navAction('User', () => _go(UserViewScreen()), icon: Icons.person),
    ]);

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design =
        Theme.of(context).extension<ReactiveDesignSystem>()!;


    final actions = _actionsFor(design);
    final body = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      if (i > 0) body.add(design.verticalGap(design.spacing));
      body.add(actions[i]);
    }

    return BasicScreenScaffold(
      center: design.layoutDirection==Axis.horizontal,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            "${(self?.userName != null) ? self?.userName : 'PetCenter'}",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: body,
    );
  }
}