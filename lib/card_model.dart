// card_model.dart
class CardModel {
  final int uniqueId; // Identificatore univoco per ogni istanza di carta
  final String imagePath; // Percorso dell'immagine, usato anche come ID per la coppia
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.uniqueId,
    required this.imagePath,
    this.isFlipped = false,
    this.isMatched = false,
  });
}