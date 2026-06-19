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
import 'package:clean_boilerplate/features/match_entry/data/models/match_entry_model.dart';
import 'package:clean_boilerplate/features/match_entry/domain/entities/match_entry_entity.dart';
import 'package:clean_boilerplate/features/match_entry/presentation/bloc/match_entry_bloc.dart';
import 'package:clean_boilerplate/features/match_entry/presentation/widgets/match_entry_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Standalone player data-entry screen. Pick a season and a match, then record
/// each player's stats for that match.
class MatchEntryScreen extends StatelessWidget {
  const MatchEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MatchEntryBloc>()..add(const InitMatchEntryData()),
      child: const _MatchEntryView(),
    );
  }
}

class _MatchEntryView extends StatelessWidget {
  const _MatchEntryView();

  Future<void> _openForm(
    BuildContext context, {
    MatchEntryEntity? entry,
  }) async {
    final bloc = context.read<MatchEntryBloc>();
    final state = bloc.state;
    if (state.selectedSeasonId == null) {
      context.showAlertSnackBar('Select a season first to record stats.');
      return;
    }
    if (entry == null && state.availablePlayers.isEmpty) {
      context.showAlertSnackBar(
        state.allPlayers.isEmpty
            ? 'Add players first to record stats.'
            : 'All players already have an entry for this season.',
      );
      return;
    }
    final result = await context.showCustomBottomSheet<MatchEntryEntity>(
      child: MatchEntryFormSheet(
        entry: entry,
        availablePlayers: state.availablePlayers,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    final withSeason = MatchEntryModel(
      id: result.id,
      playerId: result.playerId,
      goals: result.goals,
      goalsConceded: result.goalsConceded,
      hattricks: result.hattricks,
      cleanSheet: result.cleanSheet,
      motm: result.motm,
      result: result.result,
      notes: result.notes,
      seasonId: entry?.seasonId ?? state.selectedSeasonId,
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
      appBar: AppBar(title: const Text('Match Data Entry')),
      drawer: const AppMenuDrawer(),
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
            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    _Selectors(state: state),
                    Expanded(child: _body(context, state)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, MatchEntryState state) {
    if (state.status == MatchEntryStatus.failure && state.entries.isEmpty) {
      return AdminErrorView(
        message: state.errorMessage,
        onRetry: () =>
            context.read<MatchEntryBloc>().add(const InitMatchEntryData()),
      );
    }
    if (state.selectedSeasonId == null) {
      return const AdminEmptyView(
        message: 'Select a season to manage player entries.',
        icon: Icons.assignment_outlined,
      );
    }
    if (state.status == MatchEntryStatus.loading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.entries.isEmpty) {
      return const AdminEmptyView(
        message: 'No entries yet. Tap "Add Entry" to record player stats.',
        icon: Icons.assignment_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<MatchEntryBloc>().add(const ReloadMatchEntries()),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeLarge,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeLarge,
          Dimensions.paddingSizeExtraLarge32 * 2,
        ),
        itemCount: state.entries.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: Dimensions.paddingSizeDefault),
        itemBuilder: (context, index) {
          final e = state.entries[index];
          return _EntryCard(
            entry: e,
            onEdit: () => _openForm(context, entry: e),
            onDelete: () => _confirmDelete(context, e),
          );
        },
      ),
    );
  }
}

/// Season picker that drives which entries are shown.
class _Selectors extends StatelessWidget {
  final MatchEntryState state;
  const _Selectors({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeSmall,
      ),
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
            context.read<MatchEntryBloc>().add(SelectEntrySeason(v));
          }
        },
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
