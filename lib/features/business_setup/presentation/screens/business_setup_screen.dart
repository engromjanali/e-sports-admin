import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:flutter/material.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final TextEditingController _versionController = TextEditingController();
  bool _maintenanceMode = false;
  bool _verifyEmail = false;

  @override
  void dispose() {
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.local.businessSetup),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: context.local.appSetup),
              const SizedBox(height: Dimensions.spaceDefault),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  context.local.maintenanceMode,
                  style: AppTextStyles.sfProRoundedMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                value: _maintenanceMode,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    _maintenanceMode = value ?? false;
                  });
                },
              ),
              const SizedBox(height: Dimensions.spaceDefault),
              CommonLabeledInputItemWidget(
                label: context.local.version,
                hintText: context.local.enterVersion,
                controller: _versionController,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                  horizontal: Dimensions.paddingSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.spaceLarge),
              const Divider(),
              const SizedBox(height: Dimensions.spaceLarge),
              _SectionTitle(title: context.local.userSetup),
              const SizedBox(height: Dimensions.spaceDefault),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  context.local.verifyEmail,
                  style: AppTextStyles.sfProRoundedMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                value: _verifyEmail,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    _verifyEmail = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.sfProRoundedSemiBold.copyWith(
        fontSize: Dimensions.fontSizeExtraLarge,
      ),
    );
  }
}
