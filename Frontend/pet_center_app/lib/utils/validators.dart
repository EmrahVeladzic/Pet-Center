bool isValidEmailChars(String value) {
  final parts = value.split('@');
  if (parts.length != 2) return false;

  final local = parts[0];
  final domain = parts[1];

  final localRegex = RegExp(r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~.\-]+$");
  final domainRegex = RegExp(r"^[A-Za-z0-9.\-]+$");

  return localRegex.hasMatch(local) && domainRegex.hasMatch(domain);
}

String? validateContact(String? input) {
  if (input == null || input.trim().isEmpty) {
    return "The contact is required.";
  }

  if (input.contains(RegExp(r'\s'))) {
    return "Whitespace not allowed.";
  }

  if (input.length < 3) {
    return "The contact is too short.";
  }

  if (input.length > 255) {
    return "The contact is too long.";
  }

  final specialCount = '@'.allMatches(input).length;

  if (specialCount != 1) {
    return "The contact requires exactly one \"@\".";
  }

  if (!isValidEmailChars(input)) {
    return "Invalid contact format.";
  }

  return null;
}

String? validateCode(String? code) {
  if (code == null || int.tryParse(code) == null) {
    return "The code needs to be numeric with no whitespace.";
  }
  return null;
}

String? validatePassword(String? pwd) {
  if (pwd == null || pwd.isEmpty) {
    return "The password is required.";
  }

  if (pwd.trim() != pwd) {
    return "Leading and trailing whitespace is not allowed.";
  }

  return null;
}

String? validateGeneric(String? text) {
  if (text == null || text.trim().isEmpty) {
    return "This field is required.";
  }

  return null;
}
