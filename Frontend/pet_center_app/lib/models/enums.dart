import 'package:json_annotation/json_annotation.dart';

enum CacheEntityType {
  @JsonValue('notification')
  notification,

  @JsonValue('announcement')
  announcement,

  @JsonValue('report')
  report,

  @JsonValue('listing')
  listing,
}

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

enum OrderingMethod {
  @JsonValue(0)
  id,
  @JsonValue(1)
  priceDescending,
  @JsonValue(2)
  priceAscending,
  @JsonValue(3)
  postedDescending,
  @JsonValue(4)
  postedAscending,
}

extension AccessExtension on Access {
  int get value {
    switch (this) {
      case Access.owner:
        return 255;
      case Access.admin:
        return 254;
      case Access.business:
        return 1;
      case Access.user:
        return 0;
    }
  }
}

extension ListingTypeExtension on ListingType {
  int get value {
    switch (this) {
      case ListingType.generic:
        return 0;
      case ListingType.product:
        return 1;
      case ListingType.pet:
        return 2;
      case ListingType.medical:
        return 3;
    }
  }
}

extension AnimalScaleExtension on AnimalScale {
  int get value {
    switch (this) {
      case AnimalScale.small:
        return 0;
      case AnimalScale.medium:
        return 1;
      case AnimalScale.large:
        return 2;
    }
  }
}

extension OrderingMethodExtension on OrderingMethod {
  int get value {
    switch (this) {
      case OrderingMethod.id:
        return 0;
      case OrderingMethod.priceDescending:
        return 1;
      case OrderingMethod.priceAscending:
        return 2;
      case OrderingMethod.postedDescending:
        return 3;
      case OrderingMethod.postedAscending:
        return 4;
    }
  }
}
