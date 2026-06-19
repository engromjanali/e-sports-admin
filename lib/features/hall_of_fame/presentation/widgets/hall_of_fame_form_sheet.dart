import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_dropdown_widget.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/features/hall_of_fame/domain/entities/hall_of_fame_entity.dart';
import 'package:clean_boilerplate/features/player/domain/entities/player_entity.dart';
import 'package:flutter/material.dart';

/// Bottom sheet form for creating/editing a Hall of Fame inductee.
/// Pops a [HallOfFameEntity].
class HallOfFameFormSheet extends StatefulWidget {
  final HallOfFameEntity? entry;
  final List<PlayerEntity> players;

  const HallOfFameFormSheet({super.key, this.entry, this.players = const []});

  @override
  State<HallOfFameFormSheet> createState() => _HallOfFameFormSheetState();
}

class _HallOfFameFormSheetState extends State<HallOfFameFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _seasonController;
  late final TextEditingController _teamController;
  late final TextEditingController _detailController;
  late final TextEditingController _orderController;
  late HofCategory _category;
  String? _playerId;
  String? _playerError;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _category = e?.category ?? HofCategory.ballonDor;
    _playerId = e?.playerId;
    _seasonController = TextEditingController(text: e?.season ?? '');
    _teamController = TextEditingController(text: e?.team ?? '');
    _detailController = TextEditingController(text: e?.detail ?? '');
    _orderController =
        TextEditingController(text: e?.sortOrder.toString() ?? '0');
  }

  @override
  void dispose() {
    _seasonController.dispose();
    _teamController.dispose();
    _detailController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final hasPlayer = _playerId != null && _playerId!.isNotEmpty;
    setState(() => _playerError = hasPlayer ? null : 'Select a player');
    if (!formValid || !hasPlayer) return;
    final entity = HallOfFameEntity(
      id: widget.entry?.id ?? '',
      category: _category,
      season: _seasonController.text.trim(),
      playerId: _playerId!,
      team: _teamController.text.trim(),
      detail: _detailController.text.trim(),
      sortOrder: int.tryParse(_orderController.text.trim()) ?? 0,
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
                _isEditing ? 'Edit Inductee' : 'New Inductee',
                style: AppTextStyles.sfProRoundedSemiBold
                    .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledDropdownWidget<HofCategory>(
                label: 'Category',
                hintText: 'Select award category',
                isRequired: true,
                value: _category,
                items: HofCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _category = v ?? HofCategory.ballonDor),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Season',
                hintText: 'e.g. Season 1',
                controller: _seasonController,
                isRequired: true,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Season is required' : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledDropdownWidget<String?>(
                label: 'Player',
                hintText: 'Select a player',
                isRequired: true,
                value: _playerId,
                errorText: _playerError,
                items: widget.players
                    .map(
                      (p) => DropdownMenuItem<String?>(
                        value: p.id,
                        child: Text(p.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _playerId = v;
                  _playerError = null;
                }),
              ),
              const SizedBox(height: Dimensions.spaceSmall),
              Text(
                "The app shows the linked player's name & photo. Team and detail "
                'below are optional supporting lines.',
                style: AppTextStyles.sfProRoundedRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: context.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Team / Subtitle',
                hintText: 'e.g. Empire FC, or Captain: Aryan',
                controller: _teamController,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Detail / Stats',
                hintText: 'e.g. PTS: 142 · Wins: 18',
                controller: _detailController,
                maxLines: 2,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Display Order',
                hintText: '0',
                controller: _orderController,
                keyboardType: TextInputType.number,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceLarge),
              AppPrimaryButton(
                label: _isEditing ? 'Update Inductee' : 'Create Inductee',
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
