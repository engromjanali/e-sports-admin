import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/features/faq/domain/entities/faq_entity.dart';
import 'package:flutter/material.dart';

/// Bottom sheet form for creating/editing a FAQ. Pops a [FaqEntity].
class FaqFormSheet extends StatefulWidget {
  final FaqEntity? faq;

  const FaqFormSheet({super.key, this.faq});

  @override
  State<FaqFormSheet> createState() => _FaqFormSheetState();
}

class _FaqFormSheetState extends State<FaqFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late final TextEditingController _categoryController;
  late final TextEditingController _orderController;
  late bool _isActive;

  bool get _isEditing => widget.faq != null;

  @override
  void initState() {
    super.initState();
    final f = widget.faq;
    _questionController = TextEditingController(text: f?.question ?? '');
    _answerController = TextEditingController(text: f?.answer ?? '');
    _categoryController = TextEditingController(text: f?.category ?? 'General');
    _orderController =
        TextEditingController(text: f?.displayOrder.toString() ?? '0');
    _isActive = f?.isActive ?? true;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _categoryController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final entity = FaqEntity(
      id: widget.faq?.id ?? 0,
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      displayOrder: int.tryParse(_orderController.text.trim()) ?? 0,
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
        bottom:
            MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeLarge,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit FAQ' : 'New FAQ',
                style: AppTextStyles.sfProRoundedSemiBold
                    .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Question',
                hintText: 'e.g. How do I reset my password?',
                controller: _questionController,
                isRequired: true,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Question is required'
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: 'Answer',
                hintText: 'Provide a clear answer...',
                controller: _answerController,
                isRequired: true,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Answer is required'
                    : null,
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
                    flex: 3,
                    child: CommonLabeledInputItemWidget(
                      label: 'Category',
                      hintText: 'e.g. Account, Gameplay',
                      controller: _categoryController,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: CommonLabeledInputItemWidget(
                      label: 'Order',
                      hintText: '0',
                      controller: _orderController,
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
              Container(
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: context.customThemeColors.borderColor),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Active',
                    style: AppTextStyles.sfProRoundedMedium
                        .copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  subtitle: Text(
                    'Visible to users in the app',
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
                label: _isEditing ? 'Update FAQ' : 'Create FAQ',
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
