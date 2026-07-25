import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/data/services/inventory_service.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

final inventoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) => InventoryService().getInventory());
final itemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) => InventoryService().getItems());

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Inventori', style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  Text('Item & koleksi spesiesmu', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                    child: TabBar(
                      controller: _tabCtrl,
                      labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w400, fontSize: 13),
                      labelColor: AppColors.primaryGlow,
                      unselectedLabelColor: AppColors.textMuted,
                      indicator: BoxDecoration(color: AppColors.primaryGlow.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      dividerColor: Colors.transparent,
                      tabs: const [Tab(text: '🧪 Item'), Tab(text: '🐾 Koleksi')],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _ItemsTab(),
                  _CollectionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    return itemsAsync.when(
      data: (items) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) => _ItemCard(item: items[i]),
      ),
      loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryGlow))),
      error: (e, _) => Center(child: Text('Gagal memuat item', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.danger))),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final typeColors = {
      'capture_ball': AppColors.accentBlue,
      'scanner': AppColors.primaryGlow,
      'radar': AppColors.accentGold,
      'booster': AppColors.accentPurple,
    };
    final color = typeColors[item['type']] ?? AppColors.textMuted;
    final qty = item['quantity'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: qty > 0 ? color.withOpacity(0.35) : AppColors.textMuted.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_itemIcon(item['type']), color: color, size: 26),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
                    Text(item['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          // Stock badge
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: qty > 0 ? color : AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('x$qty', style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _itemIcon(String? type) {
    switch (type) {
      case 'capture_ball': return Icons.catching_pokemon;
      case 'scanner': return Icons.document_scanner_outlined;
      case 'radar': return Icons.radar;
      case 'booster': return Icons.local_florist;
      default: return Icons.inventory_2_outlined;
    }
  }
}

class _CollectionTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invAsync = ref.watch(inventoryProvider);
    return invAsync.when(
      data: (inventory) => inventory.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.catching_pokemon, color: AppColors.textMuted, size: 52),
                const SizedBox(height: 12),
                const Text('Belum ada spesies yang ditangkap', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 6),
                Text('Pergi ke Peta dan mulai selamatkan spesies!', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted.withOpacity(0.6), fontSize: 12)),
              ]),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: inventory.length,
              itemBuilder: (ctx, i) => _CapturedCard(item: inventory[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryGlow))),
      error: (e, _) => Center(child: Text('Gagal memuat koleksi', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.danger))),
    );
  }
}

class _CapturedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _CapturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final species = item['species'] as Map<String, dynamic>?;
    if (species == null) return const SizedBox.shrink();
    final rarity = species['rarity'] ?? 'common';
    final color = rarityColor(rarity);
    final thumbUrl = species['thumbnail_url'] as String?;
    final qty = (item['quantity'] as num? ?? 0).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                thumbUrl != null
                    ? CachedNetworkImage(imageUrl: thumbUrl, height: 110, width: double.infinity, fit: BoxFit.cover,
                        placeholder: (c, u) => Container(height: 110, color: AppColors.bgSurface, child: const Center(child: Icon(Icons.eco, color: AppColors.textMuted, size: 32))),
                        errorWidget: (c, u, e) => Container(height: 110, color: AppColors.bgSurface, child: const Center(child: Icon(Icons.eco, color: AppColors.textMuted, size: 32))))
                    : Container(height: 110, color: AppColors.bgSurface, child: const Center(child: Icon(Icons.eco, color: AppColors.textMuted, size: 32))),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.85), borderRadius: BorderRadius.circular(6)),
                    child: Text(rarity.toUpperCase(), style: const TextStyle(fontFamily: 'Outfit', fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.bgDark.withOpacity(0.75), borderRadius: BorderRadius.circular(6)),
                    child: Text('x$qty', style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(species['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
                Text(species['latin_name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

