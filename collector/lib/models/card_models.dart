class CardRef {
  final String id;       // e.g., "base1-4"
  final String name;     // "Charizard"
  final String setName;  // "Base Set"
  final String rarity;   // "Rare Holo"
  final String imageUrl; // PNG
  CardRef({
    required this.id,
    required this.name,
    required this.setName,
    required this.rarity,
    required this.imageUrl,
  });
}

class PriceQuote {
  final String cardId;
  final double? market;
  final double? low;
  final double? high;
  final DateTime? updatedAt;
  PriceQuote({
    required this.cardId,
    this.market,
    this.low,
    this.high,
    this.updatedAt,
  });
}
