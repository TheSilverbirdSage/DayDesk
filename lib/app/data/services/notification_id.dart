/// Inline CRC-32 (IEEE 802.3 polynomial 0xEDB88320). No external dependency.
///
/// We use this to derive a stable 31-bit positive notification id from a
/// payload's [NotificationPayload.key]. Determinism is what makes
/// re-scheduling idempotent — issuing the same key twice yields the same id,
/// so the OS replaces the pending notification rather than duplicating it.
/// See plan decision D3.
int crc32(String input) {
  // Process bytes; Dart strings are UTF-16, but `codeUnits` is fine for our
  // dedupe purposes — the hash is for stability, not cryptographic use.
  var crc = 0xFFFFFFFF;
  for (final unit in input.codeUnits) {
    crc ^= unit;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 1) == 1 ? (crc >>> 1) ^ 0xEDB88320 : (crc >>> 1);
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

/// Returns a stable 31-bit positive id for a payload key. Always > 0 to fit
/// in any 32-bit signed int that platform APIs (Android, iOS) expect.
int payloadId(String key) => crc32(key) & 0x7FFFFFFF;
