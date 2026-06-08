/// Modello e contenuto delle tips educative.
///
/// Aggiungi nuove tips alla lista [allTips].
/// [gameTag] null  → tip generale (mostrata in tutti i giochi).
/// [gameTag] 'gameA' / 'gameB' / 'gameC' → mostrata solo in quel gioco.
class AppTip {
  final String id;
  final String title;
  final String body;
  final String? gameTag;

  const AppTip({
    required this.id,
    required this.title,
    required this.body,
    this.gameTag,
  });
}
abstract final class AppTips {
  static const List<AppTip> allTips = [
    AppTip(
      id: 'gen_1',
      title: 'Il ruolo delle aree di attesa',
      body:
          'Sono piazze o spazi aperti sicuri destinati alla prima accoglienza. '
          'Qui riceverai le prime informazioni sull\'evento e generi di conforto '
          'in attesa delle aree di ricovero.',
    ),
    AppTip(
      id: 'gen_2',
      title: 'Se sei in casa: durante la scossa',
      body:
          'Non usare le scale, l\'ascensore o i balconi. Riparati sotto tavoli, '
          'letti o strutture portanti, tenendoti lontano da finestre, vetrate '
          'e mobili pesanti.',
    ),
    AppTip(
      id: 'gen_3',
      title: 'Se sei in casa: dopo la scossa',
      body:
          'Aspetta la fine della scossa prima di uscire per evitare calcinacci. '
          'Se possibile, prima di abbandonare la casa chiudi gli interruttori '
          'di gas, acqua e corrente elettrica.',
    ),
    AppTip(
      id: 'gen_4',
      title: 'Se ti trovi all\'aperto',
      body:
          'Allontanati dagli edifici e raggiungi subito l\'area di attesa più vicina. '
          'Evita assolutamente di fermarti vicino ad alberi, cornicioni, lampioni '
          'o linee elettriche.',
    ),
    AppTip(
      id: 'gen_5',
      title: 'Non usare l\'automobile',
      body:
          'Durante un\'emergenza non prendere l\'auto per spostarti. È vitale '
          'che le strade rimangano completamente libere per consentire '
          'il passaggio dei mezzi di soccorso.',
    ),
  
    // ── Specifiche Gioco A ────────────────────────────────────────────────────
    AppTip(
      id: 'gameA_1',
      title: 'Suggerimento: usa i colori',
      body:
          'Le celle verdi sono vicine a un\'area di attesa reale. '
          'Nella realtà, imparare a orientarsi visivamente nel quartiere '
          'ti aiuta a memorizzare dove si trovano questi punti di raccolta.',
      gameTag: 'gameA',
    ),

    // ── Specifiche Gioco B ────────────────────────────────────────────────────
    AppTip(
      id: 'gameB_1',
      title: 'Impara gli indirizzi',
      body:
          'Memorizzare il nome e l\'indirizzo di almeno un\'area di attesa '
          'vicino a casa o al lavoro è una delle azioni più utili '
          'che puoi fare per la tua sicurezza.',
      gameTag: 'gameB',
    ),

    // ── Specifiche Gioco C ────────────────────────────────────────────────────
    AppTip(
      id: 'gameC_1',
      title: 'Riconosci i luoghi familiari',
      body:
          'Le foto ti mostrano i luoghi come li vedresti camminando. '
          'Familiarizzare visivamente con le aree di attesa ti permette '
          'di riconoscerle e raggiungerle anche sotto stress.',
      gameTag: 'gameC',
    ),
  ];

  /// Tips applicabili a [gameTag]: tutte le generali + quelle specifiche.
  static List<AppTip> forGame(String gameTag) => allTips
      .where((t) => t.gameTag == null || t.gameTag == gameTag)
      .toList();

  /// Seleziona una tip casuale tra quelle disponibili per [gameTag],
  /// escludendo opzionalmente un id già mostrato di recente.
  static AppTip pickRandom(String gameTag, {String? excludeId}) {
    final pool = forGame(gameTag)
        .where((t) => t.id != excludeId)
        .toList();
    final source = pool.isNotEmpty ? pool : forGame(gameTag);
    source.shuffle();
    return source.first;
  }
}