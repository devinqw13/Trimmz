import 'package:flutter/material.dart';

class PulsingWidget extends StatefulWidget {
  final Tween<double> tween;
  final Widget child;
  final Duration duration;

  const PulsingWidget({@required this.child, this.duration, this.tween}) : assert(child != null);
  _PulsingWidget createState() => _PulsingWidget();
}

class _PulsingWidget extends State<PulsingWidget> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Duration _duration;
  Tween<double> _tween;

  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tween = widget.tween ?? Tween(begin: 1.0, end: 0.50);
    _duration = widget.duration ?? Duration(milliseconds: 1000);
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );
    final CurvedAnimation curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
    _animation = _tween.animate(curve);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}