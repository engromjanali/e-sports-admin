import 'package:clean_boilerplate/config/util/dimensions.dart';
import 'package:clean_boilerplate/config/util/styles.dart';
import 'package:clean_boilerplate/core/di/injection.dart';
import 'package:clean_boilerplate/core/extensions/context_extensions.dart';
import 'package:clean_boilerplate/core/widgets/app_menu_drawer.dart';
import 'package:clean_boilerplate/features/tags/data/datasources/tags_data_source.dart';
import 'package:clean_boilerplate/features/tags/domain/entities/tag_entity.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = TagsDataSource(getIt<SupabaseClient>());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tag Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Player Roles'),
              Tab(text: 'Custom Tags'),
            ],
          ),
        ),
        drawer: const AppMenuDrawer(),
        body: TabBarView(
          children: [
            _TagListTab(dataSource: ds, isRoles: true),
            _TagListTab(dataSource: ds, isRoles: false),
          ],
        ),
      ),
    );
  }
}

class _TagListTab extends StatefulWidget {
  final TagsDataSource dataSource;
  final bool isRoles;

  const _TagListTab({required this.dataSource, required this.isRoles});

  @override
  State<_TagListTab> createState() => _TagListTabState();
}

class _TagListTabState extends State<_TagListTab>
    with AutomaticKeepAliveClientMixin {
  List<TagEntity> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = widget.isRoles
          ? await widget.dataSource.getRoles()
          : await widget.dataSource.getCustomTags();
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _add() async {
    final name = await _showAddDialog();
    if (name == null || !mounted) return;
    try {
      final item = widget.isRoles
          ? await widget.dataSource.createRole(name)
          : await widget.dataSource.createCustomTag(name);
      if (mounted) {
        setState(() {
          _items = [..._items, item]..sort((a, b) => a.name.compareTo(b.name));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: context.errorColor),
        );
      }
    }
  }

  Future<void> _delete(TagEntity item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${item.name}"?'),
        content: const Text(
          'This removes it from all players. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: ctx.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      if (widget.isRoles) {
        await widget.dataSource.deleteRole(item.id);
      } else {
        await widget.dataSource.deleteCustomTag(item.id);
      }
      if (mounted) setState(() => _items = _items.where((e) => e.id != item.id).toList());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: context.errorColor),
        );
      }
    }
  }

  Future<String?> _showAddDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isRoles ? 'Add Role' : 'Add Custom Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: widget.isRoles ? 'e.g. Striker' : 'e.g. Academy',
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) Navigator.pop(ctx, v);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(widget.isRoles ? 'Add Role' : 'Add Tag'),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isRoles ? Icons.label_outline : Icons.style_outlined,
                    size: 48,
                    color: context.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(
                    widget.isRoles
                        ? 'No roles yet. Tap + to add one.'
                        : 'No custom tags yet. Tap + to add one.',
                    style: AppTextStyles.sfProRoundedRegular.copyWith(
                      color: context.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeLarge,
                  Dimensions.paddingSizeLarge,
                  Dimensions.paddingSizeLarge,
                  Dimensions.paddingSizeExtraLarge32 * 3,
                ),
                itemCount: _items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      color: context.theme.cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusLarge),
                      border: Border.all(
                          color: context.customThemeColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Icon(
                            widget.isRoles
                                ? Icons.label_rounded
                                : Icons.style_rounded,
                            size: 18,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTextStyles.sfProRoundedMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _delete(item),
                          icon: Icon(Icons.delete_outline,
                              color: context.errorColor),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
