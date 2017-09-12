library application;

import 'package:angular2/core.dart';
import 'dart:html';
import 'dart:core';
import 'dart:async';
import 'sort/sort.dart';

import 'dart:math';
import 'math/math.dart';
import 'graphic/render.dart';
import 'diagram/diagram_manager.dart';
import 'package:three/three.dart';
import 'package:three/extras/scene_utils.dart' as SceneUtils;
import 'data/data_processing.dart';
import 'dart:async';
import 'app_logger.dart';
import 'geometry/geometry.dart';

export 'graphic/render.dart';
export 'app_logger.dart';
export 'sort/sort.dart';
export 'diagram/diagram_manager.dart';
export 'data/data_processing.dart';

enum VisualizationAction{
  clearCanvas,
  freeMovement,
  enableCaption,
  freeHandEdit,
  download,
  settings,
  sort,
  editConnections
}

enum NotificationType{
  info,
  error
}

@Injectable()
class Application{

  final Visualization _vis;
  final DataProcessing _dataProcessing;
  final DiagramManager _diagramManager;
  final SortHandler _sortManager;
  final AppLogger _log;

  Function urlNavigation;
  bool tableChanged = true;
  bool sortSettingsChanged = false;
  bool diagramTypeChange = false;
  bool canvasMouseClickListen = false;
  MatrixValueRepresentation latestRepresentation = null;
  String latestNotificationMessage = "Default notification message";
  NotificationType latestNotificationType = NotificationType.info;

  bool isDiagramAlreadyGenerated = false;

  StreamController<String> _notificationStream = new StreamController<String>();

  Stream<String> get notificationMessages => _notificationStream.stream;

  StreamController<VisConnection> _connectionStream = new StreamController<VisConnection>();
  bool isListenConnectionStream = false;

  Stream<VisConnection> get connectionData => _connectionStream.stream;

  static List<String> dataID = new List<String>();

  CanvasElement get visualizationCanvasElement{
    return this._vis.renderCanvasElement as CanvasElement;
  }

  void resizeRenderer(double width, double height){
    this._vis.changeRendererSize(width, height);
  }

  ///Initialize render
  Application(this._dataProcessing, this._vis, this._sortManager,
      this._log, this._diagramManager){
    //this.addNotification(NotificationType.info, "Application initialized");
  }

  String setInputData(List<List<List<dynamic>>> matrix){
    var newID = MathFunc.generateUniqueID(dataID);
    _dataProcessing.addMatrix(newID, matrix);
    return newID;
  }

  List<dynamic> getRawMatrix([String ID]){
    if(ID == null || ID.isEmpty){
      var newID = MathFunc.generateUniqueID(dataID);
      return <dynamic>[newID, this._dataProcessing.getMatrix(newID, true).getDataForUI()];
    }else{
      return <dynamic>[ID, this._dataProcessing.getMatrix(ID).getDataForUI()];
    }
  }

  Map<String, InputData> getInputData([String ID, List<int> options = null, bool getEmptyTable = false, bool regenerateTable = false]){
    var retVal = new Map<String, InputData>();
    if((ID == null || ID.isEmpty) || regenerateTable){
      String newID = (ID == null || ID.isEmpty) ? MathFunc.generateUniqueID(dataID) : ID;
      if(options != null ){
        retVal[newID] = this._dataProcessing.getMatrix(newID, !getEmptyTable, getEmptyTable, options);
      }else{
        retVal[newID] = this._dataProcessing.getMatrix(newID, !getEmptyTable, getEmptyTable, [6,15,6,15,1,1, 100, 200]);
      }
      return retVal;
    }else{
      retVal[ID] = this._dataProcessing.getMatrix(ID);
      return retVal;
    }
  }

  void createDiagram(String ID){
    setLatestNotificationMessage(NotificationType.info, "Diagram succesfully created");

    //try {
      VisualObject finalVisObject = _processData(ID);

      if(_sortManager.isSortEnabled && (tableChanged || sortSettingsChanged)){
        var sortState = _sortManager.requireSort(finalVisObject);
        finalVisObject = _sortManager.runSort(finalVisObject);
        _log.sender.fine(sortState);
      }

      _visualizeData(finalVisObject);
      tableChanged = false;

    /*}catch(error){
      _log.sender.severe(error);
    }*/
  }

  void updateDataMatrixFromUploadedFile(String ID, InputData data){
    this._dataProcessing.setMatrix(ID, data);
  }

