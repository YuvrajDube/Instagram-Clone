import 'dart:math' as math;

import 'package:flutter/material.dart';

class ZoomableImage extends StatefulWidget {
  const ZoomableImage({
    super.key,
    required this.child,
    this.onDoubleTap,
    this.onInteractionStateChanged,
    this.minScale = 1,
    this.maxScale = 3,
    this.resetDuration = const Duration(milliseconds: 220),
  });

  final Widget child;
  final VoidCallback? onDoubleTap;
  final ValueChanged<bool>? onInteractionStateChanged;
  final double minScale;
  final double maxScale;
  final Duration resetDuration;

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;

  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;
  OverlayEntry? _overlayEntry;
  Rect? _originRect;

  double _scale = 1;
  double _baseScale = 1;
  Offset _offset = Offset.zero;

  int _pointerCount = 0;
  bool _isScaling = false;
  bool _isInteracting = false;
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: widget.resetDuration,
    )..addListener(() {
        if (!mounted) {
          return;
        }
        setState(() {
          _scale = _scaleAnimation?.value ?? _scale;
          _offset = _offsetAnimation?.value ?? _offset;
        });
      });
  }

  @override
  void dispose() {
    _removeOverlay();
    _resetController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_pointerCount < 2) {
      return;
    }
    _resetController.stop();
    _isScaling = true;
    _setInteracting(true);
    _baseScale = _scale;
    _ensureOverlay();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isScaling) {
      return;
    }

    final double nextScale = (_baseScale * details.scale).clamp(
      widget.minScale,
      widget.maxScale,
    );

    Offset nextOffset = _offset;
    if (nextScale > 1.01) {
      nextOffset += details.focalPointDelta;
      nextOffset = _clampOffset(nextOffset, nextScale);
    } else {
      nextOffset = Offset.zero;
    }

    setState(() {
      _scale = nextScale;
      _offset = nextOffset;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isScaling) {
      return;
    }
    _isScaling = false;
    _animateReset();
  }

  void _setInteracting(bool value) {
    if (_isInteracting == value) {
      return;
    }
    _isInteracting = value;
    widget.onInteractionStateChanged?.call(value);
  }

  void _animateReset() {
    _scaleAnimation = Tween<double>(begin: _scale, end: 1).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _offsetAnimation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );

    _resetController
      ..reset()
      ..forward().whenCompleteOrCancel(() {
        _removeOverlay();
        if (mounted) {
          _setInteracting(false);
        }
      });
  }

  void _ensureOverlay() {
    if (_overlayEntry != null) {
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final OverlayState overlay = Overlay.of(context);
    if (renderBox == null || !renderBox.hasSize) {
      return;
    }

    final Offset globalOffset = renderBox.localToGlobal(Offset.zero);
    _originRect = Rect.fromLTWH(
      globalOffset.dx,
      globalOffset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        final Rect rect = _originRect!;
        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: Transform.translate(
                offset: _offset,
                child: Transform.scale(
                  scale: _scale,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _originRect = null;
  }

  Offset _clampOffset(Offset raw, double scale) {
    if (_viewportSize == Size.zero) {
      return raw;
    }

    final double maxDx = (_viewportSize.width * (scale - 1)) * 0.3;
    final double maxDy = (_viewportSize.height * (scale - 1)) * 0.3;

    return Offset(
      raw.dx.clamp(-maxDx, maxDx),
      raw.dy.clamp(-maxDy, maxDy),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Listener(
          onPointerDown: (_) {
            _pointerCount += 1;
            if (_pointerCount >= 2) {
              _setInteracting(true);
            }
          },
          onPointerUp: (_) {
            _pointerCount = math.max(0, _pointerCount - 1);
          },
          onPointerCancel: (_) {
            _pointerCount = math.max(0, _pointerCount - 1);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: widget.onDoubleTap,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: RepaintBoundary(
              child: Opacity(
                opacity: _overlayEntry == null ? 1 : 0,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
