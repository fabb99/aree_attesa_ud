import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Interfaccia contrattuale per il fornitore di fotografie.
/// 
/// Questa astrazione permette in futuro di scambiare facilmente la sorgente
/// delle immagini (es. da Assets locali a Network/API) senza toccare la UI.
abstract class GameCPhotoProvider {
  Widget buildPhotoGallery(int safeZoneId, {double? height});
}

// ─── Implementazione Asset Locale ───────────────────────────────────────────

/// Implementazione che carica le foto dalla cartella locale degli assets.
/// 
/// Gestisce dinamicamente un numero variabile di foto per area provando
/// a caricare `1.jpeg`, `2.jpeg` ecc. finché non cattura un'eccezione
/// di "file non trovato", determinando così la fine della galleria.
class AssetPhotoProvider implements GameCPhotoProvider {
  /// Limite massimo di foto per prevenire loop infiniti imprevisti.
  final int maxPhotos;

  const AssetPhotoProvider({this.maxPhotos = 20});

  String _path(int safeZoneId, int index) =>
      'assets/safeZones/$safeZoneId/$index.jpeg';

  /// Esplora in modo asincrono l'esistenza delle foto per l'area specificata.
  Future<List<String>> _loadPaths(int safeZoneId) async {
    final paths = <String>[];
    for (int i = 1; i <= maxPhotos; i++) {
      final path = _path(safeZoneId, i);
      try {
        // Tenta il caricamento in memoria. Se il file non esiste, lancia eccezione.
        await rootBundle.load(path);
        paths.add(path);
      } catch (_) {
        break; // Primo file mancante trovato, fine della galleria.
      }
    }
    return paths;
  }

  @override
  Widget buildPhotoGallery(int safeZoneId, {double? height}) {
    return _AsyncPhotoGallery(
      safeZoneId: safeZoneId,
      loadPaths: _loadPaths,
      height: height,
    );
  }
}

// ─── Widget Asincrono Interno ───────────────────────────────────────────────

class _AsyncPhotoGallery extends StatefulWidget {
  final int safeZoneId;
  final Future<List<String>> Function(int) loadPaths;
  final double? height;

  const _AsyncPhotoGallery({
    required this.safeZoneId,
    required this.loadPaths,
    this.height,
  });

  @override
  State<_AsyncPhotoGallery> createState() => _AsyncPhotoGalleryState();
}

class _AsyncPhotoGalleryState extends State<_AsyncPhotoGallery> {
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadPaths(widget.safeZoneId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _LoadingPlaceholder(height: widget.height);
        }
        
        final paths = snapshot.data ?? [];
        if (paths.isEmpty) return _Placeholder(height: widget.height);
        
        if (paths.length == 1) {
          return Image.asset(
            paths.first,
            height: widget.height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _Placeholder(height: widget.height),
          );
        }
        
        return _PhotoGallery(paths: paths, height: widget.height);
      },
    );
  }
}

// ─── Galleria Interattiva (PageView) ──────────────────────────────────────────

class _PhotoGallery extends StatefulWidget {
  final List<String> paths;
  final double? height;
  const _PhotoGallery({required this.paths, this.height});

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.paths.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => Image.asset(
              widget.paths[i],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Placeholder(height: widget.height),
            ),
          ),

          // ── Indicatori a punti in basso ──
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.paths.length, (i) {
                final isActive = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withAlpha(102),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

          // ── Contatore X / Y in alto a destra ──
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.paths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ─── Placeholder Fallback ─────────────────────────────────────────────────────

class _LoadingPlaceholder extends StatelessWidget {
  final double? height;
  const _LoadingPlaceholder({this.height});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        color: AppColors.bgDark,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.gameCLight),
        ),
      );
}

class _Placeholder extends StatelessWidget {
  final double? height;
  const _Placeholder({this.height});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        color: AppColors.bgDark,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.white24, size: 48),
            SizedBox(height: 8),
            Text('Foto non disponibile',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
}