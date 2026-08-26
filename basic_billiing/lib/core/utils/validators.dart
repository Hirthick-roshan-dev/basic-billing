class Validators {
  Validators._();

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateProductName(String? value, {int maxLength = 80}) {
    final req = validateRequired(value, 'Product name');
    if (req != null) return req;
    if (value!.trim().length > maxLength) {
      return 'Product name cannot exceed $maxLength characters';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    if (parsed < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final trimmed = value.trim();
    // Allow standard 7 to 15 digits phone numbers with optional leading +
    final phoneRegex = RegExp(r'^\+?[0-9\s\-()]{7,15}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validatePercentage(String? value, {double max = 100.0}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid percentage';
    }
    if (parsed < 0 || parsed > max) {
      return 'Percentage must be between 0 and $max';
    }
    return null;
  }
}
