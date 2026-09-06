import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../core/ui/tokens.dart';

void overlaySnackMessage(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late final OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => _OverlaySnackMessage(
      message: message,
      onDone: () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      },
    ),
  );

  overlay.insert(overlayEntry);
}

class _OverlaySnackMessage extends StatefulWidget {
  final String message;
  final VoidCallback onDone;

  const _OverlaySnackMessage({required this.message, required this.onDone});

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
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (mounted) widget.onDone();
      });
    });
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
      bottom: AppSpacing.xxl * 2 + bottomInset,
      right: 0,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.sizeOf(context).width - AppSpacing.xxl * 2,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(AppRadii.md),
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
