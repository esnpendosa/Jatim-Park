import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/data/models/species_model.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class EncyclopediaScreen extends ConsumerStatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  ConsumerState<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends ConsumerState<EncyclopediaScreen> {
  String _selectedCategory = 'semua';

  @override
  Widget build(BuildContext context) {
    final datasetList = [
      SpeciesModel(
        id: 1,
        name: 'Honda PCX 160',
        latinName: 'Motorcycle PCX 160cc',
        category: 'hewan',
        rarity: 'epic',
        habitat: 'Kawasan Rozitech Office',
        food: 'Pertamax Turbo',
        ecologicalRole: 'Kendaraan operasional utama Ranger Rozitech',
        conservationStatus: 'Aktif Beroperasi',
        baseCp: 1250,
        thumbnailUrl: 'assets/Honda PCX 160.jpg',
        funFact: 'Kendaraan matic premium armada survey lokasi Rozitech.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 2,
        name: 'Sandal Selop Karet Pria',
        latinName: 'Footwear Rubber Craft',
        category: 'hewan',
        rarity: 'rare',
        habitat: 'Markas Ranger Rozitech',
        food: 'Karet Alam',
        ecologicalRole: 'Perlengkapan wajib jalan kaki Ranger',
        conservationStatus: 'Siap Pakai',
        baseCp: 650,
        thumbnailUrl: 'assets/Sandal Selop Karet Pria.jpg',
        funFact: 'Perlengkapan kaki tahan air buatan lokal untuk patroli lapangan.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 3,
        name: 'Pohon Pisang',
        latinName: 'Musa paradisiaca',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Area Perkebunan Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Penyedia pangan dan penahan erosi tanah',
        conservationStatus: 'Melimpah (Least Concern)',
        baseCp: 450,
        thumbnailUrl: 'assets/Pohon Pisang.jpg',
        funFact: 'Tumbuhan terna raksasa yang daun dan buahnya bermanfaat bagi ekosistem.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 4,
        name: 'Lidah Mertua',
        latinName: 'Sansevieria trifasciata',
        category: 'tumbuhan',
        rarity: 'rare',
        habitat: 'Taman Edelweis Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Pembersih dan pemurni polusi udara',
        conservationStatus: 'Dilindungi (Protected)',
        baseCp: 750,
        thumbnailUrl: 'assets/Lidah Mertua.jpg',
        funFact: 'Tanaman hias penghasil oksigen tinggi dan penyerap zat beracun.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 5,
        name: 'Bayam Duri',
        latinName: 'Amaranthus spinosus',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Area Kebun Belakang',
        food: 'Fotosintesis',
        ecologicalRole: 'Tumbuhan obat alami ekosistem',
        conservationStatus: 'Melimpah',
        baseCp: 300,
        thumbnailUrl: 'assets/Bayam Duri.jpg',
        funFact: 'Tumbuhan obat tradisional dengan batang berduri khas.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 6,
        name: 'Rumput Ekor Kucing',
        latinName: 'Typha latifolia',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Lahan Lembab Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Penjaga kelembaban tanah dan mikroba',
        conservationStatus: 'Aman',
        baseCp: 350,
        thumbnailUrl: 'assets/Rumput Ekor Kucing.jpg',
        funFact: 'Tumbuhan unik berbentuk seperti ekor kucing yang tumbuh di area lembab.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 7,
        name: 'Saga Rambat',
        latinName: 'Abrus precatorius',
        category: 'tumbuhan',
        rarity: 'epic',
        habitat: 'Pagar Halaman Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Penutup tanah dan peneduh alami',
        conservationStatus: 'Langka (Rare)',
        baseCp: 950,
        thumbnailUrl: 'assets/Saga Rambat.jpg',
        funFact: 'Tumbuhan merambat dengan biji merah cantik yang khas.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 8,
        name: 'Kudzu',
        latinName: 'Pueraria montana',
        category: 'tumbuhan',
        rarity: 'rare',
        habitat: 'Area Perbukitan',
        food: 'Fotosintesis',
        ecologicalRole: 'Penyerap nitrogen tanah',
        conservationStatus: 'Terjaga',
        baseCp: 850,
        thumbnailUrl: 'assets/Kudzu.jpg',
        funFact: 'Tanaman polong-polongan merambat dengan daya tumbuh cepat.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 9,
        name: 'Daun Mangga',
        latinName: 'Mangifera indica',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Halaman Depan Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Peneduh dan produsen oksigen',
        conservationStatus: 'Aman',
        baseCp: 400,
        thumbnailUrl: 'assets/daun mangga.jpg',
        funFact: 'Daun pohon mangga kaya antioksidan alami.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 10,
        name: 'Harimau Sumatra',
        latinName: 'Panthera tigris sumatrae',
        category: 'hewan',
        rarity: 'legendary',
        habitat: 'Hutan Hujan Sumatra',
        food: 'Karnivora (Rusa, Babi Hutan)',
        ecologicalRole: 'Predator puncak pengendali ekosistem hutan',
        conservationStatus: 'Kritis (Critically Endangered)',
        baseCp: 1500,
        thumbnailUrl: 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=500',
        funFact: 'Harimau Sumatra adalah subspesies harimau terkecil yang masih ada di dunia.',
        isDiscovered: true,
      ),
    ];

    final filteredList = _selectedCategory == 'semua'
        ? datasetList
        : datasetList.where((s) => s.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ENSIKLOPEDIA EKOLOGI',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Katalog Spesies & Aset Terbuka di Sekitar Baloga & Rozitech',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _CategoryChip(
                          icon: Icons.grid_view_rounded,
                          label: 'Semua (10)',
                          isSelected: _selectedCategory == 'semua',
                          onTap: () => setState(() => _selectedCategory = 'semua'),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          icon: Icons.pets_rounded,
                          label: 'Hewan (3)',
                          isSelected: _selectedCategory == 'hewan',
                          onTap: () => setState(() => _selectedCategory = 'hewan'),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          icon: Icons.local_florist_rounded,
                          label: 'Tumbuhan (7)',
                          isSelected: _selectedCategory == 'tumbuhan',
                          onTap: () => setState(() => _selectedCategory = 'tumbuhan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _UnlockedSpeciesCard(species: filteredList[i]),
                  childCount: filteredList.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGlow : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryGlow : AppColors.textMuted.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockedSpeciesCard extends StatelessWidget {
  final SpeciesModel species;
  const _UnlockedSpeciesCard({required this.species});

  Color rarityColor(String rarity) {
    switch (rarity) {
      case 'legendary': return AppColors.rarityLegendary;
      case 'epic': return AppColors.rarityEpic;
      case 'rare': return AppColors.rarityRare;
      default: return AppColors.rarityCommon;
    }
  }

  Widget _buildImage(String? url, Color color) {
    if (url != null && url.startsWith('assets/')) {
      return Image.asset(url, height: 120, width: double.infinity, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: url ?? '',
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (c, u) => Container(height: 120, color: AppColors.bgCard, child: Icon(Icons.eco, color: color)),
      errorWidget: (c, u, e) => Container(height: 120, color: AppColors.bgCard, child: Icon(Icons.eco, color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(species.rarity);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.bgCard,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          isScrollControlled: true,
          builder: (ctx) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            builder: (_, sc) => _SpeciesDetailSheet(species: species, scrollController: sc),
          ),
        );
      },
      child: Container(
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
                  _buildImage(species.thumbnailUrl, color),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_open_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 3),
                          Text('TERBUKA', style: TextStyle(fontFamily: 'Outfit', fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        species.rarity.toUpperCase(),
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
                    species.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    species.latinName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (species.category == 'hewan' ? AppColors.accentBlue : AppColors.primaryGlow).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              species.category == 'hewan' ? Icons.pets_rounded : Icons.local_florist_rounded,
                              size: 10,
                              color: species.category == 'hewan' ? AppColors.accentBlue : AppColors.primaryGlow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              species.category == 'hewan' ? 'Hewan' : 'Tumbuhan',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: species.category == 'hewan' ? AppColors.accentBlue : AppColors.primaryGlow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesDetailSheet extends StatelessWidget {
  final SpeciesModel species;
  final ScrollController scrollController;
  const _SpeciesDetailSheet({required this.species, required this.scrollController});

  Widget _buildImage(String? url) {
    if (url != null && url.startsWith('assets/')) {
      return Image.asset(url, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: url ?? '',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (c, u) => Container(height: 200, color: AppColors.bgSurface),
      errorWidget: (c, u, e) => Container(height: 200, color: AppColors.bgSurface, child: const Icon(Icons.eco, size: 60, color: AppColors.textMuted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = species.conservationStatus.toLowerCase().contains('kritis') || species.conservationStatus.toLowerCase().contains('critically');

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),

        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _buildImage(species.thumbnailUrl),
        ),

        const SizedBox(height: 16),
        Text(species.name, style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(species.latinName, style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isCritical ? AppColors.danger : AppColors.primaryGlow).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: (isCritical ? AppColors.danger : AppColors.primaryGlow).withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, color: isCritical ? AppColors.danger : AppColors.primaryGlow, size: 16),
              const SizedBox(width: 6),
              Text(
                'STATUS: TERBUKA ENSIKLOPEDIA • ${species.conservationStatus}',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w800, color: isCritical ? AppColors.danger : AppColors.primaryGlow),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        _infoRow(Icons.terrain_rounded, 'Habitat Lokasi', species.habitat),
        if (species.food != null) _infoRow(Icons.restaurant_rounded, 'Pangan & Nutrisi', species.food!),
        _infoRow(Icons.eco_rounded, 'Peran Ekologi', species.ecologicalRole),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGlow.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGlow.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: AppColors.primaryGlow, size: 16),
                  SizedBox(width: 6),
                  Text('Fakta Singkat & Unik', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: AppColors.primaryGlow, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              Text(species.funFact, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white)),
          ],
        ),
      );
}
