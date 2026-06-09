import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_dropdown_widget.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_input_item_widget.dart';
import 'package:clean_boilerplate/features/business_setup/domain/entities/app_settings_entity.dart';
import 'package:clean_boilerplate/features/business_setup/presentation/bloc/business_setup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessSetupScreen extends StatelessWidget {
  const BusinessSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BusinessSetupBloc>()..add(const LoadBusinessSetup()),
      child: const _BusinessSetupView(),
    );
  }
}

class _BusinessSetupView extends StatefulWidget {
  const _BusinessSetupView();

  @override
  State<_BusinessSetupView> createState() => _BusinessSetupViewState();
}

class _BusinessSetupViewState extends State<_BusinessSetupView> {
  final TextEditingController _versionController = TextEditingController();
  bool _maintenanceMode = false;
  bool _verifyEmail = false;
  int? _currentSeasonId;
  bool _hydrated = false;

  @override
  void dispose() {
    _versionController.dispose();
    super.dispose();
  }

  void _hydrate(AppSettingsEntity settings) {
    _versionController.text = settings.version ?? '';
    _maintenanceMode = settings.maintenanceMode;
    _verifyEmail = settings.verifyEmail;
    _currentSeasonId = settings.currentSeasonId;
    _hydrated = true;
  }

  void _save(BuildContext context, AppSettingsEntity current) {
    final updated = AppSettingsEntity(
      id: current.id,
      currentSeasonId: _currentSeasonId,
      version: _versionController.text.trim().isEmpty
          ? null
          : _versionController.text.trim(),
      verifyEmail: _verifyEmail,
      maintenanceMode: _maintenanceMode,
    );
    context.read<BusinessSetupBloc>().add(SaveBusinessSetup(updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.local.businessSetup)),
      drawer: const AppMenuDrawer(),
      body: SafeArea(
        child: BlocConsumer<BusinessSetupBloc, BusinessSetupState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError ||
              (c.settings != null && !_hydrated),
          listener: (context, state) {
            if (state.settings != null && !_hydrated) {
              setState(() => _hydrate(state.settings!));
            }
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context
                  .read<BusinessSetupBloc>()
                  .add(const ClearBusinessSetupFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context
                  .read<BusinessSetupBloc>()
                  .add(const ClearBusinessSetupFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == BusinessSetupStatus.loading &&
                state.settings == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == BusinessSetupStatus.failure &&
                state.settings == null) {
              return AdminErrorView(
                message: state.errorMessage,
                onRetry: () => context
                    .read<BusinessSetupBloc>()
                    .add(const LoadBusinessSetup()),
              );
            }
            final settings = state.settings;
            if (settings == null) {
              return const AdminEmptyView(message: 'No settings found.');
            }

            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: context.local.appSetup),
                      const SizedBox(height: Dimensions.spaceDefault),
                      CommonLabeledDropdownWidget<int>(
                        label: 'Current Season',
                        hintText: 'Select current season',
                        value: _currentSeasonId,
                        items: state.seasons
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.displayName),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _currentSeasonId = v),
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
                      const SizedBox(height: Dimensions.spaceDefault),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context.local.maintenanceMode,
                          style: AppTextStyles.sfProRoundedMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        value: _maintenanceMode,
                        onChanged: (value) =>
                            setState(() => _maintenanceMode = value),
                      ),
                      const SizedBox(height: Dimensions.spaceSmall),
                      const Divider(),
                      const SizedBox(height: Dimensions.spaceLarge),
                      _SectionTitle(title: context.local.userSetup),
                      const SizedBox(height: Dimensions.spaceDefault),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context.local.verifyEmail,
                          style: AppTextStyles.sfProRoundedMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        value: _verifyEmail,
                        onChanged: (value) =>
                            setState(() => _verifyEmail = value),
                      ),
                      const SizedBox(height: Dimensions.spaceExtraLarge),
                      AppPrimaryButton(
                        label: 'Save Changes',
                        icon: Icons.save_outlined,
                        isLoading: state.isSaving,
                        onPressed: () => _save(context, settings),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
