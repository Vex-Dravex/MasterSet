import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/collection_providers.dart';

class MyCollectionPage extends ConsumerWidget {
  const MyCollectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(userCollectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
      ),
      body: collectionAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Text('Your collection is empty for now.'),
            );
          }

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final entry = cards[index];

              return ListTile(
                leading: entry.imageUrl.isNotEmpty
                    ? Image.network(
                        entry.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported),
                title: Text(entry.name),
                subtitle: Text('${entry.setName} • ${entry.rarity}'),
                trailing: CircleAvatar(
                  radius: 14,
                  child: Text(
                    entry.quantity.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading collection:\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
