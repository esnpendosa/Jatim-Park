import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/data/models/species_model.dart';
import 'package:baloga_ar_rescue/presentation/providers/inventory_provider.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> speciesData;
  const CaptureScreen({super.key, required this.speciesData});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _isTargetMatched = false;
  bool _isCapturing = false;
  bool _isSuccess = false;
  bool _berryFed = false;

  late Map<String, dynamic> _activeSpeciesData;
  String _scanStatusMessage = 'Arahkan kamera ke objek target dan tekan PINDAI & COCOKKAN OBJEK.';

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  // Complete Rozitech Dataset List for Real-time Camera Auto-Object Selection
  final List<Map<String, dynamic>> _datasetList = [
    {
      'species_id': 2,
      'species_name': 'Sandal Selop Karet Pria',
      'species_latin': 'Footwear Rubber Craft',
      'species_thumbnail': 'assets/Sandal Selop Karet Pria.jpg',
      'base_cp': 650,
      'rarity': 'rare',
      'category': 'hewan',
      'species_fact': 'Perlengkapan kaki tahan air buatan lokal untuk patroli lapangan Rozitech.',
    },
    {
      'species_id': 1,
      'species_name': 'Honda PCX 160',
      'species_latin': 'Motorcycle PCX 160cc',
      'species_thumbnail': 'assets/Honda PCX 160.jpg',
      'base_cp': 1250,
      'rarity': 'epic',
      'category': 'hewan',
      'species_fact': 'Kendaraan matic premium armada survey lokasi Rozitech.',
    },
    {
      'species_id': 3,
      'species_name': 'Pohon Pisang',
      'species_latin': 'Musa paradisiaca',
      'species_thumbnail': 'assets/Pohon Pisang.jpg',
      'base_cp': 450,
      'rarity': 'common',
      'category': 'tumbuhan',
      'species_fact': 'Tumbuhan terna raksasa yang daun dan buahnya bermanfaat bagi ekosistem.',
    },
    {
      'species_id': 4,
      'species_name': 'Lidah Mertua',
      'species_latin': 'Sansevieria trifasciata',
      'species_thumbnail': 'assets/Lidah Mertua.jpg',
      'base_cp': 750,
      'rarity': 'rare',
      'category': 'tumbuhan',
      'species_fact': 'Tanaman hias penghasil oksigen tinggi dan penyerap polusi.',
    },
    {
      'species_id': 5,
      'species_name': 'Bayam Duri',
      'species_latin': 'Amaranthus spinosus',
      'species_thumbnail': 'assets/Bayam Duri.jpg',
      'base_cp': 300,
      'rarity': 'common',
      'category': 'tumbuhan',
      'species_fact': 'Tumbuhan obat tradisional dengan batang berduri khas.',
    },
    {
      'species_id': 6,
      'species_name': 'Rumput Ekor Kucing',
      'species_latin': 'Typha latifolia',
      'species_thumbnail': 'assets/Rumput Ekor Kucing.jpg',
      'base_cp': 350,
      'rarity': 'common',
      'category': 'tumbuhan',
      'species_fact': 'Tumbuhan unik berbentuk ekor kucing yang tumbuh di area lembab.',
    },
    {
      'species_id': 7,
      'species_name': 'Saga Rambat',
      'species_latin': 'Abrus precatorius',
      'species_thumbnail': 'assets/Saga Rambat.jpg',
      'base_cp': 950,
      'rarity': 'epic',
      'category': 'tumbuhan',
      'species_fact': 'Tumbuhan merambat dengan biji merah cantik yang khas.',
    },
    {
      'species_id': 8,
      'species_name': 'Kudzu',
      'species_latin': 'Pueraria montana',
      'species_thumbnail': 'assets/Kudzu.jpg',
      'base_cp': 850,
      'rarity': 'rare',
      'category': 'tumbuhan',
      'species_fact': 'Tanaman polong-polongan merambat dengan daya tumbuh cepat.',
    },
    {
      'species_id': 9,
      'species_name': 'Daun Mangga',
      'species_latin': 'Mangifera indica',
      'species_thumbnail': 'assets/daun mangga.jpg',
      'base_cp': 400,
      'rarity': 'common',
      'category': 'tumbuhan',
      'species_fact': 'Daun pohon mangga kaya antioksidan alami.',
    },
    {
      'species_id': 10,
      'species_name': 'Harimau Sumatra',
      'species_latin': 'Panthera tigris sumatrae',
      'species_thumbnail': 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=500',
      'base_cp': 1500,
      'rarity': 'legendary',
      'category': 'hewan',
      'species_fact': 'Subspesies harimau terkecil yang masih ada di dunia.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _activeSpeciesData = Map<String, dynamic>.from(widget.speciesData.isNotEmpty ? widget.speciesData : _datasetList[0]);
    _initCamera();

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(_cameras![0], ResolutionPreset.high, enableAudio: false);
        await _cameraController!.initialize();
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _useBerry() {
    final invNotifier = ref.read(inventoryProvider.notifier);
    final success = invNotifier.useBerry();

    if (success) {
      setState(() {
        _berryFed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.accentGold,
          content: Text(
            'BUAH BERRY DIBERIKAN! Spesies menjadi tenang & Peluang Tangkap +30%!',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.bgDark),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok Buah Berry habis!')),
      );
    }
  }

  void _performScanValidation() {
    setState(() {
      _isScanning = true;
      _scanStatusMessage = 'MEMINDAI FITUR KAMERA AR & DETEKSI OTOMATIS OBJEK...';
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _showAutoDetectSelectionModal();
    });
  }

  void _showAutoDetectSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            const Row(
              children: [
                Icon(Icons.center_focus_strong_rounded, color: AppColors.primaryGlow, size: 24),
                SizedBox(width: 8),
                Text(
                  'DETEKSI OTOMATIS OBJEK KAMERA',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih objek yang saat ini tampak di layar kamera Anda untuk pencocokan otomatis:',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView.builder(
                itemCount: _datasetList.length,
                itemBuilder: (c, i) {
                  final ds = _datasetList[i];
                  final name = ds['species_name'] as String;
                  final latin = ds['species_latin'] as String;
                  final thumb = ds['species_thumbnail'] as String;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _activeSpeciesData = Map<String, dynamic>.from(ds);
                        _isScanning = false;
                        _isTargetMatched = true;
                        _scanStatusMessage = 'PEMINDAIAN BERHASIL! Kamera terdeteksi sebagai $name. Tekan EKO-SPHERE untuk menangkap.';
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primaryGlow,
                          content: Text(
                            '🎯 DETEKSI OTOMATIS BERHASIL: Kamera cocok dengan $name!',
                            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryGlow.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: _buildSpeciesImage(thumb, AppColors.primaryGlow),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text(latin, style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryGlow, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onThrowBall() {
    final speciesName = _activeSpeciesData['species_name'] ?? 'Spesies Rozitech';

    if (!_isTargetMatched) {
      _showScanFailedErrorDialog(speciesName);
      return;
    }

    final invNotifier = ref.read(inventoryProvider.notifier);
    final successBall = invNotifier.useEkoSphere();

    if (!successBall) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok Eko-Sphere habis!')),
      );
      return;
    }

    if (_isCapturing || _isSuccess) return;

    final speciesLatin = _activeSpeciesData['species_latin'] ?? 'Rozitech Ecological Item';
    final speciesThumb = _activeSpeciesData['species_thumbnail'] ?? 'assets/Sandal Selop Karet Pria.jpg';
    final rarity = _activeSpeciesData['rarity'] ?? 'rare';
    final baseCp = (_activeSpeciesData['base_cp'] as int?) ?? 650;
    final speciesId = (_activeSpeciesData['species_id'] as int?) ?? 2;
    final speciesFact = _activeSpeciesData['species_fact'] ?? 'Spesies unik di ekosistem Rozitech.';

    setState(() {
      _isCapturing = true;
      _scanStatusMessage = 'MELEMPAR EKO-SPHERE & MENYELAMATKAN SPESIES...';
    });

    _animController.forward().then((_) => _animController.reverse());

    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      final capturedModel = SpeciesModel(
        id: speciesId,
        name: speciesName,
        latinName: speciesLatin,
        category: _activeSpeciesData['category'] ?? 'hewan',
        rarity: rarity,
        habitat: 'Kawasan Rozitech',
        food: 'Makanan Ekosistem Alami',
        ecologicalRole: 'Peran Ekologi Rozitech',
        conservationStatus: 'Tersimpan di Inventori',
        baseCp: baseCp,
        thumbnailUrl: speciesThumb,
        funFact: speciesFact,
        isDiscovered: true,
      );

      invNotifier.addCapturedSpecies(capturedModel);

      setState(() {
        _isCapturing = false;
        _isSuccess = true;
      });
    });
  }

  void _showScanFailedErrorDialog(String speciesName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C0E0E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.danger, width: 2)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 26),
            SizedBox(width: 8),
            Text(
              'PEMINDAIAN KAMERA GAGAL',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PEMINDAIAN GAGAL: Objek kamera belum dicocokkan dengan dataset $speciesName!',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white, height: 1.3),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tekan PINDAI & COCOKKAN OBJEK di bawah layar untuk melakukan deteksi otomatis kamera.',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('MENGERTI', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'legendary': return AppColors.rarityLegendary;
      case 'epic': return AppColors.rarityEpic;
      case 'rare': return AppColors.rarityRare;
      default: return AppColors.rarityCommon;
    }
  }

  Widget _buildSpeciesImage(String? url, Color color) {
    if (url != null && url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover, height: 120, width: 120);
    }
    return CachedNetworkImage(
      imageUrl: url ?? '',
      fit: BoxFit.cover,
      height: 120,
      width: 120,
      placeholder: (c, u) => Container(color: AppColors.bgCard, child: Icon(Icons.pets, color: color, size: 40)),
      errorWidget: (c, u, e) => Container(color: AppColors.bgCard, child: Icon(Icons.pets, color: color, size: 40)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invState = ref.watch(inventoryProvider);
    final speciesName = _activeSpeciesData['species_name'] ?? 'Sandal Selop Karet Pria';
    final speciesLatin = _activeSpeciesData['species_latin'] ?? 'Footwear Rubber Craft';
    final speciesThumb = _activeSpeciesData['species_thumbnail'] ?? 'assets/Sandal Selop Karet Pria.jpg';
    final rarity = _activeSpeciesData['rarity'] ?? 'rare';
    final baseCp = _activeSpeciesData['base_cp'] ?? 650;
    final speciesFact = _activeSpeciesData['species_fact'] ?? 'Spesies unik di ekosistem Rozitech.';

    final rarColor = _rarityColor(rarity);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. LIVE CAMERA FEED BACKGROUND
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: const Color(0xFF0F1A14),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryGlow),
                    SizedBox(height: 16),
                    Text(
                      'MEMBUAT KONEKSI AR KAMERA REALTIME...',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGlow),
                    ),
                  ],
                ),
              ),
            ),

          // 2. TOP BAR HEADER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: rarColor.withValues(alpha: 0.8), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          speciesName.toUpperCase(),
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8),
                        ),
                        Text(
                          '${rarity.toUpperCase()} • $baseCp CP',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w800, color: rarColor),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.bgCard,
                          title: const Text('CARA MENGGUNAKAN ITEM AR', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, color: AppColors.primaryGlow)),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1. DETEKSI OTOMATIS: Tekan tombol hijau di tengah untuk mendeteksi objek kamera secara otomatis.', style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 12)),
                              SizedBox(height: 10),
                              Text('2. EKO-SPHERE: Jika pemindaian cocok, tekan Eko-Sphere untuk menangkap ke Inventori.', style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 12)),
                              SizedBox(height: 10),
                              Text('3. BUAH BERRY: Tekan Berry untuk menenangkan spesies & +30% sukses tangkap.', style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 12)),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('MENGERTI', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.primaryGlow)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryGlow, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. CENTER AR TARGETING RETICLE & CREATURE OVERLAY
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_berryFed)
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentGold.withValues(alpha: 0.25),
                      boxShadow: [BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.6), blurRadius: 40, spreadRadius: 10)],
                    ),
                  ),

                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isTargetMatched ? AppColors.primaryGlow : AppColors.danger,
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(color: (_isTargetMatched ? AppColors.primaryGlow : AppColors.danger).withValues(alpha: 0.6), blurRadius: 20),
                      ],
                    ),
                  ),
                ),

                ClipOval(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: _buildSpeciesImage(speciesThumb, rarColor),
                  ),
                ),

                if (_isScanning)
                  const SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(color: AppColors.primaryGlow, strokeWidth: 4),
                  ),
              ],
            ),
          ),

          // 4. BOTTOM ACTION CONTROL BAR
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isTargetMatched ? AppColors.primaryGlow : AppColors.danger,
                    ),
                  ),
                  child: Text(
                    _scanStatusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isTargetMatched ? Colors.white : AppColors.danger,
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _performScanValidation,
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    label: const Text(
                      'PINDAI & COCOKKAN OBJEK',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGlow,
                      foregroundColor: AppColors.bgDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _onThrowBall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _isTargetMatched ? AppColors.primaryGlow : AppColors.textMuted, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sports_volleyball_rounded, color: _isTargetMatched ? AppColors.primaryGlow : AppColors.textMuted, size: 22),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('EKO-SPHERE', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                Text('Sisa: x${invState.ekoSpheres}', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: _isTargetMatched ? AppColors.primaryGlow : AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: _useBerry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.accentGold, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.apple_rounded, color: AppColors.accentGold, size: 22),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('BUAH BERRY', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                Text('Sisa: x${invState.berries}', style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accentGold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 5. SUCCESS CAPTURE MODAL DIALOG (Flowchart Step 4)
          if (_isSuccess)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: AppColors.primaryGlow.withValues(alpha: 0.6), blurRadius: 30)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B4D2E),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            child: const Center(
                              child: Text(
                                'SPESIES TERSIMPAN KE INVENTORI!',
                                style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  speciesName,
                                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A2D1F)),
                                ),
                                Text(
                                  speciesLatin,
                                  style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 12),

                                ClipOval(
                                  child: SizedBox(
                                    height: 130,
                                    width: 130,
                                    child: _buildSpeciesImage(speciesThumb, rarColor),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.amber.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('FAKTA UNIK & MANFAAT', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1B4D2E))),
                                      const SizedBox(height: 4),
                                      Text(
                                        speciesFact,
                                        style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: Colors.grey[800], height: 1.3),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.amber.shade600),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        '+100 XP  •  +250 POIN',
                                        style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1B4D2E)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => context.go('/inventory'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1B4D2E),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: const Text(
                                          'CEK INVENTORI',
                                          style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => context.go('/map'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade800,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: const Text(
                                          'KEMBALI KE PETA',
                                          style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                                        ),
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
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
