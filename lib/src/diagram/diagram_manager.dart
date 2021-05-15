library diagram;

import 'dart:async';
import 'package:angular/core.dart';
import 'package:angular/angular.dart';
import '../geometry/geometry.dart';
import '../data/data_processing.dart';
import '../math/math.dart';
import 'package:vector_math/vector_math.dart';
import '../graphic/render.dart' show Color;
import 'dart:math';
import 'package:angular/core.dart';
import '../app_logger.dart';
import '../graphic/render.dart';

export '../geometry/geometry.dart' show LineBezier;

part 'interface/diagram.dart';
part '2d_diagram.dart';
part 'diagram_vis_object.dart';

enum MatrixValueRepresentation{
  circos,
  segmentsHeight
}

@Injectable()
class DiagramManager{

  static List<String> listOfIDs = new List<String>();

  static ShapeType connectionType = ShapeType.bezier;

  MatrixValueRepresentation latestRepresentation = null;
  Map<String, Map<String, VisualObject>> diagramVisualObject;
  Map<String, VisualObject> _listOFVisualObjects;
  Map<String, Diagram> _listOFDiagrams;
  List<String> _diagramsID;
  Map<String, Map<String, int>> _defaultOrder;

  final AppLogger _log;
  final DataProcessing _dataProcessing;

  DiagramManager(this._log, this._dataProcessing)
    : this._listOFDiagrams = new Map<String, Diagram>(),
    this._diagramsID = new List(),
    this._listOFVisualObjects = new Map(),
    this._defaultOrder = new Map<String, Map<String, int>>(),
    this.diagramVisualObject = new Map<String, Map<String, VisualObject>>();

  String get printAllDiagrams{
    StringBuffer sb = new StringBuffer();
    sb.write("\n");
    this._listOFDiagrams.forEach((String key, Diagram diagram){
      sb.write("$key => ${diagram.toString()}\n");
    });
    return sb.toString();
  }

