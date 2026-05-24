import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:flutter/material.dart';

enum PlayerStatusType {
  pending,
  approved,
  suspended,
}

class PlayerStatusScreen extends StatelessWidget {
  final PlayerStatusType statusType;

  const PlayerStatusScreen({
    required this.statusType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final title = switch (statusType) {
      PlayerStatusType.pending => context.local.pendingPlayer,
      PlayerStatusType.approved => context.local.approvedPlayer,
      PlayerStatusType.suspended => context.local.suspendedPlayer,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: const AppMenuDrawer(),
      body: SafeArea(
        child: statusType == PlayerStatusType.pending ? const _PendingPlayerList() : Center(
          child: Text(title),
        ),
      ),
    );
  }
}

class _PendingPlayerList extends StatelessWidget {
  const _PendingPlayerList();

  static const double _serialColumnWidth = 24;

  static const List<_DummyPlayer> _players = [
    _DummyPlayer(name: 'Rahim Uddin-------kjh khlkhjlkhjlkhlhihlk ;oij lkjpoi. j;lj --0-0---888'),
    _DummyPlayer(name: 'Karim Hasan'),
    _DummyPlayer(name: 'Nayeem Islam'),
    _DummyPlayer(name: 'Tanvir Ahmed'),
    _DummyPlayer(name: 'Sakib Rahman'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = ResponsiveHelper.isDesktop(context) ? Dimensions.webMaxWidth : constraints.maxWidth;

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tableWidth = constraints.maxWidth < 520 ? 520.0 : constraints.maxWidth;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          children: [
                            _PendingPlayerHeader(),
                            const Divider(height: 1),
                            ...List.generate(_players.length, (index) {
                              return _PendingPlayerRow(
                                serial: index + 1,
                                player: _players[index],
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PendingPlayerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.sfProRoundedSemiBold.copyWith(
      fontSize: Dimensions.fontSizeDefault,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _PendingPlayerList._serialColumnWidth,
            child: Text(context.local.sl, style: textStyle),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Text(context.local.name, style: textStyle),
          const Spacer(),
          Text(context.local.action, style: textStyle),
        ],
      ),
    );
  }
}

class _PendingPlayerRow extends StatelessWidget {
  final int serial;
  final _DummyPlayer player;

  const _PendingPlayerRow({
    required this.serial,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.sfProRoundedRegular.copyWith(
      fontSize: Dimensions.fontSizeDefault,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _PendingPlayerList._serialColumnWidth,
                child: Text('$serial', style: textStyle),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(player.name),
                        content: Text(context.local.pendingPlayer),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    player.name,
                    style: AppTextStyles.sfProRoundedMedium.copyWith(
                      color: context.primaryColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: context.local.edit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    tooltip: context.local.suspend,
                    icon: const Icon(Icons.block),
                    onPressed: () {},
                  ),
                  IconButton(
                    tooltip: context.local.approve,
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _DummyPlayer {
  final String name;

  const _DummyPlayer({required this.name});
}
