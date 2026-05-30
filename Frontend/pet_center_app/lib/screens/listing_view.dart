import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';

import 'package:pet_center_app/screens/components/listing/availability_card.dart';
import 'package:pet_center_app/screens/components/listing/comment_card.dart';
import 'package:pet_center_app/screens/components/listing/comment_creator.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/screens/components/listing/deletion_dialog.dart';
import 'package:pet_center_app/screens/components/listing/discount_dialog.dart';
import 'package:pet_center_app/screens/components/listing/evaluate_dialog.dart';
import 'package:pet_center_app/screens/components/listing/listing_extension_card.dart';
import 'package:pet_center_app/screens/components/listing/report_dialog.dart';
import 'package:pet_center_app/screens/components/note_card.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/listing_edit.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/category_service.dart';
import 'package:pet_center_app/services/individual_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/hive_cache.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/pricing.dart';
import 'package:pet_center_app/utils/validators.dart';

class ListingViewScreen extends StatefulWidget {
  final ListingResponseDTO listing;

  final void Function(bool hard)? onModify;
  final VoidCallback? commentDeletionHook;
  final String? forAnimal;
  final VoidCallback? obtainHook;
  const ListingViewScreen({
    super.key,
    required this.listing,
    this.onModify,
    this.forAnimal,
    this.commentDeletionHook,
    this.obtainHook,
  });
  @override
  State<StatefulWidget> createState() => _ListingViewScreenState();
}

class _ListingViewScreenState extends State<ListingViewScreen> {
  bool mature = self?.matureAccount ?? false;

  void evaluate() {
    if (widget.listing.id == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (_) => EvaluateDialog(
        listingId: widget.listing.id!,
        evaluateCallback: (eval) {
          if (eval != widget.listing.approved && widget.onModify != null) {
            widget.onModify!(true);
          }

          if (mounted) {
            setState(() {
              widget.listing.approved = eval;
            });
          }
        },
      ),
    );
  }

  void product() async {
    if (self?.userSupplies == null) {
      return;
    }

    final item = items.cast<ItemDTO?>().firstWhere(
      (i) =>
          i?.id == widget.listing.productListingExtension!.productId &&
          i?.mass != null,
    );

    if (item == null) {
      return;
    }

    final supply = self!.userSupplies!.cast<SuppliesSubDTO?>().firstWhere(
      (s) => s?.consumableId == item.categoryId && s?.kindId == item.kindId,
    );

    int current = supply?.massGrams ?? 0;

    int newTotal =
        current +
        (widget.listing.productListingExtension!.perListing * item.mass!);

    final output = await CategoryService.trackSupplies(
      item.categoryId,
      item.kindId,
      newTotal,
    );

    if (mounted && output != null && self != null) {
      setState(() {
        if (self!.ownedAnimals != null) {
          self!.userSupplies!.removeWhere(
            (s) =>
                s.kindId == output.kindId &&
                s.consumableId == output.consumableId,
          );
          self!.userSupplies!.add(output);
        } else {
          self!.userSupplies = [output];
        }
      });

      showSnackbar("Obtained.");

      if (widget.obtainHook != null) {
        Navigator.pop(context);
        widget.obtainHook!();
      }
    }
  }

  void adopt() async {
    final output = await IndividualService.copy(
      widget.listing.animalListingExtension!.animalId,
      null,
    );

    if (mounted && output != null && self != null) {
      setState(() {
        if (self!.ownedAnimals != null) {
          self!.ownedAnimals!.add(output);
        } else {
          self!.ownedAnimals = [output];
        }
      });

      if (widget.obtainHook != null) {
        widget.obtainHook!();
      }
    }
  }

  void medical(int days) async {
    final output = await IndividualService.setMedical(
      widget.forAnimal!,
      widget.listing.medicalListingExtension!.procedureId,
      days,
    );

    if (mounted &&
        output != null &&
        self != null &&
        self!.ownedAnimals != null) {
      setState(() {
        final animal = self!.ownedAnimals!
            .cast<IndividualResponseDTO?>()
            .firstWhere((i) => i?.id == widget.forAnimal);

        if (animal != null) {
          animal.medicalRecord.removeWhere(
            (m) =>
                m.procedureId ==
                widget.listing.medicalListingExtension!.procedureId,
          );
          animal.medicalRecord.add(output);
        }
      });

      if (widget.obtainHook != null) {
        widget.obtainHook!();
      }
    }
  }

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
        widget.onModify!(true);
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

