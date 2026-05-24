import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
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
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }
}
