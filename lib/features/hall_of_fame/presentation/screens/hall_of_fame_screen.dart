import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/features/hall_of_fame/domain/entities/hall_of_fame_entity.dart';
import 'package:clean_boilerplate/features/hall_of_fame/presentation/bloc/hall_of_fame_bloc.dart';
import 'package:clean_boilerplate/features/hall_of_fame/presentation/widgets/hall_of_fame_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HallOfFameScreen extends StatelessWidget {
  const HallOfFameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HallOfFameBloc>()..add(const LoadHallOfFame()),
      child: const _HallOfFameView(),
    );
  }
}

class _HallOfFameView extends StatelessWidget {
  const _HallOfFameView();

  Future<void> _openForm(BuildContext context, {HallOfFameEntity? entry}) async {
    final bloc = context.read<HallOfFameBloc>();
    final result = await context.showCustomBottomSheet<HallOfFameEntity>(
      child: HallOfFameFormSheet(
        entry: entry,
        players: bloc.state.players,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    if (entry == null) {
      bloc.add(CreateHallOfFameRequested(result));
    } else {
      bloc.add(UpdateHallOfFameRequested(result));
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, HallOfFameEntity e) async {
    final bloc = context.read<HallOfFameBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete inductee?'),
        content: Text(
            'Remove "${e.displayName}" (${e.season}) from ${e.category.label}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: context.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(DeleteHallOfFameRequested(e.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hall of Fame')),
      drawer: const AppMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Inductee'),
      ),
      body: SafeArea(
        child: BlocConsumer<HallOfFameBloc, HallOfFameState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context.read<HallOfFameBloc>().add(const ClearHallOfFameFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context.read<HallOfFameBloc>().add(const ClearHallOfFameFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == HallOfFameStatus.loading &&
                state.entries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == HallOfFameStatus.failure &&
                state.entries.isEmpty) {
              return AdminErrorView(
                message: state.errorMessage,
                onRetry: () =>
                    context.read<HallOfFameBloc>().add(const LoadHallOfFame()),
              );
            }
            if (state.entries.isEmpty) {
              return const AdminEmptyView(
                message: 'No inductees yet. Add the first champion.',
                icon: Icons.emoji_events_outlined,
              );
            }

            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;
            final grouped = state.grouped;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: RefreshIndicator(
                  onRefresh: () async =>
                      context.read<HallOfFameBloc>().add(const LoadHallOfFame()),
                  child: ListView(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    children: [
                      for (final category in HofCategory.values) ...[
                        _CategoryHeader(
                          category: category,
                          count: grouped[category]!.length,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        if (grouped[category]!.isEmpty)
                          _EmptyCategoryHint(category: category)
                        else
                          ...grouped[category]!.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeDefault),
                              child: _HofCard(
                                entry: e,
                                onEdit: () => _openForm(context, entry: e),
                                onDelete: () => _confirmDelete(context, e),
                              ),
                            ),
                          ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
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

class _CategoryHeader extends StatelessWidget {
  final HofCategory category;
  final int count;

  const _CategoryHeader({required this.category, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.emoji_events_rounded,
            size: 20, color: context.primaryColor),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(
          category.label,
          style: AppTextStyles.sfProRoundedSemiBold
              .copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Text(
          '($count)',
          style: AppTextStyles.sfProRoundedRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: context.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _EmptyCategoryHint extends StatelessWidget {
  final HofCategory category;
  const _EmptyCategoryHint({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Text(
        'No entries for ${category.label} yet.',
        style: AppTextStyles.sfProRoundedRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: context.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

class _HofCard extends StatelessWidget {
  final HallOfFameEntity entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HofCard({
    required this.entry,
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
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Text(
              entry.season.replaceAll('Season ', 'S'),
              style: AppTextStyles.sfProRoundedSemiBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: context.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName.isEmpty ? 'Unknown player' : entry.displayName,
                  style: AppTextStyles.sfProRoundedSemiBold
                      .copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                if (entry.team.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.team,
                    style: AppTextStyles.sfProRoundedRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: context.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
                if (entry.detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfProRoundedRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: context.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
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