  VisualObject _processData(String ID, [bool modifyTable]){

    try {
      if(tableChanged){
        var retVal = this._dataProcessing.getInputDataVisualObject(ID);
        this._diagramManager.updateVisualObjectData(ID, retVal);
        return retVal;
      }else{
        return this._diagramManager.getVisualObjByID(ID);
      }
    }catch(error, stacktrace){
      _log.sender.warning(error);
      return this._dataProcessing.getInputDataVisualObject(ID);
    }

  }

  void _visualizeData(VisualObject diagramRoot){
    if(this._vis.isDiagramAlreadyDrawn(diagramRoot.id) && !diagramTypeChange){

      Diagram oldDiagram = _diagramManager.getDiagramByID(diagramRoot.id);

      oldDiagram.modifyDiagram(diagramRoot);

      var diagramPointData = oldDiagram.getDiagramsShapesPoints(diagramRoot);

      if(_vis == null){
        throw new StateError("Dependeny injection is not working well, visualization is missing");
      }

      _vis.clearCanvas();
      _vis.diagrams[diagramRoot.id] = new Object3D();

      _vis.drawDiagram2(diagramRoot.id, diagramPointData);

      //await _vis.modifyDiagram(diagramRoot.id, diagramPointData);

    }else{

      /*if(this._diagramManager.actualDiagramsIsVisible.isNotEmpty){
        this._vis.clearCanvas();
        this._vis.diagrams.remove(this._diagramManager.latestActualDiagramID);
        this._diagramManager.removeActualDiagram();
      }*/

      try{
        this._vis.clearCanvas();
        this._vis.diagrams.remove(this._diagramManager.latestActualDiagramID);
        this._diagramManager.removeActualDiagram();
      }catch(e){
        if((e is StateError) && (e as StateError).message == "No diagram was added to diagram manager yet, so actualDigram is empty"){

        }else{
          setLatestNotificationMessage(NotificationType.error, "An undefined error occured during creating the diagram. Try again with different settings or data");
        }
        print(e);
      }


      Diagram newDiagram = _diagramManager.addDiagram(diagramRoot, latestRepresentation);

      var diagramPointData = newDiagram.getDiagramsShapesPoints(diagramRoot);

      if(_vis == null){
        throw new StateError("Dependeny injection is not working well, visualization is missing");
      }

      _vis.clearCanvas();
      _vis.diagrams[diagramRoot.id] = new Object3D();

      _vis.drawDiagram2(diagramRoot.id, diagramPointData);

    }
    sortSettingsChanged = false;
    diagramTypeChange = false;
    this.showLatestNotificationMessage();
    isDiagramAlreadyGenerated = true;
  }

  void reSortDiagram(){
    this.createDiagram(this._diagramManager.latestActualDiagramID);
  }

  void modifyValueRepresentation(bool colorRepresentation){
    if(colorRepresentation){
      ConnectionVis.coloringScheme = DiagramColoring.valueWithTwoColor;
    }else{
      ConnectionVis.coloringScheme = DiagramColoring.circos;
    }
    this.updatePoints(this._diagramManager.latestActualDiagramID);
  }

  void applySegmentsColor(VisConnection conn, int type){
    var id = "";
    if(type == 1){
      id = conn.segmentOne.parent.id;
    }else{
      id = conn.segmentTwo.parent.id;
    }

    conn.config.connectionColor = ConnectionVis.mainSegmentsColor[id];

    this.updatePoints(this._diagramManager.latestActualDiagramID);
  }

  void setAllConnectionsColorGrey(bool checked){
    Map<String, VisConnection> connections = ConnectionManager.listOfConnection[this._diagramManager.latestActualDiagramID];
    if(checked){
      var greyColor = new Color.fromArray([0.25,0.25,0.25]);
      for(var i = 0; i < connections.length; i++){
        connections[connections.keys.elementAt(i)].config.connectionColor = greyColor;
      }
    }else{
      for(var i = 0; i < connections.length; i++){
        var id = connections[connections.keys.elementAt(i)].segmentOne.parent.id;
        connections[connections.keys.elementAt(i)].config.connectionColor = ConnectionVis.mainSegmentsColor[id];
      }
    }
    this.updatePoints(this._diagramManager.latestActualDiagramID);
  }

  void changeWayToDrawDiagram(int index){
    this._diagramManager.getLatestDiagram().wayToCreateSegments
      = MatrixValueRepresentation.values[index];

    latestRepresentation = MatrixValueRepresentation.values[index];
    if(MatrixValueRepresentation.values[index] == MatrixValueRepresentation.circos){
      this._diagramManager.getLatestDiagram().outerSegmentCircle.radius = 160.0;
    }else{
      this._diagramManager.getLatestDiagram().outerSegmentCircle.radius = 250.0;
    }
    diagramTypeChange = true;
    this.redrawLatestDiagram();
  }

