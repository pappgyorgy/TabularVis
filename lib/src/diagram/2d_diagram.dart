part of diagram;

class Diagram2D implements Diagram {
  static HomogeneousCoordinate _defaultCenter =
      new HCoordinate2D(new Vector3(0.0, 0.0, 1.0));

  static SimpleCircle<HomogeneousCoordinate> defaultDrawCircle =
    new HCircle2D(_defaultCenter as HCoordinate2D, 130.0);
  static SimpleCircle<HomogeneousCoordinate> defaultBaseCircle =
    new HCircle2D(_defaultCenter as HCoordinate2D, 135.0);
  static SimpleCircle<HomogeneousCoordinate> defaultSegmentCircle =
      new HCircle2D(_defaultCenter as HCoordinate2D, 156.0);
  static SimpleCircle<HomogeneousCoordinate> defaultDirectionCircle =
      new HCircle2D(_defaultCenter as HCoordinate2D, 153.0);

  SimpleCircle<HomogeneousCoordinate> _drawCircle =
      Diagram2D.defaultDrawCircle;
  SimpleCircle<HomogeneousCoordinate> _baseCircle =
      Diagram2D.defaultBaseCircle;
  ///Indicates the inner side of the segments
  SimpleCircle<HomogeneousCoordinate> _segmentCircle =
      Diagram2D.defaultSegmentCircle;
  ///Indicates the outer side of the direction
  SimpleCircle<HomogeneousCoordinate> _directionCircle =
      Diagram2D.defaultDirectionCircle;
  ///Indicates the outer side of the direction line between segment and the diorection
  SimpleCircle<HomogeneousCoordinate> _directionOuterLineCircle =
      Diagram2D.defaultDirectionCircle.clone();
  ///Indicates the outer side direction's shape
  SimpleCircle<HomogeneousCoordinate> _directionUpperCircle =
      Diagram2D.defaultDirectionCircle.clone()..radius = 145.0;
  ///Indicates the inner side direction's shape
  SimpleCircle<HomogeneousCoordinate> _directionLowerCircle =
      Diagram2D.defaultDirectionCircle.clone()..radius = 135.0;
  ///Indicates the outer side of the segments
  SimpleCircle<HomogeneousCoordinate> _outerSegmentCircle =
      Diagram2D.defaultSegmentCircle.clone()..radius = 180.0;
  ///Indicates the inner side of the segments lines
  SimpleCircle<HomogeneousCoordinate> _lineSegmentCircle =
      Diagram2D.defaultSegmentCircle.clone();
  ///Indicates the outer side of the segments lines
  SimpleCircle<HomogeneousCoordinate> _lineOuterSegmentCircle =
      Diagram2D.defaultSegmentCircle.clone();
  ///Indicates the connections outer side line
  SimpleCircle<HomogeneousCoordinate> _lineOuterDrawCircle =
      Diagram2D.defaultDrawCircle.clone();
  
  DivideType _poincareLinesDivideType = DivideType.apollonian;

  @Deprecated("It was moved to the VisObject")
  Map<String, ShapeForm> _listOfShapes =
    new Map<String, ShapeForm>();

  //TODO we have to refactor this to get the shapes from the root vis object
  Map<String, ShapeForm> get listOfShapes {
    return this._listOfShapes;
  }

  @override
  num maxValue = 0.0;

  @override
  MatrixValueRepresentation wayToCreateSegments
    = MatrixValueRepresentation.circos;

  @override
  double averageValue = 1.0;

  double get maxSegmentRadius{
    return (this.outerSegmentCircle.radius -
        this.segmentCircle.radius).abs();
  }

  /// Indicates the direction of the blocks' label
  /// 0 - horizontal
  /// 1 - vertical
  @override
  int textDirection = 0;

  bool isAscendingOrder = true;

  double spaceBetweenBlocksModifier = 1.5;

  double directionShapeHeightsModifier = 0.0;

