import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/features/faq/domain/entities/faq_entity.dart';
import 'package:clean_boilerplate/features/faq/presentation/bloc/faq_bloc.dart';
import 'package:clean_boilerplate/features/faq/presentation/widgets/faq_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FaqBloc>()..add(const LoadFaqs()),
      child: const _FaqView(),
    );
  }
}

class _FaqView extends StatelessWidget {
  const _FaqView();

  Future<void> _openForm(BuildContext context, {FaqEntity? faq}) async {
    final bloc = context.read<FaqBloc>();
    final result = await context.showCustomBottomSheet<FaqEntity>(
      child: FaqFormSheet(faq: faq),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    if (faq == null) {
      bloc.add(CreateFaqRequested(result));
    } else {
      bloc.add(UpdateFaqRequested(result));
    }
  }

  Future<void> _confirmDelete(BuildContext context, FaqEntity faq) async {
    final bloc = context.read<FaqBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete FAQ?'),
        content: Text('Delete this FAQ? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(color: context.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(DeleteFaqRequested(faq.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      drawer: const AppMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('FAQ'),
      ),
      body: SafeArea(
        child: BlocConsumer<FaqBloc, FaqState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context.read<FaqBloc>().add(const ClearFaqFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context.read<FaqBloc>().add(const ClearFaqFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == FaqStatus.loading && state.faqs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == FaqStatus.failure && state.faqs.isEmpty) {
              return AdminErrorView(
                message: state.errorMessage,
                onRetry: () =>
                    context.read<FaqBloc>().add(const LoadFaqs()),
              );
            }
            if (state.faqs.isEmpty) {
              return const AdminEmptyView(
                message: 'No FAQs yet. Add the first one.',
                icon: Icons.help_outline_rounded,
              );
            }

            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: RefreshIndicator(
                  onRefresh: () async =>
                      context.read<FaqBloc>().add(const LoadFaqs()),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemCount: state.faqs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                    itemBuilder: (context, index) {
                      final f = state.faqs[index];
                      return _FaqCard(
                        faq: f,
                        onEdit: () => _openForm(context, faq: f),
                        onDelete: () => _confirmDelete(context, f),
                      );
                    },
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

class _FaqCard extends StatelessWidget {
  final FaqEntity faq;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FaqCard({
    required this.faq,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: context.customThemeColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: faq.isActive
                  ? context.primaryColor.withValues(alpha: 0.12)
                  : context.textTheme.bodySmall!.color!.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              size: 20,
              color: faq.isActive
                  ? context.primaryColor
                  : context.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        faq.question,
                        style: AppTextStyles.sfProRoundedSemiBold
                            .copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                    if (!faq.isActive)
                      Container(
                        margin: const EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.textTheme.bodySmall!.color!
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(
                          'Hidden',
                          style: AppTextStyles.sfProRoundedRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: context.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  faq.answer,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sfProRoundedRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: context.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${faq.category}  •  #${faq.displayOrder}',
                  style: AppTextStyles.sfProRoundedRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: context.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
