import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/features/player/domain/entities/player_entity.dart';
import 'package:clean_boilerplate/features/player/presentation/bloc/player_bloc.dart';
import 'package:clean_boilerplate/features/player/presentation/widgets/player_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlayerBloc>()..add(const LoadPlayers()),
      child: const _PlayerView(),
    );
  }
}

class _PlayerView extends StatelessWidget {
  const _PlayerView();

  Future<void> _openForm(BuildContext context, {PlayerEntity? player}) async {
    final bloc = context.read<PlayerBloc>();
    final result = await context.showCustomBottomSheet<PlayerEntity>(
      child: PlayerFormSheet(player: player),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    if (player == null) {
      bloc.add(CreatePlayerRequested(result));
    } else {
      bloc.add(UpdatePlayerRequested(result));
    }
  }

  Future<void> _confirmDelete(BuildContext context, PlayerEntity p) async {
    final bloc = context.read<PlayerBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete player?'),
        content: Text('Delete "${p.name}"? This cannot be undone.'),
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
    if (confirmed ?? false) bloc.add(DeletePlayerRequested(p.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      drawer: const AppMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Player'),
      ),
      body: SafeArea(
        child: BlocConsumer<PlayerBloc, PlayerState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context.read<PlayerBloc>().add(const ClearPlayerFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context.read<PlayerBloc>().add(const ClearPlayerFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == PlayerStatus.loading && state.players.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == PlayerStatus.failure && state.players.isEmpty) {
              return AdminErrorView(
                message: state.errorMessage,
                onRetry: () =>
                    context.read<PlayerBloc>().add(const LoadPlayers()),
              );
            }
            if (state.players.isEmpty) {
              return const AdminEmptyView(
                message: 'No players yet. Add your squad.',
                icon: Icons.groups_outlined,
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
                      context.read<PlayerBloc>().add(const LoadPlayers()),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemCount: state.players.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                    itemBuilder: (context, index) {
                      final p = state.players[index];
                      return _PlayerCard(
                        player: p,
                        onEdit: () => _openForm(context, player: p),
                        onDelete: () => _confirmDelete(context, p),
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

class _PlayerCard extends StatelessWidget {
  final PlayerEntity player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlayerCard({
    required this.player,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final img = player.profileImageUrl;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: context.customThemeColors.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: context.primaryColor.withValues(alpha: 0.12),
            backgroundImage:
                (img != null && img.isNotEmpty) ? NetworkImage(img) : null,
            child: (img == null || img.isEmpty)
                ? Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
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
                Text(
                  player.name,
                  style: AppTextStyles.sfProRoundedSemiBold
                      .copyWith(fontSize: Dimensions.fontSizeLarge),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (player.jerseyNumber != null) '#${player.jerseyNumber}',
                    if (player.playerRoles.isNotEmpty)
                      player.playerRoles.join(', '),
                  ].join('  •  '),
                  style: AppTextStyles.sfProRoundedRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: context.textTheme.bodySmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
