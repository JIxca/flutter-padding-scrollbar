import 'dart:async';

import 'package:flutter/material.dart';
import 'package:padding_scrollbar/padding_scrollbar.dart';

const double _kScrollbarThickness = 6.0;
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 300);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 600);

class PaddingScrollbar extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;

  const PaddingScrollbar({
    Key key,
    @required this.child,
    this.padding = EdgeInsets.zero,
  })  : assert(padding != null),
        super(key: key);

  @override
  _PaddingScrollbarState createState() => _PaddingScrollbarState();
}

class _PaddingScrollbarState extends State<PaddingScrollbar>
    with TickerProviderStateMixin {
  ScrollbarPainter _materialPainter;
  TargetPlatform _currentPlatform;
  TextDirection _textDirection;
  Color _themeColor;

  AnimationController _fadeoutAnimationController;
  Animation<double> _fadeoutOpacityAnimation;
  Timer _fadeoutTimer;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarFadeDuration,
    );
    _fadeoutOpacityAnimation = CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ThemeData theme = Theme.of(context);
    _currentPlatform = theme.platform;

    switch (_currentPlatform) {
      case TargetPlatform.iOS:
        _fadeoutTimer?.cancel();
        _fadeoutTimer = null;
        _fadeoutAnimationController.reset();
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        _themeColor = theme.highlightColor.withOpacity(1.0);
        _textDirection = Directionality.of(context);
        _materialPainter = _buildMaterialScrollbarPainter();
        break;
    }
  }

  ScrollbarPainter _buildMaterialScrollbarPainter() {
    return ScrollbarPainter(
      color: _themeColor,
      textDirection: _textDirection,
      thickness: _kScrollbarThickness,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      padding: MediaQuery.of(context).padding.add(widget.padding),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }
    if (_currentPlatform != TargetPlatform.iOS &&
        (notification is ScrollUpdateNotification ||
            notification is OverscrollNotification)) {
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }
      _materialPainter.update(
          notification.metrics, notification.metrics.axisDirection);
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(_kScrollbarTimeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
    return false;
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _fadeoutTimer?.cancel();
    _materialPainter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPlatform) {
      case TargetPlatform.iOS:
        return CupertinoPaddingScrollbar(
          child: widget.child,
          padding: widget.padding,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: RepaintBoundary(
            child: CustomPaint(
              foregroundPainter: _materialPainter,
              child: RepaintBoundary(
                child: widget.child,
              ),
            ),
          ),
        );
    }
    throw FlutterError('Unknown platform for scrollbar insertion');
  }
}
