import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'elements/connection_params.dart';
import 'ui/draw_arrow.dart';
import 'elements/flow_element.dart';
import 'ui/grid_background.dart';

/// Class to store all the scene elements.
/// It notifies changes to [FlowChart]
class Dashboard extends ChangeNotifier {
  List<FlowElement> elements;
  Offset dashboardPosition;
  Size dashboardSize;
  Offset handlerFeedbackOffset;
  GridBackgroundParams gridBackgroundParams;
  VoidCallback? onRecenter;

  Dashboard()
      : elements = [],
        dashboardPosition = Offset.zero,
        dashboardSize = const Size(0, 0),
        handlerFeedbackOffset = const Offset(0, 0),
        gridBackgroundParams = GridBackgroundParams();

  /// set grid background parameters
  setGridBackgroundParams(GridBackgroundParams params) {
    gridBackgroundParams = params;
    notifyListeners();
  }

  /// set the feedback offset to help on mobile device to see the
  /// end of arrow and not hiding behind the finger when moving it
  setHandlerFeedbackOffset(Offset offset) {
    handlerFeedbackOffset = offset;
  }

  /// set [isResizable] element property
  setElementResizable(FlowElement element, bool resizable,
      {bool notify = true}) {
    element.isResizing = resizable;
    if (notify) notifyListeners();
  }

  /// add a [FlowElement] to the dashboard
  addElement(FlowElement element, {bool notify = true}) {
    if (element.id.isEmpty) {
      element.id = const Uuid().v4();
    }
    elements.add(element);
    if (notify) {
      notifyListeners();
    }
  }

  /// find the element by its [id]
  int findElementIndexById(String id) {
    return elements.indexWhere((element) => element.id == id);
  }

  /// find the element by its [id] for convenience
  /// return null if not found
  FlowElement? findElementById(String id) {
    try {
      return elements.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  /// find the connection from [srcElement] to [destElement]
  /// return null if not found
  /// In case of multiple connections, first conneciton is returnd
  ConnectionParams? findConnectionByElements(
      FlowElement srcElement, FlowElement destElement) {
    try {
      return srcElement.next
          .firstWhere((element) => element.destElementId == destElement.id);
    } catch (e) {
      return null;
    }
  }

  /// remove all elements
  removeAllElements({bool notify = true}) {
    elements.clear();
    if (notify) notifyListeners();
  }

  /// remove the [handler] connection of [element]
  removeElementConnection(FlowElement element, Handler handler,
      {bool notify = true}) {
    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = const Alignment(0.0, -1.0);
        break;
      case Handler.bottomCenter:
        alignment = const Alignment(0.0, 1.0);
        break;
      case Handler.leftCenter:
        alignment = const Alignment(-1.0, 0.0);
        break;
      case Handler.rightCenter:
      default:
        alignment = const Alignment(1.0, 0.0);
    }
    element.next.removeWhere((handlerParam) =>
        handlerParam.arrowParams.startArrowPosition == alignment);
    if (notify) notifyListeners();
  }

  /// remove the connection from [srcElement] to [destElement]
  removeConnectionByElements(FlowElement srcElement, FlowElement destElement,
      {bool notify = true}) {
    srcElement.next.removeWhere(
        (handlerParam) => handlerParam.destElementId == destElement.id);
    if (notify) notifyListeners();
  }

  /// remove all the connection from the [element]
  removeElementConnections(FlowElement element, {bool notify = true}) {
    element.next.clear();
    if (notify) notifyListeners();
  }

  /// remove all the elements with [id] from the dashboard
  removeElementById(String id, {bool notify = true}) {
    // remove the element
    String elementId = '';
    elements.removeWhere((element) {
      if (element.id == id) {
        elementId = element.id;
      }
      return element.id == id;
    });

    // remove all connections to the elements found
    for (FlowElement e in elements) {
      e.next.removeWhere((handlerParams) {
        return elementId.contains(handlerParams.destElementId);
      });
    }
    if (notify) notifyListeners();
  }

  /// remove element
  /// return true if it has been removed
  bool removeElement(FlowElement element, {bool notify = true}) {
    // remove the element
    bool found = false;
    String elementId = element.id;
    elements.removeWhere((e) {
      if (e.id == element.id) found = true;
      return e.id == element.id;
    });

    // remove all connections to the element
    for (FlowElement e in elements) {
      e.next.removeWhere(
          (handlerParams) => handlerParams.destElementId == elementId);
    }
    if (notify) notifyListeners();
    return found;
  }

  /// needed to know the diagram widget position to compute
  /// offsets for drag and drop elements
  setDashboardPosition(Offset position) {
    dashboardPosition = position;
  }

  /// needed to know the diagram widget size
  setDashboardSize(Size size) {
    dashboardSize = size;
  }

  /// make an arrow connection from [sourceElement] to
  /// the elements with id [destId]
  /// [arrowParams] definition of arrow parameters
  addNextById(FlowElement sourceElement, String destId, ArrowParams arrowParams,
      {bool notify = true}) {
    int found = 0;
    for (int i = 0; i < elements.length; i++) {
      if (elements[i].id == destId) {
        // if the [id] already exist, remove it and add this new connection
        sourceElement.next
            .removeWhere((element) => element.destElementId == destId);
        sourceElement.next.add(ConnectionParams(
          destElementId: elements[i].id,
          arrowParams: arrowParams,
        ));

        found++;
      }
    }

    if (found == 0) {
      debugPrint('Element with $destId id not found!');
      return;
    }
    if (notify) {
      notifyListeners();
    }
  }

  //******************************* */
  /// manage load/save using json
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'elements': elements.map((x) => x.toMap()).toList(),
    };
  }

  factory Dashboard.fromMap(Map<String, dynamic> map) {
    Dashboard d = Dashboard();
    d.elements = List<FlowElement>.from(
      (map['elements'] as List<dynamic>).map<FlowElement>(
        (x) => FlowElement.fromMap(x as Map<String, dynamic>),
      ),
    );
    return d;
  }

  String toJson() => json.encode(toMap());

  factory Dashboard.fromJson(String source) =>
      Dashboard.fromMap(json.decode(source) as Map<String, dynamic>);

  String prettyJson() {
    var spaces = ' ' * 2;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(toMap());
  }

  /// recenter the dashboard
  void recenter() {
    // center should be where the rough center of the first element is, disregarding decorations
    if (elements.isNotEmpty) {
      Offset center = Offset(
          dashboardSize.width / 2 - elements.first.size.width / 2,
          dashboardSize.height / 2 - elements.first.size.height / 2);
      gridBackgroundParams.offset = center;
      Offset currentDeviation = elements.first.position - center;
      for (FlowElement element in elements) {
        element.position -= currentDeviation;
      }
    }
    if (onRecenter != null) onRecenter!();
    notifyListeners();
  }

  /// save the dashboard into [completeFilePath]
  saveDashboard(String completeFilePath) {
    File f = File(completeFilePath);
    f.writeAsStringSync(prettyJson(), flush: true);
  }

  /// clear the dashboard and load the new one
  loadDashboard(String completeFilePath) {
    File f = File(completeFilePath);
    if (f.existsSync()) {
      elements.clear();
      String source = f.readAsStringSync();

      List<FlowElement> all = List<FlowElement>.from(
        ((json.decode(source))['elements'] as List<dynamic>).map<FlowElement>(
          (x) => FlowElement.fromMap(x as Map<String, dynamic>),
        ),
      );
      for (int i = 0; i < all.length; i++) {
        addElement(all.elementAt(i));
      }
      notifyListeners();
    }

    recenter();
  }
}
