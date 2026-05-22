import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';

import 'package:pet_center_app/screens/components/listing/availability_card.dart';
import 'package:pet_center_app/screens/components/listing/comment_card.dart';
import 'package:pet_center_app/screens/components/listing/comment_creator.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/screens/components/listing/deletion_dialog.dart';
import 'package:pet_center_app/screens/components/listing/listing_extension_card.dart';
import 'package:pet_center_app/screens/components/listing/report_dialog.dart';
import 'package:pet_center_app/screens/components/note_card.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/hive_cache.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/pricing.dart';

class ListingViewScreen extends StatefulWidget {
  final ListingResponseDTO listing;

  final VoidCallback? onModify;
  final VoidCallback? commentDeletionHook;
  const ListingViewScreen({
    super.key,
    required this.listing,
    this.onModify,

    this.commentDeletionHook,
  });
  @override
  State<StatefulWidget> createState() => _ListingViewScreenState();
}

class _ListingViewScreenState extends State<ListingViewScreen> {
  Access role = userToken?.role ?? Access.user;
  bool mature = self?.matureAccount ?? false;

  void toggleVisibility() async {
    final output = await ListingService.setVisibility(
      widget.listing.id!,
      !widget.listing.visible,
    );

    if (output && mounted) {
      setState(() {
        widget.listing.visible = !widget.listing.visible;
      });

      if (widget.onModify != null) {
        widget.onModify!();
      }
    }
  }

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
    if (!mounted) {
      return;
    }

    final removed = reports.where((r) => r.commentId == input.id).toList();

    for (ReportResponseSubDTO rem in removed) {
      CacheManager.delete(rem.id!, CacheEntityType.report);
    }

    setState(() {
      widget.listing.comments.remove(input);
      reports.removeWhere((r) => r.commentId == input.id);

      if (widget.commentDeletionHook != null) {
        widget.commentDeletionHook!();
      }
    });
  }

  void deleteListing(bool ban) async {
    if (widget.listing.id != null) {
      final bool deleted = await ListingService.delete(widget.listing.id!);

      final removedR = reports
          .where((r) => r.listingId == widget.listing.id)
          .toList();

      for (ReportResponseSubDTO remR in removedR) {
        CacheManager.delete(remR.id!, CacheEntityType.report);
      }

      List<NotificationSubDTO> removedN =
          self?.notifications
              ?.where((n) => n.listingId == widget.listing.id)
              .toList() ??
          <NotificationSubDTO>[];

      for (NotificationSubDTO remN in removedN) {
        CacheManager.delete(remN.id!, CacheEntityType.notification);
      }

      CacheManager.delete(widget.listing.id!, CacheEntityType.listing);

      setState(() {
        reports.removeWhere((r) => r.listingId == widget.listing.id);
        self?.notifications?.removeWhere(
          (n) => n.listingId == widget.listing.id,
        );
      });

      if (deleted && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            widget.listing.name,
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          if (role == Access.business &&
              (self?.workplaces?.any(
                    (w) => w.id == widget.listing.franchiseId,
                  ) ==
                  true)) ...[
            if (!widget.listing.approved) ...[
              IconButton(
                icon: const Icon(Icons.edit),

                onPressed: () {
                  if (!mounted) {
                    return;
                  }
                },
              ),
            ],
            if (!widget.listing.visible) ...[
              IconButton(
                icon: const Icon(Icons.visibility_off),

                onPressed: toggleVisibility,
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.visibility),

                onPressed: toggleVisibility,
              ),
            ],
          ],

          if (role == Access.admin ||
              role == Access.owner ||
              (role == Access.business &&
                  self?.workplaces?.any(
                        (w) => w.id == widget.listing.franchiseId,
                      ) ==
                      true)) ...[
            IconButton(
              icon: const Icon(Icons.delete),

              onPressed: () {
                if (!mounted) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (_) => DeletionDialog(
                    bannable: false,
                    itemName: "listing",
                    deletionAction: deleteListing,
                  ),
                );
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.report),

              onPressed: () {
                if (!mounted) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (_) => ReportDialog(
                    listingId: widget.listing.id!,
                    commentId: null,
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: [
        design.verticalGap(),
        if (widget.listing.media.isNotEmpty) ...[
          ...widget.listing.media.map(
            (img) => ImageDisplay(
              dataSource: img,
              creationToken: widget.listing.mediaCreationToken,
              locked: true,
              creating: false,
            ),
          ),
        ] else ...[
          ImageDisplay(
            dataSource: null,
            creationToken: widget.listing.mediaCreationToken,
            locked: true,
            creating: false,
          ),
        ],
        design.verticalGap(),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
          child: Text(
            "\"${widget.listing.description}\" - Posted on ${formatDate(widget.listing.posted)}.",
          ),
        ),

        design.verticalGap(),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
          child: design.textMarquee(
            'Price: ${fromMinor(widget.listing.priceMinor, widget.listing.listingDiscount?.percentage)}',
          ),
        ),

        if (widget.listing.type != ListingType.generic) ...[
          design.verticalGap(),
          ListingExtensionCard(listing: widget.listing),
        ],
        if (widget.listing.notes != null) ...[
          design.verticalGap(),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
            child: design.textMarquee('Notes:'),
          ),
          ...widget.listing.notes!.map((note) => NoteCard(note: note)),
        ],
        if (widget.listing.availability.isNotEmpty) ...[
          design.verticalGap(),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
            child: design.textMarquee('This listing is available at:'),
          ),
          ...widget.listing.availability.map(
            (available) => AvailabilityCard(available: available),
          ),
        ],
        design.verticalGap(),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
          child: design.textMarquee(
            'For more information, you may${widget.listing.availability.isEmpty ? " " : " also "}contact ${widget.listing.franchiseName} at ${widget.listing.contact}.',
          ),
        ),

        if (widget.listing.comments.isNotEmpty ||
            (role == Access.user && widget.listing.id != null && mature)) ...[
          design.verticalGap(),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
            child: design.textMarquee('User reviews:'),
          ),

          if (role == Access.user && widget.listing.id != null && mature) ...[
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
              onDelete: () {
                removeComment(comment);
              },
            ),
          ),
        ],
      ],

      bottomNavigationBar: BottomAppBar(),
    );
  }
}
