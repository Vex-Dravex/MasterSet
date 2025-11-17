import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/collection_repository.dart';

/// Global Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Collection repository provider
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseCollectionRepository(client);
});

/// User collection provider (all cards the user owns)
final userCollectionProvider =
    FutureProvider<List<UserCardEntry>>((ref) async {
  final repo = ref.watch(collectionRepositoryProvider);
  return repo.getUserCollection();
});

/// 🔹 NEW: Single entry for a given cardId (or null if user doesn't own it)
final userCardForCardProvider =
    FutureProvider.family<UserCardEntry?, String>((ref, cardId) async {
  final repo = ref.watch(collectionRepositoryProvider);
  return repo.getUserCardForCard(cardId);
});

/// 🔹 NEW: Actions wrapper to mutate collection and refresh providers
class CardCollectionActions {
  CardCollectionActions(this.ref);

  final Ref ref;

  CollectionRepository get _repo =>
      ref.read(collectionRepositoryProvider);

  Future<void> add(String cardId, {int quantity = 1}) async {
    await _repo.addOrIncrementCard(cardId, quantity: quantity);

    // Refresh both the single-card view and the full collection
    ref.invalidate(userCardForCardProvider(cardId));
    ref.invalidate(userCollectionProvider);
  }

  Future<void> remove(String cardId, {int quantity = 1}) async {
    await _repo.decrementOrRemoveCard(cardId, quantity: quantity);

    ref.invalidate(userCardForCardProvider(cardId));
    ref.invalidate(userCollectionProvider);
  }
}

/// 🔹 NEW: Provider to access CardCollectionActions from the UI
final cardCollectionActionsProvider =
    Provider<CardCollectionActions>((ref) {
  return CardCollectionActions(ref);
});
