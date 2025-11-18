import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Replace this import with your actual collection repository provider import.
import 'lib/repositories/collection_repository.dart';

// TODO: Replace this with your real card model type.
// For example: `CardWithSet`, `PokemonCardWithSet`, etc.
class CardDetailArgs {
  final dynamic card; // Replace `dynamic` with your real type.
  final int initialQuantity;

  const CardDetailArgs({
    required this.card,
    required this.initialQuantity,
  });
}

class CardDetailPage extends ConsumerStatefulWidget {
  static const String routeName = 'card-detail';

  final CardDetailArgs args;

  const CardDetailPage({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends ConsumerState<CardDetailPage> {
  late int _quantity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.args.initialQuantity;
  }

  Future<void> _increment() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(collectionRepositoryProvider);

      // TODO: Replace `widget.args.card.id` with however you reference the card ID.
      await repo.addOrIncrementCard(widget.args.card.id);

      setState(() => _quantity += 1);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _decrement() async {
    if (_isSaving || _quantity <= 0) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(collectionRepositoryProvider);

      // TODO: Replace `widget.args.card.id` and method name as needed.
      await repo.decrementOrRemoveCard(widget.args.card.id);

      setState(() => _quantity -= 1);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _addIfZero() async {
    if (_quantity > 0) return;
    await _increment();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.args.card;

    // TODO: Replace these field names with your actual model fields.
    final String name = card.name ?? 'Unknown Card';
    final String setName = card.setName ?? 'Unknown Set';
    final String rarity = card.rarity ?? 'Unknown Rarity';
    final String? imageUrl = card.imageUrl; // nullable if missing

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Image
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.image_not_supported));
                        },
                      )
                    : Container(
                        alignment: Alignment.center,
                        color: Colors.black12,
                        child: const Icon(
                          Icons.catching_pokemon,
                          size: 64,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Name + Set
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              setName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rarity: $rarity',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Quantity controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'In your collection:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 0 && !_isSaving ? _decrement : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: !_isSaving ? _increment : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Primary add button
            FilledButton.icon(
              onPressed: _quantity == 0 && !_isSaving ? _addIfZero : null,
              icon: const Icon(Icons.add),
              label: Text(_quantity == 0 ? 'Add to My Collection' : 'Already added'),
            ),

            if (_isSaving) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