  void modifySortingSettings(bool isSortEnabled, [int sortingAlgorithm = null]){
    this._sortManager.isSortEnabled = isSortEnabled;
    if(sortingAlgorithm != null){
      this._sortManager.defaultType = SortAlgorithmType.values[sortingAlgorithm];
    }
    sortSettingsChanged = true;
  }

  Future visualizationUserInteraction(VisualizationAction action, [List<dynamic> options]) async{
    switch(action){
      case VisualizationAction.clearCanvas:
        try{
          if(options == null){
            this._vis.clearCanvas();
            this._vis.diagrams.remove(this._diagramManager.latestActualDiagramID);
            this._diagramManager.removeActualDiagram();
          }else{
            String actualDiagramID = options.first as String;
            this._diagramManager.removeDiagramByID(actualDiagramID);
            this._vis.diagrams.remove(actualDiagramID);
            this._vis.clearCanvas();
          }
        }catch(error, stacktrace){
          print("$error\n$stacktrace");
        }
        break;
      case VisualizationAction.freeMovement:
          this._vis.toogleFreeMovement();
        break;
      case VisualizationAction.download:
        String imageDataURL = await this._vis.canvasDataURL;
        if(imageDataURL != null){
          this.downloadImageToClient("Diagram:${this._diagramManager.latestActualDiagramID}.png", imageDataURL);
        }else{
          throw new StateError("Image data URL is missing");
        }
        break;
      case VisualizationAction.settings:
        break;
      case VisualizationAction.editConnections:
        break;
      default:
        throw new StateError("This action ($action) is not exist");
        break;
    }
  }

  Future<bool> diagramInteraction(Point actPoint, Point previousPoint, int button) async{
    switch(button){
      case 1:
        await this._vis.moveShape(
          ShapeMove.move,
          this._diagramManager.latestActualDiagramID,
            <Point>[actPoint, previousPoint]
        );
        break;
      case 4:
        await this._vis.moveShape(
          ShapeMove.rotate,
          this._diagramManager.latestActualDiagramID,
            <Point>[actPoint, previousPoint]
        );
        break;
      case 2:
        break;
      default:
        break;
    }
    return true;
  }

  Future<bool> diagramZoom(double zoom) async{
    await this._vis.moveShape(ShapeMove.zoom, this._diagramManager.latestActualDiagramID, <double>[zoom]);
    return true;
  }

  bool get isFreeMovementEnabled => this._vis.freeMovementEnabled;

  void downloadFileToClient(String filename, String text){
    AnchorElement tl = document.createElement('a') as AnchorElement;
    tl..attributes['href'] = 'data:text/plain;charset=utf-8,' + Uri.encodeComponent(text)
      ..attributes['download'] = filename
      ..click();
  }

  void downloadImageToClient(String filename, String text){
    //ImageElement imageElement = new ImageElement(src: text, height: 2160, width: 3840);
    //var windowBase = window.open(text, filename);
    //windowBase.postMessage()
    AnchorElement tl = document.createElement('a') as AnchorElement;
    tl..attributes['href'] = text
      ..attributes['download'] = filename
      ..click();

  }

  Future<bool> updatePoints(String diagramID) async{

    VisualObject finalVisObject = this._diagramManager.getVisualObjByID(diagramID);

    if(sortSettingsChanged){
      VisualObject diagramRoot = _processData(diagramID);

      finalVisObject = _sortManager.requireSort(diagramRoot).run();
    }

    var diagram = _diagramManager.getDiagramByID(diagramID);

    var diagramPointData = diagram.getDiagramsShapesPoints(finalVisObject);

    if(_vis == null){
      throw new StateError("Dependeny injection is not working well, visualization is missing");
    }

    _vis.clearCanvas();
    _vis.diagrams[finalVisObject.id] = new Object3D();

    _vis.drawDiagram2(finalVisObject.id, diagramPointData);

    print("pointsUpdated");

    sortSettingsChanged = false;
    return true;
  }

  void changeBezierParam(int type, num value){
    switch(type){
      case 1: //crest
        LineBezier.crest = value.toDouble();
        break;
      case 2: //bezier_radius
        LineBezier.bezier_radius = value.toDouble();
        break;
      case 3: //bezier_radius_purity
        LineBezier.bezier_radius_purity = value.toDouble();
        break;
      default:
        break;
    }

    var latestDiagramID = "";
    try{
      /*latestDiagramID = this._diagramManager.latestActualDiagramID;
      if(latestDiagramID != null){
        updatePoints(latestDiagramID);
      }*/
      this.updatePoints(this._diagramManager.latestActualDiagramID);
    }catch(error, stacktrace){
      //print("noMod");
    }
  }

