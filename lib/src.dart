import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SliderFlow extends StatefulWidget {
  final int count;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double borderRadiusValue;
  final ValueChanged<int> onActiveCountChanged;

  const SliderFlow({
    super.key,
    required this.count,
    required this.onActiveCountChanged,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.textStyle,
    this.borderRadiusValue = 4,
  });

  @override
  State<SliderFlow> createState() => _SliderFlowState();
}

class _SliderFlowState extends State<SliderFlow>
    with SingleTickerProviderStateMixin {
  late List<bool> _activeItems;
  int _lastActiveCount = 0;

  @override
  void initState() {
    super.initState();
    _activeItems = List.generate(widget.count, (_) => false);
  }

  void _setActiveCount(int activeCount) {
    if (activeCount != _lastActiveCount) {
      _lastActiveCount = activeCount;
      _activeItems = List.generate(widget.count, (i) => i < activeCount);
      HapticFeedback.selectionClick();
      widget.onActiveCountChanged(activeCount);
      setState(() {});
    }
  }

  void _updateFromDrag(Offset localPosition, double maxHeight) {
    final normalized = 1 - (localPosition.dy / maxHeight);
    final activeCount = (normalized * widget.count)
        .clamp(0, widget.count)
        .round();
    _setActiveCount(activeCount);
  }

  bool _isEndItem(int index) => index == 0 || index == widget.count - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bgColor =
        widget.backgroundColor ?? theme.colorScheme.surfaceVariant;
    final Color activeColor =
        widget.activeColor ?? theme.colorScheme.primary;
    final Color inactiveColor =
        widget.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.4);
    final TextStyle labelStyle =
        widget.textStyle ?? theme.textTheme.bodySmall ?? const TextStyle();

    return Container(
      width: 70,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadiusValue * 2),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          final box = context.findRenderObject() as RenderBox;
          final localOffset = box.globalToLocal(details.globalPosition);
          _updateFromDrag(localOffset, box.size.height);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.count, (index) {
            final bool isActive = _activeItems[index];
            return GestureDetector(
              onTap: () => _setActiveCount(index + 1),
              child: _SliderFlowItem(
                index: index,
                isActive: isActive,
                isEndItem: _isEndItem(index),
                currentValue: _lastActiveCount,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                textStyle: labelStyle,
                borderRadiusValue: widget.borderRadiusValue,
              ),
            );
          }).reversed.toList(),
        ),
      ),
    );
  }
}

class _SliderFlowItem extends StatefulWidget {
  final int index;
  final bool isActive;
  final bool isEndItem;
  final int currentValue;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle textStyle;
  final double borderRadiusValue;

  const _SliderFlowItem({
    required this.index,
    required this.isActive,
    required this.isEndItem,
    required this.currentValue,
    required this.activeColor,
    required this.inactiveColor,
    required this.textStyle,
    required this.borderRadiusValue,
  });

  @override
  State<_SliderFlowItem> createState() => _SliderFlowItemState();
}

class _SliderFlowItemState extends State<_SliderFlowItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayColor =
    widget.isActive ? widget.activeColor : widget.inactiveColor;
    final bool isCurrent =
        widget.isActive && widget.index == widget.currentValue - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // FIXED SIZE BOX TO PREVENT LINE SHIFT
        SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final double scale = isCurrent
                    ? 1.0 + 0.05 * _pulseController.value
                    : 1.0;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  height: 20 * scale,
                  width: 20 * scale,
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius:
                    BorderRadius.circular(widget.borderRadiusValue),
                    boxShadow: widget.isActive
                        ? [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.7),
                        blurRadius: isCurrent ? 12 : 6,
                        spreadRadius: isCurrent ? 2 : 1,
                      ),
                    ]
                        : [],
                  ),
                );
              },
            ),
          ),
        ),

        // Horizontal connecting line
        Container(
          width: widget.isEndItem ? 8 : 10,
          height: 0.2,
          color: displayColor,
        ),

        // Vertical line
        Container(
          width: widget.isEndItem ? 5 : 1,
          height: 30,
          decoration: BoxDecoration(
            shape:
            widget.isEndItem ? BoxShape.circle : BoxShape.rectangle,
            color: displayColor,
          ),
        ),

        SizedBox(width: widget.isEndItem ? 3 : 6),

        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: widget.textStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: isCurrent ? widget.activeColor : widget.inactiveColor,
          ),
          child: Text('${widget.index + 1}'),
        ),
      ],
    );
  }
}
