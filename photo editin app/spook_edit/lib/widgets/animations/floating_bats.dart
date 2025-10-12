import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

/// Halloween-themed floating bats background animation
class FloatingBatsBackground extends StatefulWidget {
  final int batCount;
  final Color batColor;

  const FloatingBatsBackground({
    super.key,
    this.batCount = 5,
    this.batColor = AppConstants.primaryOrange,
  });

  @override
  State<FloatingBatsBackground> createState() => _FloatingBatsBackgroundState();
}

class _FloatingBatsBackgroundState extends State<FloatingBatsBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<double> _batSizes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.batCount,
      (index) => AnimationController(
        duration: Duration(seconds: 10 + index * 2),
        vsync: this,
      )..repeat(),
    );

    _animations = _controllers.map((controller) {
      final startY = _random.nextDouble();
      final endY = _random.nextDouble();
      return Tween<Offset>(
        begin: Offset(-0.1, startY),
        end: Offset(1.1, endY),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    _batSizes = List.generate(
      widget.batCount,
      (index) => 30.0 + index * 10.0,
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _animations.asMap().entries.map((entry) {
        final index = entry.key;
        final animation = entry.value;
        return SlideTransition(
          position: animation,
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.pets, // Replace with bat icon if available
              size: _batSizes[index],
              color: widget.batColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}