  void changeShapePosition(int type, num value){
    switch(type){
      case 1: //bar
        print("bar index changed to: ${value}");
        break;
      case 2: //block
        print("block index changed to: ${value}");
        break;
      case 3: //group
        print("group index changed to: ${value}");
        break;
      default:
        break;
    }

    var latestDiagramID = "";
    try{
      /*latestDiagramID = this._diagramManager.latestActualDiagramID;
      if(latestDiagramID != null){
        updatePoints(latestDiagramID);
      }*/
      //createDiagram(latestDiagramID);
    }catch(error, stacktrace){
      //print("noMod");
    }
  }

  void redrawLatestDiagram() {
    this.createDiagram(this._diagramManager.latestActualDiagramID);
    try{

    }catch(error){
      print(error);
    }
  }

  void enableSegmentRandomColor(bool checked) {
    ConnectionManager.changAndUpdateSegmentColorPool(
      this._diagramManager.latestActualDiagramID, checked
    );
    this.updatePoints(
      this._diagramManager.latestActualDiagramID
    );
  }

  String _crateCircosFileFormat(DataMatrix matrixData) {

    if(matrixData.allLabel.length != Label.groupLabels.length){
      return "#Using group and download matrix is not supported at the same time";
      throw new StateError("Using group and download matrix is not supported at the same time");
    }

    StringBuffer sb = new StringBuffer();
    for(var i = 0; i <= matrixData.row_num; i++){
      for(var j = 0; j <= matrixData.col_num; j++){
        if(i == 0){
          if(j < 2){
            if(j == 0){
              sb.write("data");
            }else{
              sb.write("\tdata");
            }
            continue;
          }else{
            sb.write("\t${matrixData.getColLabel(j-1).groupLabel.index}");
          }
        }else if(i == 1){
          if(j < 2){
            if(j == 0){
              sb.write("data");
            }else{
              sb.write("\tdata");
            }
            continue;
          }else{
            sb.write("\t${matrixData.getTableVale(i-1, j-1)[0]}");
          }
        }else{
          if(j == 0){
            sb.write("${matrixData.getRowLabel(i-1).groupLabel.index}");
          }else{
            sb.write("\t${matrixData.getTableVale(i-1, j-1)[0]}");
          }
        }
      }
      sb.write("\n");
    }

    return sb.toString();
  }

  int numberOfStateForTestingSoring = 14;
  int numberOfTestRound = 1;

  void testSortAlgorithm(){

    Map<String, InputData> generatedDiagrams =
        new Map<String, InputData>();

    int index = 0;

    Stopwatch sortAlgorithmTimer = new Stopwatch();
    sortAlgorithmTimer.start();

    int size = 16;

    for(var h = 0; h < numberOfTestRound; h++) {
      _sortManager.resultOfSorting.clear();
      size += 5;
      print("size: ${size-1} -------------------------------------");

      for (var i = 1; i <= numberOfStateForTestingSoring; i++) {
        var inputData = this.getInputData("", [size, 10, size, 10, 1, 1, 1, 100]);

        var diagramID = inputData.keys.first;
        (inputData[diagramID] as DataMatrix);

        generatedDiagrams.addAll(inputData);
        //print(inputData[diagramID].getDataForUI());

        for (var algorithmIndex = 0;
        algorithmIndex < SortAlgorithmType.values.length;
        algorithmIndex++) {

          for (var k = 0; k < 1; k++) {
            var newDiagramMatrix = inputData[diagramID].copy();
            var visObject = newDiagramMatrix.getVisualizationObjectHierarchy(true);
            doSort(SortAlgorithmType.values[algorithmIndex], visObject);

            //print(getPercent(SortAlgorithmType.values[algorithmIndex], k));
          }
        }

        /*var newDiagramMatrix = inputData[diagramID].copy();
        print(newDiagramMatrix.toString());
        var visObject = newDiagramMatrix.getVisualizationObjectHierarchy(true);
        doSort(SortAlgorithmType.beesAlgorithm, visObject);
        print(_sortManager.resultOfSorting.values
            .elementAt(0)
            .first
            .getSortStatistic());*/

        print(getPercent("${SortAlgorithmType.values.length} algorithms ran", (index / numberOfStateForTestingSoring) * 100.0, index));
        index++;
      }


      print("################");

      _sortManager.resultOfSorting.forEach((String diagram, List<Sort> sorts){
        sorts.forEach((Sort sortSate){
          print(sortSate.getSortStatistic());
        });
      });

      print("################");

      print("-------------------------------------");
    }

    sortAlgorithmTimer.stop();
    print("Time required to run: ${sortAlgorithmTimer.elapsed}");

    /*generatedDiagrams.forEach((String key, InputData matrix){
      for (var algorithmIndex = 0;
        algorithmIndex < SortAlgorithmType.values.length;
        algorithmIndex++) {

        for (var k = 0; k < 1; k++) {
          var visObject = matrix.getVisualizationObjectHierarchy(key);
          doSort(SortAlgorithmType.values[algorithmIndex], visObject);
          //print(getPercent(SortAlgorithmType.values[algorithmIndex], k));
        }
        print(getPercent(SortAlgorithmType.values[algorithmIndex], index));
      }
      index++;
    });*/



  }

