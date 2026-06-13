import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/features/competition/domain/entities/competition_entity.dart';
import 'package:flutter/material.dart';

class CompetitionFormSheet extends StatefulWidget {
  final CompetitionEntity? competition;

  const CompetitionFormSheet({super.key, this.competition});

  @override
  State<CompetitionFormSheet> createState() => _CompetitionFormSheetState();
}

class _CompetitionFormSheetState extends State<CompetitionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late bool _isActive;

  bool get _isEditing => widget.competition != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.competition?.name ?? '');
    _isActive = widget.competition?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final entity = CompetitionEntity(
      id: widget.competition?.id ?? 0,
      name: _nameController.text.trim(),
      isActive: _isActive,
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
                _isEditing ? 'Edit Competition' : 'New Competition',
                style: AppTextStyles.sfProRoundedSemiBold
                    .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Name',
                hintText: 'e.g. Premier League',
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
              Container(
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSmall),
                  border:
                      Border.all(color: context.customThemeColors.borderColor),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Active',
                    style: AppTextStyles.sfProRoundedMedium
                        .copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  subtitle: Text(
                    'Show in dropdown when creating matches',
                    style: AppTextStyles.sfProRoundedRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: context.textTheme.bodySmall?.color,
                    ),
                  ),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ),
              const SizedBox(height: Dimensions.spaceLarge),
              AppPrimaryButton(
                label: _isEditing ? 'Update Competition' : 'Create Competition',
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
