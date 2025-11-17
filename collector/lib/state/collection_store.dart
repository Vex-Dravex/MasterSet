import 'package:flutter/foundation.dart';

class CollectionStore {
  CollectionStore._();
  static final instance = CollectionStore._();

  final ValueNotifier<Map<String, int>> state = ValueNotifier(<String, int>{});

  void add(String cardId, {int qty = 1}) {
    final current = state.value[cardId] ?? 0;
    state.value = {...state.value, cardId: current + qty};
  }

  void removeOne(String cardId) {
    final current = state.value[cardId] ?? 0;
    if (current <= 1) {
      final next = Map<String, int>.from(state.value)..remove(cardId);
      state.value = next;
    } else {
      state.value = {...state.value, cardId: current - 1};
    }
  }

  int qtyOf(String cardId) => state.value[cardId] ?? 0;
}
