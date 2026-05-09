import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:finanfo/core/services/encryption_service.dart';

/// A circular avatar that handles three photo formats automatically:
/// - Network URL (http/https) → CachedNetworkImage
/// - AES-encrypted string → decrypted Image.memory
/// - null / empty → shows the user's initial letter
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.uid,
    this.photoUrl,
    required this.displayName,
    required this.radius,
    required this.primaryColor,
    this.fontSize,
    this.onTap,
  });

  final String uid;
  final String? photoUrl;
  final String displayName;
  final double radius;
  final Color primaryColor;
  final double? fontSize;
  final VoidCallback? onTap;

  String get _initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final fSize = fontSize ?? radius * 0.7;
    final url = photoUrl;

    Widget inner;

    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        inner = ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: (ctx, _, e) => _initialWidget(fSize),
          ),
        );
      } else {
        final bytes = EncryptionService.decryptBytes(uid, url);
        if (bytes != null) {
          inner = ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (ctx, e, _) => _initialWidget(fSize),
            ),
          );
        } else {
          inner = _initialWidget(fSize);
        }
      }
    } else {
      inner = _initialWidget(fSize);
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: primaryColor.withValues(alpha: 0.18),
      child: inner,
    );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }

  Widget _initialWidget(double fSize) => Text(
        _initial,
        style: TextStyle(
          fontSize: fSize,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
      );
}
