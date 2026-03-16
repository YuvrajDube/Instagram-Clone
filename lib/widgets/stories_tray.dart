import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../utils/constants.dart';

class StoriesTray extends StatelessWidget {
  const StoriesTray({
    super.key,
    required this.users,
  });

  final List<AppUser> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final AppUser user = users[index];
          return _StoryBubble(user: user);
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(2.2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFFFED373),
                      Color(0xFFF15245),
                      Color(0xFFD92E7F),
                      Color(0xFF9B36B7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: CircleAvatar(
                    radius: UiConstants.storyAvatarRadius,
                    backgroundColor: const Color(0xFFF0F0F0),
                    backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryText,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
