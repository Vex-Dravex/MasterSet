import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/mock_card_service.dart';
import '../models/card_models.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _service = MockCardService();
  final _controller = TextEditingController();
  var _results = <CardRef>[]; // <- now uses the model CardRef
  DateTime? _lastSubmit;

  void _search(String query) async {
    _lastSubmit = DateTime.now();
    final results = await _service.search(query);
    // simple debounce guard
    if (_lastSubmit != null &&
        DateTime.now().difference(_lastSubmit!) >=
            const Duration(milliseconds: 150)) {
      setState(() => _results = results);
    } else {
      setState(() => _results = results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon TCG Collector')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText:
                    'Search Pokémon… (e.g., Pikachu, Charizard, base1-4)',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _search,
              onChanged: (q) {
                // lightweight debounce
                Future.delayed(const Duration(milliseconds: 280), () {
                  if (_controller.text == q) _search(q);
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('Type to search…'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final c = _results[i];
                        return ListTile(
                          leading: Image.network(
                            c.imageUrl,
                            width: 56,
                            height: 56,
                          ),
                          title: Text(c.name),
                          subtitle: Text('${c.setName} • ${c.rarity}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/card/${c.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
