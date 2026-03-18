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
