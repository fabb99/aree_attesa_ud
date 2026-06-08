import '../../../core/models/hex_cell.dart';
import '../../../core/models/safe_zone.dart';

enum GameAPhase { loading, playing, finished }

class GameAState {
  final List<HexCell> cells;
  final List<SafeZone> safeZones;
  final int movesLeft;
  final int totalMoves;
  final int foundSafeZones;
  final int totalSafeZones;
  final GameAPhase phase;
  final String? lastFoundName;
  final String? lastFoundAddress;

  /// Contatore mosse sbagliate dall'ultima tip mostrata.
  /// Resettato a 0 ogni volta che viene mostrata una tip.
  final int wrongTapsSinceLastTip;

  /// Flag alzato dal notifier quando la soglia è raggiunta.
  /// La screen lo legge, mostra la tip e chiama [clearShowTip].
  final bool showTip;

  const GameAState({
    required this.cells,
    required this.safeZones,
    required this.movesLeft,
    required this.totalMoves,
    required this.foundSafeZones,
    required this.totalSafeZones,
    this.phase = GameAPhase.loading,
    this.lastFoundName,
    this.lastFoundAddress,
    this.wrongTapsSinceLastTip = 0,
    this.showTip = false,
  });

  GameAState copyWith({
    List<HexCell>? cells,
    List<SafeZone>? safeZones,
    int? movesLeft,
    int? totalMoves,
    int? foundSafeZones,
    int? totalSafeZones,
    GameAPhase? phase,
    String? lastFoundName,
    String? lastFoundAddress,
    bool clearLastFound = false,
    int? wrongTapsSinceLastTip,
    bool? showTip,
  }) {
    return GameAState(
      cells: cells ?? this.cells,
      safeZones: safeZones ?? this.safeZones,
      movesLeft: movesLeft ?? this.movesLeft,
      totalMoves: totalMoves ?? this.totalMoves,
      foundSafeZones: foundSafeZones ?? this.foundSafeZones,
      totalSafeZones: totalSafeZones ?? this.totalSafeZones,
      phase: phase ?? this.phase,
      lastFoundName:
          clearLastFound ? null : (lastFoundName ?? this.lastFoundName),
      lastFoundAddress:
          clearLastFound ? null : (lastFoundAddress ?? this.lastFoundAddress),
      wrongTapsSinceLastTip:
          wrongTapsSinceLastTip ?? this.wrongTapsSinceLastTip,
      showTip: showTip ?? this.showTip,
    );
  }

  /// Punteggio: percentuale di safe zone trovate * 100
  int get score =>
      totalSafeZones == 0 ? 0 : (foundSafeZones * 100 ~/ totalSafeZones);

  /// Numero di mosse usate
  int get movesUsed => totalMoves - movesLeft;

  static GameAState initial() => const GameAState(
        cells: [],
        safeZones: [],
        movesLeft: 0,
        totalMoves: 0,
        foundSafeZones: 0,
        totalSafeZones: 0,
        phase: GameAPhase.loading,
        wrongTapsSinceLastTip: 0,
        showTip: false,
      );
}