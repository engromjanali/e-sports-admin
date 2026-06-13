import 'package:clean_boilerplate/config/util/app_constants.dart';
import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/core/widgets/image_picker_field.dart';
import 'package:clean_boilerplate/features/player/domain/entities/player_entity.dart';
import 'package:flutter/material.dart';

/// Bottom sheet form for creating/editing a player. Pops a [PlayerEntity].
class PlayerFormSheet extends StatefulWidget {
  final PlayerEntity? player;
  final List<String> availableRoles;
  final List<String> availableTags;

  const PlayerFormSheet({
    super.key,
    this.player,
    this.availableRoles = const [],
    this.availableTags = const [],
  });

  @override
  State<PlayerFormSheet> createState() => _PlayerFormSheetState();
}

class _PlayerFormSheetState extends State<PlayerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sortNameController;
  late final TextEditingController _jerseyController;

  String? _imageUrl;
  late List<String> _roles;
  late List<String> _tags;

  bool get _isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    _nameController = TextEditingController(text: p?.name ?? '');
    _sortNameController = TextEditingController(text: p?.sortName ?? '');
    _jerseyController =
        TextEditingController(text: p?.jerseyNumber?.toString() ?? '');
    _imageUrl = p?.profileImageUrl;
    _roles = List<String>.from(p?.playerRoles ?? const []);
    _tags = List<String>.from(p?.customTags ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortNameController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final entity = PlayerEntity(
      id: widget.player?.id ?? '',
      name: _nameController.text.trim(),
      sortName: _sortNameController.text.trim().isEmpty
          ? null
          : _sortNameController.text.trim(),
      profileImageUrl: _imageUrl,
      jerseyNumber: int.tryParse(_jerseyController.text.trim()),
      playerRoles: _roles,
      customTags: _tags,
    );
    Navigator.of(context).pop(entity);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.paddingSizeLarge,
        right: Dimensions.paddingSizeLarge,
        top: Dimensions.paddingSizeLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            Dimensions.paddingSizeLarge,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Player' : 'New Player',
                style: AppTextStyles.sfProRoundedSemiBold
                    .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              ImagePickerField(
                label: 'Profile Photo',
                folder: AppConstants.playersImageFolder,
                initialUrl: _imageUrl,
                onUploaded: (url) => _imageUrl = url,
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Name',
                hintText: 'Full name',
                controller: _nameController,
                isRequired: true,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CommonLabeledInputItemWidget(
                      label: 'Short Name',
                      hintText: 'e.g. R. Uddin',
                      controller: _sortNameController,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: CommonLabeledInputItemWidget(
                      label: 'Jersey #',
                      hintText: '10',
                      controller: _jerseyController,
                      keyboardType: TextInputType.number,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              _TagSelector(
                label: 'Roles',
                emptyHint: 'No roles found. Add them in Tag Management first.',
                availableOptions: widget.availableRoles,
                selected: _roles,
                onChanged: (v) => setState(() => _roles = v),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              _TagSelector(
                label: 'Custom Tags',
                emptyHint: 'No custom tags found. Add them in Tag Management first.',
                availableOptions: widget.availableTags,
                selected: _tags,
                onChanged: (v) => setState(() => _tags = v),
                selectedColor: const Color(0xFFFFD700),
              ),
              const SizedBox(height: Dimensions.spaceLarge),
              AppPrimaryButton(
                label: _isEditing ? 'Update Player' : 'Create Player',
                icon: Icons.save_outlined,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Multi-select chip picker ──────────────────────────────────────────────────

class _TagSelector extends StatelessWidget {
  final String label;
  final String emptyHint;
  final List<String> availableOptions;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final Color? selectedColor;

  const _TagSelector({
    required this.label,
    required this.emptyHint,
    required this.availableOptions,
    required this.selected,
    required this.onChanged,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selectedColor ?? context.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.sfProRoundedMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        if (availableOptions.isEmpty)
          Text(
            emptyHint,
            style: AppTextStyles.sfProRoundedRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: context.textTheme.bodySmall?.color,
            ),
          )
        else
          Wrap(
            spacing: Dimensions.paddingSizeSmall,
            runSpacing: Dimensions.paddingSizeSmall,
            children: availableOptions.map((option) {
              final isSelected = selected.contains(option);
              return FilterChip(
                label: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? accent : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: accent.withValues(alpha: 0.15),
                checkmarkColor: accent,
                side: BorderSide(
                  color: isSelected
                      ? accent.withValues(alpha: 0.6)
                      : context.customThemeColors.borderColor,
                ),
                onSelected: (val) {
                  final updated = List<String>.from(selected);
                  if (val) {
                    updated.add(option);
                  } else {
                    updated.remove(option);
                  }
                  onChanged(updated);
                },
              );
            }).toList(),
          ),
        if (selected.isNotEmpty && availableOptions.isEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Wrap(
            spacing: Dimensions.paddingSizeSmall,
            runSpacing: Dimensions.paddingSizeSmall,
            children: selected
                .map(
                  (v) => Chip(
                    label: Text(v),
                    onDeleted: () => onChanged(
                        selected.where((e) => e != v).toList()),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
