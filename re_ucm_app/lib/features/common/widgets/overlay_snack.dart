import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/ui/constants.dart';

void overlaySnackMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => _OverlaySnackMessage(message: message),
  );

  overlay.insert(overlayEntry);

  Future.delayed(
    const Duration(milliseconds: 5500),
    () => overlayEntry.remove(),
  );
}

class _OverlaySnackMessage extends StatefulWidget {
  final String message;

  const _OverlaySnackMessage({required this.message});

  @override
  State<_OverlaySnackMessage> createState() => __OverlaySnackMessageState();
}

class __OverlaySnackMessageState extends State<_OverlaySnackMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Durations.medium2,
      reverseDuration: Durations.short4,
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(_animation);

    _controller.forward();
    Future.delayed(const Duration(seconds: 5), () => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = max(
      MediaQuery.viewInsetsOf(context).bottom,
      MediaQuery.paddingOf(context).bottom,
    );

    return Positioned(
      bottom: appPadding * 4 + bottomInset,
      right: 0,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width - appPadding * 4,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(
                horizontal: appPadding * 3,
                vertical: appPadding * 2,
              ),
              margin: const EdgeInsets.symmetric(horizontal: appPadding * 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                widget.message,
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
