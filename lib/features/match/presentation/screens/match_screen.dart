import 'package:clean_boilerplate/config/route/app_router.dart';
import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/common_extensions.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/core/widgets/common_labeled_dropdown_widget.dart';
import 'package:clean_boilerplate/features/match/domain/entities/match_entity.dart';
import 'package:clean_boilerplate/features/match/presentation/bloc/match_bloc.dart';
import 'package:clean_boilerplate/features/match/presentation/widgets/match_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MatchBloc>()..add(const InitMatchData()),
      child: const _MatchView(),
    );
  }
}

class _MatchView extends StatelessWidget {
  const _MatchView();

  Future<void> _openForm(BuildContext context, {MatchEntity? match}) async {
    final bloc = context.read<MatchBloc>();
    final state = bloc.state;
    if (state.seasons.isEmpty) {
      context.showAlertSnackBar('Create a season first before adding matches.');
      return;
    }
    final result = await context.showCustomBottomSheet<MatchEntity>(
      child: MatchFormSheet(
        match: match,
        seasons: state.seasons,
        competitions: state.competitions,
        defaultSeasonId: state.selectedSeasonId,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    if (match == null) {
      bloc.add(CreateMatchRequested(result));
    } else {
      bloc.add(UpdateMatchRequested(result));
    }
  }

  Future<void> _confirmDelete(BuildContext context, MatchEntity m) async {
    final bloc = context.read<MatchBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete match?'),
        content: Text('Delete "${m.title}"? Its data entries are also removed.'),
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
    if (confirmed ?? false) bloc.add(DeleteMatchRequested(m.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      drawer: const AppMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Match'),
      ),
      body: SafeArea(
        child: BlocConsumer<MatchBloc, MatchState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context.read<MatchBloc>().add(const ClearMatchFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context.read<MatchBloc>().add(const ClearMatchFeedback());
            }
          },
          builder: (context, state) {
            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    if (state.seasons.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeLarge),
                        child: CommonLabeledDropdownWidget<int>(
                          label: 'Season',
                          hintText: 'Select season',
                          value: state.selectedSeasonId,
                          items: state.seasons
                              .map((s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.displayName),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              context
                                  .read<MatchBloc>()
                                  .add(SelectMatchSeason(v));
                            }
                          },
                        ),
                      ),
                    Expanded(child: _buildBody(context, state)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MatchState state) {
    if (state.status == MatchListStatus.loading && state.matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == MatchListStatus.failure && state.matches.isEmpty) {
      return AdminErrorView(
        message: state.errorMessage,
        onRetry: () => context.read<MatchBloc>().add(const InitMatchData()),
      );
    }
    if (state.seasons.isEmpty) {
      return const AdminEmptyView(
        message: 'No seasons found. Create a season first.',
        icon: Icons.event_busy_outlined,
      );
    }
    if (state.matches.isEmpty) {
      return const AdminEmptyView(
        message: 'No matches in this season yet.',
        icon: Icons.sports_soccer_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context
          .read<MatchBloc>()
          .add(SelectMatchSeason(state.selectedSeasonId ?? 0)),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeLarge,
          0,
          Dimensions.paddingSizeLarge,
          Dimensions.paddingSizeExtraLarge32 * 2,
        ),
        itemCount: state.matches.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: Dimensions.paddingSizeDefault),
        itemBuilder: (context, index) {
          final m = state.matches[index];
          return _MatchCard(
            match: m,
            onEnterData: () => context.push(
              AppRoutes.getMatchEntriesRoute(m.id),
              extra: m,
            ),
            onEdit: () => _openForm(context, match: m),
            onDelete: () => _confirmDelete(context, m),
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback onEnterData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MatchCard({
    required this.match,
    required this.onEnterData,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEnterData,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: context.customThemeColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.title,
                    style: AppTextStyles.sfProRoundedSemiBold
                        .copyWith(fontSize: Dimensions.fontSizeLarge),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusChip(status: match.status),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    switch (v) {
                      case 'data':
                        onEnterData();
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'data', child: Text('Enter data')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              children: [
                Text(
                  match.scoreLine,
                  style: AppTextStyles.sfProRoundedBold
                      .copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    [
                      if ((match.competitionName ?? '').isNotEmpty) match.competitionName!,
                      if (match.date.isNotEmpty) match.date,
                    ].join('  •  '),
                    style: AppTextStyles.sfProRoundedRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: context.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              children: [
                Icon(Icons.edit_note,
                    size: 16, color: context.primaryColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  'Tap to enter player stats',
                  style: AppTextStyles.sfProRoundedMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color _color(BuildContext context) {
    switch (status) {
      case 'finished':
        return context.customThemeColors.successColor;
      case 'cancelled':
        return context.errorColor;
      case 'live':
        return context.customThemeColors.warningColor;
      default:
        return context.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        status.capitalize,
        style: AppTextStyles.sfProRoundedMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: color,
        ),
      ),
    );
  }
}