  double _directionsDefaultHeight = 20.0;

  bool drawLabelNum = false;

  double get directionsHeight{
    return _directionsDefaultHeight + directionShapeHeightsModifier;
  }

  @override
  double angleShift = PI/2.0;

  @override
  double lineWidth = 0.3;

  @override
  int get verticesPerRadian => 30;

  int get tickRange{

    var valueToCompare = (this.maxValue - this.averageValue) > this.averageValue
        ? this.maxValue / 2.0
        : this.averageValue;
    //var valueToCompare = this.maxValue;
    //var valueToCompare = this.averageValue;
    if(valueToCompare <= 100){
      return 25;
    }else if(valueToCompare <= 200){
      return 100;
    }else if(valueToCompare <= 500){
      return 250;
    }else if(valueToCompare <= 1000){
      return 500;
    }else if(valueToCompare <= 5000){
      return 1000;
    }else if(valueToCompare <= 10000){
      return 5000;
    }else if(valueToCompare <= 20000){
      return 7500;
    }else if(valueToCompare <= 30000){
      return 10000;
    }else{
      return 15000;
    }

    /*if(this.averageValue <= 100){
      return 25;
    }else if(this.averageValue <= 200){
      return 50;
    }else if(this.averageValue <= 400){
      return 100;
    }else if(this.averageValue <= 800){
      return 200;
    }else if(this.averageValue <= 1200){
      return 300;
    }else if(this.averageValue <= 1600){
      return 400;
    }else if(this.averageValue <= 2000){
      return 500;
    }else if(this.averageValue <= 4000){
      return 1000;
    }else if(this.averageValue <= 8000){
      return 2000;
    }else if(this.averageValue <= 12000){
      return 3000;
    }else if(this.averageValue <= 16000){
      return 4000;
    }else{
      return 5000;
    }*/
  }

  bool _isVisible = true;
  int _lineSegment = 30;

  ShapeType connectionType = ShapeType.bezier;

  RangeMath<double> _diagram =
    new NumberRange.fromNumbers(0.0, MathFunc.PITwice);

  Diagram2D(VisualObject dataObject, [MatrixValueRepresentation wayToCreateSegments = null]) {
    if(wayToCreateSegments != null){
      this.wayToCreateSegments = wayToCreateSegments;
    }
    updateCirclesRadius();
    this.modifyDiagram(dataObject);
  }

  Diagram2D.empty(){
    updateCirclesRadius();
  }

  void updateCirclesRadius(){
    this._directionCircle.radius = _drawCircle.radius + directionsHeight;
    this.segmentCircle.radius = this._directionCircle.radius + this.lineWidth;

    this._directionUpperCircle.radius = this._drawCircle.radius + (directionsHeight * 0.6);
    //this._directionLowerCircle.radius = this._drawCircle.radius + (directionsHeight * 0.2);

    this._outerSegmentCircle.radius = this.segmentCircle.radius + 25;

    if(this.wayToCreateSegments == MatrixValueRepresentation.segmentsHeight){
      this._lineOuterDrawCircle.radius = this._drawCircle.radius - lineWidth;
      this._lineOuterSegmentCircle.radius = this._segmentCircle.radius + (-lineWidth + 25.0);
      this._lineSegmentCircle.radius = this._segmentCircle.radius + lineWidth;
      this._directionOuterLineCircle.radius = this._directionCircle.radius + lineWidth;
    }else{
      int increaseValue = 40;
      /*this._outerSegmentCircle.radius = this._outerSegmentCircle.radius + increaseValue;
      this._segmentCircle.radius = this._segmentCircle.radius + increaseValue;
      this._directionCircle.radius = this._directionCircle.radius + increaseValue;
      this._directionUpperCircle.radius = this._directionUpperCircle.radius + increaseValue;*/
      this._directionOuterLineCircle.radius = _directionCircle.radius + lineWidth;
      //this._directionLowerCircle.radius;
      this._lineOuterDrawCircle.radius = this._drawCircle.radius - lineWidth;
      this._lineOuterSegmentCircle.radius = (lineWidth + this._outerSegmentCircle.radius);
      this._lineSegmentCircle.radius = this._segmentCircle.radius + lineWidth;
    }
  }

