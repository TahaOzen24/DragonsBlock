/// Public legal URLs for Play Console / in-app links.
///
/// Host [docs/privacy-policy.html] (GitHub Pages or your domain), then set
/// [privacyPolicyUrl] to that HTTPS URL before store submission.
class LegalUrls {
  LegalUrls._();

  /// Replace after hosting. Empty = in-app dialog only (Play still needs a public URL).
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: '',
  );

  static const String supportEmail = 'support@dragonsblock.app';

  static bool get hasPrivacyPolicyUrl => privacyPolicyUrl.trim().isNotEmpty;
}
