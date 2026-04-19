import 'package:flutter/material.dart';

enum SlideDirection { up, down, left, right }

class SliderAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double
  offset; // Seberapa jauh widget akan bergeser (dalam fraksi ukurannya)

  const SliderAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.direction = SlideDirection.up,
    this.offset = 0.2, // Nilai default 20% dari ukurannya
  });

  @override
  State<SliderAnimation> createState() => _SliderAnimationState();
}

class _SliderAnimationState extends State<SliderAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.up: // Muncul dari bawah ke atas
        beginOffset = Offset(0, widget.offset);
        break;
      case SlideDirection.down: // Muncul dari atas ke bawah
        beginOffset = Offset(0, -widget.offset);
        break;
      case SlideDirection.left: // Muncul dari kanan ke kiri
        beginOffset = Offset(widget.offset, 0);
        break;
      case SlideDirection.right: // Muncul dari kiri ke kanan
        beginOffset = Offset(-widget.offset, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve:
                Curves.easeOutCubic, // Memberikan efek decelerate yang smooth
          ),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
