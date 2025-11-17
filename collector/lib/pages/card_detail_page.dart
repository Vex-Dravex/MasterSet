import 'package:flutter/material.dart';
import '../services/mock_card_service.dart';
import '../services/price_service.dart';
import '../state/collection_store.dart';

class CardDetailPage extends StatefulWidget {
  final String cardId;
  const CardDetailPage({super.key, required this.cardId});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  final _cards = MockCardService();
  final _prices = MockPriceService();
  double? _market;
  bool _loadingPrice = true;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    final q = await _prices.getPrice(widget.cardId);
    setState(() {
      _market = q.market;
      _loadingPrice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards.getById(widget.cardId);

    return Scaffold(
      appBar: AppBar(title: Text(card.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(card.imageUrl, height: 240),
            const SizedBox(height: 16),
            Text(card.setName, style: Theme.of(context).textTheme.titleMedium),
            Text('Rarity: ${card.rarity}'),
            const SizedBox(height: 12),
            if (_loadingPrice)
              const Text('Loading price…')
            else
              Text(_market == null ? 'No price' : 'Market: \$${_market!.toStringAsFixed(2)}'),
            const SizedBox(height: 20),

            // Live quantity view via ValueListenableBuilder
            ValueListenableBuilder<Map<String, int>>(
              valueListenable: CollectionStore.instance.state,
              builder: (_, map, __) {
                final qty = map[card.id] ?? 0;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () => CollectionStore.instance.add(card.id),
                          child: const Text('Add to My Collection'),
                        ),
                        const SizedBox(width: 12),
                        if (qty > 0)
                          OutlinedButton(
                            onPressed: () => CollectionStore.instance.removeOne(card.id),
                            child: const Text('-1'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('You own: $qty'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

