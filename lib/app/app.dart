import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart';
import '../repositories/posts_repository.dart';
import '../widgets/feed_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostsProvider>(
      create: (_) => PostsProvider(repository: PostsRepository())..loadInitial(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Feed Clone',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        ),
        home: const FeedScreen(),
      ),
    );
  }
}
