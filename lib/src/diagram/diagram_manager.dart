library diagram;

import 'dart:async';
import '../geometry/geometry.dart';
import '../data/data_processing.dart';
import '../math/math.dart';
import 'package:vector_math/vector_math.dart';
import 'package:dartson/dartson.dart';
import 'package:three/three.dart';
import 'package:three/extras/geometry_utils.dart' as GeomUtils;
import 'package:three/extras/font_utils.dart' as FontUtils;
import 'package:three/extras/core/shape_utils.dart' as ShapeUtils;
import 'package:three/extras/shaders/shaders.dart';
import 'dart:math';
import 'package:bezier_simple_connect_viewer/src/geometry/polygon_near_linear_triangulation.dart';
import 'package:angular2/core.dart';
import '../app_logger.dart';

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

  Map<String, VisualObject> _listOFVisualObjects;
  Map<String, Diagram> _listOFDiagrams;
  List<String> _diagramsID;

  final AppLogger _log;

  DiagramManager(this._log)
    : this._listOFDiagrams = new Map<String, Diagram>(),
    this._diagramsID = new List(),
    this._listOFVisualObjects = new Map();

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
  }

  VisualObject getVisualObjByID(String ID){
    var retVal = this._listOFVisualObjects[ID];
    if(retVal == null){
      throw new StateError("There is no visualObject yet, with the given ID: $ID");
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

  Future<List<DiagramVisObject>> reDrawDiagram([String diagramID = ""]) async{
    if(diagramID.isEmpty){
      Diagram latestDiagram = this._listOFDiagrams[this._diagramsID.last];
      latestDiagram.modifyDiagram(
          this._listOFVisualObjects[this._diagramsID.last]);
      /*return await latestDiagram.getDiagramsShapesPoints(
          this._listOFVisualObjects[this._diagramsID.last]
      );*/
      return null;
    }else{

    }
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
    if(this._listOFDiagrams.containsKey(diagramData.id))
      throw new StateError("Alredy have a diagram with the give ID{${diagramData.id}}. List of diagrams: ${this._checkActualDiagram()}");

    this._diagramsID.add(diagramData.id);
    this._listOFVisualObjects[diagramData.id] = diagramData;
    return this._listOFDiagrams[diagramData.id] = new Diagram(DiagramType.basic, diagramData, wayToCreateSegments);
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

}