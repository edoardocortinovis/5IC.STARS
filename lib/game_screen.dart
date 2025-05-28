import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'card_model.dart';
import 'card_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int _gridSize = 16; // 4x4
  final int _imagePairs = 8;
  final int _maxAttempts = 25;
  final int _freeAttemptsThreshold = 5;

  List<CardModel> _cards = [];
  List<String> _availableImagePaths = [];

  int _score = 0;
  int _attempts = 0;
  List<CardModel> _flippedCards = [];
  bool _allowInput = true;
  bool _isGameOver = false;
  String _gameOverMessage = "";
  int _uniqueIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadImagesAndInitializeGame();
  }

  void _loadImagesAndInitializeGame() {
    // Simula il caricamento di 21 percorsi di immagini
    // Assicurati che questi file esistano in assets/images/
    _availableImagePaths = List.generate(21, (index) => 'assets/images/image${index + 1}.png');
    // Aggiungi un controllo per assicurarti di avere abbastanza immagini uniche
    if (_availableImagePaths.length < _imagePairs) {
       // Gestisci l'errore: non abbastanza immagini uniche disponibili.
       // Potresti mostrare un messaggio all'utente o usare immagini di fallback.
       print("Errore: Non ci sono abbastanza immagini uniche disponibili per iniziare il gioco.");
       // Imposta uno stato di errore o usa un set di immagini di default
        _availableImagePaths.clear(); // Pulisce la lista per evitare errori successivi
        // Aggiungi immagini di placeholder se necessario o mostra un messaggio di errore UI
        // Per semplicità, qui fermiamo l'inizializzazione se non ci sono abbastanza immagini.
        // In un'app reale, dovresti gestire questo caso in modo più robusto.
       if (mounted) {
        setState(() {
          _isGameOver = true;
          _gameOverMessage = "Errore: Immagini non sufficienti.";
        });
       }
       return;
    }
    _initializeGame();
  }


  void _initializeGame() {
    _uniqueIdCounter = 0;
    _cards = [];
    _flippedCards = [];
    _score = 0;
    _attempts = 0;
    _isGameOver = false;
    _gameOverMessage = "";
    _allowInput = true;

    // Seleziona 8 immagini uniche casualmente
    final random = Random();
    List<String> selectedImagePaths = [];
    List<String> tempAvailableImages = List.from(_availableImagePaths); // Copia per la modifica
    tempAvailableImages.shuffle(random);

    for (int i = 0; i < _imagePairs; i++) {
      if (tempAvailableImages.isNotEmpty) {
        selectedImagePaths.add(tempAvailableImages.removeAt(0));
      } else {
        // Questo non dovrebbe accadere se il controllo iniziale _availableImagePaths.length < _imagePairs è corretto
        print("Errore: esaurite le immagini disponibili durante la selezione.");
        break; 
      }
    }
    
    // Crea le coppie di carte
    for (String imagePath in selectedImagePaths) {
      _cards.add(CardModel(uniqueId: _uniqueIdCounter++, imagePath: imagePath));
      _cards.add(CardModel(uniqueId: _uniqueIdCounter++, imagePath: imagePath));
    }

    _cards.shuffle(random);

    if (mounted) {
      setState(() {});
    }
  }

  void _handleCardTap(CardModel card) {
    if (!_allowInput || card.isFlipped || card.isMatched || _flippedCards.length >= 2) {
      return;
    }

    if (mounted) {
      setState(() {
        card.isFlipped = true;
      });
    }
    _flippedCards.add(card);

    if (_flippedCards.length == 2) {
      _allowInput = false; // Blocca ulteriori tap mentre si controlla
      _attempts++;
      Timer(const Duration(milliseconds: 300), _checkForMatch); // Breve ritardo per mostrare la seconda carta
    }
     if (mounted) {
      setState(() {}); // Aggiorna per mostrare la carta girata immediatamente
    }
  }

  void _checkForMatch() {
    CardModel card1 = _flippedCards[0];
    CardModel card2 = _flippedCards[1];

    if (card1.imagePath == card2.imagePath) { // Match!
      if (mounted) {
        setState(() {
          card1.isMatched = true;
          card2.isMatched = true;
          _score++;
        });
      }
    } else { // No match
      if (mounted) {
         // Detrazione punti solo se si superano i tentativi gratuiti
        if (_attempts > _freeAttemptsThreshold) {
          setState(() {
            _score = (_score - 1).clamp(0, 20); // Max 20 punti, non scendere sotto 0
          });
        }
      }
      // Rigira le carte dopo un ritardo
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            card1.isFlipped = false;
            card2.isFlipped = false;
          });
        }
      });
    }
    
    // Indipendentemente dal match, pulisci le carte girate e riattiva l'input dopo l'animazione di non-match
    Timer(const Duration(seconds: 1), () { // Assicurati che questo timer sia appropriato
        if (mounted) {
            setState(() {
                _flippedCards.clear();
                _allowInput = true;
                _checkWinOrLoseCondition();
            });
        }
    });
  }

  void _checkWinOrLoseCondition() {
    if (_score == _imagePairs) {
      _isGameOver = true;
      _gameOverMessage = "Complimenti, Hai Vinto!";
    } else if (_attempts >= _maxAttempts) {
      _isGameOver = true;
      _gameOverMessage = "Hai Perso! Tentativi esauriti.";
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isGameOver ? _initializeGame : null, // Abilita solo se il gioco è finito o per riavviare
            tooltip: 'Ricomincia Partita',
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
     if (_availableImagePaths.isEmpty && _cards.isEmpty && _isGameOver) {
      // Caso specifico in cui le immagini non sono state caricate correttamente
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_gameOverMessage, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadImagesAndInitializeGame, // Tenta di ricaricare e inizializzare
              child: const Text('Riprova a Caricare'),
            ),
          ],
        ),
      );
    }
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Punteggio: $_score', style: Theme.of(context).textTheme.headlineSmall),
                Text('Tentativi: $_attempts / $_maxAttempts', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return CardWidget(
                    card: _cards[index],
                    onCardTap: _isGameOver ? (_) {} : _handleCardTap, // Disabilita tap se game over
                  );
                },
              ),
            ),
            if (_isGameOver)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Text(
                      _gameOverMessage,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _score == _imagePairs ? Colors.green[700] : Colors.red[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Gioca Ancora'),
                      onPressed: _initializeGame,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
  }
}