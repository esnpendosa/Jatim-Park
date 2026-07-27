import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/presentation/providers/inventory_provider.dart';
import 'package:baloga_ar_rescue/data/models/species_model.dart';
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
                  Tab(text: 'ITEM & BOLA'),
                  Tab(text: 'SPESIES TERSIMPAN'),
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
                _StackedCollectionTab(),
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
        'name': 'Buah Berry Nutrisi',
        'type': 'food',
        'quantity': invState.berries,
        'icon': Icons.apple_rounded,
        'color': AppColors.accentGold,
        'description': 'Memberi makan spesies untuk menenangkan dan meningkatkan sukses tangkap +30%.',
      },
      {
        'id': 3,
        'name': 'Radar Ekologi AR',
        'type': 'utility',
        'quantity': invState.radars,
        'icon': Icons.radar_rounded,
        'color': AppColors.accentPurple,
        'description': 'Meningkatkan akurasi pemindaian reticle target pada kamera AR.',
      },
      {
        'id': 4,
        'name': 'Serum Booster CP',
        'type': 'booster',
        'quantity': 2,
        'icon': Icons.science_rounded,
        'color': AppColors.rarityLegendary,
        'description': 'Meningkatkan CP spesies tersimpan sebesar +100 CP.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // BEKAL GRATIS RANGER BANNER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGlow.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryGlow.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, color: AppColors.primaryGlow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'CARA MENDAPATKAN ITEM BEKAL RANGER:',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '• Setiap Menangkap 1 Spesies: Hadiah otomatis +3 Eko-Sphere & +5 Buah Berry!\n• Selesaikan Misi Harian: Dapatkan +10 Eko-Sphere & +10 Berry gratis.\n• Klaim Bekal Harian: Tekan tombol di bawah untuk isi ulang stok.',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(inventoryProvider.notifier).addItems(spheres: 5, berries: 10, radars: 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.primaryGlow,
                        content: Text(
                          '🎁 BEKAL RANGER DIKLAIM! +5 Eko-Sphere & +10 Buah Berry ditambahkan!',
                          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: const Text(
                    'KLAIM BEKAL RANGER GRATIS (+5 BOLA & +10 BERRY)',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGlow,
                    foregroundColor: AppColors.bgDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...itemsList.map((item) {
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
        }),
      ],
    );
  }
}

class _StackedCollectionTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invState = ref.watch(inventoryProvider);
    final rawSpeciesList = invState.capturedSpecies;

    // GROUP & STACK CAPTURED SPECIES BY SPECIES NAME/ID
    final Map<String, Map<String, dynamic>> groupedMap = {};
    for (var sp in rawSpeciesList) {
      final key = sp.name;
      if (groupedMap.containsKey(key)) {
        groupedMap[key]!['count'] = (groupedMap[key]!['count'] as int) + 1;
      } else {
        groupedMap[key] = {
          'species': sp,
          'count': 1,
        };
      }
    }

    final stackedList = groupedMap.values.toList();

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
      itemCount: stackedList.length,
      itemBuilder: (ctx, i) {
        final itemData = stackedList[i];
        final sp = itemData['species'] as SpeciesModel;
        final count = itemData['count'] as int;
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

                    // STACKED QUANTITY BADGE (x1, x2, x3, etc.)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGlow,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
                        ),
                        child: Text(
                          'x$count',
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),

                    // RARITY TAG
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
