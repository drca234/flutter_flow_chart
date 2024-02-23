import 'dart:convert';
import 'package:flutter/material.dart';

import '../ui/draw_arrow.dart';

final List<String> connectionTypes = ["Standard", "Branching", "Optional"];
final List<ArrowParams> connectionArrowParams = [ArrowParams(), ArrowParams(color: Colors.blue), ArrowParams()];

class ConnectionParams {
  final String destElementId;
  ArrowParams arrowParams;

  /// Used to determine by other classes whether this connection should be considered or not.
  final int connectionType;
  final int conditionalDisplay; 

  ConnectionParams({
    required this.destElementId,
    required this.arrowParams,
    connectionType,
    conditionalDisplay,
  })  : connectionType = connectionType ?? 0,
        conditionalDisplay = conditionalDisplay ?? -1;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'destElementId': destElementId,
      'arrowParams': arrowParams.toMap(),
      'connectionType': connectionType,
      'conditionalDisplay': conditionalDisplay,
    };
  }

  factory ConnectionParams.fromMap(Map<String, dynamic> map) {
    return ConnectionParams(
      destElementId: map['destElementId'] as String,
      arrowParams:
          ArrowParams.fromMap(map['arrowParams'] as Map<String, dynamic>),
          connectionType: map['connectionType'] as int,
    conditionalDisplay: map['conditionalDisplay'] as int,

    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectionParams.fromJson(String source) =>
      ConnectionParams.fromMap(json.decode(source) as Map<String, dynamic>);
}
