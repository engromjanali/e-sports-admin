import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/common_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_dropdown_widget.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/features/match_entry/domain/entities/match_entry_entity.dart';
import 'package:clean_boilerplate/features/player/domain/entities/player_entity.dart';
import 'package:flutter/material.dart';

/// Form for adding/editing a player's stat line in a match.
/// Pops a [MatchEntryEntity].
class MatchEntryFormSheet extends StatefulWidget {
  final String matchId;
  final MatchEntryEntity? entry;
  final List<PlayerEntity> availablePlayers;

  const MatchEntryFormSheet({
    required this.matchId,
    required this.availablePlayers,
    super.key,
    this.entry,
  });

  @override
  State<MatchEntryFormSheet> createState() => _MatchEntryFormSheetState();
}

class _MatchEntryFormSheetState extends State<MatchEntryFormSheet> {
  late final TextEditingController _goalsController;
  late final TextEditingController _concededController;
  late final TextEditingController _hattricksController;
  late final TextEditingController _notesController;

  String? _playerId;
  String _result = 'draw';
  bool _cleanSheet = false;
  bool _motm = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _goalsController = TextEditingController(text: '${e?.goals ?? 0}');
    _concededController =
        TextEditingController(text: '${e?.goalsConceded ?? 0}');
    _hattricksController = TextEditingController(text: '${e?.hattricks ?? 0}');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _playerId = e?.playerId;
    _result = e?.result ?? 'draw';
    _cleanSheet = e?.cleanSheet ?? false;
    _motm = e?.motm ?? false;
  }

  @override
  void dispose() {
    _goalsController.dispose();
    _concededController.dispose();
    _hattricksController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_playerId == null) {
      context.showErrorSnackBar('Please select a player');
      return;
    }
    final entity = MatchEntryEntity(
      id: widget.entry?.id ?? '',
      playerId: _playerId!,
      matchId: widget.matchId,
      goals: _goalsController.text.trim().toIntOrNull ?? 0,
      goalsConceded: _concededController.text.trim().toIntOrNull ?? 0,
      hattricks: _hattricksController.text.trim().toIntOrNull ?? 0,
      cleanSheet: _cleanSheet,
      motm: _motm,
      result: _result,
      notes: _notesController.text.trim(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing
                  ? 'Edit Entry — ${widget.entry?.playerName ?? ''}'
                  : 'New Entry',
              style: AppTextStyles.sfProRoundedSemiBold
                  .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
            ),
            const SizedBox(height: Dimensions.spaceDefault),
            if (!_isEditing)
              CommonLabeledDropdownWidget<String>(
                label: 'Player',
                hintText: 'Select player',
                isRequired: true,
                value: _playerId,
                items: widget.availablePlayers
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            p.jerseyNumber != null
                                ? '#${p.jerseyNumber}  ${p.name}'
                                : p.name,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _playerId = v),
              ),
            if (!_isEditing)
              const SizedBox(height: Dimensions.spaceDefault),
            Row(
              children: [
                Expanded(
                  child: CommonLabeledInputItemWidget(
                    label: 'Goals',
                    hintText: '0',
                    controller: _goalsController,
                    keyboardType: TextInputType.number,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: CommonLabeledInputItemWidget(
                    label: 'Conceded',
                    hintText: '0',
                    controller: _concededController,
                    keyboardType: TextInputType.number,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: CommonLabeledInputItemWidget(
                    label: 'Hat-tricks',
                    hintText: '0',
                    controller: _hattricksController,
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
            CommonLabeledDropdownWidget<String>(
              label: 'Result',
              hintText: 'Result',
              value: _result,
              items: kMatchResults
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.capitalize),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _result = v ?? 'draw'),
            ),
            const SizedBox(height: Dimensions.spaceSmall),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Clean sheet',
                style: AppTextStyles.sfProRoundedMedium
                    .copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              value: _cleanSheet,
              onChanged: (v) => setState(() => _cleanSheet = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Man of the match',
                style: AppTextStyles.sfProRoundedMedium
                    .copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              value: _motm,
              onChanged: (v) => setState(() => _motm = v),
            ),
            const SizedBox(height: Dimensions.spaceDefault),
            CommonLabeledInputItemWidget(
              label: 'Notes',
              hintText: 'Optional notes',
              controller: _notesController,
              maxLines: 3,
              minLines: 2,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeDefault,
              ),
            ),
            const SizedBox(height: Dimensions.spaceLarge),
            AppPrimaryButton(
              label: _isEditing ? 'Update Entry' : 'Save Entry',
              icon: Icons.save_outlined,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
