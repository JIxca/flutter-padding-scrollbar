library padding_scrollbar;

import 'dart:async';

import 'package:flutter/widgets.dart';

const Color _kScrollbarColor = Color(0x99777777);
const double _kScrollbarMinLength = 36.0;
const double _kScrollbarMinOverscrollLength = 8.0;
const Radius _kScrollbarRadius = Radius.circular(1.25);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 50);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
const double _kScrollbarThickness = 2.5;
const double _kScrollbarMainAxisMargin = 3.0;
const double _kScrollbarCrossAxisMargin = 3.0;

class CupertinoPaddingScrollbar extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;

  const CupertinoPaddingScrollbar({
    Key key,
    @required this.child,
    this.padding = EdgeInsets.zero,
  })  : assert(padding != null),
        super(key: key);

  @override
  _CupertinoPaddingScrollbarState createState() =>
      _CupertinoPaddingScrollbarState();
}

class _CupertinoPaddingScrollbarState extends State<CupertinoPaddingScrollbar>
    with TickerProviderStateMixin {
  ScrollbarPainter _painter;
  TextDirection _textDirection;

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
    _textDirection = Directionality.of(context);
    _painter = _buildCupertinoScrollbarPainter();
  }

  ScrollbarPainter _buildCupertinoScrollbarPainter() {
    return ScrollbarPainter(
      color: _kScrollbarColor,
      textDirection: _textDirection,
      thickness: _kScrollbarThickness,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      mainAxisMargin: _kScrollbarMainAxisMargin,
      crossAxisMargin: _kScrollbarCrossAxisMargin,
      radius: _kScrollbarRadius,
      padding: MediaQuery.of(context).padding.add(widget.padding),
      minLength: _kScrollbarMinLength,
      minOverscrollLength: _kScrollbarMinOverscrollLength,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }
    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }
      _fadeoutTimer?.cancel();
      _painter.update(notification.metrics, notification.metrics.axisDirection);
    } else if (notification is ScrollEndNotification) {
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
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: CustomPaint(
          foregroundPainter: _painter,
          child: RepaintBoundary(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
