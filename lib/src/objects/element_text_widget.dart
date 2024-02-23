import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Common widget for the element text
class ElementTextWidget extends StatelessWidget {
  final FlowElement element;

  const ElementTextWidget({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Text(
          maxLines: 3,
          softWrap: true,
          element.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: element.textColor,
            fontSize: element.textSize,
            overflow: TextOverflow.ellipsis,
            fontWeight: element.textIsBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: element.fontFamily,
          ),
        ),
      ),
    );
  }
}
