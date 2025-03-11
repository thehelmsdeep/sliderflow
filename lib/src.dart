import 'package:flutter/material.dart';

class SliderFlow extends StatefulWidget {
  final int count;
  final Color activeColor;
  final Color deActiveColor;
  final Color backgroundColor;
  final TextStyle textStyle;
  final double borderRadiusValue;
  final Function(int numberOfActives) onActiveCountChanged;

  const SliderFlow({
    super.key,
    required this.count,
    required this.onActiveCountChanged,
    this.backgroundColor = const Color(0xff10112b),
    this.activeColor = const Color(0xff53b9f8),
    this.deActiveColor = const Color(0xff737475),
    this.textStyle = const TextStyle(fontSize: 11),
    this.borderRadiusValue = 1,
  });

  @override
  _SliderFlowState createState() => _SliderFlowState();
}




class _SliderFlowState extends State<SliderFlow> {
  late List<bool> activeItems;

  @override
  void initState() {
    super.initState();
    activeItems = List.generate(widget.count, (index) => false);
  }

  void _updateDragPosition(Offset localPosition, double maxHeight) {
    int activeIndex = ((1 - (localPosition.dy / maxHeight)) * widget.count)
        .clamp(0, widget.count)
        .toInt();
    setState(() {
      for (int i = 0; i < widget.count; i++) {
        activeItems[i] = i < activeIndex;
      }
    });

    widget.onActiveCountChanged(currentValue);
  }

  bool isLastIOrFirst(int index) => index == widget.count - 1 || index == 0;

  int get currentValue => activeItems.where((e) => e).toList().length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadiusValue * 2),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset localOffset = box.globalToLocal(details.globalPosition);
          _updateDragPosition(localOffset, box.size.height);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.count, (index) {
                bool isActive = activeItems[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 20,
                      width: 20,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? widget.activeColor
                            : widget.deActiveColor,
                        borderRadius:
                            BorderRadius.circular(widget.borderRadiusValue),
                      ),
                    ),
                    Container(
                      width: isLastIOrFirst(index) ? 8 : 10,
                      height: 0.2,
                      color:
                          isActive ? widget.activeColor : widget.deActiveColor,
                    ),
                    Container(
                      width: isLastIOrFirst(index) ? 5 : 1,
                      height: isLastIOrFirst(index) ? 30 : 30,
                      decoration: BoxDecoration(
                        shape: isLastIOrFirst(index)
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        color: isActive
                            ? widget.activeColor
                            : widget.deActiveColor,
                      ),
                    ),
                    SizedBox(
                      width: isLastIOrFirst(index) ? 3 : 6,
                    ),
                    Text(
                      '${index + 1}',
                      style: widget.textStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: (isActive && index == currentValue - 1)
                            ? widget.activeColor
                            : widget.deActiveColor,
                      ),
                    ),
                  ],
                );
              }).reversed.toList(),
            );
          },
        ),
      ),
    );
  }
}
