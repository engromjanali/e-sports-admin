import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/common_extensions.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/features/match/domain/entities/match_entity.dart';
import 'package:clean_boilerplate/features/match_entry/data/models/match_entry_model.dart';
import 'package:clean_boilerplate/features/match_entry/domain/entities/match_entry_entity.dart';
import 'package:clean_boilerplate/features/match_entry/presentation/bloc/match_entry_bloc.dart';
import 'package:clean_boilerplate/features/match_entry/presentation/widgets/match_entry_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Per-match data entry screen. [match] is optional context for the header;
/// [matchId] is the source of truth for loading entries.
class MatchEntryScreen extends StatelessWidget {
  final String matchId;
  final MatchEntity? match;

  const MatchEntryScreen({required this.matchId, super.key, this.match});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<MatchEntryBloc>()..add(InitMatchEntries(matchId)),
      child: _MatchEntryView(matchId: matchId, match: match),
    );
  }
}

class _MatchEntryView extends StatelessWidget {
  final String matchId;
  final MatchEntity? match;

  const _MatchEntryView({required this.matchId, this.match});

  Future<void> _openForm(
    BuildContext context, {
    MatchEntryEntity? entry,
  }) async {
    final bloc = context.read<MatchEntryBloc>();
    final state = bloc.state;
    if (entry == null && state.availablePlayers.isEmpty) {
      context.showAlertSnackBar(
        state.allPlayers.isEmpty
            ? 'Add players first to record stats.'
            : 'All players already have an entry for this match.',
      );
      return;
    }
    final result = await context.showCustomBottomSheet<MatchEntryEntity>(
      child: MatchEntryFormSheet(
        matchId: matchId,
        entry: entry,
        availablePlayers: state.availablePlayers,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    final withSeason = MatchEntryModel(
      id: result.id,
      playerId: result.playerId,
      matchId: result.matchId,
      goals: result.goals,
      goalsConceded: result.goalsConceded,
      hattricks: result.hattricks,
      cleanSheet: result.cleanSheet,
      motm: result.motm,
      result: result.result,
      notes: result.notes,
      source: result.source,
      seasonId: match?.seasonId,
    );
    bloc.add(UpsertMatchEntryRequested(withSeason));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MatchEntryEntity e,
  ) async {
    final bloc = context.read<MatchEntryBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text('Remove ${e.playerName ?? 'this player'}\'s stats?'),
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
    if (confirmed ?? false) bloc.add(DeleteMatchEntryRequested(e.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(match?.title ?? 'Match Data Entry'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add Entry'),
      ),
      body: SafeArea(
        child: BlocConsumer<MatchEntryBloc, MatchEntryState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context.read<MatchEntryBloc>().add(const ClearMatchEntryFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context.read<MatchEntryBloc>().add(const ClearMatchEntryFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == MatchEntryStatus.loading &&
                state.entries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == MatchEntryStatus.failure &&
                state.entries.isEmpty) {
              return AdminErrorView(
                message: state.errorMessage,
                onRetry: () =>
                    context.read<MatchEntryBloc>().add(InitMatchEntries(matchId)),
              );
            }

            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    if (match != null) _MatchHeader(match: match!),
                    Expanded(
                      child: state.entries.isEmpty
                          ? const AdminEmptyView(
                              message:
                                  'No entries yet. Tap "Add Entry" to record player stats.',
                              icon: Icons.assignment_outlined,
                            )
                          : RefreshIndicator(
                              onRefresh: () async => context
                                  .read<MatchEntryBloc>()
                                  .add(const ReloadMatchEntries()),
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeLarge,
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeLarge,
                                  Dimensions.paddingSizeExtraLarge32 * 2,
                                ),
                                itemCount: state.entries.length,
                                separatorBuilder: (_, _) => const SizedBox(
                                    height: Dimensions.paddingSizeDefault),
                                itemBuilder: (context, index) {
                                  final e = state.entries[index];
                                  return _EntryCard(
                                    entry: e,
                                    onEdit: () => _openForm(context, entry: e),
                                    onDelete: () => _confirmDelete(context, e),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  final MatchEntity match;
  const _MatchHeader({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match.title,
            style: AppTextStyles.sfProRoundedSemiBold
                .copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            [
              match.scoreLine,
              if ((match.competitionName ?? '').isNotEmpty) match.competitionName!,
              if (match.date.isNotEmpty) match.date,
            ].join('  •  '),
            style: AppTextStyles.sfProRoundedRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: context.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final MatchEntryEntity entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final img = entry.playerImageUrl;
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
          CircleAvatar(
            radius: 22,
            backgroundColor: context.primaryColor.withValues(alpha: 0.12),
            backgroundImage:
                (img != null && img.isNotEmpty) ? NetworkImage(img) : null,
            child: (img == null || img.isEmpty)
                ? Text(
                    (entry.playerName ?? '?').isNotEmpty
                        ? entry.playerName![0].toUpperCase()
                        : '?',
                    style: AppTextStyles.sfProRoundedSemiBold
                        .copyWith(color: context.primaryColor),
                  )
                : null,
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
                        entry.playerName ?? entry.playerId,
                        style: AppTextStyles.sfProRoundedSemiBold
                            .copyWith(fontSize: Dimensions.fontSizeDefault),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _ResultPill(result: entry.result),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Wrap(
                  spacing: Dimensions.paddingSizeSmall,
                  runSpacing: Dimensions.paddingSizeExtraSmall,
                  children: [
                    _StatBadge(label: 'G', value: '${entry.goals}'),
                    _StatBadge(label: 'GC', value: '${entry.goalsConceded}'),
                    if (entry.hattricks > 0)
                      _StatBadge(label: 'HT', value: '${entry.hattricks}'),
                    if (entry.cleanSheet) const _FlagBadge(label: 'Clean sheet'),
                    if (entry.motm) const _FlagBadge(label: 'MOTM'),
                  ],
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

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.customThemeColors.borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        '$label $value',
        style: AppTextStyles.sfProRoundedMedium
            .copyWith(fontSize: Dimensions.fontSizeExtraSmall),
      ),
    );
  }
}

class _FlagBadge extends StatelessWidget {
  final String label;
  const _FlagBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.customThemeColors.successColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: AppTextStyles.sfProRoundedMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: context.customThemeColors.successColor,
        ),
      ),
    );
  }
}

class _ResultPill extends StatelessWidget {
  final String result;
  const _ResultPill({required this.result});

  Color _color(BuildContext context) {
    switch (result) {
      case 'win':
        return context.customThemeColors.successColor;
      case 'loss':
        return context.errorColor;
      default:
        return context.customThemeColors.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        result.capitalize,
        style: AppTextStyles.sfProRoundedSemiBold.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: color,
        ),
      ),
    );
  }
}
