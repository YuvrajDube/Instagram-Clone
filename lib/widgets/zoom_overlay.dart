import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ZoomOverlay extends StatefulWidget {
  const ZoomOverlay({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<ZoomOverlay> createState() => _ZoomOverlayState();
}

class _ZoomOverlayState extends State<ZoomOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;

  double _scale = 1;
  double _baseScale = 1;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: UiConstants.mediumAnimation,
    )
      ..addListener(() {
        if (!mounted) {
          return;
        }
        setState(() {
          _scale = _scaleAnimation?.value ?? _scale;
          _offset = _offsetAnimation?.value ?? _offset;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).pop();
        }
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _resetController.stop();
    _baseScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double nextScale = (_baseScale * details.scale).clamp(1, 4.0);
    setState(() {
      _scale = nextScale;
      if (_scale <= 1.01) {
        _offset = Offset.zero;
      } else {
        _offset += details.focalPointDelta;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _animateBackAndClose();
  }

  void _animateBackAndClose() {
    _scaleAnimation = Tween<double>(begin: _scale, end: 1).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _offsetAnimation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _resetController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _animateBackAndClose,
            ),
          ),
          SafeArea(
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRect(
                    child: Transform.translate(
                      offset: _offset,
                      child: Transform.scale(
                        scale: _scale,
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF1B1B1B),
                          ),
                          errorWidget: (context, url, error) => const ColoredBox(
                            color: Color(0xFF1B1B1B),
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
