import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';

/// Horizontal scrolling tab bar driven by a plain list of [labels]. The owning
/// feature maps the selected index back onto its own category enum.
class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({
    super.key,
    required this.controller,
    required this.labels,
    required this.onIndexChanged,
  });

  final TabController controller;
  final List<String> labels;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: onIndexChanged,
        tabs: [for (final label in labels) Tab(text: label, height: 44)],
      ),
    );
  }
}
