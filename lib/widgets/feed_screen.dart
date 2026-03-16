import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/posts_provider.dart';
import '../utils/constants.dart';
import 'feed_loading_shimmer.dart';
import 'post_preview_card.dart';
import 'stories_tray.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const int _storiesCount = 1;

  void _maybeLoadMore({
    required int index,
    required PostsProvider provider,
  }) {
    if (index >= provider.posts.length - 2) {
      provider.loadNextPage();
    }
  }

  void _showActionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not update this action. Try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (BuildContext context, PostsProvider provider, Widget? child) {
        final String? profileAvatarUrl =
            provider.posts.isNotEmpty ? provider.posts.first.user.avatarUrl : null;

        return Scaffold(
          appBar: _buildTopBar(),
          body: _buildBody(context, provider),
          bottomNavigationBar: _BottomNavBar(profileAvatarUrl: profileAvatarUrl),
        );
      },
    );
  }

  PreferredSizeWidget _buildTopBar() {
    return AppBar(
      backgroundColor: AppColors.pageBackground,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 56,
      toolbarHeight: 56,
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.add,
          color: AppColors.primaryText,
          size: 26,
        ),
      ),
      title: const Text(
        'Instagram',
        style: TextStyle(
          fontFamily: 'Billabong',
          color: AppColors.primaryText,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 0.94,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          padding: const EdgeInsets.only(right: 8),
          icon: const Icon(
            Icons.favorite_border,
            color: AppColors.primaryText,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PostsProvider provider) {
    if (provider.isInitialLoading) {
      return const FeedLoadingShimmer();
    }

    if (provider.errorMessage != null && provider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: provider.loadInitial,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final List<AppUser> storyUsers = _storyUsers(provider);
    final int extraLoader = provider.isLoadingMore ? 1 : 0;
    return RefreshIndicator(
      onRefresh: provider.loadInitial,
      child: ListView.builder(
        itemCount: provider.posts.length + _storiesCount + extraLoader,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return StoriesTray(users: storyUsers);
          }

          final int postIndex = index - _storiesCount;

          if (postIndex == provider.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          _maybeLoadMore(index: postIndex, provider: provider);
          final post = provider.posts[postIndex];

          return PostPreviewCard(
            post: post,
            onLikePressed: () async {
              try {
                await provider.toggleLike(post.id);
              } catch (_) {
                if (context.mounted) {
                  _showActionError(context);
                }
              }
            },
            onSavePressed: () async {
              try {
                await provider.toggleSave(post.id);
              } catch (_) {
                if (context.mounted) {
                  _showActionError(context);
                }
              }
            },
          );
        },
      ),
    );
  }

  List<AppUser> _storyUsers(PostsProvider provider) {
    final Map<int, AppUser> uniqueUsers = <int, AppUser>{};
    for (final post in provider.posts) {
      uniqueUsers[post.user.id] = post.user;
      if (uniqueUsers.length == 10) {
        break;
      }
    }
    return uniqueUsers.values.toList(growable: false);
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.profileAvatarUrl});

  final String? profileAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECECEC))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(Icons.home_filled, size: 26, color: AppColors.primaryText),
              const Icon(Icons.smart_display_outlined, size: 26, color: AppColors.primaryText),
              Transform.rotate(
                angle: -math.pi / 8,
                child: const Icon(
                  Icons.send_outlined,
                  size: 24,
                  color: AppColors.primaryText,
                ),
              ),
              const Icon(Icons.search_rounded, size: 28, color: AppColors.primaryText),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: const Color(0xFFEAEAEA),
                    backgroundImage: profileAvatarUrl == null
                        ? null
                        : CachedNetworkImageProvider(profileAvatarUrl!),
                    child: profileAvatarUrl == null
                        ? const Icon(Icons.person, color: Colors.black54, size: 17)
                        : null,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3354),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
