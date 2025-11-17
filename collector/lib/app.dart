import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/search_page.dart';
import 'pages/card_detail_page.dart';
import 'pages/my_collection_page.dart';

final _router = GoRouter(
  initialLocation: '/collection', // 👈 start on My Collection for now
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SearchPage(),
    ),
    GoRoute(
      path: '/collection',
      builder: (_, __) => const MyCollectionPage(),
    ),
    GoRoute(
      path: '/card/:id',
      builder: (context, state) =>
          CardDetailPage(cardId: state.pathParameters['id']!),
    ),
  ],
);

class CollectorApp extends StatelessWidget {
  const CollectorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pokémon TCG Collector',
      theme: ThemeData.dark(useMaterial3: true),
      routerConfig: _router,
    );
  }
}