  ///TODO refactor to get shape from the root vis object
  ShapeForm getShape(String ID) {
    if (!this._listOfShapes.containsKey(ID) &&
        !this._listOfShapes.containsKey(ID)) throw new StateError(
        "There is no shape with the given ID");

    if (this._listOfShapes.containsKey(ID)) {
      return this._listOfShapes[ID];
    } else {
      return this._listOfShapes[ID];
    }
  }

  bool get isVisible => this._isVisible;

  bool toggleVisibility() {
    return this._isVisible = !this._isVisible;
  }

  SimpleCircle<HomogeneousCoordinate> get drawCircle => this._drawCircle;
  SimpleCircle<HomogeneousCoordinate> get baseCircle => this._baseCircle;
  SimpleCircle<HomogeneousCoordinate> get segmentCircle => this._segmentCircle;
  SimpleCircle<HomogeneousCoordinate> get outerSegmentCircle => this._outerSegmentCircle;
  SimpleCircle<HomogeneousCoordinate> get lineSegmentCircle => this._lineSegmentCircle;
  SimpleCircle<HomogeneousCoordinate> get lineOuterSegmentCircle => this._lineOuterSegmentCircle;
  SimpleCircle<HomogeneousCoordinate> get lineOuterDrawCircle => this._lineOuterDrawCircle;
  SimpleCircle<HomogeneousCoordinate> get directionCircle => this._directionCircle;
  SimpleCircle<HomogeneousCoordinate> get directionUpperCircle => this._directionUpperCircle;
  SimpleCircle<HomogeneousCoordinate> get directionLowerCircle => this._directionLowerCircle;
  SimpleCircle<HomogeneousCoordinate> get directionOuterLineCircle => this._directionOuterLineCircle;

  DivideType get poincareLinesDivideType => this._poincareLinesDivideType;

  set poincareLinesDivideType(DivideType value){
    this._poincareLinesDivideType = value;
  }

  int get lineSegment => this._lineSegment;

  double getLineWidthArc(SimpleCircle<HomogeneousCoordinate> circle){
    return this.lineWidth / circle.radius;
  }

