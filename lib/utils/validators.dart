String? validateID(String? value) {
  if (value == null || value.isEmpty || value.length != 12) {
    return 'Invalid ID';
  }
  return null;
}

String? checkNotEmpty({
  String? value,
  String errorMessage = 'This Field is required',
}) {
  if (value == null || value.isEmpty) {
    return errorMessage;
  }
  return null;
}
