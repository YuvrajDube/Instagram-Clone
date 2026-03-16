import '../models/app_user.dart';
import '../models/post.dart';
import '../models/post_media.dart';

class PostsRepository {
  PostsRepository({this.simulateFailure = false});

  static const int _maxPages = 5;
  static const int _pageSize = 10;
  static const Duration _fetchDelay = Duration(milliseconds: 1500);
  static const Duration _interactionDelay = Duration(milliseconds: 250);

  final bool simulateFailure;

  Future<List<Post>> fetchPosts({required int page}) async {
    await Future.delayed(_fetchDelay);

    if (page < 1 || page > _maxPages) {
      return const <Post>[];
    }

    final int start = (page - 1) * _pageSize;
    return List<Post>.generate(
      _pageSize,
      (int index) => _buildPost(start + index + 1),
      growable: false,
    );
  }

  bool get hasMoreSeedData => true;

  Future<void> persistLike({
    required int postId,
    required bool nextValue,
  }) async {
    await Future.delayed(_interactionDelay);
    if (simulateFailure && postId % 17 == 0) {
      throw Exception('Unable to update like for post $postId');
    }
  }

  Future<void> persistSave({
    required int postId,
    required bool nextValue,
  }) async {
    await Future.delayed(_interactionDelay);
    if (simulateFailure && postId % 19 == 0) {
      throw Exception('Unable to update save for post $postId');
    }
  }

  Post _buildPost(int id) {
    final AppUser user = _buildUser(id);
    final int mediaCount = (id % 3) + 1;
    final List<PostMedia> media = List<PostMedia>.generate(
      mediaCount,
      (int idx) {
        final int imageSeed = (id * 10) + idx;
        return PostMedia(
          id: imageSeed,
          imageUrl: 'https://picsum.photos/seed/feed_$imageSeed/1080/1080',
          alt: 'Post image $imageSeed',
        );
      },
      growable: false,
    );

    final int baseLikeCount = 200 + (id * 7);

    return Post(
      id: id,
      user: user,
      media: media,
      caption: _captions[id % _captions.length],
      likeCount: baseLikeCount,
      commentCount: 8 + (id % 42),
      createdAt: DateTime.now().subtract(Duration(hours: id * 2)),
      isLiked: id % 5 == 0,
      isSaved: id % 7 == 0,
    );
  }

  AppUser _buildUser(int id) {
    final String username = _usernames[id % _usernames.length];
    final String displayName = username.replaceAll('.', ' ').toUpperCase();
    final int avatarSeed = 1000 + id;

    return AppUser(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: 'https://picsum.photos/seed/avatar_$avatarSeed/200/200',
    );
  }

  static const List<String> _usernames = <String>[
    'aria.studio',
    'pixel.diary',
    'wander.with.sam',
    'daily.frames',
    'cafe.stories',
    'fit.craft',
    'design.depth',
    'taste.and.trails',
    'motion.notes',
    'sunset.board',
  ];

  static const List<String> _captions = <String>[
    'Chasing clean lines and warm light today.',
    'Small details make the whole frame feel alive.',
    'Saved this one from the golden hour rush.',
    'Swipe for the close-up textures.',
    'Proof that simple moments can be the loudest.',
    'Drafting visual notes for the next shoot.',
    'Weekend colors hit differently.',
    'A little contrast and a lot of patience.',
  ];
}
