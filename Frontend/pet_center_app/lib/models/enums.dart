import 'package:json_annotation/json_annotation.dart';

enum Access {
  @JsonValue(255)
  owner,
  @JsonValue(254)
  admin,
  @JsonValue(1)
  business,
  @JsonValue(0)
  user,
}

Access fromClaim(String claim) {
  return switch (claim) {
    'Owner' => Access.owner,
    'Admin' => Access.admin,
    'Employee' => Access.business,
    _ => Access.user,
  };
}

enum ListingType {
  @JsonValue(0)
  generic,
  @JsonValue(1)
  product,
  @JsonValue(2)
  pet,
  @JsonValue(3)
  medical,
}

enum AnimalScale {
  @JsonValue(0)
  small,
  @JsonValue(1)
  medium,
  @JsonValue(2)
  large,
}
