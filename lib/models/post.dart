import 'app_user.dart';
import 'post_media.dart';

class Post {
  const Post({
    required this.id,
    required this.user,
    required this.media,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.isLiked,
    required this.isSaved,
  });

  final int id;
  final AppUser user;
  final List<PostMedia> media;
  final String caption;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isLiked;
  final bool isSaved;

  Post copyWith({
    int? id,
    AppUser? user,
    List<PostMedia>? media,
    String? caption,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
    bool? isLiked,
    bool? isSaved,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      media: media ?? this.media,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
