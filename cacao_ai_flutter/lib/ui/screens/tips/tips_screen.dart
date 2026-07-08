import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/tips_provider.dart';
import '../../../data/models/tip.dart';
import '../../theme/app_theme.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Tous';

  final List<String> _categories = ['Tous', 'Sol', 'Maladies', 'Technique'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tipsProvider = Provider.of<TipsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conseils Agricoles'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.textLight,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Tous les conseils'),
            Tab(text: 'Mes Favoris'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category filter bar (only shown if not empty)
            if (_tabController.index == 0) _buildCategoryFilterBar(),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: All tips list
                  _buildTipsList(
                    tipsProvider,
                    tipsProvider.tips.where((t) {
                      if (_selectedCategory == 'Tous') return true;
                      return t.category.toLowerCase() == _selectedCategory.toLowerCase();
                    }).toList(),
                  ),
                  
                  // Tab 2: Favorites list
                  _buildTipsList(
                    tipsProvider,
                    tipsProvider.favoriteTips,
                    emptyMessage: 'Aucun conseil dans vos favoris.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              disabledColor: AppTheme.bgCard,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipsList(TipsProvider provider, List<Tip> list, {String? emptyMessage}) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
    }

    if (list.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 48, color: AppTheme.primaryGreen),
              const SizedBox(height: 16),
              Text(
                emptyMessage ?? 'Aucun conseil disponible pour cette catégorie.',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchTips(),
      color: AppTheme.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final tip = list[index];
          return _buildTipCard(provider, tip);
        },
      ),
    );
  }

  Widget _buildTipCard(TipsProvider provider, Tip tip) {
    final dateStr = DateFormat('dd MMM yyyy').format(tip.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: AppTheme.softShadow,
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tip.category.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dateStr,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4),
          child: Text(
            tip.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            tip.isFavorite ? Icons.bookmark : Icons.bookmark_border,
            color: tip.isFavorite ? AppTheme.primaryGreen : AppTheme.textMuted,
          ),
          onPressed: () {
            provider.toggleFavorite(tip.id);
          },
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tip.content,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textLight),
          ),
        ],
        onExpansionChanged: (expanded) {
          if (expanded) {
            provider.addToHistory(tip.id);
          }
        },
      ),
    );
  }
}
