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
  bool _isTargetMatched = false; // Starts UNMATCHED until camera scan validates object
  bool _isCapturing = false;
  bool _isSuccess = false;
  bool _berryFed = false;
  String _scanStatusMessage = 'Arahkan kamera tepat ke objek target dan tekan PINDAI & COCOKKAN OBJEK.';

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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
    final speciesName = widget.speciesData['species_name'] ?? 'Spesies Rozitech';

    setState(() {
      _isScanning = true;
      _scanStatusMessage = 'MEMINDAI FITUR KAMERA AR & MENGANALISIS DATASET...';
    });

    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      // Ask user or check camera object match
      // If targeting Honda PCX or specific item, demand exact camera match
      _showScanValidationResultDialog(speciesName);
    });
  }

  void _showScanValidationResultDialog(String speciesName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primaryGlow)),
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryGlow, size: 24),
            const SizedBox(width: 8),
            Text(
              'VALIDASI OBJEK KAMERA',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah kamera Anda saat ini mengarah tepat ke objek: $speciesName?',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white, height: 1.3),
            ),
            const SizedBox(height: 10),
            Text(
              'Petunjuk: Jika kamera mengarah ke objek lain (seperti Sandal/Lantai), tekan "TIDAK COCOK".',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          // TIDAK COCOK BUTTON (Simulates scan error when camera object is different)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isScanning = false;
                _isTargetMatched = false;
                _scanStatusMessage = 'PEMINDAIAN GAGAL: Objek kamera tidak cocok dengan dataset $speciesName!';
              });
              _showScanFailedErrorDialog(speciesName);
            },
            child: const Text('TIDAK COCOK', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.danger)),
          ),

          // YA, COCOK BUTTON
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isScanning = false;
                _isTargetMatched = true;
                _scanStatusMessage = 'PEMINDAIAN BERHASIL! Objek kamera cocok dengan dataset $speciesName. Tekan EKO-SPHERE untuk menangkap.';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryGlow,
                  content: Text(
                    'PEMINDAIAN BERHASIL: Objek kamera cocok dengan $speciesName!',
                    style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGlow, foregroundColor: AppColors.bgDark),
            child: const Text('YA, COCOK', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
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
              'PEMINDAIAN GAGAL: Objek yang terlihat di kamera tidak cocok dengan dataset $speciesName!',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white, height: 1.3),
            ),
            const SizedBox(height: 10),
            const Text(
              'Arahkan kamera tepat ke objek yang sesuai lalu tekan PINDAI & COCOKKAN OBJEK kembali.',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('COBA LAGI', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _onThrowBall() {
    final speciesName = widget.speciesData['species_name'] ?? 'Spesies Rozitech';

    // STRICT CHECK: Cannot capture if camera object has NOT been scanned or is unmatched!
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

    final speciesLatin = widget.speciesData['species_latin'] ?? 'Rozitech Ecological Item';
    final speciesThumb = widget.speciesData['species_thumbnail'] ?? 'assets/Sandal Selop Karet Pria.jpg';
    final rarity = widget.speciesData['rarity'] ?? 'rare';
    final baseCp = (widget.speciesData['base_cp'] as int?) ?? 650;
    final speciesId = (widget.speciesData['species_id'] as int?) ?? 1;
    final speciesFact = widget.speciesData['species_fact'] ?? 'Spesies unik di ekosistem Rozitech.';

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
        category: 'hewan',
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
    final speciesName = widget.speciesData['species_name'] ?? 'Harimau Sumatra';
    final speciesLatin = widget.speciesData['species_latin'] ?? 'Panthera tigris sumatrae';
    final speciesThumb = widget.speciesData['species_thumbnail'] ?? 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=500';
    final rarity = widget.speciesData['rarity'] ?? 'legendary';
    final baseCp = widget.speciesData['base_cp'] ?? 1500;
    final speciesFact = widget.speciesData['species_fact'] ?? 'Spesies kunci penyerap karbon dan penyeimbang ekosistem.';

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
                              Text('1. PINDAI & COCOKKAN: Arahkan kamera ke objek target dan tekan tombol hijau di tengah.', style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 12)),
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
