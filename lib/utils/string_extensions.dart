extension StringCapitalizeExtension on String {
  /// Capitalizes the first letter of each word in a string.
  /// E.g. "john doe" -> "John Doe", "SAHIL" -> "Sahil"
  String capitalizeFirstLetter() {
    if (trim().isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