  String getPercent(dynamic type, double k, int index){
    StringBuffer sb = new StringBuffer();
    sb.write("${type} percent: ${k}% ");
    sb.write("[");
    for(var i = 0; i < (index - 1); i++){
      sb.write("-");
    }
    if(k != 0) {
      sb.write("|");
    }
    for(var i = (index + 1); i < numberOfStateForTestingSoring; i++){
      sb.write(" ");
    }
    sb.write("]\n");
    return sb.toString();
  }

  void doSort(SortAlgorithmType type, VisualObject visObject){
    _sortManager.requireSort(visObject, type).run();
  }

  VisConnection handleCanvasMouseClick(int clickX, int clickY){
    HomogeneousCoordinate mouseClickPos = this._vis.getMousePosition(new Point(clickX, clickY));
    //HomogeneousCoordinate mouseClickPos = this._vis.render.getMousePosition(new Point(clickX, clickY));
    VisualObject rootElement = this._diagramManager.getVisualObjByID(this._diagramManager.latestActualDiagramID);
    var connection = this._diagramManager.getLatestDiagram().getConnectionFromPosition(
          rootElement, mouseClickPos);
    return connection;
  }

  void closeNotificationStream(){
    _notificationStream.close();
  }

  void closeConnectionStream(){
    _connectionStream.close();
  }

  void addNotification(NotificationType type, String message){
    _notificationStream.add(type == NotificationType.error ? "error~$message" : "info~$message");
  }

  void addConnectionData(VisConnection connection){
    _connectionStream.add(connection);
  }

  void showLatestNotificationMessage(){
    _notificationStream.add(latestNotificationType == NotificationType.error
        ? "error~$latestNotificationMessage"
        : "info~$latestNotificationMessage");
  }

  void setLatestNotificationMessage(NotificationType type, String message){
    latestNotificationMessage = message;
    latestNotificationType = type;
  }

  VisConnection get defaultConnection{
    if(ConnectionManager.listOfConnection[this._diagramManager.latestActualDiagramID] != null){
      return ConnectionManager.listOfConnection[this._diagramManager.latestActualDiagramID].values.elementAt(0);
    }else{
      return null;
    }
  }

  void connectionsDirectionChange(int direction) {
    ConnectionManager.listOfConnection[this._diagramManager.latestActualDiagramID].values.forEach((VisConnection conn){
      conn.direction = direction;
    });
    //this.updatePoints(this._diagramManager.latestActualDiagramID);
    this.redrawLatestDiagram();
  }

  void changeDiagramLooks(int part, num value){
    var latestDiagram = this._diagramManager.getLatestDiagram();
    if(part == 1){
      latestDiagram.directionShapeHeightsModifier = value.toDouble();
      latestDiagram.updateCirclesRadius();
    }else if(part == 2){
      latestDiagram.spaceBetweenBlocksModifier = value.toDouble();
    }else{
      latestDiagram.lineWidth = value.toDouble();
      latestDiagram.updateCirclesRadius();
    }
    this.redrawLatestDiagram();
  }

  void showDiagramTicks(bool checked) {
    this._diagramManager.getLatestDiagram().drawLabelNum = checked;
    this.redrawLatestDiagram();
  }

  void setAllConnectionsColor(bool checked) {
    Map<String, VisConnection> connections = ConnectionManager.listOfConnection[this._diagramManager.latestActualDiagramID];
    if(checked){
      for(var i = 0; i < connections.length; i++){
        connections[connections.keys.elementAt(i)].config.connectionColor = ConnectionVis.unifiedColor;
      }
    }else{
      for(var i = 0; i < connections.length; i++){
        var id = connections[connections.keys.elementAt(i)].segmentOne.parent.id;
        connections[connections.keys.elementAt(i)].config.connectionColor = ConnectionVis.mainSegmentsColor[id];
      }
    }
    this.updatePoints(this._diagramManager.latestActualDiagramID);
  }

}