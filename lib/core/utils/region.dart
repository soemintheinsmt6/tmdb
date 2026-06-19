import 'dart:ui';

/// The device's ISO-3166 region code (e.g. `"US"`), used to pick the local
/// watch-provider offering from TMDB's per-country `/watch/providers` map.
/// Falls back to `US` when the platform reports no country.
String deviceRegionCode() {
  final country = PlatformDispatcher.instance.locale.countryCode;
  return (country == null || country.isEmpty) ? 'US' : country.toUpperCase();
}
