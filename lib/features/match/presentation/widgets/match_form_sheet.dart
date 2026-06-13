import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/common_extensions.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_dropdown_widget.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/features/competition/domain/entities/competition_entity.dart';
import 'package:clean_boilerplate/features/match/domain/entities/match_entity.dart';
import 'package:clean_boilerplate/features/season/domain/entities/season_entity.dart';
import 'package:flutter/material.dart';

/// Bottom sheet form for creating/editing a match. Pops a [MatchEntity].
class MatchFormSheet extends StatefulWidget {
  final MatchEntity? match;
  final List<SeasonEntity> seasons;
  final List<CompetitionEntity> competitions;
  final int? defaultSeasonId;

  const MatchFormSheet({
    required this.seasons,
    required this.competitions,
    super.key,
    this.match,
    this.defaultSeasonId,
  });

  @override
  State<MatchFormSheet> createState() => _MatchFormSheetState();
}

class _MatchFormSheetState extends State<MatchFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _homeController;
  late final TextEditingController _awayController;
  late final TextEditingController _homeScoreController;
  late final TextEditingController _awayScoreController;

  int? _seasonId;
  String? _competition;
  int? _competitionId;
  String _status = 'upcoming';
  String _date = '';

  bool get _isEditing => widget.match != null;

  @override
  void initState() {
    super.initState();
    final m = widget.match;
    _homeController = TextEditingController(text: m?.homeTeam ?? 'The Elits');
    _awayController = TextEditingController(text: m?.awayTeam ?? '');
    _homeScoreController =
        TextEditingController(text: m?.homeScore?.toString() ?? '');
    _awayScoreController =
        TextEditingController(text: m?.awayScore?.toString() ?? '');
    _seasonId = m?.seasonId ??
        widget.defaultSeasonId ??
        (widget.seasons.isNotEmpty ? widget.seasons.first.id : null);
    _status = m?.status ?? 'upcoming';
    _date = m?.date ?? '';
    // Pre-select competition from existing FK id or name (join result).
    final existingId = m?.competitionId;
    final existingName = m?.competitionName ?? '';
    final matched = widget.competitions.where(
      (c) => (existingId != null && c.id == existingId) || c.name == existingName,
    ).firstOrNull;
    _competition = matched?.name;
    _competitionId = matched?.id ?? existingId;
  }

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _date =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_seasonId == null) {
      context.showErrorSnackBar('Please select a season');
      return;
    }
    final entity = MatchEntity(
      id: widget.match?.id ?? '',
      seasonId: _seasonId!,
      homeTeam: _homeController.text.trim(),
      awayTeam: _awayController.text.trim(),
      homeScore: _homeScoreController.text.trim().toIntOrNull,
      awayScore: _awayScoreController.text.trim().toIntOrNull,
      date: _date,
      competitionId: _competitionId,
      status: _status,
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
                _isEditing ? 'Edit Match' : 'New Match',
                style: AppTextStyles.sfProRoundedSemiBold
                    .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledDropdownWidget<int>(
                label: 'Season',
                hintText: 'Select season',
                isRequired: true,
                value: _seasonId,
                items: widget.seasons
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.displayName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _seasonId = v),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Home Team',
                hintText: 'Home team',
                controller: _homeController,
                isRequired: true,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Away Team',
                hintText: 'Away team',
                controller: _awayController,
                isRequired: true,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledDropdownWidget<String>(
                label: 'Competition',
                hintText: 'Select competition',
                value: _competition,
                items: widget.competitions
                    .where((c) => c.isActive)
                    .map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  final picked = widget.competitions.where((c) => c.name == v).firstOrNull;
                  setState(() {
                    _competition = picked?.name;
                    _competitionId = picked?.id;
                  });
                },
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DateField(
                      value: _date.isEmpty ? 'Pick date' : _date,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: CommonLabeledDropdownWidget<String>(
                      label: 'Status',
                      hintText: 'Status',
                      value: _status,
                      items: kMatchStatuses
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.capitalize),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _status = v ?? 'upcoming'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              Row(
                children: [
                  Expanded(
                    child: CommonLabeledInputItemWidget(
                      label: 'Home Score',
                      hintText: '0',
                      controller: _homeScoreController,
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
                      label: 'Away Score',
                      hintText: '0',
                      controller: _awayScoreController,
                      keyboardType: TextInputType.number,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spaceLarge),
              AppPrimaryButton(
                label: _isEditing ? 'Update Match' : 'Create Match',
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

class _DateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: AppTextStyles.sfProRoundedMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeLarge - 2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: context.customThemeColors.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.sfProRoundedRegular
                        .copyWith(fontSize: Dimensions.fontSizeDefault),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
