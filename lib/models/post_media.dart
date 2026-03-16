class PostMedia {
  const PostMedia({
    required this.id,
    required this.imageUrl,
    this.alt = '',
  });

  final int id;
  final String imageUrl;
  final String alt;
}
