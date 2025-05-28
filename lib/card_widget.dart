import 'package:flutter/material.dart';
import 'dart:math' as math; // Per pi
import 'card_model.dart';

class CardWidget extends StatefulWidget {
  final CardModel card;
  final Function(CardModel) onCardTap;

  const CardWidget({
    super.key,
    required this.card,
    required this.onCardTap,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFrontVisible = false; // Traccia se la faccia dell'immagine è visibile

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Imposta lo stato iniziale basato su isFlipped e isMatched
    _isFrontVisible = widget.card.isFlipped || widget.card.isMatched;
    if (_isFrontVisible) {
      _controller.value = 1; // Se è già girata, mostra la faccia
    }
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se lo stato di flip della carta cambia dall'esterno (es. logica di gioco)
    bool shouldBeFrontVisible = widget.card.isFlipped || widget.card.isMatched;
    if (_isFrontVisible != shouldBeFrontVisible) {
      if (shouldBeFrontVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _isFrontVisible = shouldBeFrontVisible;
    } else if (widget.card.isMatched && _controller.value != 1) {
        // Assicura che le carte abbinate rimangano girate
        _controller.value = 1;
        _isFrontVisible = true;
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.card.isMatched) return; // Non fare nulla se la carta è già abbinata

    widget.onCardTap(widget.card); // Chiama la logica di gioco

    // L'animazione sarà gestita da didUpdateWidget basandosi sullo stato di widget.card.isFlipped
  }

  @override
  Widget build(BuildContext context) {
    // Calcola l'angolo di rotazione. Quando _animation.value è 0.5, l'angolo è pi/2 (90 gradi).
    final angle = _animation.value * math.pi;

    // Determina quale lato mostrare. Se l'animazione è oltre la metà, mostra il fronte.
    final Widget contentToShow = _animation.value <= 0.5
        ? _buildCardSide(isFront: false) // Mostra il dorso
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(math.pi), // Specchia il contenuto del fronte
            child: _buildCardSide(isFront: true), // Mostra il fronte (immagine)
          );
    
    return GestureDetector(
      onTap: _handleTap,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Prospettiva
          ..rotateY(angle), // Ruota sull'asse Y
        alignment: Alignment.center,
        child: contentToShow,
      ),
    );
  }

  Widget _buildCardSide({required bool isFront}) {
    // Dorso della carta
    Widget backSide = Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[300],
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/images/card_back.png'), // Assicurati che questa immagine esista
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
    );

    // Fronte della carta (immagine)
    Widget frontSide = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          widget.card.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Placeholder in caso di errore caricamento immagine
            return Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40))
            );
          },
        ),
      ),
    );
    
    if (isFront) {
        return widget.card.isMatched
            ? Opacity(opacity: 0.6, child: frontSide) // Rendi le carte abbinate leggermente trasparenti
            : frontSide;
    } else {
        return backSide;
    }
  }
}