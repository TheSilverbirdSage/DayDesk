import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class SwipeDeleteAction extends StatefulWidget {
  const SwipeDeleteAction({
    super.key,
    required this.child,
    required this.onDelete,
    this.bottomInset = 14,
  });

  final Widget child;
  final VoidCallback onDelete;
  final double bottomInset;

  @override
  State<SwipeDeleteAction> createState() => _SwipeDeleteActionState();
}

class _SwipeDeleteActionState extends State<SwipeDeleteAction> {
  static const _actionWidth = 74.0;

  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            offset: Offset(_dragOffset / MediaQuery.sizeOf(context).width, 0),
            child: widget.child,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: widget.bottomInset),
                child: IgnorePointer(
                  ignoring: _dragOffset == 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: _dragOffset == 0 ? 0 : 1,
                    child: SizedBox(
                      width: _actionWidth,
                      child: Material(
                        color: AppTheme.urgent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: widget.onDelete,
                          child: const Center(
                            child: Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 26,
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

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-_actionWidth, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen = _dragOffset < -_actionWidth / 2 || velocity < -350;
    setState(() {
      _dragOffset = shouldOpen ? -_actionWidth : 0;
    });
  }
}
