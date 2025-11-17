import '../models/card_models.dart';

abstract class PriceService {
  Future<PriceQuote> getPrice(String cardId);
}

// Mock now; later swap to Dio client that hits your Edge Function.
class MockPriceService implements PriceService {
  @override
  Future<PriceQuote> getPrice(String cardId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    // Simple mock: give Charizard a price; Pikachu a cheap one.
    final price = cardId.contains('base1-4') ? 150.0 : 2.5;
    return PriceQuote(cardId: cardId, market: price, low: price * 0.9, high: price * 1.15, updatedAt: DateTime.now());
  }
}
