import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/core/widgets/app_primary_button.dart';
import 'package:clean_boilerplate/features/privacy_policy/presentation/bloc/privacy_policy_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrivacyPolicyBloc>()..add(const LoadPrivacyPolicy()),
      child: const _PrivacyPolicyView(),
    );
  }
}

class _PrivacyPolicyView extends StatefulWidget {
  const _PrivacyPolicyView();

  @override
  State<_PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<_PrivacyPolicyView> {
  final HtmlEditorController _controller = HtmlEditorController();

  Future<void> _save(BuildContext context) async {
    final html = await _controller.getText();
    if (!context.mounted) return;
    context
        .read<PrivacyPolicyBloc>()
        .add(SavePrivacyPolicyRequested(html));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      drawer: const AppMenuDrawer(),
      body: SafeArea(
        child: BlocConsumer<PrivacyPolicyBloc, PrivacyPolicyState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context
                  .read<PrivacyPolicyBloc>()
                  .add(const ClearPrivacyPolicyFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context
                  .read<PrivacyPolicyBloc>()
                  .add(const ClearPrivacyPolicyFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == PrivacyPolicyStatus.loading ||
                state.status == PrivacyPolicyStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == PrivacyPolicyStatus.failure &&
                state.policy == null) {
              return AdminErrorView(
                message: state.errorMessage,
                onRetry: () => context
                    .read<PrivacyPolicyBloc>()
                    .add(const LoadPrivacyPolicy()),
              );
            }

            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compose the privacy policy shown to users in the app. '
                        'Use the toolbar to format text — bold, highlight, font size, lists, links.',
                        style: AppTextStyles.sfProRoundedRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: context.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.theme.cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusLarge),
                            border: Border.all(
                                color: context.customThemeColors.borderColor),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: HtmlEditor(
                            controller: _controller,
                            htmlEditorOptions: HtmlEditorOptions(
                              hint: 'Write the privacy policy here...',
                              initialText: state.policy?.content ?? '',
                              shouldEnsureVisible: true,
                            ),
                            htmlToolbarOptions: const HtmlToolbarOptions(
                              defaultToolbarButtons: [
                                StyleButtons(),
                                FontSettingButtons(),
                                FontButtons(),
                                ColorButtons(),
                                ListButtons(),
                                ParagraphButtons(caseConverter: false),
                              ],
                            ),
                            otherOptions: const OtherOptions(height: 520),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      AppPrimaryButton(
                        label: 'Save Privacy Policy',
                        icon: Icons.save_outlined,
                        isLoading: state.isSubmitting,
                        onPressed: () => _save(context),
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
