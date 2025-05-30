import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: unused_import
import 'dart:math' as math;
// ignore: unnecessary_import
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MemePage extends StatefulWidget {
  const MemePage({super.key});

  @override
  State<MemePage> createState() => _MemePageState();
}

class _MemePageState extends State<MemePage> with TickerProviderStateMixin {
  final List<String> memeFiles = [
    'immaginimeme/meme1.jpg',
    'immaginimeme/meme2.jpg',
    'immaginimeme/meme3.jpg',
    'immaginimeme/meme4.jpg',
    'immaginimeme/meme5.jpg',
    'immaginimeme/meme6.jpg',
    'immaginimeme/meme7.jpg',
    'immaginimeme/meme8.jpg',
    'immaginimeme/meme9.jpg',
    'immaginimeme/meme10.jpg',
    'immaginimeme/meme11.jpg',
    'immaginimeme/meme12.jpg',
    'immaginimeme/meme13.jpg',
    'immaginimeme/meme14.jpg',
    'immaginimeme/meme15.jpg',
    'immaginimeme/meme16.jpg',
    'immaginimeme/meme17.jpg',
    'immaginimeme/meme18.jpg',
    'immaginimeme/meme19.jpg',
    'immaginimeme/meme20.jpg',
  ];

  // Palette di colori Tinder-style
  final Color primaryColor = const Color(0xFFFD3A73); // Rosso Tinder
  final Color secondaryColor = const Color(0xFF2A9D8F); // Verde acqua
  final Color backgroundColor = const Color(0xFFF8F8F8); // Grigio chiaro
  final Color darkGrayColor = const Color(0xFF505965); // Grigio scuro
  final Color lightGrayColor = const Color(0xFFF0F2F5); // Grigio chiarissimo

  // Lista per salvare i meme preferiti
  List<int> savedMemes = [];

  // Chiave per SharedPreferences
  static const String savedMemesKey = 'saved_memes_list';

  // Indice del meme corrente
  int currentIndex = 0;

  // Controller per le animazioni
  late AnimationController _swipeController;
  late AnimationController _cardController;
  late Animation<double> _cardScaleAnimation;

  // Animazioni Tinder-like
  late AnimationController _likeAnimationController;
  // ignore: unused_field
  late Animation<double> _likeIconSize;
  // ignore: unused_field
  late Animation<double> _likeIconOpacity;

  late AnimationController _nopeAnimationController;
  // ignore: unused_field
  late Animation<double> _nopeIconSize;
  // ignore: unused_field
  late Animation<double> _nopeIconOpacity;

  Offset _dragStart = Offset.zero;
  Offset _dragPosition = Offset.zero;
  bool _isDragging = false;

  // Stato per mostrare i meme salvati
  bool _showingSavedMemes = false;

  // Controller per le animazioni di feedback
  late AnimationController _likeController;
  late AnimationController _saveController;

  // Controllo del livello di zoom per ogni meme
  double _currentZoom = 1.0;
  final Map<int, double> _zoomLevels = {};

  @override
  void initState() {
    super.initState();

    // Carica i meme salvati da SharedPreferences
    _loadSavedMemes();

    // Controller per l'animazione di swipe
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Controller per l'animazione della carta
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    // Controller per l'animazione del like
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Controller per l'animazione del salvataggio
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animazioni in stile Tinder
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _likeIconSize = Tween<double>(begin: 0, end: 140).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _likeIconOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _nopeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _nopeIconSize = Tween<double>(begin: 0, end: 140).animate(
      CurvedAnimation(
        parent: _nopeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _nopeIconOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(
        parent: _nopeAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Avvia l'animazione della carta all'inizio
    _cardController.forward();
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _cardController.dispose();
    _likeController.dispose();
    _saveController.dispose();
    _likeAnimationController.dispose();
    _nopeAnimationController.dispose();
    super.dispose();
  }

  // Carica i meme salvati da SharedPreferences
  Future<void> _loadSavedMemes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMemesString = prefs.getString(savedMemesKey);

    if (savedMemesString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(savedMemesString);
        setState(() {
          savedMemes = decodedList.map<int>((item) => item as int).toList();
        });
      } catch (e) {
        setState(() {
          savedMemes = [];
        });
      }
    }
  }

  // Salva i meme salvati in SharedPreferences
  Future<void> _saveSavedMemes() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(savedMemes);
    await prefs.setString(savedMemesKey, encodedList);
  }