  void updateVisualObjectData(String ID, VisualObject updatedData){
    this._listOFVisualObjects[ID] = updatedData;

    if(!_defaultOrder.containsKey(ID)){
      this._defaultOrder[ID] = new Map<String, int>();
      this._listOFVisualObjects[ID].performFunctionOnChildren((String groupKey, VisualObject actGroup) {
        this._defaultOrder[ID][actGroup.label.id] = actGroup.label.index;

        actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock) {
          this._defaultOrder[ID][actBlock.id] = actBlock.label.index;
        });
      });
    }
  }

  VisualObject getLatestDiagramVisualObjByID(String ID, {bool resetDefaultOrder: false}){
    //var retVal = this._listOFVisualObjects[ID];
    var retVal = this._listOFDiagrams[this.latestActualDiagramID].actualDataObject;
    if(retVal == null){
      throw new StateError("There is no visualObject yet, with the given ID: $ID");
    }else{
      if(resetDefaultOrder){
        this._defaultOrder[ID].forEach((String id, int index){
          if(id.contains("_")){
            retVal.getChildByIDs(id.split('_').first, 1, id).label.index = index;
          }else{
            retVal.getChildByIDs(id).label.index = index;
          }
        });
      }
    }
    return retVal;
  }

  VisualObject getVisualObjByID(String diagramID, String ID, {bool resetDefaultOrder: false}){
    var retVal = this._listOFDiagrams[diagramID].dataObjects[ID];
    if(retVal == null){
      throw new StateError("There is no visualObject yet, with the given ID: $ID");
    }else{
      if(resetDefaultOrder){
        this._defaultOrder[ID].forEach((String id, int index){
          if(id.contains("_")){
            retVal.getChildByIDs(id.split('_').first, 1, id).label.index = index;
          }else{
            retVal.getChildByIDs(id).label.index = index;
          }
        });
      }
    }
    return retVal;
  }

  Diagram getDiagramByID(String ID){
    if(this._listOFDiagrams[ID] == null)
      throw new StateError("Can not found diagram with the given ID{$ID}");

    return this._listOFDiagrams[ID];
  }

  Diagram getLatestDiagram(){
    return this._listOFDiagrams[this._diagramsID.last];
  }

  List<ShapeForm> reDrawDiagram([String diagramID = ""]){
    if(diagramID.isEmpty){
      Diagram latestDiagram = this._listOFDiagrams[this._diagramsID.last];
      latestDiagram.modifyDiagram();

      /*if(latestDiagram.valueRanges != null){
        var copyOfVisualObjects = this._listOFVisualObjects[this._diagramsID.last].copy();

        copyOfVisualObjects.ge


      }else {
        latestDiagram.modifyDiagram(
            this._listOFVisualObjects[this._diagramsID.last]);
      }
          /*return await latestDiagram.getDiagramsShapesPoints(
          this._listOFVisualObjects[this._diagramsID.last]
      );*/
      */
    }else{
      this._listOFDiagrams[diagramID].modifyDiagram();
      return this._listOFDiagrams[diagramID].getDiagramsShapesPoints(this._listOFDiagrams[diagramID].actualDataObject);
    }
  }

  void set actDiagramNewValueRange(List<RangeMath<double>> newRanges){
    this.getLatestDiagram().valueRanges = newRanges;
  }

  void removeDiagramByID(String ID){
    if(this._diagramsID.remove(ID) == null)
      throw new StateError("Can not found diagram ID with the given ID{$ID}");

    if(this._listOFVisualObjects.remove(ID) == null)
      throw new StateError("Can not found diagram with the given ID{$ID}");

    if(this._listOFDiagrams.remove(ID) == null)
      throw new StateError("Can not found diagram with the given ID{$ID}");

  }

  Diagram addDiagram(VisualObject diagramData, [MatrixValueRepresentation wayToCreateSegments = null]){
    this._diagramsID.add(MathFunc.generateUniqueID(DiagramManager.listOfIDs));

    if(!_defaultOrder.containsKey(this._diagramsID.last)){
      this._defaultOrder[this._diagramsID.last] = new Map<String, int>();
      diagramData.performFunctionOnChildren((String groupKey, VisualObject actGroup) {
        this._defaultOrder[this._diagramsID.last][actGroup.label.id] = actGroup.label.index;

        actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock) {
          this._defaultOrder[this._diagramsID.last][actBlock.id] = actBlock.label.index;

          actBlock.performFunctionOnChildren((String barKey, VisualObject actBar) {
            this._defaultOrder[this._diagramsID.last][actBar.id] = actBar.label.index;
          });
        });
      });
    }

    return this._listOFDiagrams[this._diagramsID.last] = new Diagram(DiagramType.basic, diagramData, wayToCreateSegments);
  }

  Diagram createEmptyDiagram(){
    this._diagramsID.add(MathFunc.generateUniqueID(DiagramManager.listOfIDs));
    return this._listOFDiagrams[this._diagramsID.last] = new Diagram(DiagramType.basic);
  }

  Diagram createDiagram(String dataObjectID){
    var objects = this._dataProcessing.getInputDataVisualObject(dataObjectID);

    this.addDiagram(objects, latestRepresentation);
  }

  VisualObject getVisObjectForDiagram(Diagram diagram, String ID){

    try {
      if(diagram.dataObjects[ID] == null){

        var retVal = this._dataProcessing.getInputDataVisualObject(ID);
        if(!_defaultOrder.containsKey(ID)){
          this._defaultOrder[ID] = new Map<String, int>();
          retVal.performFunctionOnChildren((String groupKey, VisualObject actGroup) {
            this._defaultOrder[ID][actGroup.label.id] = actGroup.label.index;

            actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock) {
              this._defaultOrder[ID][actBlock.id] = actBlock.label.index;

              actBlock.performFunctionOnChildren((String barKey, VisualObject actBar) {
                this._defaultOrder[this._diagramsID.last][actBar.id] = actBar.label.index;
              });
            });
          });
        }

        return retVal;

      }else{
        if(this._dataProcessing.inputDataChanged[ID]){

          var retVal = this._dataProcessing.getInputDataVisualObject(ID);
          if(!_defaultOrder.containsKey(ID)){
            this._defaultOrder[ID] = new Map<String, int>();
            retVal.performFunctionOnChildren((String groupKey, VisualObject actGroup) {
              this._defaultOrder[ID][actGroup.label.id] = actGroup.label.index;

              actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock) {
                this._defaultOrder[ID][actBlock.id] = actBlock.label.index;

                actBlock.performFunctionOnChildren((String barKey, VisualObject actBar) {
                  this._defaultOrder[this._diagramsID.last][actBar.id] = actBar.label.index;
                });
              });
            });
          }

          return retVal;

        }else{
          return diagram.dataObjects[ID];
        }
      }

    }catch(error, stacktrace){
      _log.sender.warning(error);
      return this._dataProcessing.getInputDataVisualObject(ID);
    }

  }

  List<String> get allActualDiagramID => this._diagramsID;

  String get latestActualDiagramID{
    if(this._diagramsID.isEmpty){
      return null;
    }else{
      return this._diagramsID.last;
    }
  }

  bool _checkActualDiagram(){
    var result = true;
    if(this._diagramsID != null) {
      if (this._diagramsID.length < 1) {
        if(this._listOFDiagrams.length < 1){
          throw new StateError("No diagram was added to diagram manager yet, so actualDigram is empty");
        }else{
          throw new StateError("Internal error: actual diagrams list is empty");
        }
      } else {
        var lengthBeforeRemove = this._diagramsID.length;
        this._diagramsID.removeWhere((String key){
          return key.isEmpty;
        });

        if(lengthBeforeRemove > this._diagramsID.length){
          result = false;
        }
      }
    }else{
      throw new StateError("ActualDiagramID list is Null");
    }

    this._diagramsID.forEach((String key){
      if(this._listOFDiagrams[key] == null)
        throw new StateError("Internal error: actual diagram (id: ${this._diagramsID}) is not found in listOfDiagrams: ${this.printAllDiagrams}");
    });


    return result;
  }

  void removeActualDiagram([List<int> index, bool isAllDiagram = false]){
    this._checkActualDiagram();
    if(isAllDiagram){
      if(this._diagramsID.length != this._listOFDiagrams) {
        throw new StateError("list of diagrams id length is not equal with list of diagrams");
      }else{
        this._listOFDiagrams.clear();
        this._listOFVisualObjects.clear();
        this._diagramsID.clear();
      }
    }else if(index == null){
      this._listOFDiagrams.remove(this._diagramsID.last);
      this._listOFVisualObjects.remove(this._diagramsID.last);
      this._diagramsID.removeLast();
    }else{
      var listOfKey = <String>[];
      index.forEach((int index) {
        try {
          RangeError.checkValidIndex(
              index, this._diagramsID, "toggleActualDiagramVisibility", null,
              "Bronken index to actualDiagramID list");
          listOfKey.add(this._diagramsID[index]);
        }catch(error, stacktrace){
          print("$error\n$stacktrace");
        }
      });
      listOfKey.forEach((String key){
        this._listOFDiagrams.remove(key);
        this._listOFVisualObjects.remove(key);
        this._diagramsID.remove(key);
      });
    }
  }

  void toggleActualDiagramVisibility([List<int> index, bool isAllDiagram = false]){
    this._checkActualDiagram();
    if(isAllDiagram){
      this._diagramsID.forEach((String key){
        this._listOFDiagrams[key].toggleVisibility;
      });
    }else if(index == null){
      this._listOFDiagrams[this._diagramsID.first].toggleVisibility;
    }else{
      index.forEach((int index){
        RangeError.checkValidIndex(index, this._diagramsID, "toggleActualDiagramVisibility", null, "Bronken index to actualDiagramID list" );
        this._listOFDiagrams[this._diagramsID[index]].toggleVisibility;
      });
    }

  }

  int get numberOfActiveDiagram => this._diagramsID.length;

  int get maximumNumberOfAddableActiveDiagram{
    return this._listOFDiagrams.length - this._diagramsID.length;
  }

  void increaseNumberOfActiveDiagram({int number: 1}){
    if(this._diagramsID.length + number > this._listOFDiagrams.length)
      throw new StateError(
          "Can not increase further more the number of active diagrams. Number of active diagrams: ${this._diagramsID.length}");


    var diagramsKeys = new List<String>.from(this._listOFDiagrams.keys);
    diagramsKeys.removeWhere((String key){
      return this._diagramsID.contains(key);
    });

    for(var i = 0; i < number; i++){
       this._diagramsID.add(diagramsKeys[i]);
    }
  }

  int get maximumNumberOfRemovableActiveDiagram{
    return this._diagramsID.length - 1;
  }

  void decreaseNumberOfActiveDiagram({int number: 1}) {
    if ((this._diagramsID.length - number) < 1)
      throw new StateError(
          "Can not decrease further more the number of active diagrams. Number of active diagrams: ${this._diagramsID.length}");

    this._diagramsID.removeRange(this._diagramsID.length - number, this._diagramsID.length);
  }

  Map<String, bool> get actualDiagramsIsVisible{
    var result = new Map<String, bool>();
    this._diagramsID.forEach((String ID){
      if(this._listOFDiagrams[ID] != null){
        result[ID] = this._listOFDiagrams[ID].isVisible;
      }
    });
    return result;
  }

  List<ShapeForm> reDrawLatestDiagram() {
    return this.reDrawDiagram(this.latestActualDiagramID);
  }

  void resetElementsDefaultOrder(String latestActualDiagramID, [bool updateRequired = false]) {
    if(updateRequired){
      this._defaultOrder[latestActualDiagramID] = new Map<String, int>();
      this.getDiagramByID(latestActualDiagramID).actualDataObject.performFunctionOnChildren((String groupKey, VisualObject actGroup) {
        this._defaultOrder[this._diagramsID.last][actGroup.label.id] = actGroup.label.index;

        actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock) {
          this._defaultOrder[this._diagramsID.last][actBlock.id] = actBlock.label.index;

          actBlock.performFunctionOnChildren((String barKey, VisualObject actBar) {
            this._defaultOrder[this._diagramsID.last][actBar.id] = actBar.label.index;
          });
        });
      });
    }else {
      var actVisData = this
          .getLatestDiagram()
          .actualDataObject;
      this._defaultOrder[latestActualDiagramID].forEach((String id, int index) {
        if (id.contains("_")) {
          var idParts = id.split('_');
          if (idParts.length < 3) {
            actVisData
                .getChildByIDs(idParts[0], 1, id)
                .label
                .index = index;
          } else {
            actVisData
                .getChildByIDs(idParts[0], 2, "${idParts[0]}_${idParts[1]}", id)
                .label
                .index = index;
          }
        } else {
          actVisData
              .getChildByIDs(id)
              .label
              .index = index;
        }
      });
    }
  }

}