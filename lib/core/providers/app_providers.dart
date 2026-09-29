import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/grid_repository.dart';
import '../data/safe_zone_repository.dart';

/// Provider di dipendenza condivisi in tutta l'applicazione.
///
/// Definire i repository qui come singleton tramite Provider garantisce
/// che la cache e la logica di accesso ai dati non vengano duplicate, 
/// ed evita istanze multiple accidentali tra i diversi mini-giochi.

final gridRepositoryProvider = Provider(
  (_) => GridRepository(),
  name: 'gridRepositoryProvider',
);

final safeZoneRepositoryProvider = Provider(
  (_) => SafeZoneRepository(),
  name: 'safeZoneRepositoryProvider',
);