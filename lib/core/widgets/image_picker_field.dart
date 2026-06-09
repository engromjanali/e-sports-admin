import 'dart:typed_data';

import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Image picker that uploads the selected image to Supabase Storage and
/// reports back the public URL via [onUploaded].
class ImagePickerField extends StatefulWidget {
  final String? label;
  final String folder;
  final String? initialUrl;
  final ValueChanged<String> onUploaded;
  final double height;

  const ImagePickerField({
    required this.folder,
    required this.onUploaded,
    super.key,
    this.label,
    this.initialUrl,
    this.height = 140,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _previewBytes;
  String? _url;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  Future<void> _pick() async {
    if (_uploading) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _previewBytes = bytes;
        _uploading = true;
      });

      final ext = picked.name.contains('.')
          ? picked.name.split('.').last
          : 'jpg';

      final url = await getIt<StorageService>().uploadImage(
        bytes: bytes,
        folder: widget.folder,
        fileExtension: ext,
      );

      if (!mounted) return;
      setState(() {
        _url = url;
        _uploading = false;
      });
      widget.onUploaded(url);
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      context.showErrorSnackBar('Image upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.sfProRoundedMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
        InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: context.customThemeColors.borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_uploading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
    }

    final Widget? image = _previewBytes != null
        ? Image.memory(_previewBytes!, fit: BoxFit.cover)
        : (_url != null && _url!.isNotEmpty
            ? Image.network(
                _url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(context),
              )
            : null);

    if (image == null) return _placeholder(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Positioned(
          right: Dimensions.paddingSizeSmall,
          bottom: Dimensions.paddingSizeSmall,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: const Icon(Icons.edit, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: Dimensions.iconSizeLarge,
            color: context.primaryColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'Tap to upload',
            style: AppTextStyles.sfProRoundedRegular
                .copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ],
      ),
    );
  }
}
