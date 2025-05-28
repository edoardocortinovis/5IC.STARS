import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts
import 'package:flutter_animate/flutter_animate.dart'; // Importa flutter_animate

// --- Costanti ---
const int maxWords = 7; // Definisci la costante per il numero massimo di parole

// --- Modello Dati (Phrase) ---
class Phrase {
  final int? id;
  final String text;

  Phrase({this.id, required this.text});

  Map<String, dynamic> toMap() => {'id': id, 'text': text};

  factory Phrase.fromMap(Map<String, dynamic> map) =>
      Phrase(id: map['id'] as int?, text: map['text'] as String);

  @override
  String toString() => 'Phrase{id: $id, text: $text}';
}

// --- Helper Database ---
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final String _dbName =
      'word_puzzle_cute_ita_v6.db'; // Aggiornato per evitare conflitti
  final String _tableName = 'phrases';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    print("Percorso database: $path"); // Log del percorso per debug
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL UNIQUE CHECK(LENGTH(text) - LENGTH(REPLACE(text, ' ', '')) + 1 <= $maxWords)
      )
    ''');
    await _populateInitialData(db);
  }

  Future<void> _populateInitialData(Database db) async {
    // Frasi iniziali in Italiano
    List<String> initialPhrases = [
      "Il primo giorno di scuola ero disorientato",
      "I giorni passavano e la paura diminuiva",
      "Arrivato in seconda era già tutto diverso",
      "In terza le difficoltà sono aumentate notevolmente",
      "In quarta le uscite erano sempre meno",
      "Ora, in quinta, le responsabilità sono diverse",
      "Fatiche e divertimenti hanno colorato questi anni",
      "Seduto, ma con la testa sulle nuvole",
      "Ogni giorno porta sempre qualcosa di nuovo",
      "Il caffè è sempre stato un eroe",
      "Son sveglio, ma non è mai vero",
      "Un errore che così errore non fu",
      "Ma quante macchinette svuotate con le chiavette",
      "Professori un po’ disagiati mai più ritrovati",
      "Anni passati come i compagni negli anni",
      "Dai che è venerdì…Cisco ci aspetta",
      "Il vuoto in pancia e l’ansia",
      "Consegnate i cellulari, prendete carta e penna",
      "Cerca nello schema che tutto troverai sicuramente",
      "Alla sufficienza puntiamo, a casa non lavoriamo",
      "Il mio impegno al Pale è innegabile",
      "Io con Cisco costruisco l’intero mondo",
      "Io senza schemi sono un DSA perso",
      "Gara con banchi a rotelle nei corridoi",
      "I mesi con le chiavette sono stati golosi",
      "Chatgpt è stato il migliore nelle verifiche",
      "Se un dilemma avrai a chattone chiederai",
      "Chattone ci ha veramente salvato l’anno",
      "Domandai al chattone, a luglio mi diplomo",
      "In terza mi innamorai. Chattone ti amo!",
      "La miglior prof di matematica è Valtulina",
      "Il recupero di matematica è il migliore",
      "Con Eulero la matematica è stata divertente",
      "La Valtu aiuta e lo farà sempre",
      "La matematica ascoltata da noi viene dimenticata",
      "La prof di mate è la migliore",
      "In molti ci hanno lasciato, nessuno dimenticato",
      "Tutto ha un inizio che è adesso",
      "Tranquillità e pace, come sarà il futuro?",
      "L’impegno porterà sempre a dei risultati",
      "Compagni ci lasciano, ma rimangono nel cuore",
      "Il tempo passato, come il tempo, volato",
    ];
    Batch batch = db.batch();
    int count = 0;
    for (String phraseText in initialPhrases) {
      if (phraseText.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length <=
          maxWords) {
        batch.insert(_tableName, {
          'text': phraseText,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        count++;
      } else {
        print("Frase saltata (troppo lunga): $phraseText");
      }
    }
    await batch.commit(noResult: true);
    print("Database popolato con $count frasi iniziali.");
  }

  Future<int> insertPhrase(Phrase phrase) async {
    if (phrase.text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length >
        maxWords) {
      print("Frase troppo lunga per essere inserita: ${phrase.text}");
      return -1;
    }
    final db = await database;
    try {
      return await db.insert(
        _tableName,
        phrase.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print("Errore durante l'inserimento della frase: $e");
      return -1;
    }
  }

  Future<Phrase?> getRandomPhrase(Set<int> excludedIds) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    String whereClause =
        excludedIds.isNotEmpty
            ? 'id NOT IN (${List.filled(excludedIds.length, '?').join(',')})'
            : '1=1';
    try {
      maps = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: excludedIds.toList(),
        orderBy: 'RANDOM()',
        limit: 1,
      );
    } catch (e) {
      print("Errore nel recuperare una frase casuale: $e");
      return null;
    }
    if (maps.isNotEmpty) {
      return Phrase.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> getPhraseCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

// --- Applicazione Principale ---


class WordPuzzleApp extends StatelessWidget {
  const WordPuzzleApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(
      brightness: brightness,
      colorSchemeSeed: Colors.pinkAccent, // Changed seed for a "cuter" feel
      useMaterial3: true,
      textTheme: GoogleFonts.nunitoSansTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
    );

    final titleStyle = GoogleFonts.pacifico(
      fontSize: 28,
      color: baseTheme.colorScheme.primary,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor:
          brightness == Brightness.light
              ? Colors.pink[50]
              : Colors.grey[900], // Softer background
      cardTheme: CardTheme(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // More rounded
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        color: brightness == Brightness.light ? Colors.white : Colors.grey[800],
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: baseTheme.colorScheme.onPrimary,
          backgroundColor: baseTheme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ), // Slightly larger
          shape: const StadiumBorder(),
          elevation: 3,
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              baseTheme.colorScheme.error, // Default error color for reset
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intreccio di Parole',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WordPuzzleGameScreen(),
    );
  }
}

// --- Widget Schermata di Gioco ---
class WordPuzzleGameScreen extends StatefulWidget {
  const WordPuzzleGameScreen({super.key});

  @override
  State<WordPuzzleGameScreen> createState() => _WordPuzzleGameScreenState();
}

class _WordPuzzleGameScreenState extends State<WordPuzzleGameScreen>
    with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Phrase? _currentPhrase;
  List<String> _originalWords = [];
  List<String> _shuffledWords = [];
  final List<String> _selectedWords = [];
  List<String> _previousAttemptWords = [];
  Set<int> _availableIndices = {};
  bool _isCorrect = false;
  bool _isLoading = true;
  bool _allPhrasesSeen = false;
  final Set<int> _seenPhraseIds = {};
  final Random _random = Random();
  int _totalPhrases = 0;

  bool _showWrongFeedback =
      false; // *** NUOVA VARIABILE DI STATO PER FEEDBACK ERRATO ***

  final Map<int, AnimationController> _buttonPulseControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    for (var controller in _buttonPulseControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeGame() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _dbHelper.database;
      _totalPhrases = await _dbHelper.getPhraseCount();
      if (_totalPhrases == 0) {
        print(
          "Attenzione: Il database è vuoto. Controlla _populateInitialData o aggiungi frasi.",
        );
      }
      await _loadNextPhrase();
    } catch (e) {
      print("Errore durante l'inizializzazione del gioco: $e");
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text('Errore durante il caricamento del gioco: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadNextPhrase() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _isCorrect = false;
      _selectedWords.clear();
      _previousAttemptWords.clear();
      _showWrongFeedback = false; // *** RESETTA FEEDBACK ERRATO ***
      for (var controller in _buttonPulseControllers.values) {
        controller.dispose();
      }
      _buttonPulseControllers.clear();
    });

    await Future.delayed(const Duration(milliseconds: 150));

    try {
      if (_totalPhrases > 0 && _seenPhraseIds.length >= _totalPhrases) {
        if (mounted) {
          setState(() {
            _allPhrasesSeen = true;
            _isLoading = false;
            _currentPhrase = null;
          });
        }
        print("Tutte le frasi viste!");
        return;
      }

      Phrase? newPhrase = await _dbHelper.getRandomPhrase(_seenPhraseIds);

      if (!mounted) return;

      if (newPhrase != null) {
        _currentPhrase = newPhrase;
        if (_currentPhrase!.id != null) {
          _seenPhraseIds.add(_currentPhrase!.id!);
        } else {
          print("Attenzione: Frase caricata senza ID: ${_currentPhrase!.text}");
        }

        _originalWords =
            _currentPhrase!.text
                .split(RegExp(r'\s+'))
                .where((s) => s.isNotEmpty)
                .map((s) => s.trim())
                .toList();
        _shuffledWords = List<String>.from(_originalWords);
        _shuffledWords.shuffle(_random);

        while (_listEquals(_shuffledWords, _originalWords) &&
            _originalWords.length > 1) {
          _shuffledWords.shuffle(_random);
        }

        _availableIndices = Set<int>.from(
          List<int>.generate(_shuffledWords.length, (i) => i),
        );

        _shuffledWords.asMap().forEach((index, word) {
          _buttonPulseControllers[index] = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 150),
            lowerBound: 1.0,
            upperBound: 1.15,
          );
        });
      } else {
        print(
          "Impossibile caricare una nuova frase (DB potrebbe essere vuoto o tutte viste).",
        );
        _currentPhrase = null;
        _originalWords = [];
        _shuffledWords = [];
        _availableIndices = {};
        if (_totalPhrases > 0) _allPhrasesSeen = true;
      }
    } catch (e) {
      print("Errore durante il caricamento della prossima frase: $e");
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text(
              'Errore durante il caricamento della prossima frase: $e',
            ),
          ),
        );
      }
      _currentPhrase = null;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onWordSelected(String word, int tappedIndex) {
    if (_isCorrect || _isLoading) return;

    _buttonPulseControllers[tappedIndex]?.forward().then(
      (_) => _buttonPulseControllers[tappedIndex]?.reverse(),
    );

    setState(() {
      if (_showWrongFeedback) {
        // A full incorrect attempt was made, and now user is starting a new one.
        // _previousAttemptWords still holds the last full incorrect attempt.
        _selectedWords.clear();
        _availableIndices = Set<int>.from(
          List<int>.generate(_shuffledWords.length, (i) => i),
        );
        _showWrongFeedback =
            false; // Clear "wrong" feedback, new attempt starts
      }

      // This check is for preventing re-adding an already selected word in a partial attempt
      if (!_availableIndices.contains(tappedIndex)) {
        return;
      }

      _selectedWords.add(word);
      _availableIndices.remove(tappedIndex);
      _checkIfCorrect();
    });
  }

  void _resetCurrentAttempt() {
    if (_isLoading || _selectedWords.isEmpty) return;
    setState(() {
      // _previousAttemptWords remains if it was set from a full wrong attempt.
      // It's cleared if the user starts a new phrase or gets it right.
      _selectedWords.clear();
      _isCorrect = false;
      _showWrongFeedback = false; // Hide "wrong" feedback on explicit reset
      _availableIndices = Set<int>.from(
        List<int>.generate(_shuffledWords.length, (i) => i),
      );
    });
  }

  void _checkIfCorrect() {
    if (_selectedWords.length == _originalWords.length) {
      bool correct = _listEquals(_selectedWords, _originalWords);
      setState(() {
        _isCorrect = correct;
        if (correct) {
          _previousAttemptWords
              .clear(); // Clear previous attempt if now correct
          _showWrongFeedback = false; // Hide wrong feedback
        } else {
          // Full, incorrect attempt
          _previousAttemptWords = List.from(_selectedWords);
          _showWrongFeedback = true; // Show wrong feedback
        }
      });
    } else {
      // Incomplete attempt
      if (_isCorrect || _showWrongFeedback) {
        // Only setState if values need to change
        setState(() {
          _isCorrect = false;
          _showWrongFeedback =
              false; // Hide wrong feedback if attempt is now incomplete
        });
      }
    }
  }

  void _proceed() {
    if (_isLoading) return;

    if (_allPhrasesSeen) {
      setState(() {
        _seenPhraseIds.clear();
        _allPhrasesSeen = false;
      });
    }
    _loadNextPhrase(); // This will also reset _showWrongFeedback
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleStyle =
        theme.appBarTheme.titleTextStyle ??
        GoogleFonts.pacifico(fontSize: 28, color: colorScheme.primary);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            // Background Gradient
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.tertiary.withOpacity(0.1),
                  theme
                      .scaffoldBackgroundColor, // Use themed scaffold background
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Important for centering content
                  children: [
                    Text(
                          'Intreccio di Parole',
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.2, curve: Curves.easeOutCubic),
                    const SizedBox(height: 20),
                    Flexible(
                      // Allows content to shrink if needed
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeInOutQuad,
                        switchOutCurve: Curves.easeInOutQuad,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _buildCurrentStateWidget(theme),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStateWidget(ThemeData theme) {
    if (_isLoading && _currentPhrase == null && !_allPhrasesSeen) {
      return _buildLoadingIndicator(
        theme,
        key: const ValueKey('loading_initial'),
      );
    } else if (_allPhrasesSeen) {
      return _buildAllSeenState(theme, key: const ValueKey('all_seen'));
    } else if (_currentPhrase != null) {
      return _buildGameContent(
        theme,
        key: ValueKey(
          'game_${_currentPhrase?.id}_${_seenPhraseIds.length}',
        ), // More unique key
      );
    } else {
      // This case might indicate an error after initial load or if DB becomes empty mid-game
      return _buildErrorState(theme, key: const ValueKey('error_state'));
    }
  }

  Widget _buildLoadingIndicator(ThemeData theme, {required Key key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Intrecciando parole...',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSeenState(ThemeData theme, {required Key key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
                Icons.celebration_rounded,
                size: 80,
                color: theme.colorScheme.tertiary,
              )
              .animate()
              .then(delay: 200.ms)
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .shake(hz: 2, duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            'Wow! Le hai risolte tutte!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
          const SizedBox(height: 30),
          ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Gioca Ancora?'),
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: theme.colorScheme.onTertiary,
                ),
              )
              .animate()
              .fadeIn(delay: 600.ms)
              .scaleXY(begin: 0.8, duration: 400.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, {required Key key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: theme.colorScheme.error,
          ).animate().shake(),
          const SizedBox(height: 20),
          Text(
            _totalPhrases == 0
                ? 'Nessuna frase trovata!\nAggiungine qualcuna per giocare.'
                : 'Ops! Qualcosa è andato storto.\nRiprova.',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.errorContainer,
              backgroundColor: theme.colorScheme.error.withOpacity(0.1),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_totalPhrases > 0)
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova Caricamento'),
              onPressed: _initializeGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildGameContent(ThemeData theme, {required Key key}) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          elevation: 4.0,
          color: colorScheme.surfaceVariant.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 28.0,
                horizontal: 18.0,
              ),
              constraints: const BoxConstraints(minHeight: 90),
              alignment: Alignment.center,
              child: Text(
                _selectedWords.isEmpty
                    ? 'Tocca le parole sotto...'
                    : _selectedWords.join(' '),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      _selectedWords.isEmpty
                          ? colorScheme.outline.withOpacity(0.8)
                          : colorScheme.onSurfaceVariant,
                  fontStyle:
                      _selectedWords.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (_previousAttemptWords.isNotEmpty && !_isCorrect)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 0.0),
            child: Text(
              'Tentativo: ${_previousAttemptWords.join(' ')}',
              style: textTheme.bodyMedium?.copyWith(
                color:
                    _showWrongFeedback
                        ? colorScheme.error.withOpacity(0.9)
                        : colorScheme.outline.withOpacity(0.7),
                fontStyle: FontStyle.italic,
                fontWeight:
                    _showWrongFeedback ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 200.ms),
          ),

        SizedBox(
          height:
              (_previousAttemptWords.isNotEmpty && !_isCorrect) ||
                      _showWrongFeedback
                  ? 15
                  : 30,
        ),

        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(colorScheme.secondary),
              ),
            ),
          )
        else
          Wrap(
            spacing: 10.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: List.generate(_shuffledWords.length, (index) {
                  return _buildWordButton(theme, index);
                })
                .animate(interval: 50.ms)
                .fadeIn(duration: 250.ms, curve: Curves.easeOut)
                .slideY(begin: 0.3, duration: 250.ms, curve: Curves.easeOut),
          ),
        const SizedBox(height: 25),

        Container(
          constraints: const BoxConstraints(minHeight: 90),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (Widget child, Animation<double> animation) {
              if (child.key == const ValueKey('wrong_feedback')) {
                return child
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .shake(hz: 2.5, duration: 300.ms, curve: Curves.easeIn);
              }
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                  reverseCurve: Curves.easeOutCubic,
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _buildFeedbackOrActions(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildWordButton(ThemeData theme, int index) {
    final word = _shuffledWords[index];
    final bool isAvailable = _availableIndices.contains(index);
    final controller = _buttonPulseControllers[index];
    final colorScheme = theme.colorScheme;

    Color bgColor =
        isAvailable
            ? colorScheme.primary
            : colorScheme.secondaryContainer.withOpacity(0.4);
    Color fgColor =
        isAvailable
            ? colorScheme.onPrimary
            : colorScheme.onSecondaryContainer.withOpacity(0.6);

    return ScaleTransition(
      key: ValueKey("word_btn_${_currentPhrase?.id}_${index}_$word"),
      scale: controller ?? const AlwaysStoppedAnimation(1.0),
      child: ElevatedButton(
            onPressed: isAvailable ? () => _onWordSelected(word, index) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              disabledBackgroundColor: colorScheme.surfaceVariant.withOpacity(
                0.5,
              ),
              disabledForegroundColor: colorScheme.onSurfaceVariant.withOpacity(
                0.4,
              ),
              elevation: isAvailable ? 3 : 1,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              side:
                  isAvailable
                      ? BorderSide.none
                      : BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.surfaceVariant.withOpacity(0.5);
                }
                return bgColor;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurfaceVariant.withOpacity(0.4);
                }
                return fgColor;
              }),
            ),
            child: Text(
              word,
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          )
          .animate(target: isAvailable ? 0 : 1)
          .fade(end: 0.5, duration: 150.ms)
          .scaleXY(end: isAvailable ? 1.0 : 0.95, duration: 150.ms),
    );
  }

  Widget _buildFeedbackOrActions(ThemeData theme) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_isCorrect) {
      return Column(
        key: const ValueKey('success_feedback'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.greenAccent[700],
                size: 55,
              )
              .animate()
              .scale(delay: 50.ms, duration: 500.ms, curve: Curves.elasticOut)
              .then(delay: 200.ms)
              .shake(hz: 1.5, duration: 300.ms),
          const SizedBox(height: 12),
          Text(
                'Perfetto!',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 150.ms)
              .shimmer(
                duration: 900.ms,
                delay: 300.ms,
                color: Colors.lightGreenAccent,
              ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
                icon: Icon(
                  _allPhrasesSeen
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 20,
                ),
                label: Text(
                  _allPhrasesSeen ? 'Gioca Ancora?' : 'Prossima Frase',
                ),
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 16,
                  ),
                ),
              )
              .animate()
              .slideY(
                begin: 0.6,
                delay: 250.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(),
        ],
      );
    } else if (_showWrongFeedback) {
      return Column(
        key: const ValueKey('wrong_feedback'), // Key for AnimatedSwitcher
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sentiment_very_dissatisfied_rounded, // Cuter "sad" icon
            color: colorScheme.error.withOpacity(0.9),
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            'Ops! Non è corretto.',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            icon: Icon(
              Icons.replay_circle_filled_rounded,
              size: 22,
              color: colorScheme.error.withOpacity(0.8),
            ),
            label: Text(
              'Riprova',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            onPressed: _resetCurrentAttempt,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colorScheme.error.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_selectedWords.isNotEmpty) {
      return TextButton.icon(
        key: const ValueKey('reset_action'),
        icon: Icon(
          Icons.cancel_outlined,
          size: 22,
          color: colorScheme.secondary.withOpacity(0.9),
        ),
        label: Text(
          'Annulla Selezione',
          style: TextStyle(
            color: colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: _resetCurrentAttempt,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
      ).animate().fadeIn(duration: 200.ms);
    } else {
      return Container(
        key: const ValueKey('idle_message'),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'Componi la frase corretta!',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
      );
    }
  }
}
