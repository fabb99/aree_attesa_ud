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
      title: 'Cos\'è un\'area di attesa?',
      body: 'È il luogo dove la popolazione riceve le prime informazioni e generi '
          'di conforto dopo un\'emergenza.',
    ),
    AppTip(
      id: 'gen_2',
      title: 'Dove si trovano le aree di attesa?',
      body: 'Piazze, parcheggi e spazi aperti lontani da edifici a rischio, '
          'versanti instabili e impianti industriali pericolosi.',
    ),
    AppTip(
      id: 'gen_3',
      title: 'Come raggiungere un area di attesa?',
      body: 'A piedi, seguendo percorsi sicuri. Non usare l\'auto: '
          'le strade devono restare libere per i mezzi di soccorso.',
    ),
  
    // ── Gioco A ───────────────────────────────────────────────────────────────────
    AppTip(
      id: 'gameA_1',
      title: 'Usa i colori come guida',
      body: 'Verde = adiacente, giallo = vicino, arancione = nella zona, '
          'rosso = lontana. Concentrati sulle celle verdi!',
      gameTag: 'gameA',
    ),

    AppTip(
      id: 'gameA_2',
      title: 'Guarda il numero sulla cella',
      body: 'Il numero indica quante aree di attesa si trovano nelle celle '
          'immediatamente adiacenti. Usalo per mirare meglio.',
      gameTag: 'gameA',
    ),

    AppTip(
      id: 'gameA_3',
      title: 'Cerca i parchi e parcheggi',
      body:' Le aree di attesa sono spesso in spazi aperti come parchi e parcheggi. '
          'Zoomando sulla mappa puoi riconoscerli e mirare lì.',
      gameTag: 'gameA',
    ),

    // ── Gioco B ───────────────────────────────────────────────────────────────────
    AppTip(
      id: 'gameB_1',
      title: 'La distanza è la tua bussola',
      body: 'Ogni tap sbagliato mostra quante celle ti separano dalla risposta. '
          'Usala per restringere la zona di ricerca.',
      gameTag: 'gameB',
    ),
    AppTip(
      id: 'gameB_2',
      title: 'Ricorda i tap precedenti',
      body: ' Incrociando le distanze di due tap sbagliati puoi triangolare '
          'la posizione esatta.',
      gameTag: 'gameB',
    ),

    // ── Gioco C ───────────────────────────────────────────────────────────────────
    AppTip(
      id: 'gameC_1',
      title: 'Durante la scossa: se sei in casa',
      body: 'Riparati sotto un tavolo o una struttura portante. '
          'Allontanati da finestre e mobili pesanti. Non uscire finché non finisce.',
      gameTag: 'gameC',
    ),
    AppTip(
      id: 'gameC_2',
      title: 'Durante la scossa: se sei fuori',
      body: 'Allontanati dagli edifici e cerca uno spazio aperto. '
          'Evita alberi, cornicioni, lampioni e linee elettriche.',
      gameTag: 'gameC',
    ),
    AppTip(
      id: 'gameC_3',
      title: 'Dopo la scossa: prima di uscire',
      body: 'Chiudi gas, acqua e corrente elettrica. '
          'Usa le scale, mai l\'ascensore, e raggiungi l\'area di attesa a piedi.',
      gameTag: 'gameC',
    ),
    AppTip(
      id: 'gameC_4',
      title: 'Dopo la scossa: Non usare l\'auto',
      body: 'Le strade devono restare libere per i mezzi di soccorso. '
          'Raggiungi sempre l\'area di attesa a piedi.',
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