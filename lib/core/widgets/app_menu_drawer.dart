import 'package:clean_boilerplate/config/route/app_router.dart';
import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/features/settings/domain/entities/theme_mode.dart';
import 'package:clean_boilerplate/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:clean_boilerplate/features/settings/presentation/bloc/theme/theme_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            _DrawerHeader(),
            _NavTile(
              icon: Icons.home_rounded,
              label: 'Home',
              route: AppRoutes.home,
              location: location,
            ),
            _NavTile(
              icon: Icons.business,
              label: context.local.businessSetup,
              route: AppRoutes.businessSetup,
              location: location,
            ),
            _SectionLabel(label: context.local.dataManagement),
            _NavTile(
              icon: Icons.event,
              label: context.local.seasons,
              route: AppRoutes.seasons,
              location: location,
            ),
            _NavTile(
              icon: Icons.groups,
              label: context.local.players,
              route: AppRoutes.players,
              location: location,
            ),
            _NavTile(
              icon: Icons.sports_soccer,
              label: context.local.matches,
              route: AppRoutes.matches,
              location: location,
            ),
            _NavTile(
              icon: Icons.assignment_rounded,
              label: 'Match Entries',
              route: AppRoutes.matchEntries,
              location: location,
            ),
            _NavTile(
              icon: Icons.emoji_events_rounded,
              label: 'Competitions',
              route: AppRoutes.competitions,
              location: location,
            ),
            _NavTile(
              icon: Icons.help_outline_rounded,
              label: 'FAQs',
              route: AppRoutes.faqs,
              location: location,
            ),
            _NavTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              route: AppRoutes.privacyPolicy,
              location: location,
            ),
            _NavTile(
              icon: Icons.label_rounded,
              label: 'Tag Management',
              route: AppRoutes.tags,
              location: location,
            ),
            _NavTile(
              icon: Icons.military_tech_rounded,
              label: 'Hall of Fame',
              route: AppRoutes.hallOfFame,
              location: location,
            ),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.how_to_reg),
              title: Text(context.local.playerApproval),
              initiallyExpanded: location == AppRoutes.pendingPlayer ||
                  location == AppRoutes.approvedPlayer ||
                  location == AppRoutes.suspendedPlayer,
              children: [
                _SubNavTile(
                  label: context.local.pendingPlayer,
                  route: AppRoutes.pendingPlayer,
                  location: location,
                ),
                _SubNavTile(
                  label: context.local.approvedPlayer,
                  route: AppRoutes.approvedPlayer,
                  location: location,
                ),
                _SubNavTile(
                  label: context.local.suspendedPlayer,
                  route: AppRoutes.suspendedPlayer,
                  location: location,
                ),
              ],
            ),
            const Divider(),
            const _ThemeSection(),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      color: context.primaryColor.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined,
              size: Dimensions.iconSizeLarge, color: context.primaryColor),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'ELITS FC Admin',
            style: AppTextStyles.sfProRoundedSemiBold
                .copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeSmall,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.sfProRoundedSemiBold.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: context.textTheme.bodySmall?.color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String location;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: location == route,
      onTap: () {
        context.pop();
        if (location != route) context.go(route);
      },
    );
  }
}

class _SubNavTile extends StatelessWidget {
  final String label;
  final String route;
  final String location;

  const _SubNavTile({
    required this.label,
    required this.route,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
      title: Text(label),
      selected: location == route,
      onTap: () {
        context.pop();
        if (location != route) context.go(route);
      },
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
      ),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final current = state.maybeWhen(
            dark: (_) => AppThemeMode.dark,
            light: (_) => AppThemeMode.light,
            orElse: () => AppThemeMode.system,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeSmall,
                ),
                child: Text(
                  'APPEARANCE',
                  style: AppTextStyles.sfProRoundedSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: context.textTheme.bodySmall?.color,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Row(
                children: [
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    label: 'Light',
                    selected: current == AppThemeMode.light,
                    onTap: () => context.read<ThemeBloc>().add(
                          const ThemeEvent.changeThemeMode(AppThemeMode.light),
                        ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  _ThemeOption(
                    icon: Icons.brightness_auto_rounded,
                    label: 'System',
                    selected: current == AppThemeMode.system,
                    onTap: () => context.read<ThemeBloc>().add(
                          const ThemeEvent.changeThemeMode(AppThemeMode.system),
                        ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark',
                    selected: current == AppThemeMode.dark,
                    onTap: () => context.read<ThemeBloc>().add(
                          const ThemeEvent.changeThemeMode(AppThemeMode.dark),
                        ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
            border: Border.all(
              color: selected ? primary : context.theme.dividerColor,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? primary : context.textTheme.bodySmall?.color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.sfProRoundedMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: selected ? primary : context.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
