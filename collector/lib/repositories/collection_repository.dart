import 'package:supabase_flutter/supabase_flutter.dart';

/// A single row in the user's collection, joined with card metadata.
class UserCardEntry {
  final String id;       // user_cards.id
  final String cardId;   // cards.id
  final int quantity;

  // Joined card fields
  final String name;
  final String setName;
  final String rarity;
  final String imageUrl;

  UserCardEntry({
    required this.id,
    required this.cardId,
    required this.quantity,
    required this.name,
    required this.setName,
    required this.rarity,
    required this.imageUrl,
  });

  factory UserCardEntry.fromMap(Map<String, dynamic> map) {
    final card = map['card'] as Map<String, dynamic>?;
    final set = card?['set'] as Map<String, dynamic>?;

    return UserCardEntry(
      id: map['id'] as String,
      cardId: map['card_id'] as String,
      quantity: map['quantity'] as int,
      name: (card?['name'] as String?) ?? 'Unknown',
      setName: (set?['name'] as String?) ?? 'Unknown Set',
      rarity: (card?['rarity'] as String?) ?? 'Unknown',
      imageUrl: (card?['image_url'] as String?) ?? '',
    );
  }
}

/// Contract for a collection repository.
abstract class CollectionRepository {
  /// All cards in the current user's collection.
  Future<List<UserCardEntry>> getUserCollection();

  /// Insert a new user_cards row.
  Future<UserCardEntry> addCard(String cardId, {int quantity = 1});

  /// Get a single user_cards row for the given cardId, or null if user doesn't own it.
  Future<UserCardEntry?> getUserCardForCard(String cardId);

  /// Add to an existing user_cards row if present, otherwise create a new row.
  Future<UserCardEntry> addOrIncrementCard(String cardId, {int quantity = 1});

  /// Decrement quantity or delete the row if it hits zero.
  Future<UserCardEntry?> decrementOrRemoveCard(String cardId, {int quantity = 1});
}

/// Supabase implementation of the collection repository.
class SupabaseCollectionRepository implements CollectionRepository {
  final SupabaseClient client;

  SupabaseCollectionRepository(this.client);

  @override
  Future<List<UserCardEntry>> getUserCollection() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }

    final rows = await client
        .from('user_cards')
        .select('''
          id,
          card_id,
          quantity,
          card:cards(
            name,
            rarity,
            image_url,
            set:set_id(name)
          )
        ''')
        .eq('user_id', user.id);

    final list = rows as List<dynamic>;
    return list
        .map((row) => UserCardEntry.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserCardEntry> addCard(String cardId, {int quantity = 1}) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }

    final inserted = await client
        .from('user_cards')
        .insert({
          'user_id': user.id,
          'card_id': cardId,
          'quantity': quantity,
        })
        .select('''
          id,
          card_id,
          quantity,
          card:cards(
            name,
            rarity,
            image_url,
            set:set_id(name)
          )
        ''')
        .single();

    return UserCardEntry.fromMap(inserted as Map<String, dynamic>);
  }

  /// Get a single entry for the given cardId (or null if user doesn't own it).
  @override
  Future<UserCardEntry?> getUserCardForCard(String cardId) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }

    final row = await client
        .from('user_cards')
        .select('''
          id,
          card_id,
          quantity,
          card:cards(
            name,
            rarity,
            image_url,
            set:set_id(name)
          )
        ''')
        .eq('user_id', user.id)
        .eq('card_id', cardId)
        .maybeSingle();

    if (row == null) return null;

    return UserCardEntry.fromMap(row as Map<String, dynamic>);
  }

  /// Add or increment quantity if row already exists.
  @override
  Future<UserCardEntry> addOrIncrementCard(String cardId,
      {int quantity = 1}) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }

    final existing = await client
        .from('user_cards')
        .select('''
          id,
          card_id,
          quantity,
          card:cards(
            name,
            rarity,
            image_url,
            set:set_id(name)
          )
        ''')
        .eq('user_id', user.id)
        .eq('card_id', cardId)
        .maybeSingle();

    if (existing == null) {
      final inserted = await client
          .from('user_cards')
          .insert({
            'user_id': user.id,
            'card_id': cardId,
            'quantity': quantity,
          })
          .select('''
            id,
            card_id,
            quantity,
            card:cards(
              name,
              rarity,
              image_url,
              set:set_id(name)
            )
          ''')
          .single();

      return UserCardEntry.fromMap(inserted as Map<String, dynamic>);
    }

    final existingMap = existing as Map<String, dynamic>;
    final currentQty = existingMap['quantity'] as int? ?? 0;
    final newQty = currentQty + quantity;

    final updated = await client
        .from('user_cards')
        .update({'quantity': newQty})
        .eq('id', existingMap['id'])
        .select('''
          id,
          card_id,
          quantity,
          card:cards(
            name,
            rarity,
            image_url,
            set:set_id(name)
          )
        ''')
        .single();

    return UserCardEntry.fromMap(updated as Map<String, dynamic>);
  }

  /// Decrement quantity or delete row if it hits zero.
  @override
  Future<UserCardEntry?> decrementOrRemoveCard(String cardId,
      {int quantity = 1}) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }

    final existing = await client
        .from('user_cards')
        .select('''
          id,
          card_id,
          quantity,
          card:cards(
            name,
            rarity,
            image_url,
            set:set_id(name)
          )
        ''')
        .eq('user_id', user.id)
        .eq('card_id', cardId)
        .maybeSingle();

    if (existing == null) return null;

    final existingMap = existing as Map<String, dynamic>;
    final currentQty = existingMap['quantity'] as int? ?? 0;
    final newQty = currentQty - quantity;

    if (newQty <= 0) {
      await client.from('user_cards').delete().eq('id', existingMap['id']);
      return null;
    }

    final updated = await client
        .from('user_cards')
        .update({'quantity': newQty})
        .eq('id', existingMap['id'])
        .select('''
          id,
          card_id,
          quantity,
          card:cards(
            name,
            rarity,
            image_url,
            set:set_id(name)
          )
        ''')
        .single();

    return UserCardEntry.fromMap(updated as Map<String, dynamic>);
  }
}
