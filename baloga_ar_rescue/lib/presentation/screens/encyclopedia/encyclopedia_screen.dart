import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/data/models/species_model.dart';
import 'package:baloga_ar_rescue/data/services/species_service.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

final speciesListProvider = FutureProvider.family<List<SpeciesModel>, String?>((ref, category) async {
  return SpeciesService().getAllSpecies(category: category);
});

class EncyclopediaScreen extends ConsumerStatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  ConsumerState<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends ConsumerState<EncyclopediaScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(speciesListProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ensiklopedia', style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  Text('Spesies Nusantara', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  // Filter tabs
                  Row(
                    children: [
                      _filterChip('Semua', null),
                      const SizedBox(width: 8),
                      _filterChip('Hewan', 'hewan'),
                      const SizedBox(width: 8),
                      _filterChip('Tumbuhan', 'tumbuhan'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Species grid
            Expanded(
              child: speciesAsync.when(
                data: (species) => GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: species.length,
                  itemBuilder: (ctx, i) => _SpeciesCard(species: species[i]),
                ),
                loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryGlow))),
                error: (e, _) => Center(child: Text('Gagal memuat data\n$e', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.danger))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? category) {
    final active = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryLight : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primaryLight : AppColors.textMuted.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMuted)),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final SpeciesModel species;
  const _SpeciesCard({required this.species});

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(species.rarity);
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(species.isDiscovered ? 0.5 : 0.15), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  species.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: species.thumbnailUrl!,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(height: 130, color: AppColors.bgSurface, child: const Center(child: Icon(Icons.eco_outlined, color: AppColors.textMuted, size: 40))),
                          errorWidget: (ctx, url, err) => Container(height: 130, color: AppColors.bgSurface, child: const Center(child: Icon(Icons.eco_outlined, color: AppColors.textMuted, size: 40))),
                        )
                      : Container(height: 130, color: AppColors.bgSurface, child: const Center(child: Icon(Icons.eco_outlined, color: AppColors.textMuted, size: 40))),

                  // Undiscovered fog
                  if (!species.isDiscovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Center(child: Icon(Icons.lock_outline, color: AppColors.textMuted, size: 32)),
                      ),
                    ),

                  // Rarity badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withOpacity(0.85), borderRadius: BorderRadius.circular(8)),
                      child: Text(species.rarity.toUpperCase(), style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(species.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(species.latinName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (species.category == 'hewan' ? AppColors.accentBlue : AppColors.primaryLight).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          species.category == 'hewan' ? '🦁 Hewan' : '🌿 Tumbuhan',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w600, color: species.category == 'hewan' ? AppColors.accentBlue : AppColors.primaryLight),
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

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, sc) => _SpeciesDetailSheet(species: species, scrollController: sc),
      ),
    );
  }
}

class _SpeciesDetailSheet extends StatelessWidget {
  final SpeciesModel species;
  final ScrollController scrollController;
  const _SpeciesDetailSheet({required this.species, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isCritical = species.conservationStatus.toLowerCase().contains('kritis') || species.conservationStatus.toLowerCase().contains('critically');
    final color = rarityColor(species.rarity);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withOpacity(0.4), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),

        // Image
        if (species.thumbnailUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(imageUrl: species.thumbnailUrl!, height: 200, fit: BoxFit.cover,
                placeholder: (c, u) => Container(height: 200, color: AppColors.bgSurface),
                errorWidget: (c, u, e) => Container(height: 200, color: AppColors.bgSurface, child: const Icon(Icons.eco, size: 60, color: AppColors.textMuted))),
          ),

        const SizedBox(height: 16),
        Text(species.name, style: const TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        Text(species.latinName, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
        const SizedBox(height: 12),

        // Status konservasi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isCritical ? AppColors.danger : AppColors.warning).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: (isCritical ? AppColors.danger : AppColors.warning).withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber, color: isCritical ? AppColors.danger : AppColors.warning, size: 14),
              const SizedBox(width: 6),
              Flexible(child: Text(species.conservationStatus, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: isCritical ? AppColors.danger : AppColors.warning))),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _infoRow('🏔️ Habitat', species.habitat),
        if (species.food != null) _infoRow('🍃 Makanan', species.food!),
        _infoRow('🌱 Peran Ekologi', species.ecologicalRole),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡 Fakta Menarik', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: color, fontSize: 13)),
              const SizedBox(height: 6),
              Text(species.funFact, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      );
}

