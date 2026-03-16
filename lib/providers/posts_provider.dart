import 'package:flutter/foundation.dart';

import '../models/post.dart';
import '../repositories/posts_repository.dart';

class PostsProvider extends ChangeNotifier {
  PostsProvider({required PostsRepository repository}) : _repository = repository;

  final PostsRepository _repository;
  final List<Post> _posts = <Post>[];

  static const int _maxPages = 5;

  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;

  List<Post> get posts => List<Post>.unmodifiable(_posts);
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadInitial() async {
    if (_isInitialLoading) {
      return;
    }

    _isInitialLoading = true;
    _errorMessage = null;
    _posts.clear();
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final List<Post> firstPage = await _repository.fetchPosts(page: 1);
      _posts.addAll(firstPage);
      _currentPage = 1;
      _hasMore = _currentPage < _maxPages;
    } catch (_) {
      _errorMessage = 'Could not load feed. Pull to retry.';
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final int targetPage = _currentPage + 1;
      final List<Post> nextPage = await _repository.fetchPosts(page: targetPage);
      _posts.addAll(nextPage);
      _currentPage = targetPage;
      _hasMore = _currentPage < _maxPages && nextPage.isNotEmpty;
    } catch (_) {
      _errorMessage = 'Could not load more posts.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId) async {
    final int index = _posts.indexWhere((Post post) => post.id == postId);
    if (index == -1) {
      return;
    }

    final Post previous = _posts[index];
    final bool nextLiked = !previous.isLiked;
    final int nextLikeCount = nextLiked ? previous.likeCount + 1 : previous.likeCount - 1;

    _posts[index] = previous.copyWith(
      isLiked: nextLiked,
      likeCount: nextLikeCount,
    );
    notifyListeners();

    try {
      await _repository.persistLike(postId: postId, nextValue: nextLiked);
    } catch (_) {
      _posts[index] = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleSave(int postId) async {
    final int index = _posts.indexWhere((Post post) => post.id == postId);
    if (index == -1) {
      return;
    }

    final Post previous = _posts[index];
    final bool nextSaved = !previous.isSaved;
    _posts[index] = previous.copyWith(isSaved: nextSaved);
    notifyListeners();

    try {
      await _repository.persistSave(postId: postId, nextValue: nextSaved);
    } catch (_) {
      _posts[index] = previous;
      notifyListeners();
      rethrow;
    }
  }
}
