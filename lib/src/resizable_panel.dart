import 'package:flutter/material.dart';

class ResizablePanel extends StatefulWidget {
  Widget? left;
  Widget? right;
  double handle_size;
  double initial_panel_size;
  double left_min_width;
  double right_min_width;
  Function(double) on_update_size;
  CrossAxisAlignment cross_axis_alignment;

  ResizablePanel(
      {required this.left,
      required this.right,
      required this.initial_panel_size,
      required this.on_update_size,
      this.handle_size = 4,
      this.left_min_width = 0,
      this.right_min_width = 0,
      this.cross_axis_alignment = CrossAxisAlignment.start});

  @override
  _ResizablePanelState createState() {
    return _ResizablePanelState();
  }
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double panel_size;

  double clamp_panel_size(double panel_size, BoxConstraints constraints) {
    try {
      return panel_size.clamp(widget.left_min_width, constraints.maxWidth - widget.right_min_width);
    } on ArgumentError catch (_) {
      return panel_size;
    }
  }

  @override
  void initState() {
    panel_size = widget.initial_panel_size;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResizablePanel oldWidget) {
    if (oldWidget.initial_panel_size != widget.initial_panel_size)
      setState(() {
        panel_size = widget.initial_panel_size;
      });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.left == null && widget.right == null) return Row(children: []);
    if (widget.left == null) return Row(children: [Expanded(child: widget.right!)]);
    if (widget.right == null) return Row(children: [Expanded(child: widget.left!)]);

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      panel_size = clamp_panel_size(panel_size, constraints);
      return Row(
        children: [
          Stack(
            children: [
              SizedBox(
                width: panel_size,
                child: widget.left!,
              ),
              Positioned(
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (DragUpdateDetails dragDetails) {
                      double new_size = clamp_panel_size(panel_size + dragDetails.delta.dx, constraints);
                      setState(() {
                        panel_size = new_size;
                      });
                    },
                    onHorizontalDragEnd: (DragEndDetails? drag_end_details) {
                      widget.on_update_size(panel_size);
                    },
                    child: SizedBox(
                      width: widget.handle_size,
                      height: constraints.maxHeight,
                    ),
                  ),
                ),
                right: 0,
              )
            ],
          ),
          Expanded(child: widget.right!),
        ],
        crossAxisAlignment: widget.cross_axis_alignment,
      );
    });
  }
}
