import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/account_page.dart';
import 'package:pet_center_app/screens/feed.dart';
import 'package:pet_center_app/screens/franchise_view.dart';
import 'package:pet_center_app/screens/individual_view.dart';
import 'package:pet_center_app/screens/kind_selection.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/screens/user_view.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void enterMarket() async {
    final count = await ListingService.count(
      ListingType.product,
      OrderingMethod.id,
      scaleSpecific: AnimalScale.medium,
      kindSpecific: (kinds.isNotEmpty) ? kinds.first.id : null,
      relevantId: (categories.isNotEmpty) ? categories.first.id : null,
    );

    if (count != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingSelectionScreen(
            maxPage: count,
            initType: ListingType.product,
            initOrdering: OrderingMethod.id,
            initScale: AnimalScale.medium,
            initKind: (kinds.isNotEmpty) ? kinds.first.id : null,
            initRelevant: (categories.isNotEmpty) ? categories.first.id : null,
          ),
        ),
      );
    }
  }

  void accountPage() async {
    final count = await AccountService.count(Access.user, "");

    if (count != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountPageScreen(
            maxPage: count,
            initContact: "",
            initRole: Access.user,
          ),
        ),
      );
    }
  }

  void evaluateListings() async {
    final count = await ListingService.count(
      ListingType.generic,
      OrderingMethod.id,
      showApprovedAndPending: false,
    );

    if (count != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingSelectionScreen(
            maxPage: count,
            initType: ListingType.generic,
            initOrdering: OrderingMethod.id,
            initShowApproved: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      center: true,
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
      body: [
        if (role == Access.user) ...[
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KindSelectionScreen()),
                );
              },
              child: design.fittedText('Adopt a pet'),
            ),
          ),
          SizedBox(height: design.spacing),
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: enterMarket,
              child: design.fittedText('Market'),
            ),
          ),
          SizedBox(height: design.spacing),
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        IndividualViewScreen(src: self?.ownedAnimals),
                  ),
                );
              },
              child: design.fittedText('My pets'),
            ),
          ),
        ] else if (role == Access.business) ...[
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FranchiseViewScreen()),
                );
              },
              child: design.fittedText('My workplaces'),
            ),
          ),
        ] else ...[
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: evaluateListings,
              child: design.fittedText('Evaluate listings'),
            ),
          ),
          SizedBox(height: design.spacing),
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {},
              child: design.fittedText('Evaluate forms'),
            ),
          ),
          SizedBox(height: design.spacing),
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: accountPage,
              child: design.fittedText('Manage users'),
            ),
          ),
        ],
        SizedBox(height: design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FeedScreen()),
              );
            },
            child: design.fittedText('Messages'),
          ),
        ),
        SizedBox(height: design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserViewScreen()),
              );
            },
            child: design.fittedText('User'),
          ),
        ),
      ],
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
