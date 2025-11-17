import '../models/card_models.dart';

class MockCardService {
  // Minimal seed data for fast iteration
  static final _cards = <CardRef>[
    CardRef(
      id: 'base1-58',
      name: 'Pikachu',
      setName: 'Base Set',
      rarity: 'Common',
      imageUrl: 'https://images.pokemontcg.io/base1/58.png',
    ),
    CardRef(
      id: 'base1-4',
      name: 'Charizard',
      setName: 'Base Set',
      rarity: 'Rare Holo',
      imageUrl: 'https://images.pokemontcg.io/base1/4.png',
    ),
  ];

  Future<List<CardRef>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return _cards.where((c) =>
      c.name.toLowerCase().contains(q) ||
      c.setName.toLowerCase().contains(q) ||
      c.id.toLowerCase().contains(q)
    ).toList();
  }

  CardRef getById(String id) =>
      _cards.firstWhere((c) => c.id == id, orElse: () => _cards.first);
}
