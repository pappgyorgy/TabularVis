library sortConnection;

import 'dart:math';
import 'dart:async';
import '../data/data_processing.dart';
import 'package:angular2/core.dart';

part 'crossEntropy_min_conf.dart';
part 'crossEntropy.dart';
part 'hillClimbingTool.dart';
part 'minconflicts.dart';
part 'sortAlgorithm.dart';
part 'cross_entropy_built_in_min_conflicts.dart';
part 'simulated_annealing.dart';
part 'bees_algorithm.dart';

@Injectable()
class SortHandler{

  SortAlgorithmType defaultType = SortAlgorithmType.hillClimb;

  Map<String, List<Sort>> resultOfSorting = new Map<String, List<Sort>>();

  bool _isSortEnabled = false;

  bool get isSortEnabled => _isSortEnabled;
  set isSortEnabled(bool value){
    _isSortEnabled = value;
  }

  void initializeDiagramSortList(String diagramID){
    if(!resultOfSorting.containsKey(diagramID)){
      resultOfSorting[diagramID] = new List<Sort>();
    }
  }

  Sort requireSort(VisualObject root, [SortAlgorithmType type = null]){
    type = type == null ? defaultType : type;
    initializeDiagramSortList(root.id);
    resultOfSorting[root.id].add(new Sort(root, type));
    return resultOfSorting[root.id].last;
  }

  VisualObject runSort(VisualObject root, [int indexOfSort = -1]){
    indexOfSort = indexOfSort < 0
        ? resultOfSorting[root.id].length - 1
        : indexOfSort;
    
    return resultOfSorting[root.id][indexOfSort].run();
  }
}

class Sort {

  VisualObject root;
  SortAlgorithmType type;

  Stopwatch sortAlgorithmTimer = new Stopwatch();
  int intersectionBeforeSort = 0;
  int intersectionAfterSort = 0;

  Sort(this.root, this.type);

  VisualObject run() {
    State sortState = new State.getState(type, root.copy());

    SortAlgorithm sortTool = new SortAlgorithm(type);

    intersectionBeforeSort = sortState.getValue();

    sortAlgorithmTimer.start();

    State result = sortTool.solve(sortState);

    sortAlgorithmTimer.stop();

    intersectionAfterSort = result.getValue();

    _finalizeSort(result);

    //this.root = this.root.copy();

    //print(result.groupsOrders);
    //print(result);
    //print(getSortStatistic());
    
    return result.diagramElements.rootElement;
    //return root;
  }

  List<List<String>> _getElementAllConnSegments(VisualObject element) {
    List<List<String>> connectedSegments = new List<List<String>>();

    element.connectedElements.forEach((String otherElementID,
        VisualObject connElement) {
      connectedSegments.add([connElement.parent.id, otherElementID]);
    });

    return connectedSegments;
  }

  Map<String, List<List<String>>> _getElementAllConnSegmentsMap(VisualObject element) {
    Map<String, List<List<String>>> connectedSegments = new Map<String, List<List<String>>>();

    var connectedElements = element.connectedElements;
    for(var i = 0; i < connectedElements.length; i++){
      String otherElementID = connectedElements.keys.elementAt(i);
      VisualObject connElement = connectedElements[otherElementID];
      VisualObject startSegment = element.getChildByID(otherElementID, true);

      if(!connectedSegments.containsKey(startSegment.parent.id)){
        connectedSegments[startSegment.parent.id] = new List<List<String>>();
      }
      connectedSegments[startSegment.parent.id].add([connElement.parent.id, connElement.id, otherElementID]);

    }
    /*element.connectedElements.forEach((String otherElementID,
        VisualObject connElement) {
      if(!connectedSegments.containsKey(connElement.id)){
        connectedSegments[connElement.id] = new List<List<String>>();
      }
      connectedSegments[connElement.connection.getOtherSegment(connElement).id].add([connElement.parent.id, otherElementID]);
    });*/

    return connectedSegments;
  }

