import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../model/search_filter.dart';
import '../../service/wall_haven_api_service.dart';
import 'color_picker_widget.dart';

/// Bottom sheet filter panel for advanced search options
class SearchFilterPanel extends StatefulWidget {
  final SearchFilter filter;
  final ValueChanged<SearchFilter> onFilterChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const SearchFilterPanel({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<SearchFilterPanel> createState() => _SearchFilterPanelState();
}

class _SearchFilterPanelState extends State<SearchFilterPanel> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.filter;
  }

  void _updateFilter(SearchFilter newFilter) {
    setState(() => _filter = newFilter);
    widget.onFilterChanged(newFilter);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final apiService = GetIt.instance.get<WallHavenApiService>();
    final hasApiKey = apiService.apiKey != null && apiService.apiKey!.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _updateFilter(SearchFilter.defaultFilter);
                        widget.onReset();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Categories
                    _SectionTitle(title: 'Categories'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WallpaperCategory.values.map((cat) {
                        final isSelected = _filter.categories.contains(cat);
                        return FilterChip(
                          label: Text(cat.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            final newCategories = Set<WallpaperCategory>.from(
                              _filter.categories,
                            );
                            if (selected) {
                              newCategories.add(cat);
                            } else {
                              // Don't allow deselecting all
                              if (newCategories.length > 1) {
                                newCategories.remove(cat);
                              }
                            }
                            _updateFilter(
                              _filter.copyWith(categories: newCategories),
                            );
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Purity
                    _SectionTitle(title: 'Purity'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WallpaperPurity.values.map((purity) {
                        final isSelected = _filter.purities.contains(purity);
                        final isNsfw = purity == WallpaperPurity.nsfw;
                        final isDisabled = isNsfw && !hasApiKey;

                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(purity.label),
                              if (isDisabled) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.lock,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                          selected: isSelected,
                          onSelected: isDisabled
                              ? null
                              : (selected) {
                                  final newPurities = Set<WallpaperPurity>.from(
                                    _filter.purities,
                                  );
                                  if (selected) {
                                    newPurities.add(purity);
                                  } else {
                                    // Don't allow deselecting all
                                    if (newPurities.length > 1) {
                                      newPurities.remove(purity);
                                    }
                                  }
                                  _updateFilter(
                                    _filter.copyWith(purities: newPurities),
                                  );
                                },
                        );
                      }).toList(),
                    ),
                    if (!hasApiKey)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'NSFW requires API key',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Sorting
                    _SectionTitle(title: 'Sort By'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SortingOption.values.map((option) {
                        return ChoiceChip(
                          label: Text(option.label),
                          selected: _filter.sorting == option,
                          onSelected: (selected) {
                            if (selected) {
                              _updateFilter(_filter.copyWith(sorting: option));
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Sort order
                    Row(
                      children: SortOrder.values.map((order) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: order == SortOrder.desc ? 8 : 0,
                              left: order == SortOrder.asc ? 8 : 0,
                            ),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    order == SortOrder.desc
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(order.label),
                                ],
                              ),
                              selected: _filter.order == order,
                              onSelected: (selected) {
                                if (selected) {
                                  _updateFilter(_filter.copyWith(order: order));
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Resolution
                    _SectionTitle(title: 'Minimum Resolution'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Any'),
                          selected: _filter.atleast == null,
                          onSelected: (selected) {
                            if (selected) {
                              _updateFilter(_filter.copyWith(clearAtleast: true));
                            }
                          },
                        ),
                        ...ResolutionPreset.all.entries.map((entry) {
                          return ChoiceChip(
                            label: Text(entry.value),
                            selected: _filter.atleast == entry.key,
                            onSelected: (selected) {
                              if (selected) {
                                _updateFilter(
                                  _filter.copyWith(atleast: entry.key),
                                );
                              }
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Aspect ratio
                    _SectionTitle(title: 'Aspect Ratio'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Any'),
                          selected: _filter.ratios == null,
                          onSelected: (selected) {
                            if (selected) {
                              _updateFilter(_filter.copyWith(clearRatios: true));
                            }
                          },
                        ),
                        ...RatioPreset.ratios.entries.map((entry) {
                          return ChoiceChip(
                            label: Text(entry.value),
                            selected: _filter.ratios == entry.key,
                            onSelected: (selected) {
                              if (selected) {
                                _updateFilter(
                                  _filter.copyWith(ratios: entry.key),
                                );
                              }
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Color
                    _SectionTitle(title: 'Color'),
                    const SizedBox(height: 8),
                    ColorPickerWidget(
                      selectedColor: _filter.colors,
                      onColorSelected: (color) {
                        _updateFilter(
                          color == null
                              ? _filter.copyWith(clearColors: true)
                              : _filter.copyWith(colors: color),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Apply button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onApply,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
