import 'package:clean_boilerplate/config/route/app_router.dart';
import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/features/settings/domain/entities/theme_mode.dart';
import 'package:clean_boilerplate/features/settings/presentation/bloc/theme/theme_bloc.dart';
import 'package:clean_boilerplate/features/settings/presentation/bloc/theme/theme_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _contentMaxWidth = 1000.0;

  static int _columns(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double _hPad(double width) {
    final excess = width - _contentMaxWidth;
    return excess > 0 ? excess / 2 : Dimensions.paddingSizeLarge;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = _hPad(screenWidth);
    final columns = _columns(screenWidth);

    return Scaffold(
      drawer: const AppMenuDrawer(),
      body: CustomScrollView(
        slivers: [
          _HomeHeader(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              Dimensions.paddingSizeLarge,
              hPad,
              Dimensions.paddingSizeSmall,
            ),
            sliver: const SliverToBoxAdapter(
              child: _SectionTitle('Quick Access'),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              Dimensions.paddingSizeSmall,
              hPad,
              Dimensions.paddingSizeLarge,
            ),
            sliver: SliverGrid.count(
              crossAxisCount: columns,
              mainAxisSpacing: Dimensions.paddingSizeLarge,
              crossAxisSpacing: Dimensions.paddingSizeLarge,
              childAspectRatio: 1.15,
              children: const [
                _NavCard(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Matches',
                  subtitle: 'Fixtures & scores',
                  route: AppRoutes.matches,
                  gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                _NavCard(
                  icon: Icons.groups_rounded,
                  label: 'Players',
                  subtitle: 'Squad management',
                  route: AppRoutes.players,
                  gradient: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                ),
                _NavCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Seasons',
                  subtitle: 'Season records',
                  route: AppRoutes.seasons,
                  gradient: [Color(0xFFE65100), Color(0xFFFFB74D)],
                ),
                _NavCard(
                  icon: Icons.tune_rounded,
                  label: 'Business Setup',
                  subtitle: 'App configuration',
                  route: AppRoutes.businessSetup,
                  gradient: [Color(0xFF6A1B9A), Color(0xFFBA68C8)],
                ),
                _NavCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Competitions',
                  subtitle: 'Manage competitions',
                  route: AppRoutes.competitions,
                  gradient: [Color(0xFF00695C), Color(0xFF4DB6AC)],
                ),
                _NavCard(
                  icon: Icons.help_outline_rounded,
                  label: 'FAQs',
                  subtitle: 'Manage FAQ content',
                  route: AppRoutes.faqs,
                  gradient: [Color(0xFF37474F), Color(0xFF78909C)],
                ),
                _NavCard(
                  icon: Icons.label_rounded,
                  label: 'Tags',
                  subtitle: 'Roles & custom tags',
                  route: AppRoutes.tags,
                  gradient: [Color(0xFF880E4F), Color(0xFFE91E63)],
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              0,
              hPad,
              Dimensions.paddingSizeSmall,
            ),
            sliver: const SliverToBoxAdapter(
              child: _SectionTitle('Player Approval'),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              Dimensions.paddingSizeSmall,
              hPad,
              Dimensions.paddingSizeExtraLarge32 * 2,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ApprovalTile(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Pending Approval',
                  route: AppRoutes.pendingPlayer,
                  color: const Color(0xFFFFA726),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _ApprovalTile(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Approved Players',
                  route: AppRoutes.approvedPlayer,
                  color: const Color(0xFF66BB6A),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _ApprovalTile(
                  icon: Icons.block_rounded,
                  label: 'Suspended Players',
                  route: AppRoutes.suspendedPlayer,
                  color: const Color(0xFFEF5350),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              left: Dimensions.paddingSizeLarge,
              right: Dimensions.paddingSizeLarge,
              bottom: Dimensions.paddingSizeExtraLarge,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusExtraLarge),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ELITS FC',
                          style: AppTextStyles.sfProRoundedBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraOverLarge,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Admin Management Portal',
                          style: AppTextStyles.sfProRoundedRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0D47A1),
      title: Text(
        'ELITS FC Admin',
        style: AppTextStyles.sfProRoundedSemiBold.copyWith(
          color: Colors.white,
          fontSize: Dimensions.fontSizeLarge,
        ),
      ),
      titleSpacing: 0,
      actions: [
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            final isDark = state.maybeWhen(dark: (_) => true, orElse: () => false);
            return IconButton(
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Colors.white,
              ),
              onPressed: () => context.read<ThemeBloc>().add(
                    ThemeEvent.changeThemeMode(
                      isDark ? AppThemeMode.light : AppThemeMode.dark,
                    ),
                  ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.sfProRoundedSemiBold.copyWith(
        fontSize: Dimensions.fontSizeExtraLarge,
        color: context.textTheme.bodyLarge?.color,
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final List<Color> gradient;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const Spacer(),
                Text(
                  label,
                  style: AppTextStyles.sfProRoundedSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.sfProRoundedRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApprovalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _ApprovalTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.cardColor,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.sfProRoundedMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: context.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
