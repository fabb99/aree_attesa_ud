import 'package:flutter/material.dart';

/// Schermata guida ai giochi — accessibile dalla Home tramite icona "?".
/// Self-contained: nessun provider, nessuna dipendenza esterna.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F0A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Come si gioca',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 2,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'GIOCO A'),
            Tab(text: 'GIOCO B'),
            Tab(text: 'GIOCO C'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GameGuideTab(config: _gameAGuide),
          _GameGuideTab(config: _gameBGuide),
          _GameGuideTab(config: _gameCGuide),
        ],
      ),
    );
  }
}

// ─── Tab contenuto guida ──────────────────────────────────────────────────────

class _GameGuideTab extends StatelessWidget {
  final _GuideConfig config;

  const _GameGuideTab({required this.config});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header gioco ───────────────────────────────────────────
          _GameHeader(config: config),
          const SizedBox(height: 32),

          // ── Obiettivo ─────────────────────────────────────────────
          _Section(
            icon: Icons.flag_rounded,
            title: 'OBIETTIVO',
            accentColor: config.accentColor,
            child: _ParagraphText(config.objective),
          ),
          const SizedBox(height: 24),

          // ── Come si gioca ─────────────────────────────────────────
          _Section(
            icon: Icons.touch_app_rounded,
            title: 'COME SI GIOCA',
            accentColor: config.accentColor,
            child: Column(
              children: config.steps
                  .asMap()
                  .entries
                  .map((e) => _StepRow(
                        number: e.key + 1,
                        text: e.value,
                        accentColor: config.accentColor,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Legenda colori (solo se presente) ─────────────────────
          if (config.legend != null) ...[
            _Section(
              icon: Icons.palette_outlined,
              title: 'LEGENDA COLORI',
              accentColor: config.accentColor,
              child: Column(
                children: config.legend!
                    .map((e) => _LegendRow(entry: e))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Punteggio ─────────────────────────────────────────────
          _Section(
            icon: Icons.star_rounded,
            title: 'PUNTEGGIO',
            accentColor: config.accentColor,
            child: _ParagraphText(config.scoring),
          ),
          const SizedBox(height: 24),

          // ── Suggerimento ──────────────────────────────────────────
          _TipCard(tip: config.tip, accentColor: config.accentColor),
        ],
      ),
    );
  }
}

// ─── Componenti UI ────────────────────────────────────────────────────────────

class _GameHeader extends StatelessWidget {
  final _GuideConfig config;

  const _GameHeader({required this.config});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icona
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: config.accentColor.withAlpha(40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: config.accentColor.withAlpha(80),
              width: 1.5,
            ),
          ),
          child: Icon(
            config.icon,
            color: config.accentColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.gameLabel,
                style: TextStyle(
                  color: config.accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                config.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                config.subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sezione con titolo e icona.
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo sezione
        Row(
          children: [
            Icon(icon, color: accentColor, size: 14),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: accentColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Contenuto con bordo sinistro
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 2,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(60),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

/// Riga numerata per i passi di gioco.
class _StepRow extends StatelessWidget {
  final int number;
  final String text;
  final Color accentColor;

  const _StepRow({
    required this.number,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numero step
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withAlpha(80)),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Riga legenda colori.
class _LegendRow extends StatelessWidget {
  final _LegendEntry entry;

  const _LegendRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: entry.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Testo paragrafo standard.
class _ParagraphText extends StatelessWidget {
  final String text;

  const _ParagraphText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}

/// Card suggerimento in fondo alla guida.
class _TipCard extends StatelessWidget {
  final String tip;
  final Color accentColor;

  const _TipCard({required this.tip, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: accentColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: accentColor.withAlpha(220),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _GuideConfig {
  final String gameLabel;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String objective;
  final List<String> steps;
  final List<_LegendEntry>? legend;
  final String scoring;
  final String tip;

  const _GuideConfig({
    required this.gameLabel,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.objective,
    required this.steps,
    this.legend,
    required this.scoring,
    required this.tip,
  });
}

class _LegendEntry {
  final Color color;
  final String label;

  const _LegendEntry({required this.color, required this.label});
}

// ─── Contenuti guide ──────────────────────────────────────────────────────────

const _gameAGuide = _GuideConfig(
  gameLabel: 'GIOCO A',
  title: 'Campo Minato',
  subtitle: 'Scopri le aree di attesa esplorando la mappa di Udine, una cella alla volta.',
  icon: Icons.grid_on_rounded,
  accentColor: Color(0xFF4CAF50),
  objective:
      'Trovare il maggior numero di aree di attesa della Protezione Civile di Udine '
      'prima di esaurire le mosse disponibili. '
      'Le aree di attesa sono i punti di raccolta sicuri in caso di emergenza.',
  steps: [
    'Osserva la mappa di Udine coperta da una griglia esagonale.',
    'Tocca una cella per rivelarla: il colore indica quanto sei vicino a un\'area di attesa.',
    'Usa i colori come guida per individuare le aree nascoste nelle celle adiacenti.',
    'Quando trovi un\'area di attesa, la cella diventa verde scuro con un segno di spunta.',
    'Hai 100 mosse a disposizione: usale con strategia!',
    'Premi "Fine" per terminare anticipatamente e vedere tutte le aree rimanenti.',
  ],
  legend: [
    _LegendEntry(color: Color(0xFF1B5E20), label: 'Area di attesa trovata'),
    _LegendEntry(color: Color(0xFF43A047), label: 'Distanza 1 — area adiacente'),
    _LegendEntry(color: Color(0xFFFFEB3B), label: 'Distanza 2 — area vicina'),
    _LegendEntry(color: Color(0xFFFF9800), label: 'Distanza 3 — area nella zona'),
    _LegendEntry(color: Color(0xFFE64A19), label: 'Distanza 4+ — area lontana'),
  ],
  scoring:
      'Ogni area trovata vale punti. Il punteggio finale è la percentuale di aree '
      'scoperte sul totale. Trova tutte le aree per il punteggio massimo di 100.',
  tip:
      'Il numero su ogni cella rivelata indica quante aree di attesa si trovano '
      'nelle celle immediatamente adiacenti. Usalo per concentrare le ricerche!',
);

const _gameBGuide = _GuideConfig(
  gameLabel: 'GIOCO B',
  title: 'Localizza l\'Area',
  subtitle: 'Ti viene mostrato il nome e l\'indirizzo di un\'area di attesa: trovala sulla mappa.',
  icon: Icons.my_location_rounded,
  accentColor: Color(0xFF42A5F5),
  objective:
      'Localizzare sulla mappa esagonale l\'area di attesa indicata, '
      'nel minor numero di tentativi possibile. '
      'Metti alla prova la tua conoscenza del territorio di Udine.',
  steps: [
    'Leggi il nome e l\'indirizzo dell\'area di attesa mostrati in basso.',
    'Tocca la cella sulla mappa dove pensi si trovi quell\'area.',
    'Se sbagli, la cella si colora: il numero indica la distanza dalla cella giusta.',
    'Usa la distanza per restringere la ricerca e tocca un\'altra cella.',
    'Quando trovi la cella corretta, il round termina e vedi il risultato.',
    'Si giocano 5 round in totale, con un\'area diversa per ogni round.',
  ],
  legend: [
    _LegendEntry(color: Color(0xFF43A047), label: 'Distanza 1 — sei vicinissimo'),
    _LegendEntry(color: Color(0xFFFFEB3B), label: 'Distanza 2 — nella zona'),
    _LegendEntry(color: Color(0xFFFF9800), label: 'Distanza 3 — un po\' lontano'),
    _LegendEntry(color: Color(0xFFE64A19), label: 'Distanza 4+ — lontano'),
    _LegendEntry(color: Color(0xFF1B5E20), label: 'Trovato! Area corretta'),
  ],
  scoring:
      'Ogni round vale fino a 1000 punti. Per ogni tentativo sbagliato perdi 50 punti, '
      'con un minimo garantito di 200 punti per round. '
      'Il punteggio massimo per partita è 5000 punti (5 round × 1000).',
  tip:
      'Se sei lontano, non fare tentativi a caso: osserva il numero sulla cella '
      'sbagliata e cerca in quella direzione. Ricorda la griglia degli sbagli precedenti!',
);

const _gameCGuide = _GuideConfig(
  gameLabel: 'GIOCO C',
  title: 'GeoGuesser',
  subtitle: 'Guarda la foto di un\'area di attesa e indovina dove si trova sulla mappa.',
  icon: Icons.photo_camera_outlined,
  accentColor: Color(0xFF9C27B0),
  objective:
      'Osservare le foto di un\'area di attesa e posizionare un pin sulla mappa '
      'nel punto più vicino possibile alla posizione reale. '
      'Più sei preciso, più punti guadagni.',
  steps: [
    'Osserva attentamente le foto dell\'area di attesa mostrate a schermo.',
    'Cerca indizi visivi: edifici, insegne, vegetazione, tipo di pavimentazione.',
    'Premi "Vai alla mappa" quando sei pronto a fare la tua guess.',
    'Tocca sulla mappa il punto dove pensi si trovi l\'area fotografata.',
    'Puoi spostare il pin toccando un altro punto prima di confermare.',
    'Premi "Conferma la mia guess" per vedere quanto eri vicino.',
  ],
  scoring:
      'Il punteggio si calcola con una curva esponenziale basata sulla distanza: '
      '0 metri = 5000 punti, circa 500 metri = 1800 punti, oltre 5 km = 0 punti. '
      'Il punteggio massimo per partita è 25000 punti (5 round × 5000).',
  tip:
      'Osserva ogni dettaglio delle foto: i nomi delle vie sulle targhe, '
      'il tipo di quartiere, la vegetazione. Anche un piccolo indizio '
      'può farti avvicinare di centinaia di metri!',
);
