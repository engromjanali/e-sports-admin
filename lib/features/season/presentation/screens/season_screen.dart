import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/features/season/domain/entities/season_entity.dart';
import 'package:clean_boilerplate/features/season/presentation/bloc/season_bloc.dart';
import 'package:clean_boilerplate/features/season/presentation/widgets/season_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SeasonScreen extends StatelessWidget {
  const SeasonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SeasonBloc>()..add(const LoadSeasons()),
      child: const _SeasonView(),
    );
  }
}

class _SeasonView extends StatelessWidget {
  const _SeasonView();

  Future<void> _openForm(BuildContext context, {SeasonEntity? season}) async {
    final bloc = context.read<SeasonBloc>();
    final result = await context.showCustomBottomSheet<SeasonEntity>(
      child: SeasonFormSheet(season: season),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    if (season == null) {
      bloc.add(CreateSeasonRequested(result));
    } else {
      bloc.add(UpdateSeasonRequested(result));
    }
  }

  Future<void> _confirmDelete(BuildContext context, SeasonEntity s) async {
    final bloc = context.read<SeasonBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete season?'),
        content: Text('Delete "${s.displayName}"? This cannot be undone.'),
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
    if (confirmed ?? false) bloc.add(DeleteSeasonRequested(s.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seasons')),
      drawer: const AppMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Season'),
      ),
      body: SafeArea(
        child: BlocConsumer<SeasonBloc, SeasonState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context.read<SeasonBloc>().add(const ClearSeasonFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context.read<SeasonBloc>().add(const ClearSeasonFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == SeasonStatus.loading &&
                state.seasons.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == SeasonStatus.failure &&
                state.seasons.isEmpty) {
              return _ErrorRetry(
                message: state.errorMessage,
                onRetry: () =>
                    context.read<SeasonBloc>().add(const LoadSeasons()),
              );
            }
            if (state.seasons.isEmpty) {
              return const _Empty(message: 'No seasons yet. Add one to start.');
            }

            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: RefreshIndicator(
                  onRefresh: () async =>
                      context.read<SeasonBloc>().add(const LoadSeasons()),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemCount: state.seasons.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                    itemBuilder: (context, index) {
                      final s = state.seasons[index];
                      return _SeasonCard(
                        season: s,
                        onEdit: () => _openForm(context, season: s),
                        onDelete: () => _confirmDelete(context, s),
                        onSetCurrent: () => context
                            .read<SeasonBloc>()
                            .add(SetCurrentSeasonRequested(s.id)),
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

class _SeasonCard extends StatelessWidget {
  final SeasonEntity season;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetCurrent;

  const _SeasonCard({
    required this.season,
    required this.onEdit,
    required this.onDelete,
    required this.onSetCurrent,
  });

  String _fmt(DateTime? d) => d == null
      ? '—'
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: context.customThemeColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        season.displayName,
                        style: AppTextStyles.sfProRoundedSemiBold
                            .copyWith(fontSize: Dimensions.fontSizeLarge),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (season.isCurrent) ...[
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      _CurrentBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${_fmt(season.startDate)}  →  ${_fmt(season.endDate)}',
                  style: AppTextStyles.sfProRoundedRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: context.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  onEdit();
                case 'current':
                  onSetCurrent();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              if (!season.isCurrent)
                const PopupMenuItem(
                  value: 'current',
                  child: Text('Set as current'),
                ),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        'Current',
        style: AppTextStyles.sfProRoundedMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: context.primaryColor,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.sfProRoundedRegular
              .copyWith(color: context.textTheme.bodySmall?.color),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message ?? 'Something went wrong'),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