  List<List<String>> _getSegmentsIDFromConnectedSegments(List<List<String>> listOfConnSegment, String ID){
    List<List<String>> retVal = new List<List<String>>();
    for(var i = 0; i < listOfConnSegment.length; i++){
      if(listOfConnSegment[i][0] == ID){
        retVal.add([listOfConnSegment[i][1], listOfConnSegment[i][2]]);
      }
    }
    return retVal;
  }

  List<Map<int, String>> _createTemporaryOder(Map<int, String> originalOrder,
      VisualObject actualElement) {
    List<Map<int, String>> orderID = new List<Map<int, String>>();

    int indexOfElement = _findFirstIndex(originalOrder, actualElement.id);

    var connectedSegmentsIDs = _getElementAllConnSegmentsMap(actualElement);

    //group by the connections based on segments
    var multipleSegmentsGroup = connectedSegmentsIDs.length > 1;

    connectedSegmentsIDs.forEach((String segmentID, List<List<String>> connectedSegments){
      int i = indexOfElement;
      orderID.add(new Map<int, String>());
      int index = connectedSegments.length;
      int reverseIndex = 1;
      while (orderID.last.length < connectedSegments.length) {
        var segmentIDs = _getSegmentsIDFromConnectedSegments(connectedSegments, originalOrder[i]);
        if(multipleSegmentsGroup && i == indexOfElement){
          int selectedElementIndex = actualElement.getChildByID(segmentID).label.index;
          for (var j = 0; j < segmentIDs.length; j++) {
            int connectedElementIndex = actualElement.getChildByID(segmentIDs[j][0]).label.index;
            if(selectedElementIndex < connectedElementIndex){
              orderID.last[index--] = segmentIDs[j][1];
            }else{
              orderID.last[reverseIndex++] = segmentIDs[j][1];
            }
          }
        }else {
          for (var j = 0; j < segmentIDs.length; j++) {
            orderID.last[index--] = segmentIDs[j][1];
          }
        }


        /*if(connectedSegments.containsKey(originalOrder[i])){
          orderID.last[index--] = connectedSegments[originalOrder[i]];
        }*/

        if (i + 1 > originalOrder.length) {
          i = 1;
        } else {
          i++;
        }
      }
    });

    return orderID;
  }

  int _findFirstIndex(Map<int, String> orderID, String actID) {
    for (var i = 1; i <= orderID.length; i++) {
      if (orderID[i] == actID) {
        return i;
      }
    }
    throw new StateError("The given ID: $actID is not in the order $orderID");
  }

  void _finalizeSort(State sortResult) {
    Map<int, String> orderID = sortResult.orderID;

    for (var i = 1; i <= orderID.length; i++) {
      var elementID = orderID[i];
      var actualElement = sortResult.diagramElements.rootElement.getChildByID(
          elementID);

      var elementChildOrder = _createTemporaryOder(orderID, actualElement);

      elementChildOrder.forEach((Map<int, String> segmentConnectionsOrder) {
        segmentConnectionsOrder.forEach((int index, String childElementID){
          var elementToSet = actualElement.getChildByID(childElementID, true);
          elementToSet.label.index = index;
          //print(actualElement.label);
        });
      });

      /*elementChildOrder.forEach((int index, String childElementID) {
        var elementToSet = actualElement.getChildByID(childElementID, true);
        elementToSet.label.index = index;
        print(actualElement.label);
      });*/
    };

  }

  String getSortStatistic(){
    return "${type},"
        " ${intersectionBeforeSort},"
        " ${intersectionAfterSort},"
        " ${intersectionAfterSort / intersectionBeforeSort},"
        " ${sortAlgorithmTimer.elapsed}";
  }
  
  @override
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.writeln("Sort algorithm: ${type}");
    sb.writeln("Before sort: ${intersectionBeforeSort}");
    sb.writeln("After sort: ${intersectionAfterSort}");
    sb.writeln("Percent: ${ 1 - (intersectionAfterSort / intersectionBeforeSort)}");
    sb.writeln("Required time: ${sortAlgorithmTimer.elapsed}");
    return sb.toString();
  }


}