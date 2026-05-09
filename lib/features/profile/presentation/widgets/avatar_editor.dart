import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finanfo/core/services/encryption_service.dart';
import 'package:finanfo/features/profile/presentation/providers/profile_provider.dart';

class AvatarEditor extends ConsumerWidget {
  const AvatarEditor({
    super.key,
    required this.uid,
    this.photoUrl,
    required this.displayName,
  });

  final String uid;
  final String? photoUrl;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(profileNotifierProvider).isLoading;
    final scheme = Theme.of(context).colorScheme;
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: scheme.primaryContainer,
          child: _AvatarImageOrInitials(
            uid: uid,
            photo: photoUrl,
            initials: initials,
            scheme: scheme,
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _pickImage(context, ref),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
              ),
              child: Icon(Icons.camera_alt_rounded,
                  size: 14, color: scheme.onPrimary),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final xfile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    await ref.read(profileNotifierProvider.notifier).uploadAvatar(bytes);
    if (!context.mounted) return;
    if (ref.read(profileNotifierProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update photo. Please try again.'),
        ),
      );
    }
  }
}

class _AvatarImageOrInitials extends StatelessWidget {
  const _AvatarImageOrInitials({
    required this.uid,
    required this.photo,
    required this.initials,
    required this.scheme,
  });

  final String uid;
  final String? photo;
  final String initials;
  final ColorScheme scheme;

  bool get _isLikelyUrl {
    final p = photo;
    if (p == null || p.isEmpty) return false;
    return p.startsWith('http://') || p.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final p = photo;
    if (p == null || p.isEmpty) {
      return Text(
        initials.toUpperCase(),
        style: TextStyle(fontSize: 28, color: scheme.onPrimaryContainer),
      );
    }

    if (_isLikelyUrl) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: p,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          placeholder: (_, _) => const CircularProgressIndicator(),
          errorWidget: (_, _, _) => Text(
            initials.toUpperCase(),
            style: TextStyle(fontSize: 28, color: scheme.onPrimaryContainer),
          ),
        ),
      );
    }

    final bytes = EncryptionService.decryptBytes(uid, p);
    if (bytes == null) {
      return Text(
        initials.toUpperCase(),
        style: TextStyle(fontSize: 28, color: scheme.onPrimaryContainer),
      );
    }
    return ClipOval(
      child: Image.memory(
        bytes,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Text(
          initials.toUpperCase(),
          style: TextStyle(fontSize: 28, color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