  Map<String, RangeMath<double>> getSegmentRanges(VisualObject dataObject, RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
      bool differentSpaces: false,
      dynamic defaultSpaceBetweenParts: 0.1,
      bool inOrder: false, double shiftValue: 0.0}){

    switch(this.wayToCreateSegments){
      case MatrixValueRepresentation.circos:
        return dataObject.divideRangeBasedOnChildValue(
            dividingRange,
            defaultSpaceBetweenParts: (defaultSpaceBetweenParts * spaceBetweenBlocksModifier),
            inOrder: inOrder, shiftValue: shiftValue, isAscending: this.isAscendingOrder);
        break;
      case MatrixValueRepresentation.segmentsHeight:
        return dataObject.divideRangeBasedOnEqualSubSegments(
            dividingRange,
            defaultSpaceBetweenParts: (defaultSpaceBetweenParts * spaceBetweenBlocksModifier),
            inOrder: inOrder, shiftValue: shiftValue, isAscending: this.isAscendingOrder);
        break;
      default:
        throw new StateError("Wrong segmenets devide method defined");
        break;
    }
  }

  Map<String, RangeMath<double>> getSubSegmentRanges(VisualObject dataObject, RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
      bool differentSpaces: false,
      dynamic defaultSpaceBetweenParts: 0.1,
      bool inOrder: false}){

    switch(this.wayToCreateSegments){
      case MatrixValueRepresentation.circos:
        return dataObject.divideRangeBasedOnChildValue(
            dividingRange,
            defaultSpaceBetweenParts: defaultSpaceBetweenParts,
            inOrder: inOrder, isAscending: this.isAscendingOrder);
        break;
      case MatrixValueRepresentation.segmentsHeight:
        return dataObject.divideRangeEqualParts(
            dividingRange,
            defaultSpaceBetweenParts: defaultSpaceBetweenParts,
            inOrder: inOrder, isAscending: this.isAscendingOrder);
        break;
      default:
        throw new StateError("Wrong segmenets devide method defined");
        break;
    }
  }

  bool modifyDiagram(VisualObject dataObject) {

    // TODO if we move the shape to the vis object we could remove this code part below

    var oldShapesKey = new List<String>();
    this._listOfShapes.forEach((String key, ShapeForm shape) {
      if (shape is ShapeSimple) {
        try {
          var element = dataObject.getChildByID(key, true);
        } catch (error) {
          oldShapesKey.add(key);
        }
      } else if (shape is ShapeLine) {
        oldShapesKey.add(key);
      } else {
        var deleteShape = true;
        for (VisConnection conn in ConnectionManager
            .listOfConnection[dataObject.id].values) {
          if (key == conn.nameOfConn) {
            deleteShape = false;
          }
        }
        if (deleteShape) {
          oldShapesKey.add(key);
        }
      }
    });

    oldShapesKey.forEach((String key) => this._listOfShapes.remove(key));

    //TODO end of code part

    //var segmentRanges = dataObject.divideRangeEqualParts(this._diagram, defaultSpaceBetweenParts: 0.1, inOrder: true);
    //var segmentRanges = dataObject.divideRangeBasedOnEqualSubSegments(this._diagram, defaultSpaceBetweenParts: 0.1, inOrder: true);
    //double defaultSpace = dataObject.getChildren.length < 2 ? 0.0 :  0.1;
    var groupRanges = getSegmentRanges(dataObject, this._diagram, inOrder: true, shiftValue: this.angleShift);

    List<RangeMath<double>> concentricCircleTextRange = new List<RangeMath<double>>(groupRanges.length);

    List<RangeMath<double>> groupRangesValues = groupRanges.values.toList();

    //var textRangeIndex = this.isAscendingOrder ? groupRanges.length-1 : 0;
    //var textRangeIndexIncrease = this.isAscendingOrder ? -1 : 1;
    var textRangeIndex = 0;
    var textRangeIndexIncrease = 1;

    for(var i = 0; i < groupRanges.length; i++){
      var begin = 0.0;
      var end = 0.0;

      if(this.isAscendingOrder){
        if(i == groupRanges.length - 1){
          begin = groupRangesValues[0].end;
          end = groupRangesValues.last.begin;
        }else{
          begin = groupRangesValues[i+1].end;
          end = groupRangesValues[i].begin;
        }
      }else{
        if(i == 0){
          begin = groupRangesValues.last.end;
          end = groupRangesValues[0].begin;
        }else{
          begin = groupRangesValues[i-1].end;
          end = groupRangesValues[i].begin;
        }
      }

      if((begin - end).abs() > PI/2){
        if(begin > end){
          var helper = begin - (2*PI);
          begin = helper;
        }else{
          var helper = end - (2*PI);
          end = begin;
          begin = helper;
        }
      }

      concentricCircleTextRange[textRangeIndex] = new NumberRange.fromNumbers(begin, end);
      textRangeIndex += textRangeIndexIncrease;
    }

    if(dataObject.value is num) {
      var listOfChildren = dataObject.getChildren;

      this.maxValue = 0.0;
      listOfChildren.forEach((VisualObject group){
        group.getChildren.forEach((VisualObject segment){
          segment.getChildren.forEach((VisualObject connection){
            if((connection.value as num) > this.maxValue){
              this.maxValue = connection.value as num;
            }
          });
        });
      });

      int maxIndex = 0;
      num maxHelper = listOfChildren[0].value as num;
      for(var i = 1; i < listOfChildren.length; i++){
        if((listOfChildren[i].value as num) > maxHelper){
          maxIndex = i;
          maxHelper = listOfChildren[i].value as num;
        }
      }

      var childrenOfTheBiggestGroup = listOfChildren[maxIndex].getChildren;
      int maxIndex2 = 0;
      num maxHelper2 = childrenOfTheBiggestGroup[0].value as num;
      for(var i = 1; i < childrenOfTheBiggestGroup.length; i++){
        if((childrenOfTheBiggestGroup[i].value as num) > maxHelper2){
          maxIndex2 = i;
          maxHelper2 = childrenOfTheBiggestGroup[i].value as num;
        }
      }

      this.maxValue = 0.0;
      for(VisualObject child in childrenOfTheBiggestGroup[maxIndex2].getChildren){
        if((child.value as num) > this.maxValue){
          this.maxValue = child.value as num;
        }
      }

      this.averageValue =
          ((dataObject.value as double) / ConnectionManager.listOfConnection[dataObject.id].length) / 2.0;

      int sum = 0;
      var rangeBetweenLine = this.tickRange;
      //print("range: ${rangeBetweenLine}");
      var numberOfLine = this.maxValue / rangeBetweenLine;
      var radiusIncrease = this.maxSegmentRadius / numberOfLine;
      var radiusIncreaseHalf = radiusIncrease / 2.0;

      var nextRadius = this.segmentCircle.radius;
      for(var i = 0; i <= numberOfLine; i++){
        this._listOfShapes["circular_line_$i"] = new ShapeForm(
            dataObject, ShapeType.line, this, [this._diagram, new NumberRange.fromNumbers(0.0, nextRadius)], null, "", false, 10.0, concentricCircleTextRange, sum);
        if(i < numberOfLine){
          this._listOfShapes["circular_line_half_$i"] = new ShapeForm(
              dataObject, ShapeType.line, this, [this._diagram, new NumberRange.fromNumbers(0.0, nextRadius + radiusIncreaseHalf)]);
          this._listOfShapes["circular_line_half_$i"].borderBaseColor = new Color(0xCCCCCC);
        }
        sum += rangeBetweenLine;
        nextRadius += radiusIncrease;
      }

    }

    groupRanges.forEach((String key, RangeMath<double> range){
      var valueRange = new NumberRange.fromNumbers(0.0,
          (dataObject.getChildByID(key, true).value as num).toDouble());
      _modifyShape(dataObject.getChildByID(key, true), key, range, valueRange, ShapeType.simple, null);
    });

    var segmentsRanges = new Map<String, Map<String, RangeMath<double>>>();

    for (String segmentsID in groupRanges.keys) {
      segmentsRanges[segmentsID] = getSegmentRanges(
          dataObject.getChildByID(segmentsID), groupRanges[segmentsID], inOrder: true, defaultSpaceBetweenParts: 0.0);

      segmentsRanges[segmentsID].forEach((String key, RangeMath<double> range){
        var valueRange = new NumberRange.fromNumbers(0.0,
            (dataObject.getChildByID(key, true).value as num).toDouble());
        _modifyShape(dataObject.getChildByID(key, true), key, range, valueRange, ShapeType.simple, this.getShape(segmentsID));
        this.listOfShapes[key].isDrawable = false;
      });
    }

    var segmentsDividedRanges = new Map<String, Map<String, RangeMath<double>>>();

    for(String groupID in groupRanges.keys) {
      for(String segmentID in segmentsRanges[groupID].keys) {
        /*segmentsDividedRanges[childID] =
        dataObject.getChildByID(childID).divideRangeEqualParts(segmentRanges[childID], defaultSpaceBetweenParts: 0.0, inOrder: true);*/
        /*segmentsDividedRanges[childID] =
          dataObject.getChildByID(childID).divideRangeEqualParts(segmentRanges[childID], defaultSpaceBetweenParts: 0.0, inOrder: true);*/
        segmentsDividedRanges[segmentID] = getSubSegmentRanges(
            dataObject.getChildByID(segmentID, true), segmentsRanges[groupID][segmentID],
            defaultSpaceBetweenParts: 0.0, inOrder: true);

        segmentsDividedRanges[segmentID].forEach((String key,
            RangeMath<double> range) {
          var valueRange = new NumberRange.fromNumbers(0.0,
              (dataObject
                  .getChildByID(key, true)
                  .value as num).toDouble());
          _modifyShape(
              dataObject.getChildByID(key, true), "${key}_${segmentID}", range,
              valueRange, ShapeType.simple, this.getShape(segmentID));
        });
      }
    }

    for (VisConnection conn in ConnectionManager.listOfConnection[dataObject.id].values) {
      if (conn.segmentOne.isHigherDim) {
        this._modifyShape(
            conn.segmentOne,
            conn.nameOfConn,
            segmentsDividedRanges[conn.segmentOne.parent.id][conn.segmentOne.id],
            segmentsDividedRanges[conn.segmentTwo.parent.id][conn.segmentTwo.id],
            this.connectionType, listOfShapes[conn.segmentOne.id],
            false, (conn.segmentOne.value as num).toDouble()
        );

      }else{
        this._modifyShape(
            conn.segmentOne,
            conn.nameOfConn,
            segmentsDividedRanges[conn.segmentOne.parent.id][conn.segmentOne.id],
            segmentsDividedRanges[conn.segmentTwo.parent.id][conn.segmentTwo.id],
            this.connectionType, listOfShapes["${conn.segmentOne.id}_${conn.segmentOne.parent.id}"],
            false, (conn.segmentOne.value as num).toDouble()
        );
      }
    }
    return true;
  }

  ShapeForm _createShape(VisualObject element, String key, ShapeType type,
      List<RangeMath<double>> ranges,
      [ShapeForm parent = null, bool is3D = false, double height = 10.0]){

    this._listOfShapes[key] = new ShapeForm(
        element, type, this, ranges, parent, key, is3D, height );
    if(parent == null){
      this._listOfShapes[key].isDrawable = false;
    }
    return this._listOfShapes[key];
  }

  ShapeForm _modifyShape(VisualObject element, String key, RangeMath<double> a, RangeMath<double> b,
      [ShapeType type = ShapeType.simple, ShapeForm parent = null,
      bool is3D = false, double height = 10.0]){
    if(this._listOfShapes.keys.contains(key)) {
      this._listOfShapes[key].modifyGeometry([a, b], [this._drawCircle]);
    }else{
      this._listOfShapes[key] = this._createShape(
          element, key, type, [a,b], parent, is3D, height);
    }
    return this._listOfShapes[key];
  }


  VisConnection getConnectionFromPosition(VisualObject rootElement, HomogeneousCoordinate position){
    var helperCircle = this._baseCircle.clone()..radius  = this._baseCircle.center.distanceTo(position);
    var polarCoordinate = helperCircle.getPointPolarCoordinate(position).angle;
    if(polarCoordinate < PI/2.0){
      polarCoordinate += 2*PI;
    }
    for(var i = 0; i < this._listOfShapes.length; i++){
      String key = this._listOfShapes.keys.elementAt(i);
      if(this._listOfShapes[key].isDrawable && this._listOfShapes[key] is ShapeSimple) {
        if(this._listOfShapes[key].lines.first.lineArc.range.begin <= polarCoordinate && polarCoordinate <= this._listOfShapes[key].lines.first.lineArc.range.end){
          var newKey = key.split('_').first;
          return rootElement.getChildByID(newKey, true).connection;
        }
      }
    }
    throw new StateError("No connection at the given position");
  }


  List<ShapeForm> getDiagramsShapesPoints(VisualObject rootElement){
    var result = new List<ShapeForm>();
    int numberOfTextAdded = 0;
    int index = 0;
    this._listOfShapes.forEach((String key, ShapeForm shape){
      if(shape.isDrawable) {
        if(shape is ShapeSimple){
          var newKey = key.split('_').first;
          var element = rootElement.getChildByID(newKey, true);
          var otherElement = element.connection.getOtherSegment(element);

          var lineColor = element.connection.getLineConfig();
          var shapeColor = element.connection.getSegmentConfig(newKey);
          var connectionColor = element.connection.getSegmentConfig(otherElement.id);

          shape.polygonBaseColor = new Color.fromArray([shapeColor[0], shapeColor[1], shapeColor[2]]);
          shape.borderBaseColor = new Color.fromArray([lineColor[0], lineColor[1], lineColor[2]]);
          shape.connectionColor = new Color.fromArray([connectionColor[0], connectionColor[1], connectionColor[2]]);

          result.add(shape);

          //List<double> points = shape.generatePointData()[0];
          //List<double> linePoints = shape.generateOuterLinePointData()[0];

          /*int numberOfPoint = points.length ~/ 3;

          var visObject = new DiagramVisObject.fromData(
              rootElement.id, "", element.id, points, linePoints,
              element.connection.getLineConfig(),
              element.connection.getSegmentConfig(newKey),
              numberOfPoint,index++);*/

          /*var label = element.label.name;

          visObject.label = label;

          SimpleCircle<HomogeneousCoordinate> labelCircle = this.outerSegmentCircle.clone()..radius += 20;

          double label_polar_pos = (shape.lines.first.lineArc.range.length / 2.0) + (shape.lines.first.lineArc.range.begin) as double;

          var rotateAngle = 0.0;

          if(label_polar_pos > 1.5 * PI){
            rotateAngle = label_polar_pos - (PI/2);
          }else{
            rotateAngle = (label_polar_pos - (1.5 * PI)) - PI;
          }*/

          //result.add(visObject);
        }else{
          if(shape.isDrawable) {
            if((shape is ShapeBezier) && shape.children == null){
              //List<double> points = shape.generatePointData()[0];
              //List<double> linePoints = shape.generateOuterLinePointData()[0];

              var lineColor = ConnectionManager.listOfConnection[rootElement.id][key]
                  .getLineConfig();
              var shapeColor = ConnectionManager.listOfConnection[rootElement.id][key]
                  .getConnectionConfig();

              shape.polygonBaseColor = new Color.fromArray([shapeColor[0], shapeColor[1], shapeColor[2]]);
              shape.borderBaseColor = new Color.fromArray([lineColor[0], lineColor[1], lineColor[2]]);

              result.add(shape);

              /*if(points.length != linePoints.length){
                print("alma");
                //List<double> linePoints2 = shape.generateOuterLinePointData()[0];
                //List<double> points2 = shape.generatePointData()[0];
              }

              double length = shape.lines[2].lineArc.range.length as double;
              if(length > PI){
                length = (2*PI - length);
              }

              int numberOfPoint = points.length ~/ 3;
              var visObject = new DiagramVisObject.fromData(
                  rootElement.id, "", key, points, linePoints,
                  ConnectionManager.listOfConnection[rootElement.id][key]
                      .getLineConfig(),
                  ConnectionManager.listOfConnection[rootElement.id][key]
                      .getConnectionConfig(),
                  numberOfPoint,index++);


              visObject.addShapePoints((shape as ShapeBezier).generatePolygonData());

              visObject.listOfShapePoints = (shape as ShapeBezier).generatePolygonData();

              visObject.isThin = length < 0.01;
              if(visObject.isThin){
                print("Thin: $length");
              }

              result.add(visObject);*/
            }else if (shape is ShapeLine) {
              result.add(shape);
            }else{
              /*shape.children.forEach((String childKey, ShapeForm child){

                List<double> points = child.generatePointData()[0];
                List<double> linePoints = child.generateOuterLinePointData()[0];


                int numberOfPoint = points.length ~/ 3;

                var visObject = new DiagramVisObject.fromData(
                    rootElement.id, "", childKey, points, linePoints,
                    ConnectionManager.listOfConnection[rootElement.id][key]
                        .getSubConnectionConfig(childKey, ShapeType.line),
                    ConnectionManager.listOfConnection[rootElement.id][key]
                        .getSubConnectionConfig(childKey, ShapeType.mesh),
                    numberOfPoint,index++);

                result.add(visObject);
              });*/
            }
          }//lasst
        }
      }else {
        if (shape is ShapeText) {

          /*var element = rootElement.getChildByID(key, true);

          List<double> points = shape.generatePointData()[0];
          int numberOfPoint = points.length ~/ 3;

          var visObject = new DiagramVisObject.fromData(
              rootElement.id,
              "",
              element.id,
              points, points,
              element.getChildren.first.connection.getLineConfig(),
              element.getChildren.first.connection.getSegmentConfig(element.getChildren.first.id),
              numberOfPoint,
              index++);

          var label = element.label.name;

          visObject.label = label;

          Matrix4 matrix = new Matrix4.identity();*/
          numberOfTextAdded++;
          var element = rootElement.getChildByID(key, true);

          if(!element.label.name.contains("Group")) {
            var elementChildren = shape.children.values.toList();
            SimpleCircle maxValueRadiusCircle = elementChildren[0].lines[5]
                .circle;
            for (var i = 1; i < elementChildren.length; i++) {
              if (elementChildren[i].lines.last.circle.radius >
                  maxValueRadiusCircle.radius) {
                maxValueRadiusCircle = elementChildren[i].lines.last.circle;
              }
            };

            SimpleCircle<HomogeneousCoordinate> labelCircle =
              maxValueRadiusCircle.clone()..radius = 185.0;

            /*var shapeColorList = element.getChildren.first.connection
              .getSegmentConfig(element.getChildren.first.id);*/

            var shapeColorList = element.getChildren.first.connection
                .getLineConfig();

              shape.setLabel(labelCircle, element.label.name, shapeColorList);
              result.add(shape);


            /*double label_polar_pos = (shape.lines.first.lineArc.range.length /
              2.0) + (shape.lines.first.lineArc.range.begin) as double;

            var rotateAngle = 0.0;

            if (label_polar_pos > 1.5 * PI) {
              rotateAngle = label_polar_pos - (PI / 2);
            } else {
              rotateAngle = (label_polar_pos - (1.5 * PI)) - PI;
            }

            var pos = labelCircle.getPointFromPolarCoordinate(label_polar_pos);
            var vec2 = pos.getDescartesCoordinate() as Vector2;
            //matrix.rotate(new Vector3(0.0,0.0,1.0), rotateAngle);

            var helper = (pos.getDescartesCoordinate() as Vector2).normalize();
            var circleVec = new Vector3(helper.x, helper.y, 0.0);

            var textVector = new Vector3(1.0, 0.0, 0.0);

            var rotValue = acos(circleVec.dot(textVector));
            num sum = (pos.y + circleVec.y);
            if(sum < pos.y){
              rotValue *= -1;
              if(rotValue < (-MathFunc.PITwice * 0.25)){
                rotValue = (MathFunc.PITwice * .5) + rotValue;
              }
            }else if(rotValue > (MathFunc.PITwice * 0.25)){
              rotValue = (MathFunc.PITwice * .5) + rotValue;
            }

            //matrix.rotateZ(rotValue);
            matrix.translate(new Vector3(vec2.x, vec2.y, 0.0));

            var list = new List<double>(16);
            matrix.copyIntoArray(list);
            visObject.labelMatrix = list;*/

            //result.add(visObject);
          }
        }
      }
    });

    return result;
  }

}
