import 'package:clean_boilerplate/config/route/app_router.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.business),
              title: Text(context.local.businessSetup),
              selected: location == AppRoutes.businessSetup,
              onTap: () {
                context.pop();
                if (location != AppRoutes.businessSetup) {
                  context.go(AppRoutes.businessSetup);
                }
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.groups),
              title: Text(context.local.player),
              initiallyExpanded: location == AppRoutes.pendingPlayer || location == AppRoutes.approvedPlayer || location == AppRoutes.suspendedPlayer,
              children: [
                ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
                  title: Text(context.local.pendingPlayer),
                  selected: location == AppRoutes.pendingPlayer,
                  onTap: () {
                    context.pop();
                    if (location != AppRoutes.pendingPlayer) {
                      context.go(AppRoutes.pendingPlayer);
                    }
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
                  title: Text(context.local.approvedPlayer),
                  selected: location == AppRoutes.approvedPlayer,
                  onTap: () {
                    context.pop();
                    if (location != AppRoutes.approvedPlayer) {
                      context.go(AppRoutes.approvedPlayer);
                    }
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
                  title: Text(context.local.suspendedPlayer),
                  selected: location == AppRoutes.suspendedPlayer,
                  onTap: () {
                    context.pop();
                    if (location != AppRoutes.suspendedPlayer) {
                      context.go(AppRoutes.suspendedPlayer);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
