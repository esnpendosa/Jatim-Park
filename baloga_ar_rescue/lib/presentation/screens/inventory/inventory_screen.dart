import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/presentation/providers/inventory_provider.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'INVENTORI & KOLEKSI RANGER',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabCtrl,
                labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500, fontSize: 13),
                labelColor: AppColors.primaryGlow,
                unselectedLabelColor: AppColors.textMuted,
                indicator: BoxDecoration(
                  color: AppColors.primaryGlow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '🎒 ITEM & BOLA'),
                  Tab(text: '🦁 SPESIES TERSIMPAN'),
                ],
              ),
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
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invState = ref.watch(inventoryProvider);

    final itemsList = [
      {
        'id': 1,
        'name': 'Eko-Sphere Regular',
        'type': 'ball',
        'quantity': invState.ekoSpheres,
        'icon': Icons.sports_volleyball,
        'color': AppColors.primaryGlow,
        'description': 'Bola penangkap standar untuk menyelamatkan spesies flora & fauna.',
      },
      {
        'id': 2,
        'name': 'Eko-Sphere Great',
        'type': 'ball',
        'quantity': 5,
        'icon': Icons.sports_baseball,
        'color': AppColors.accentBlue,
        'description': 'Bola tingkat tinggi dengan rasio penangkapan 1.5x lebih kuat.',
      },
      {
        'id': 3,
        'name': 'Buah Berry Nutrisi',
        'type': 'food',
        'quantity': invState.berries,
        'icon': Icons.apple_rounded,
        'color': AppColors.accentGold,
        'description': 'Memberi makan spesies untuk menenangkan dan meningkatkan sukses tangkap +30%.',
      },
      {
        'id': 4,
        'name': 'Radar Ekologi AR',
        'type': 'utility',
        'quantity': invState.radars,
        'icon': Icons.radar_rounded,
        'color': AppColors.accentPurple,
        'description': 'Meningkatkan akurasi pemindaian reticle target pada kamera AR.',
      },
      {
        'id': 5,
        'name': 'Serum Booster CP',
        'type': 'booster',
        'quantity': 2,
        'icon': Icons.science_rounded,
        'color': AppColors.rarityLegendary,
        'description': 'Meningkatkan CP spesies tersimpan sebesar +100 CP.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemsList.length,
      itemBuilder: (ctx, i) {
        final item = itemsList[i];
        final color = item['color'] as Color;
        final qty = item['quantity'] as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item['icon'] as IconData, color: color, size: 28),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['description'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'x$qty',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CollectionTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invState = ref.watch(inventoryProvider);
    final speciesList = invState.capturedSpecies;

    Color rarityColor(String rarity) {
      switch (rarity) {
        case 'legendary': return AppColors.rarityLegendary;
        case 'epic': return AppColors.rarityEpic;
        case 'rare': return AppColors.rarityRare;
        default: return AppColors.rarityCommon;
      }
    }

    Widget buildImageWidget(String? url, Color color) {
      if (url != null && url.startsWith('assets/')) {
        return Image.asset(url, fit: BoxFit.cover, height: 110, width: double.infinity);
      }
      return CachedNetworkImage(
        imageUrl: url ?? '',
        height: 110,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (c, u) => Container(height: 110, color: AppColors.bgCard, child: Icon(Icons.pets, color: color)),
        errorWidget: (c, u, e) => Container(height: 110, color: AppColors.bgCard, child: Icon(Icons.pets, color: color)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: speciesList.length,
      itemBuilder: (ctx, i) {
        final sp = speciesList[i];
        final rarity = sp.rarity;
        final color = rarityColor(rarity);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    buildImageWidget(sp.thumbnailUrl, color),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          rarity.toUpperCase(),
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(6)),
                        child: const Text(
                          'TERSIMPAN',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sp.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      sp.latinName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sp.baseCp} CP',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accentGold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
