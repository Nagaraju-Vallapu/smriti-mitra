/// Lightweight, dependency-free format checks for auth form fields.
/// Frontend-only validation — no network/backend calls.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  // Accepts an optional leading + and 7-15 digits, covering most
  // national phone number formats for this demo's purposes.
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  static bool isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

  static bool isValidPhone(String value) =>
      _phoneRegex.hasMatch(value.trim().replaceAll(RegExp(r'[\s\-]'), ''));

  /// True if [value] looks like a valid email OR a valid phone number.
  /// Used for fields (like "Gmail") that in practice are always emails,
  /// but should also accept a phone number gracefully if one is typed.
  static bool isValidEmailOrPhone(String value) =>
      isValidEmail(value) || isValidPhone(value);
}
