import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/features/season/domain/entities/season_entity.dart';
import 'package:flutter/material.dart';

/// Bottom sheet form for creating or editing a [SeasonEntity].
/// Returns a [SeasonEntity] via [Navigator.pop] on submit.
class SeasonFormSheet extends StatefulWidget {
  final SeasonEntity? season;

  const SeasonFormSheet({super.key, this.season});

  @override
  State<SeasonFormSheet> createState() => _SeasonFormSheetState();
}

class _SeasonFormSheetState extends State<SeasonFormSheet> {
  late final TextEditingController _nameController;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _status = true;

  bool get _isEditing => widget.season != null;

  @override
  void initState() {
    super.initState();
    final s = widget.season;
    _nameController = TextEditingController(text: s?.name ?? '');
    _startDate = s?.startDate ?? DateTime.now();
    _endDate = s?.endDate;
    _status = s?.status ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : (_endDate ?? _startDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _submit() {
    final entity = SeasonEntity(
      id: widget.season?.id ?? 0,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
    );
    Navigator.of(context).pop(entity);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? 'Edit Season' : 'New Season',
            style: AppTextStyles.sfProRoundedSemiBold
                .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
          ),
          const SizedBox(height: Dimensions.spaceDefault),
          CommonLabeledInputItemWidget(
            label: 'Name',
            hintText: 'e.g. 2025/26',
            controller: _nameController,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
          ),
          const SizedBox(height: Dimensions.spaceDefault),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'Start Date',
                  value: _fmt(_startDate),
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: _DateTile(
                  label: 'End Date',
                  value: _endDate == null ? 'Not set' : _fmt(_endDate!),
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.spaceSmall),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Active',
              style: AppTextStyles.sfProRoundedMedium
                  .copyWith(fontSize: Dimensions.fontSizeDefault),
            ),
            subtitle: Text(
              'Inactive seasons are hidden from the user app',
              style: AppTextStyles.sfProRoundedRegular
                  .copyWith(fontSize: Dimensions.fontSizeExtraSmall),
            ),
            value: _status,
            onChanged: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: Dimensions.spaceDefault),
          AppPrimaryButton(
            label: _isEditing ? 'Update Season' : 'Create Season',
            icon: Icons.save_outlined,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.sfProRoundedMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
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
