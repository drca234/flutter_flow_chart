import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/objects/oval_widget.dart';
import '../../flutter_flow_chart.dart';
import '../objects/parallelogram_widget.dart';
import 'element_handlers.dart';
import '../objects/diamond_widget.dart';
import '../objects/rectangle_widget.dart';
import '../objects/storage_widget.dart';
import 'resize_widget.dart';

/// Widget that use [element] properties to display it on the dashboard scene
class ElementWidget extends StatefulWidget {
  final Dashboard dashboard;
  final FlowElement element;
  final TransformationController? controller;
  final Function(BuildContext context, Offset position)? onElementPressed;
  final Function(BuildContext context, Offset position)?
      onElementSecondaryTapped;
  final Function(BuildContext context, Offset position)? onElementLongPressed;
  final Function(BuildContext context, Offset position)?
      onElementSecondaryLongTapped;
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerPressed;
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryTapped;
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerLongPressed;
  final Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryLongTapped;

  const ElementWidget({
    super.key,
    required this.dashboard,
    required this.element,
    this.onElementPressed,
    this.onElementSecondaryTapped,
    this.onElementLongPressed,
    this.onElementSecondaryLongTapped,
    this.onHandlerPressed,
    this.onHandlerSecondaryTapped,
    this.onHandlerLongPressed,
    this.onHandlerSecondaryLongTapped,
    this.controller,
  });

  @override
  State<ElementWidget> createState() => _ElementWidgetState();
}

class _ElementWidgetState extends State<ElementWidget> {
  // local widget touch position when start dragging
  Offset delta = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.element.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.element.removeListener(_elementChanged);
    super.dispose();
  }

  _elementChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget element;

    switch (widget.element.kind) {
      case ElementKind.diamond:
        element = DiamondWidget(element: widget.element);
        break;
      case ElementKind.storage:
        element = StorageWidget(element: widget.element);
        break;
      case ElementKind.oval:
        element = OvalWidget(element: widget.element);
        break;
      case ElementKind.parallelogram:
        element = ParallelogramWidget(element: widget.element);
        break;
      case ElementKind.rectangle:
      default:
        element = RectangleWidget(element: widget.element);
    }

    if (widget.element.isResizing) {
      return Transform.translate(
        offset: widget.element.position,
        transformHitTests: true,
        child: ResizeWidget(
          element: widget.element,
          dashboard: widget.dashboard,
          child: element,
        ),
      );
    }

    element = Padding(
      padding: EdgeInsets.all(widget.element.handlerSize / 2),
      child: element,
    );

    Offset tapLocation = Offset.zero;
    Offset secondaryTapDownPos = Offset.zero;
    return Transform.translate(
      offset: widget.element.position,
      transformHitTests: true,
      child: GestureDetector(
        onTapDown: (details) => tapLocation = details.globalPosition,
        onSecondaryTapDown: (details) =>
            secondaryTapDownPos = details.globalPosition,
        onTap: () {
          if (widget.onElementPressed != null) {
            widget.onElementPressed!(context, tapLocation);
          }
        },
        onSecondaryTap: () {
          if (widget.onElementSecondaryTapped != null) {
            widget.onElementSecondaryTapped!(context, secondaryTapDownPos);
          }
        },
        onLongPress: () {
          if (widget.onElementLongPressed != null) {
            widget.onElementLongPressed!(context, tapLocation);
          }
        },
        onSecondaryLongPress: () {
          if (widget.onElementSecondaryLongTapped != null) {
            widget.onElementSecondaryLongTapped!(context, secondaryTapDownPos);
          }
        },
        child: Listener(
          onPointerDown: (event) {
            delta = event.localPosition;
          },
          child: Draggable<FlowElement>(
            data: widget.element,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            childWhenDragging: null,
            feedback: Material(
              color: Colors.transparent,
              child: null,
            ),
            child: ElementHandlers(
              dashboard: widget.dashboard,
              element: widget.element,
              handlerSize: widget.element.handlerSize,
              onHandlerPressed: widget.onHandlerPressed,
              onHandlerSecondaryTapped: widget.onHandlerSecondaryTapped,
              onHandlerLongPressed: widget.onHandlerLongPressed,
              onHandlerSecondaryLongTapped: widget.onHandlerSecondaryLongTapped,
              child: element,
            ),
            onDragUpdate: (details) {
              widget.element.changePosition((details.globalPosition -
                          widget.dashboard.dashboardPosition -
                          Offset(controller.value[12], controller.value[13])) /
                      controller.value[0] -
                  Offset(widget.element.size.width / 2,
                      widget.element.size.height / 2));
            },
            onDragEnd: (details) {
              debugPrint("Matrix: ${controller.value}");
              debugPrint("Element: ${widget.element.position}");
              debugPrint("details.offset: ${details.offset}");
              debugPrint(
                  "widget.dashboard.dashboardPosition: ${widget.dashboard.dashboardPosition}");
              widget.element.changePosition((details.offset -
                          widget.dashboard.dashboardPosition -
                          Offset(controller.value[12], controller.value[13])) /
                      controller.value[0] -
                  Offset(widget.element.size.width / 2,
                      widget.element.size.height / 2));
            },
          ),
        ),
      ),
    );
  }
}
