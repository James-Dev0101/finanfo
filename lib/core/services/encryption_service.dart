import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/digests/sha256.dart';

class EncryptionService {
  EncryptionService._();

  // Per-user key derivation: SHA-256(uid + appSalt) → 32-byte AES-256 key.
  // Each user gets a unique key, so a decompiled APK alone is not enough to
  // decrypt any photo — the attacker also needs the target user's Firebase UID.
  static const _appSalt = 'finanfo_photo_salt_v1_secure';

  static Key _deriveKey(String uid) {
    final input = Uint8List.fromList(utf8.encode(uid + _appSalt));
    final keyBytes = SHA256Digest().process(input);
    return Key(keyBytes);
  }

  static Encrypter _encrypterFor(String uid) =>
      Encrypter(AES(_deriveKey(uid), mode: AESMode.cbc));

  /// Encrypts [bytes] with the key derived from [uid].
  /// Returns a storable string: "{iv_base64}:{cipher_base64}".
  static String encryptBytes(String uid, List<int> bytes) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypterFor(uid).encryptBytes(
      Uint8List.fromList(bytes),
      iv: iv,
    );
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a string produced by [encryptBytes] for the same [uid].
  /// Returns null if decryption fails (wrong key, corrupt data, or plain base64
  /// uploaded before this version — all fail gracefully to initials avatar).
  static Uint8List? decryptBytes(String uid, String stored) {
    try {
      final colon = stored.indexOf(':');
      if (colon == -1) return null;
      final iv = IV.fromBase64(stored.substring(0, colon));
      final cipher = Encrypted.fromBase64(stored.substring(colon + 1));
      return Uint8List.fromList(
        _encrypterFor(uid).decryptBytes(cipher, iv: iv),
      );
    } catch (_) {
      return null;
    }
  }
}
