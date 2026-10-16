/// Utilities for human-friendly, readable URL slugs that still embed the
/// numeric backend IDs (e.g. `/cars/toyota-camry-2021-6` or `/services/requests/request-21`).
class Slugs {
  Slugs._();

  /// Converts an arbitrary text string into a clean URL-safe slug segment.
  /// Handles unicode, spaces, punctuation, repeated hyphens, and trimming.
  static String slugify(String text, {int maxLength = 60}) {
    // Normalize and convert to lowercase
    var cleaned = text.trim().toLowerCase();

    // Replace common diacritics / unicode characters where possible
    cleaned = cleaned
        .replaceAll(RegExp(r'[àáâãäåā]'), 'a')
        .replaceAll(RegExp(r'[èéêëē]'), 'e')
        .replaceAll(RegExp(r'[ìíîïī]'), 'i')
        .replaceAll(RegExp(r'[òóôõöō]'), 'o')
        .replaceAll(RegExp(r'[ùúûüū]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c');

    // Replace non-alphanumeric characters with hyphens
    cleaned = cleaned.replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    // Remove leading/trailing hyphens and collapse consecutive hyphens
    cleaned = cleaned.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');

    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength).replaceAll(RegExp(r'-+$'), '');
    }

    return cleaned;
  }

  /// Builds a human-readable slug for a car listing: `{title-slug}-{id}`.
  /// If the title is empty or yields no slug characters, returns `'car-$id'`.
  static String buildCarSlug(int id, [String? title]) {
    if (title == null || title.trim().isEmpty) {
      return 'car-$id';
    }
    final titleSlug = slugify(title);
    if (titleSlug.isEmpty) {
      return 'car-$id';
    }
    return '$titleSlug-$id';
  }

  /// Extracts the trailing numeric ID from a car URL slug.
  /// Supports:
  /// - Pure integer string: `'6'` -> 6 (backwards compatibility for old `/cars/6` links)
  /// - Slug with trailing id: `'toyota-land-cruiser-6'` -> 6
  /// - Default car slug: `'car-6'` -> 6
  /// Returns `null` if no valid trailing ID is found.
  static int? parseCarIdFromSlug(String slug) {
    final trimmed = slug.trim();
    if (trimmed.isEmpty) return null;

    // Check if entire slug is pure integer
    final pureInt = int.tryParse(trimmed);
    if (pureInt != null && pureInt > 0) return pureInt;

    // Match trailing -{number}
    final match = RegExp(r'(?:^|-)(\d+)$').firstMatch(trimmed);
    if (match != null) {
      final idStr = match.group(1);
      if (idStr != null) {
        final parsed = int.tryParse(idStr);
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return null;
  }

  /// Formats a service request reference for readable URLs (e.g. `'request-21'`).
  static String buildServiceRequestRef(int requestId) => 'request-$requestId';

  /// Extracts the numeric service request ID from a reference or raw integer.
  /// Supports both `'request-21'` and `'21'`.
  static int? parseServiceRequestId(String ref) {
    final trimmed = ref.trim().toLowerCase();
    if (trimmed.isEmpty) return null;

    final match = RegExp(r'^(?:request-)?(\d+)$').firstMatch(trimmed);
    if (match != null) {
      final idStr = match.group(1);
      if (idStr != null) {
        return int.tryParse(idStr);
      }
    }
    return null;
  }
}
