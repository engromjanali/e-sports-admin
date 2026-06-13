import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/extensions/overly_extensions.dart';
import 'package:clean_boilerplate/core/helpers/responsive_helper.dart';
import 'package:clean_boilerplate/core/widgets/admin_state_views.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/features/competition/domain/entities/competition_entity.dart';
import 'package:clean_boilerplate/features/competition/presentation/bloc/competition_bloc.dart';
import 'package:clean_boilerplate/features/competition/presentation/widgets/competition_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompetitionScreen extends StatelessWidget {
  const CompetitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CompetitionBloc>()..add(const LoadCompetitions()),
      child: const _CompetitionView(),
    );
  }
}

class _CompetitionView extends StatelessWidget {
  const _CompetitionView();

  Future<void> _openForm(BuildContext context,
      {CompetitionEntity? competition}) async {
    final bloc = context.read<CompetitionBloc>();
    final result = await context.showCustomBottomSheet<CompetitionEntity>(
      child: CompetitionFormSheet(competition: competition),
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
    if (result == null) return;
    if (competition == null) {
      bloc.add(CreateCompetitionRequested(result));
    } else {
      bloc.add(UpdateCompetitionRequested(result));
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, CompetitionEntity c) async {
    final bloc = context.read<CompetitionBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete competition?'),
        content: Text(
            'Delete "${c.name}"? Existing matches will keep their competition label.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text('Delete', style: TextStyle(color: context.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(DeleteCompetitionRequested(c.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Competitions')),
      drawer: const AppMenuDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Competition'),
      ),
      body: SafeArea(
        child: BlocConsumer<CompetitionBloc, CompetitionState>(
          listenWhen: (p, c) =>
              p.actionMessage != c.actionMessage ||
              p.actionError != c.actionError,
          listener: (context, state) {
            if (state.actionMessage != null) {
              context.showSuccessSnackBar(state.actionMessage);
              context
                  .read<CompetitionBloc>()
                  .add(const ClearCompetitionFeedback());
            } else if (state.actionError != null) {
              context.showErrorSnackBar(state.actionError);
              context
                  .read<CompetitionBloc>()
                  .add(const ClearCompetitionFeedback());
            }
          },
          builder: (context, state) {
            if (state.status == CompetitionStatus.loading &&
                state.competitions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == CompetitionStatus.failure &&
                state.competitions.isEmpty) {
              return AdminErrorView(
                message: state.errorMessage,
                onRetry: () => context
                    .read<CompetitionBloc>()
                    .add(const LoadCompetitions()),
              );
            }
            if (state.competitions.isEmpty) {
              return const AdminEmptyView(
                message: 'No competitions yet. Add the first one.',
                icon: Icons.emoji_events_outlined,
              );
            }

            final maxWidth = ResponsiveHelper.isDesktop(context)
                ? Dimensions.webMaxWidth
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: RefreshIndicator(
                  onRefresh: () async => context
                      .read<CompetitionBloc>()
                      .add(const LoadCompetitions()),
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemCount: state.competitions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                    itemBuilder: (context, index) {
                      final c = state.competitions[index];
                      return _CompetitionCard(
                        competition: c,
                        onEdit: () => _openForm(context, competition: c),
                        onDelete: () => _confirmDelete(context, c),
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

class _CompetitionCard extends StatelessWidget {
  final CompetitionEntity competition;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CompetitionCard({
    required this.competition,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: context.customThemeColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: competition.isActive
                  ? context.primaryColor.withValues(alpha: 0.12)
                  : context.textTheme.bodySmall!.color!
                      .withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 20,
              color: competition.isActive
                  ? context.primaryColor
                  : context.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  competition.name,
                  style: AppTextStyles.sfProRoundedSemiBold
                      .copyWith(fontSize: Dimensions.fontSizeDefault),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!competition.isActive)
                  Text(
                    'Hidden from dropdown',
                    style: AppTextStyles.sfProRoundedRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: context.textTheme.bodySmall?.color,
                    ),
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