  void _onLike() {
    _likeAnimationController.forward(from: 0.0).then((_) {
      _likeAnimationController.reset();
    });

    // Passa al prossimo meme con animazione
    _animateToNextCard();
  }

  void _onDislike() {
    _nopeAnimationController.forward(from: 0.0).then((_) {
      _nopeAnimationController.reset();
    });

    // Passa al prossimo meme con animazione
    _animateToNextCard();
  }

  void _onSave() {
    if (!savedMemes.contains(currentIndex)) {
      setState(() {
        savedMemes.add(currentIndex);
      });

      // Salva la lista aggiornata in SharedPreferences
      _saveSavedMemes();

      // Avvia solo l'animazione di feedback dell'icona cuore
      _saveController.forward(from: 0.0);

      // Mostra una notifica visiva migliorata
      _showSaveConfirmation();
    }
  }

  void _onRemoveFromSaved(int memeIndex) {
    setState(() {
      savedMemes.remove(memeIndex);
    });

    // Salva la lista aggiornata in SharedPreferences
    _saveSavedMemes();

    // Mostra feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Meme rimosso dai preferiti',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Annulla',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              savedMemes.add(memeIndex);
            });
            _saveSavedMemes();
          },
        ),
      ),
    );
  }

  void _animateToNextCard() {
    // Salva il livello di zoom corrente
    _zoomLevels[currentIndex] = _currentZoom;

    // Scala la carta corrente verso il basso
    _cardController.reverse().then((_) {
      setState(() {
        if (currentIndex < memeFiles.length - 1) {
          currentIndex++;
        } else {
          // Tornare al primo meme quando raggiungiamo la fine
          currentIndex = 0;
        }

        // Ripristina il livello di zoom salvato o imposta il default
        _currentZoom = _zoomLevels[currentIndex] ?? 1.0;
      });

      // Scala la nuova carta verso l'alto
      _cardController.forward();
    });
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStart = details.localPosition;
      _dragPosition = Offset.zero;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition = details.localPosition - _dragStart;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final dragDistance = _dragPosition.dx;
    final dragSpeed = details.velocity.pixelsPerSecond.dx;

    // Se lo swipe è sufficientemente ampio o veloce
    if (dragDistance.abs() > 100 || dragSpeed.abs() > 800) {
      if (dragDistance > 0 || dragSpeed > 500) {
        // Swipe a destra - like
        _onLike();
      } else {
        // Swipe a sinistra - dislike
        _onDislike();
      }
    } else {
      // Torna alla posizione iniziale se il trascinamento non è sufficiente
      setState(() {
        _isDragging = false;
        _dragPosition = Offset.zero;
      });
    }
  }

  void _toggleSavedMemesView() {
    setState(() {
      _showingSavedMemes = !_showingSavedMemes;

      // Resetta l'animazione della carta
      _cardController.reset();
      _cardController.forward();
    });
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: primaryColor, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  'Meme Salvato!',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGrayColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Lo troverai nella raccolta dei tuoi meme preferiti',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: darkGrayColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Funzione per visualizzare il meme a schermo intero con zoom avanzato
  void _showFullScreenMeme(int memeIndex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black.withOpacity(0.9),
          child: Stack(
            children: [
              // Meme con zoom interattivo
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Hero(
                        tag: 'fullscreen_meme_$memeIndex',
                        child: Image.asset(
                          memeFiles[memeIndex],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Pulsante di chiusura
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              // Barra inferiore con informazioni e controlli
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meme ${memeIndex + 1}',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Zoom per dettagli',
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              if (savedMemes.contains(memeIndex)) {
                                _onRemoveFromSaved(memeIndex);
                              } else {
                                _onSave();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    savedMemes.contains(memeIndex)
                                        ? primaryColor
                                        : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                savedMemes.contains(memeIndex)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    savedMemes.contains(memeIndex)
                                        ? Colors.white
                                        : primaryColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superiore
            _buildAppBar(),

            // Contenuto principale - Card in stile Tinder
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(color: backgroundColor),
                child:
                    _showingSavedMemes
                        ? _buildSavedMemesView()
                        : _buildTinderCard(),
              ),
            ),

            // Barra dei pulsanti in stile Tinder
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo e titolo
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  FontAwesomeIcons.fire,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _showingSavedMemes ? 'PREFERITI' : 'MEMINDER',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  background: Paint()..color = Colors.transparent,
                  foreground:
                      Paint()
                        ..shader = LinearGradient(
                          colors: [primaryColor, const Color(0xFFFF8A65)],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ],
          ),

          // Pulsanti
          Row(
            children: [
              // Indicatore meme
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: lightGrayColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentIndex + 1}/${memeFiles.length}',
                  style: GoogleFonts.montserrat(
                    color: darkGrayColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Pulsante preferiti
              GestureDetector(
                onTap: _toggleSavedMemesView,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _showingSavedMemes ? lightGrayColor : primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_showingSavedMemes
                                ? darkGrayColor
                                : primaryColor)
                            .withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showingSavedMemes
                            ? FontAwesomeIcons.images
                            : FontAwesomeIcons.solidHeart,
                        color:
                            _showingSavedMemes ? darkGrayColor : Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showingSavedMemes
                            ? 'Esplora'
                            : savedMemes.length.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              _showingSavedMemes ? darkGrayColor : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTinderCard() {
    if (memeFiles.isEmpty) {
      return const Center(child: Text('Nessun meme disponibile'));
    }

    // Calcola la rotazione in base alla posizione di trascinamento
    final rotationAngle = _dragPosition.dx / 300;
    final scale =
        _isDragging
            ? 1.0 - (_dragPosition.dx.abs() / 2000)
            : _cardScaleAnimation.value;

    // Calcola l'opacità degli indicatori di like/dislike
    final likeOpacity =
        _dragPosition.dx > 0 ? (_dragPosition.dx / 100).clamp(0.0, 1.0) : 0.0;
    final dislikeOpacity =
        _dragPosition.dx < 0
            ? (_dragPosition.dx.abs() / 100).clamp(0.0, 1.0)
            : 0.0;

    return Center(
      child: GestureDetector(
        onPanStart: _isDragging ? null : _onDragStart,
        onPanUpdate: _isDragging ? _onDragUpdate : null,
        onPanEnd: _isDragging ? _onDragEnd : null,
        onDoubleTap: _onSave, // Doppio tap per salvare
        onTap:
            () => _showFullScreenMeme(currentIndex), // Tap per schermo intero
        child: AnimatedBuilder(
          animation: _cardController,
          builder: (context, child) {
            return Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: _isDragging ? rotationAngle : 0.0,
                child: Transform.translate(
                  offset: _isDragging ? _dragPosition : Offset.zero,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Immagine del meme
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Hero(
                          tag: 'fullscreen_meme_$currentIndex',
                          child: Image.asset(
                            memeFiles[currentIndex],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Overlay per informazioni
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.8],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Meme ${currentIndex + 1}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  savedMemes.contains(currentIndex)
                                      ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'SALVATO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Swipe per i nuovi meme • Doppio tap per salvare',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Indicatore LIKE
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Transform.rotate(
                          angle: 0.2,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: likeOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: secondaryColor,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'MI PIACE',
                                style: GoogleFonts.montserrat(
                                  color: secondaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Indicatore NOPE
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: dislikeOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: primaryColor,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PASSA',
                                style: GoogleFonts.montserrat(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Animazione di feedback per il salvataggio
                      AnimatedBuilder(
                        animation: _saveController,
                        builder: (context, child) {
                          return _saveController.value > 0
                              ? TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value > 0.5 ? 1 - value : value,
                                    child: Center(
                                      child: Container(
                                        width: 120 + (value * 40),
                                        height: 120 + (value * 40),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.favorite,
                                            color: primaryColor,
                                            size: 80 + (value * 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Rivisitato il layout della griglia dei preferiti
  Widget _buildSavedMemesView() {
    if (savedMemes.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: lightGrayColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.heart,
                  color: primaryColor.withOpacity(0.3),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nessun meme salvato',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkGrayColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Quando trovi un meme che ti piace,\nsalvalo con un doppio tap!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: darkGrayColor.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _toggleSavedMemesView,
                icon: Icon(FontAwesomeIcons.searchengin, size: 16),
                label: Text('Scopri nuovi meme'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MediaQuery.of(context).size.width / 2 - 16,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: savedMemes.length,
      itemBuilder: (context, index) {
        final memeIndex = savedMemes[index];
        return GestureDetector(
          onTap: () => _showFullScreenMeme(memeIndex),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Immagine del meme - senza container con dimensioni fisse
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag: 'fullscreen_meme_$memeIndex',
                  child: Image.asset(memeFiles[memeIndex], fit: BoxFit.cover),
                ),
              ),

              // Footer con sfondo sfumato
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Meme ${memeIndex + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Badge "SALVATO"
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    'SALVATO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Pulsante per rimuovere dai preferiti
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: () => _onRemoveFromSaved(memeIndex),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child:
          !_showingSavedMemes ? _buildSwipeButtons() : _buildSavedModeButtons(),
    );
  }

  Widget _buildSwipeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pulsante Home
        _buildRoundButton(
          onTap: () => Navigator.pop(context),
          size: 50,
          color: Colors.white,
          icon: Icons.home_rounded,
          iconColor: darkGrayColor,
          elevation: 3,
          borderColor: darkGrayColor.withOpacity(0.2),
        ),

        // Pulsante Dislike
        _buildRoundButton(
          onTap: _onDislike,
          size: 65,
          color: Colors.white,
          icon: Icons.close,
          iconColor: primaryColor,
          elevation: 5,
          borderColor: primaryColor.withOpacity(0.4),
        ),

        // Pulsante Salva
        _buildRoundButton(
          onTap: _onSave,
          size: 58,
          color:
              savedMemes.contains(currentIndex) ? primaryColor : Colors.white,
          icon:
              savedMemes.contains(currentIndex)
                  ? Icons.favorite
                  : Icons.favorite_border,
          iconColor:
              savedMemes.contains(currentIndex) ? Colors.white : primaryColor,
          borderColor: primaryColor,
          elevation: 5,
        ),

        // Pulsante Like
        _buildRoundButton(
          onTap: _onLike,
          size: 65,
          color: Colors.white,
          icon: Icons.thumb_up_alt_rounded,
          iconColor: secondaryColor,
          elevation: 5,
          borderColor: secondaryColor.withOpacity(0.4),
        ),

        // Pulsante Zoom
        _buildRoundButton(
          onTap: () => _showFullScreenMeme(currentIndex),
          size: 50,
          color: Colors.white,
          icon: Icons.fullscreen,
          iconColor: darkGrayColor,
          elevation: 3,
          borderColor: darkGrayColor.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildSavedModeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRoundButton(
          onTap: _toggleSavedMemesView,
          size: 65,
          color: primaryColor,
          icon: FontAwesomeIcons.angleLeft,
          iconColor: Colors.white,
          elevation: 5,
          hasBorder: false,
        ),
        const SizedBox(width: 20),
        Text(
          'Torna alla scoperta',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkGrayColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRoundButton({
    required VoidCallback onTap,
    required double size,
    required Color color,
    required IconData icon,
    required Color iconColor,
    double elevation = 5,
    bool hasBorder = true,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border:
              hasBorder
                  ? Border.all(
                    color: borderColor ?? Colors.transparent,
                    width: 2,
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: elevation * 2,
              spreadRadius: elevation / 4,
              offset: Offset(0, elevation / 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}
