import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/post.dart';
import '../utils/constants.dart';
import 'zoomable_image.dart';

class PostPreviewCard extends StatefulWidget {
  const PostPreviewCard({
    super.key,
    required this.post,
    required this.onLikePressed,
    required this.onSavePressed,
  });

  final Post post;
  final VoidCallback onLikePressed;
  final VoidCallback onSavePressed;

  @override
  State<PostPreviewCard> createState() => _PostPreviewCardState();
}

class _PostPreviewCardState extends State<PostPreviewCard> {
  late final PageController _pageController;
  Timer? _counterVisibilityTimer;

  int _currentPage = 0;
  bool _showImageCounter = false;
  bool _isPinchActive = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _counterVisibilityTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PostPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _counterVisibilityTimer?.cancel();
      _currentPage = 0;
      _showImageCounter = false;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  void _showCounterTemporarily() {
    _counterVisibilityTimer?.cancel();
    if (!_showImageCounter) {
      setState(() {
        _showImageCounter = true;
      });
    }
    _counterVisibilityTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showImageCounter = false;
      });
    });
  }

  Widget _buildMediaItem({
    required String imageUrl,
  }) {
    return ZoomableImage(
      onDoubleTap: widget.onLikePressed,
      onInteractionStateChanged: (bool isActive) {
        if (!mounted || _isPinchActive == isActive) {
          return;
        }
        setState(() {
          _isPinchActive = isActive;
        });
      },
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: const Color(0xFFF1F1F1)),
        errorWidget: (context, url, error) => const ColoredBox(
          color: Color(0xFFF1F1F1),
          child: Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Post postData = widget.post;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConstants.screenHorizontalPadding,
            vertical: 8,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: UiConstants.avatarRadius,
                backgroundImage: CachedNetworkImageProvider(postData.user.avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  postData.user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz),
            ],
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: _isPinchActive
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: postData.media.length,
                onPageChanged: (int page) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _currentPage = page;
                  });
                  _showCounterTemporarily();
                },
                itemBuilder: (BuildContext context, int index) {
                  return _buildMediaItem(
                    imageUrl: postData.media[index].imageUrl,
                  );
                },
              ),
              if (postData.media.length > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: AnimatedOpacity(
                    duration: UiConstants.fastAnimation,
                    opacity: _showImageCounter ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${postData.media.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (postData.media.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentPage,
                count: postData.media.length,
                effect: WormEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  spacing: 5,
                  dotColor: Colors.black.withValues(alpha: 0.2),
                  activeDotColor: Colors.black.withValues(alpha: 0.72),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UiConstants.screenHorizontalPadding,
            8,
            UiConstants.screenHorizontalPadding,
            4,
          ),
          child: Row(
            children: [
              _ActionIconButton(
                onPressed: widget.onLikePressed,
                icon: Icon(
                  postData.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: postData.isLiked ? const Color(0xFFED4956) : const Color(0xFF7A7A7A),
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              _ActionIconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comments flow in next phase.')),
                  );
                },
                icon: const Icon(Icons.mode_comment_outlined, size: 26),
              ),
              const SizedBox(width: 14),
              _ActionIconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reshare flow in next phase.')),
                  );
                },
                icon: const Icon(Icons.repeat_rounded, size: 26),
              ),
              const SizedBox(width: 14),
              _ActionIconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share flow in next phase.')),
                  );
                },
                icon: Transform.rotate(
                  angle: -math.pi / 8,
                  child: const Icon(Icons.send_outlined, size: 25),
                ),
              ),
              const Spacer(),
              _ActionIconButton(
                onPressed: widget.onSavePressed,
                icon: Icon(
                  postData.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 27,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConstants.screenHorizontalPadding,
          ),
          child: Text(
            '${postData.likeCount} likes',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConstants.screenHorizontalPadding,
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.primaryText),
              children: [
                TextSpan(
                  text: '${postData.user.username} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: postData.caption),
              ],
            ),
          ),
        ),
        const SizedBox(height: UiConstants.postVerticalGap),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      splashRadius: 22,
      padding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
    );
  }
}
