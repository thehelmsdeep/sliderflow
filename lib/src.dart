import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SliderFlowTheme {
  final Color? activeItemColor;
  final Color? inactiveItemColor;
  final double? borderRadius;
  final Color? verticalLineColor;
  final double? verticalLineWidth;
  final TextStyle? labelTextStyle;
  final TextStyle? itemTextStyle;

  const SliderFlowTheme({
    this.activeItemColor,
    this.inactiveItemColor,
    this.borderRadius,
    this.verticalLineColor,
    this.verticalLineWidth,
    this.labelTextStyle,
    this.itemTextStyle,
  });
}



class SliderFlow extends StatefulWidget {
  final int count;
  final Color? backgroundColor;
  final ValueChanged<int> onChanged;
  final String? label;
  final SliderFlowTheme? theme;
  final List<String>? itemLabels;

  const SliderFlow({
    super.key,
    required this.count,
    required this.onChanged,
    this.backgroundColor,
    this.label,
    this.theme,
    this.itemLabels
  }): assert(itemLabels == null || itemLabels.length == count, 'itemLabels length must match count');

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
      widget.onChanged(activeCount);
      setState(() {});
    }
  }

  void _updateFromDrag(Offset localPosition, double maxHeight) {
    final normalized = 1 - (localPosition.dy / maxHeight);
    final activeCount =
    (normalized * widget.count).clamp(0, widget.count).round();
    _setActiveCount(activeCount);
  }

  bool _isEndItem(int index) => index == 0 || index == widget.count - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bgColor =
        widget.backgroundColor ?? theme.colorScheme.surfaceVariant;
    final Color activeColor =
        widget.theme?.activeItemColor ?? theme.colorScheme.primary;
    final Color inactiveColor = widget.theme?.inactiveItemColor ??
        theme.colorScheme.onSurface.withOpacity(0.4);
    final double borderRadiusValue = widget.theme?.borderRadius ?? 4;
    final Color verticalLineColor =
        widget.theme?.verticalLineColor ?? inactiveColor;
    final double verticalLineWidth = widget.theme?.verticalLineWidth ?? 1;


    final TextStyle labelStyle = widget.theme?.labelTextStyle ??
        theme.textTheme.bodyMedium ??
        const TextStyle();
    final TextStyle itemStyle = widget.theme?.itemTextStyle ??
        theme.textTheme.bodySmall ??
        const TextStyle();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadiusValue * 2),
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
                      textStyle: itemStyle,
                      borderRadiusValue: borderRadiusValue,
                      verticalLineColor: verticalLineColor,
                      verticalLineWidth: verticalLineWidth,
                      itemLabel: widget.itemLabels != null
                          ? widget.itemLabels![index]
                          : '${index + 1}',

                    ),
                  );
                }).reversed.toList(),
              ),
            ),
          ),
        ),
        if (widget.label != null)
          Positioned(
            bottom: 8,
            left: -24,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                widget.label!,
                style: labelStyle,
              ),
            ),
          ),
      ],
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
  final Color verticalLineColor;
  final double verticalLineWidth;
  final String itemLabel;

  const _SliderFlowItem({
    required this.index,
    required this.isActive,
    required this.isEndItem,
    required this.currentValue,
    required this.activeColor,
    required this.inactiveColor,
    required this.textStyle,
    required this.borderRadiusValue,
    required this.verticalLineColor,
    required this.verticalLineWidth,
    required this.itemLabel,
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
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrent =
        widget.index == widget.currentValue - 1 && widget.isActive;
    final displayColor =
    widget.index < widget.currentValue ? widget.activeColor : widget.inactiveColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: isCurrent
                ?
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.5 + 0.5 * _pulseController.value,
                  child: child,
                );
              },
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.activeColor,
                  borderRadius: BorderRadius.circular(widget.borderRadiusValue),
                ),
              ),
            )

            : Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color:
                widget.isActive ? widget.activeColor : widget.inactiveColor,
                borderRadius:
                BorderRadius.circular(widget.borderRadiusValue),
              ),
            ),
          ),
        ),

        Container(
          width: widget.isEndItem ? 8 : 10,
          height: 0.2,
          color: displayColor,
        ),

        Container(
          width: widget.isEndItem ? 5 : widget.verticalLineWidth,
          height: 30,
          decoration: BoxDecoration(
            color:  widget.verticalLineColor,
            shape: widget.isEndItem ? BoxShape.circle : BoxShape.rectangle,
          ),
        ),

        SizedBox(width: widget.isEndItem ? 3 : 6),

        Text(widget.itemLabel,style: widget.textStyle),

      ],
    );
  }
}