  void setAvailability(
    AvailabilityResponseSubDTO available,
    bool addRemove,
  ) async {
    if (addRemove) {
      final output = await ListingService.setAvailability(
        widget.listing.id!,
        available.facilityId,
      );
      if (output != null && mounted) {
        setState(() {
          widget.listing.availability.add(output);
        });
        if (widget.onModify != null) widget.onModify!(true);
      }
    } else {
      final output = await ListingService.removeAvailability(
        widget.listing.id!,
        available.facilityId,
      );
      if (output && mounted) {
        setState(() {
          widget.listing.availability.removeWhere(
            (a) => a.facilityId == available.facilityId,
          );
        });
        if (widget.onModify != null) widget.onModify!(true);
      }
    }
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
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingEditScreen(
                        franchiseId: widget.listing.franchiseId,
                        fromCurrent: widget.listing,
                        callback: (value) {
                          if (mounted) {
                            setState(() {
                              widget.listing.name = value.name;
                              widget.listing.description = value.description;
                              widget.listing.priceMinor = value.priceMinor;
                              widget.listing.mediaCreationToken =
                                  value.mediaCreationToken;

                              if (widget.listing.productListingExtension !=
                                      null &&
                                  value.productListingExtension != null) {
                                widget
                                        .listing
                                        .productListingExtension!
                                        .perListing =
                                    value.productListingExtension!.perListing;
                              }
                            });
                          }
                          if (widget.onModify != null) {
                            widget.onModify!(true);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            if (widget.listing.listingDiscount == null &&
                widget.listing.id != null) ...[
              IconButton(
                icon: const Icon(Icons.local_offer),

                onPressed: () {
                  if (!mounted) {
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (_) => DiscountDialog(
                      callback: (p0) {
                        if (!mounted) {
                          return;
                        }

                        setState(() {
                          widget.listing.listingDiscount = p0;
                        });
                      },
                      listing: widget.listing.id!,
                    ),
                  );
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
        if (role == Access.business &&
            self?.workplaces?.any((w) => w.id == widget.listing.franchiseId) ==
                true &&
            self?.workplaces != null) ...[
          design.verticalGap(),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
            child: design.textMarquee('Availability:'),
          ),
          ...self!.workplaces!.expand((w) => w.facilities).map((facility) {
            final active = widget.listing.availability.any(
              (a) => a.facilityId == facility.id,
            );
            return Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: active,
                title: Text('${facility.city}, ${facility.street}'),
                onChanged: (value) {
                  if (value != null && widget.listing.id != null) {
                    final existing = widget.listing.availability
                        .cast<AvailabilityResponseSubDTO?>()
                        .firstWhere(
                          (a) => a?.facilityId == facility.id,
                          orElse: () => null,
                        );
                    if (value && existing == null) {
                      setAvailability(
                        AvailabilityResponseSubDTO(
                          facilityId: facility.id ?? '',
                        ),
                        true,
                      );
                    } else if (!value && existing != null) {
                      setAvailability(existing, false);
                    }
                  }
                },
              ),
            );
          }),
        ] else if (widget.listing.availability.isNotEmpty) ...[
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

      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (role == Access.user) ...[
                if (widget.listing.type == ListingType.product &&
                    widget.listing.productListingExtension != null &&
                    items.any(
                      (i) =>
                          i.id ==
                              widget
                                  .listing
                                  .productListingExtension!
                                  .productId &&
                          categories.any(
                            (c) => c.id == i.categoryId && c.consumable,
                          ),
                    )) ...[
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            ConfirmationDialog(confirmAction: product),
                      );
                    },
                    child: design.fittedText("Get"),
                  ),
                ] else if (widget.listing.type == ListingType.pet &&
                    widget.listing.animalListingExtension != null &&
                    self?.ownedAnimals != null &&
                    !self!.ownedAnimals!.any(
                      (i) =>
                          i.identity ==
                          widget.listing.animalListingExtension?.identity,
                    )) ...[
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            ConfirmationDialog(confirmAction: adopt),
                      );
                    },
                    child: design.fittedText("Adopt"),
                  ),
                ] else if (widget.listing.type == ListingType.medical &&
                    widget.listing.medicalListingExtension != null &&
                    widget.forAnimal != null) ...[
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => TextEntryDialog(
                          dialogName: "Days since procedure",
                          inputDecoration: "Days",
                          validation: (value) => validateNumeric(value),
                          limit: 4,
                          callback: (value) {
                            int? days = int.tryParse(value);
                            if (days != null) {
                              medical(days);
                            }
                          },
                        ),
                      );
                    },
                    child: design.fittedText("Treat pet"),
                  ),
                ],
              ] else if ((role == Access.admin || role == Access.owner) &&
                  !widget.listing.approved) ...[
                ElevatedButton(
                  onPressed: evaluate,
                  child: design.fittedText("Evaluate"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
