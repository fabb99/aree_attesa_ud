import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/grid_repository.dart';
import 'data/safe_zone_repository.dart';

/// Provider condivisi tra tutti i giochi.
///
/// Definiti una sola volta qui in `core/` per evitare la ridefinizione
/// identica in ogni feature (game_a, game_b, game_c), che causerebbe
/// istanze separate e potenziali conflitti nel grafo di dipendenze Riverpod.
///
/// Uso: importare questo file invece di ridichiarare i provider localmente.
final gridRepositoryProvider = Provider(
  (_) => GridRepository(),
  name: 'gridRepositoryProvider',
);

final safeZoneRepositoryProvider = Provider(
  (_) => SafeZoneRepository(),
  name: 'safeZoneRepositoryProvider',
);