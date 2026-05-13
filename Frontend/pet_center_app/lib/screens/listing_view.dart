import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/comment_view.dart';
import 'package:pet_center_app/screens/components/availability_card.dart';
import 'package:pet_center_app/screens/components/comment_card.dart';
import 'package:pet_center_app/screens/components/comment_creator.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/screens/components/listing_extension_card.dart';
import 'package:pet_center_app/screens/components/note_card.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/pricing.dart';

class ListingViewScreen extends StatefulWidget {
  final ListingResponseDTO listing;
  const ListingViewScreen({super.key, required this.listing});
  @override
  State<StatefulWidget> createState() => _ListingViewScreenState();
}

class _ListingViewScreenState extends State<ListingViewScreen> {
  Access role = userToken?.role ?? Access.user;
  bool mature = self?.matureAccount ?? false;

  void showComment(CommentResponseSubDTO input) {
    setState(() {
      final current = widget.listing.comments
          .cast<CommentResponseSubDTO?>()
          .firstWhere(
            (comm) => comm?.posterId == input.posterId,
            orElse: () => null,
          );

      if (current == null) {
        widget.listing.comments.add(input);
      } else {
        final index = widget.listing.comments.indexOf(current);
        widget.listing.comments[index] = input;
      }
    });
  }

  void removeComment(CommentResponseSubDTO input) {
    setState(() {
      widget.listing.comments.remove(input);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        leading: BackButton(),
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            widget.listing.name,
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: Container(
            decoration: design.panelDecoration(),
            child: ListView(
              children: [
                design.verticalGap(),
                ...widget.listing.media.map(
                  (img) => ImageDisplay(
                    dataSource: img,
                    creationToken: widget.listing.mediaCreationToken,
                    locked: widget.listing.locked,
                  ),
                ),
                design.verticalGap(),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: design.spacing,
                  ),
                  child: Text(widget.listing.description),
                ),
                if (widget.listing.priceMinor > 0) ...[
                  design.verticalGap(),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: design.spacing,
                    ),
                    child: design.textMarquee(
                      'Price: ${fromMinor(widget.listing.priceMinor)}',
                    ),
                  ),
                ] else ...[
                  design.verticalGap(),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: design.spacing,
                    ),
                    child: design.textMarquee('Price: FREE'),
                  ),
                ],
                if (widget.listing.type != ListingType.generic) ...[
                  design.verticalGap(),
                  ListingExtensionCard(listing: widget.listing),
                ],
                if (widget.listing.notes != null) ...[
                  design.verticalGap(),
                  ...widget.listing.notes!.map((note) => NoteCard(note: note)),
                ],
                if (widget.listing.availability.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: design.spacing,
                    ),
                    child: design.textMarquee('This listing is available at:'),
                  ),
                  ...widget.listing.availability.map(
                    (available) => AvailabilityCard(available: available),
                  ),
                ],
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: design.spacing,
                  ),
                  child: design.textMarquee(
                    'For more information, you may${widget.listing.availability.isEmpty ? " " : " also "}contact ${widget.listing.franchiseName} at ${widget.listing.contact}.',
                  ),
                ),

                if (widget.listing.comments.isNotEmpty ||
                    (role == Access.user &&
                        widget.listing.id != null &&
                        mature)) ...[
                  design.verticalGap(),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: design.spacing,
                    ),
                    child: design.textMarquee('User reviews:'),
                  ),

                  if (role == Access.user &&
                      widget.listing.id != null &&
                      mature) ...[
                    CommentCreator(
                      listingId: widget.listing.id!,
                      onPost: (comment) {
                        showComment(comment);
                      },
                    ),
                  ],

                  ...widget.listing.comments.map(
                    (comment) => CommentCard(
                      comment: comment,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentViewScreen(
                              comment: comment,
                              onDelete: () {
                                removeComment(comment);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
