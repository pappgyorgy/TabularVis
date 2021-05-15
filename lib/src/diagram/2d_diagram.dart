part of diagram;

class Diagram2D implements Diagram {
  static HomogeneousCoordinate _defaultCenter =
      new HCoordinate2D(new Vector3(0.0, 0.0, 1.0));

  static SimpleCircle<HomogeneousCoordinate> defaultDrawCircle =
    new HCircle2D(_defaultCenter as HCoordinate2D, 130.0);
  static SimpleCircle<HomogeneousCoordinate> defaultBaseCircle =
    new HCircle2D(_defaultCenter as HCoordinate2D, 135.0);
  static SimpleCircle<HomogeneousCoordinate> defaultSegmentCircle =
      new HCircle2D(_defaultCenter as HCoordinate2D, 161.0);
  //static SimpleCircle<HomogeneousCoordinate> defaultSegmentCircle =
  //new HCircle2D(_defaultCenter as HCoordinate2D, 190.0);
  static SimpleCircle<HomogeneousCoordinate> defaultDirectionCircle =
      new HCircle2D(_defaultCenter as HCoordinate2D, 162.0);

  SimpleCircle<HomogeneousCoordinate> _drawCircle =
      Diagram2D.defaultDrawCircle.clone();
  SimpleCircle<HomogeneousCoordinate> _baseCircle =
      Diagram2D.defaultBaseCircle.clone();
  ///Indicates the inner side of the segments
  SimpleCircle<HomogeneousCoordinate> _segmentCircle =
      Diagram2D.defaultSegmentCircle.clone();
  ///Indicates the outer side of the direction
  SimpleCircle<HomogeneousCoordinate> _directionCircle =
      Diagram2D.defaultDirectionCircle.clone();
  ///Indicates the outer side of the direction line between segment and the diorection
  SimpleCircle<HomogeneousCoordinate> _directionOuterLineCircle =
      Diagram2D.defaultDirectionCircle.clone();
  ///Indicates the outer side direction's shape
  SimpleCircle<HomogeneousCoordinate> _directionUpperCircle =
      Diagram2D.defaultDirectionCircle.clone()..radius = 140.0;
  ///Indicates the inner side direction's shape
  SimpleCircle<HomogeneousCoordinate> _directionLowerCircle =
      Diagram2D.defaultDirectionCircle.clone()..radius = 130.0;
  ///Indicates the outer side of the segments
  SimpleCircle<HomogeneousCoordinate> _outerSegmentCircle =
      Diagram2D.defaultSegmentCircle.clone()..radius += 50.0;
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

  double averageBarLength = 1.0;

  int numberOfConcentricCircleForEdgeBundling = 3;

  //TODO we have to refactor this to get the shapes from the root vis object
  Map<String, ShapeForm> get listOfShapes {
    return this._listOfShapes;
  }

  @override
  num maxValue = 0.0;

  num maxBlockValue = 0.0;

  num minBlockValue = double.infinity;

  int maxNumberOfIntersection = 0;

  int minNumberOfIntersection = 999999999999;

  int maxNumberOfBardLeftOut = 0;

  int minNumberOfBardLeftOut = 999999999999;

  @override
  num minValue = double.infinity;

  @override
  MatrixValueRepresentation wayToCreateSegments
    = MatrixValueRepresentation.segmentsHeight;

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

  double spaceBetweenBlocksModifier = 2.0;

  double directionShapeHeightsModifier = 0.0;

  double _directionsDefaultHeight = 20.0;

  int numberOfAdditionalLayer = 0;

  bool drawLabelNum = false;

  bool drawGroupLabel = false;

  double get directionsHeight{
    return _directionsDefaultHeight + directionShapeHeightsModifier;
  }

  int numberOfLine = 4;

  List<RangeMath<double>> valueRanges = <RangeMath<double>>[new NumberRange.fromNumbers(500.0, 20000.0)];

  Map<String, int> numberOfIntersectionPerConnection = new Map<String, int>();
  Map<String, int> numberOfHiddenBarsInBlock = new Map<String, int>();

  @override
  double angleShift = PI/2.0;

  @override
  double lineWidth = 0.3;

  @override
  int get verticesPerRadian => 30;

  @Deprecated("replaced by fixed number of lines")
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

  ShapeType connectionType = ShapeType.poincare;

  RangeMath<double> _diagram =
    new NumberRange.fromNumbers(0.0, MathFunc.PITwice);

  VisConnection get defaultConnection{
    var listOfConn = ConnectionManager.listOfConnection[this._actualDataObject.id].values.toList();
    return listOfConn.first;
  }

  Map<String, VisualObject> dataObjects;

  VisualObject get actualDataObject => this._actualDataObject;
  VisualObject _actualDataObject;

  Diagram2D(this._actualDataObject, [MatrixValueRepresentation wayToCreateSegments = null]) {
    if(wayToCreateSegments != null){
      this.wayToCreateSegments = wayToCreateSegments;
    }
    updateCirclesRadius();
    this.valueRanges = null;

    dataObjects = new Map<String, VisualObject>();
    dataObjects[this._actualDataObject.id] = this._actualDataObject;
    //this.modifyDiagram(this._actualDataObject);
  }

  Diagram2D.empty(){
    updateCirclesRadius();
    this.valueRanges = null;
    dataObjects = new Map<String, VisualObject>();
  }

  void updateCirclesRadius(){
    this._directionCircle.radius = defaultDrawCircle.radius + directionsHeight;
    //this.segmentCircle.radius = this._directionCircle.radius + this.lineWidth;

    //this._directionUpperCircle.radius = this._drawCircle.radius + (directionsHeight * 0.6);
    //this._directionLowerCircle.radius = this._drawCircle.radius + (directionsHeight * 0.2);

    var numberOrBars = ConnectionManager.listOfConnection[this._actualDataObject.id].length;
    double halfSpaceHelper = ((this.spaceBetweenBlocksModifier * 0.1) * numberOrBars);
    double defualtSpaceBetween = ((this.spaceBetweenBlocksModifier * 0.1) * numberOrBars) / this.actualDataObject.numberOfChildren;
    double halfSpace = (MathFunc.PITwice / (numberOrBars + halfSpaceHelper));

    var compareHelper = ConnectionManager.listOfConnection[this._actualDataObject.id].length / 100;
    //var incHeight = min(halfSpace * 130, (15.0 * compareHelper));
    var incHeight = (15.0 * compareHelper);
    //this.drawCircle.radius + 130.0 + compareHelper * 10;
    this.drawCircle.radius = min(130.0 + incHeight, 145.0);
    this.directionLowerCircle.radius = min(130.0 + incHeight, 145.0);
    this.directionUpperCircle.radius = min(140.0 + (8.0 * compareHelper), 155.0);

    if(this.drawGroupLabel){
      segmentCircle.radius = 190.0;
    }else{
      segmentCircle.radius = 165.0;
    }

    this._outerSegmentCircle.radius = this.segmentCircle.radius + 60;

    if(this.wayToCreateSegments == MatrixValueRepresentation.segmentsHeight){
      this._lineOuterDrawCircle.radius = this._drawCircle.radius - lineWidth;
      this._lineOuterSegmentCircle.radius = this._segmentCircle.radius + (-lineWidth + 60.0);
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

  Map<String, RangeMath<double>> getCircularArcRanges(VisualObject dataObject, RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
      bool differentSpaces: false,
      dynamic defaultSpaceBetweenParts: 0.1,
      bool inOrder: false, double shiftValue: 0.0}){

    switch(this.wayToCreateSegments){
      case MatrixValueRepresentation.circos:
        return dataObject.divideRangeBasedOnChildValue(
            dividingRange,
            defaultSpaceBetweenParts: (defaultSpaceBetweenParts * spaceBetweenBlocksModifier),
            inOrder: inOrder, shiftValue: shiftValue, isAscending: this.isAscendingOrder, valueRange: this.valueRanges);
        break;
      case MatrixValueRepresentation.segmentsHeight:
        return dataObject.divideRangeBasedOnEqualSubSegments(
            dividingRange,
            defaultSpaceBetweenParts: (defaultSpaceBetweenParts * spaceBetweenBlocksModifier),
            inOrder: inOrder, shiftValue: shiftValue, isAscending: this.isAscendingOrder, valueRange: this.valueRanges);
        break;
      default:
        throw new StateError("Wrong segmenets devide method defined");
        break;
    }
  }

  Map<String, RangeMath<double>> getCircularArcRangesInside(VisualObject dataObject, RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0}){

    switch(this.wayToCreateSegments){
      case MatrixValueRepresentation.circos:
        return dataObject.divideRangeBasedOnChildValueInside(
            dividingRange,
            defaultSpaceBetweenParts: (defaultSpaceBetweenParts * spaceBetweenBlocksModifier),
            inOrder: inOrder, shiftValue: shiftValue, isAscending: this.isAscendingOrder, valueRange: this.valueRanges);
        break;
      case MatrixValueRepresentation.segmentsHeight:
        return dataObject.divideRangeBasedOnEqualSubSegmentsInside(
            dividingRange,
            defaultSpaceBetweenParts: (defaultSpaceBetweenParts * spaceBetweenBlocksModifier),
            inOrder: inOrder, shiftValue: shiftValue, isAscending: this.isAscendingOrder, valueRange: this.valueRanges);
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
            inOrder: inOrder, isAscending: this.isAscendingOrder, valueRange: this.valueRanges);
        break;
      case MatrixValueRepresentation.segmentsHeight:
        return dataObject.divideRangeEqualParts(
            dividingRange,
            defaultSpaceBetweenParts: defaultSpaceBetweenParts,
            inOrder: inOrder, isAscending: this.isAscendingOrder, valueRange: this.valueRanges);
        break;
      default:
        throw new StateError("Wrong segmenets devide method defined");
        break;
    }
  }

  double roundToZero = pow(10, -10);
  double roundToOne = (1 - pow(10, -10));
  double lengthAB, lengthCD;
  double distAB, distCD, halfDistAB, halfDistCD;
  double midAB, midCD, distOfMidPoints, diffOfConnLength;
  bool normAB, normCD;

  int intersectionTest(double a, double b, double c, double d){
    if(a == c || a == d || b == c || b == d){
      return 0;
    }
    this.lengthAB = (1 - (1 - ((b - a) / pi).abs()).abs()) * pi;
    this.halfDistAB = this.lengthAB / 2;
    this.midAB = b - (1 - (b-a) / pi).sign * this.halfDistAB;
    this.lengthCD = (1 - (1 - ((d - c) / pi).abs()).abs()) * pi;
    this.halfDistCD = this.lengthCD / 2;
    this.midCD = d - (1 - (d-c) / pi).sign * this.halfDistCD;

    this.diffOfConnLength = (this.halfDistAB - this.halfDistCD) * (this.halfDistAB - this.halfDistCD);
    this.distOfMidPoints = (1 - (1 - ((this.midAB - this.midCD) / pi).abs()).abs()) * pi;

    var finalValue = (((this.distOfMidPoints * this.distOfMidPoints) - this.diffOfConnLength)
        / ((this.halfDistAB + this.halfDistCD)*(this.halfDistAB + this.halfDistCD) - this.diffOfConnLength));
    return finalValue > roundToZero && finalValue < roundToOne ? 1 : 0;
  }

  bool modifyDiagram() {

    // TODO if we move the shape to the vis object we could remove this code part below

    var oldShapesKey = new List<String>();
    this._listOfShapes.forEach((String key, ShapeForm shape) {
      if (shape is ShapeSimple) {
        try {
          var element = this._actualDataObject.getChildByID(key, true);
        } catch (error) {
          oldShapesKey.add(key);
        }
      } else if (shape is ShapeLine) {
        oldShapesKey.add(key);
      } else {
        var deleteShape = true;
        for (VisConnection conn in ConnectionManager
            .listOfConnection[this._actualDataObject.id].values) {
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

    var maxBlockNumberInGroup = 1;
    var posDoubleConvertValue = (2*pi) / ((this._actualDataObject.numberOfChildren + 1) * (maxBlockNumberInGroup + 1));

    var segmentOneValue = 0.0, segmentTwoValue = 0.0;

    List<VisConnection> listOfConnectionsGroupBlockIDs = ConnectionManager.listOfConnection[this._actualDataObject.id].values.toList(growable: false);

    this.maxNumberOfIntersection = this.minNumberOfIntersection = 0;

    for(VisConnection connection in listOfConnectionsGroupBlockIDs){
      segmentOneValue = (
          this._actualDataObject.getChildByIDs(
              connection.segmentOne.groupId, 1, connection.segmentOne.segmentId
          ).label.index +
              this._actualDataObject.getChildByIDs(
                  connection.segmentOne.groupId
              ).label.index * maxBlockNumberInGroup) * posDoubleConvertValue;
      segmentTwoValue = (
          this._actualDataObject.getChildByIDs(
              connection.segmentTwo.groupId, 1, connection.segmentTwo.segmentId
          ).label.index +
              this._actualDataObject.getChildByIDs(
                  connection.segmentTwo.groupId
              ).label.index * maxBlockNumberInGroup) * posDoubleConvertValue;
      connection.sortPositionSegMin = min(segmentOneValue, segmentTwoValue);
      connection.sortPositionSegMax = max(segmentOneValue, segmentTwoValue);

      connection.segmentOne.shapeIterable.forEach((String id, ShapeForm shape){
        if(shape is ShapeSimple){
          shape.direction = connection.direction;
        }
      });

      connection.segmentTwo.shapeIterable.forEach((String id, ShapeForm shape){
        if(shape is ShapeSimple){
          shape.direction = connection.direction == 1 ? 2 : connection.direction == 2 ? 1 : 0;
        }
      });
    }


    for (int i = 0; i < listOfConnectionsGroupBlockIDs.length; i++) {
      var sum = 0;
      for (int j = 0; j < listOfConnectionsGroupBlockIDs.length; j++) {
        if(i == j){
          continue;
        }
        sum += this.intersectionTest(
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMax,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMax
        );
      }
      if(sum > this.maxNumberOfIntersection){
        this.maxNumberOfIntersection = sum;
      } else if(sum < this.minNumberOfIntersection){
        this.minNumberOfIntersection = sum;
      }
      numberOfIntersectionPerConnection[listOfConnectionsGroupBlockIDs[i].nameOfConn] = sum;
    }

    bool valueRangesEnabled = valueRanges != null && valueRanges.length > 0;

    var groupRanges = getCircularArcRanges(this._actualDataObject, this._diagram, inOrder: true, shiftValue: this.angleShift);

    this.maxValue = 0;

    if(this._actualDataObject.value is num) {

      double sumOfAllConnValue = 0.0;
      int numberOfConnectionsInRange = 0;
      for (VisConnection conn in ConnectionManager.listOfConnection[this._actualDataObject.id].values) {
        if(valueRangesEnabled) {
          for (var i = 0; i < this.valueRanges.length; i++) {
            if (this.valueRanges[i].isValueInRange(conn.segmentOne.value)) {
              numberOfConnectionsInRange++;
            }else{
              if(this.numberOfHiddenBarsInBlock[conn.segmentOne.parent.label.id] == null){
                this.numberOfHiddenBarsInBlock[conn.segmentOne.parent.label.id] = 1;
              }else{
                this.numberOfHiddenBarsInBlock[conn.segmentOne.parent.label.id] += 1;
              }

              if(this.numberOfHiddenBarsInBlock[conn.segmentTwo.parent.label.id] == null){
                this.numberOfHiddenBarsInBlock[conn.segmentTwo.parent.label.id] = 1;
              }else{
                this.numberOfHiddenBarsInBlock[conn.segmentTwo.parent.label.id] += 1;
              }
            }


            if(conn.segmentOne.value > this.maxValue){
              this.maxValue = conn.segmentOne.value;
            }
            if(conn.segmentOne.value < this.minValue){
              this.minValue = conn.segmentOne.value;
            }

            if(conn.segmentOne.parent.value > this.maxBlockValue){
              this.maxBlockValue = conn.segmentOne.parent.value;
            }
            if(conn.segmentOne.parent.value < this.minBlockValue){
              this.minBlockValue = conn.segmentOne.parent.value;
            }

            if(conn.segmentTwo.parent.value > this.maxBlockValue){
              this.maxBlockValue = conn.segmentTwo.parent.value;
            }
            if(conn.segmentTwo.parent.value < this.minBlockValue){
              this.minBlockValue = conn.segmentTwo.parent.value;
            }

            sumOfAllConnValue += conn.segmentOne.value;
          }
        }else{
          numberOfConnectionsInRange++;
          if(conn.segmentOne.value > maxValue){
            this.maxValue = conn.segmentOne.value;
          }
          if(conn.segmentOne.value < this.minValue){
            this.minValue = conn.segmentOne.value;
          }

          if(conn.segmentOne.parent.value > this.maxBlockValue){
            this.maxBlockValue = conn.segmentOne.parent.value;
          }
          if(conn.segmentOne.parent.value < this.minBlockValue){
            this.minBlockValue = conn.segmentOne.parent.value;
          }

          if(conn.segmentTwo.parent.value > this.maxBlockValue){
            this.maxBlockValue = conn.segmentTwo.parent.value;
          }
          if(conn.segmentTwo.parent.value < this.minBlockValue){
            this.minBlockValue = conn.segmentTwo.parent.value;
          }

          sumOfAllConnValue += conn.segmentOne.value;
        }
      }

      this.averageValue =
          (sumOfAllConnValue / numberOfConnectionsInRange);
    }

    this.maxValue *= 1.25;

    var blockRanges = new Map<String, Map<String, RangeMath<double>>>();
    var numberOfBlocks = 0;

    ///ADD group elements
    this._actualDataObject.performFunctionOnChildren((String groupID, VisualObject group){
      var valueRange = new NumberRange.fromNumbers(0.0, group.value as double);
      _modifyShape(group, groupID, group.range, valueRange, ShapeType.simple, null)..isDrawable = this.drawGroupLabel;
      if(group.numberOfChildren > 1){
        var valueRange = new NumberRange.fromNumbers(0.0, this.maxSegmentRadius);
        _modifyShape(group, "${groupID}-connector", group.range, valueRange, ShapeType.blockConnection, null)..isDrawable = true;
      }

      if(group.numberOfChildren > 1){
        blockRanges[groupID] = getCircularArcRangesInside(
            this._actualDataObject.getChildByID(groupID), groupRanges[groupID], inOrder: true, defaultSpaceBetweenParts: 0.035);
      }else{
        blockRanges[groupID] = getCircularArcRanges(
            this._actualDataObject.getChildByID(groupID), groupRanges[groupID], inOrder: true, defaultSpaceBetweenParts: 0.0);
      }

      numberOfBlocks += blockRanges[groupID].length;

      /// ADD block elements
      group.performFunctionOnChildren((String blockID, VisualObject block){

        if(this.numberOfHiddenBarsInBlock[blockID] == null){
          this.numberOfHiddenBarsInBlock[blockID] = 0;
        }

        var valueRange = new NumberRange.fromNumbers(0.0, block.heightValue);
        _modifyShape(block, blockID, blockRanges[groupID][blockID], valueRange, ShapeType.simple, block.parent.getShapeByID(groupID));

        if(block.label.uniqueScale){
          var valueRange = new NumberRange.fromNumbers(0.0, 6.0);
          block.tickIncValue = block.getMaxValueOfChildren() / this.numberOfLine;
          _modifyShape(block, "${blockID}-unique-scale", blockRanges[groupID][blockID], valueRange, ShapeType.uniqueScaleIndicator, block.parent.getShapeByID(groupID));
        }

        this.numberOfAdditionalLayer = 0;
        _modifyShape(block, blockID + "-heatmap-blockValue", blockRanges[groupID][blockID], valueRange, ShapeType.heatmap, block.parent.getShapeByID(groupID));

        //this.numberOfAdditionalLayer = 3;
        //_modifyShape(block, blockID + "-heatmap-hiddenBars", blockRanges[groupID][blockID], valueRange, ShapeType.heatmap, block.parent.getShapeByID(groupID));

      });

    });

    var numberOrBars = ConnectionManager.listOfConnection[this._actualDataObject.id].length;
    var radiusIncrease = this.maxSegmentRadius / numberOfLine;

    Color halfLineColor = new Color(0xCCCCCC);

    this._actualDataObject.performFunctionOnChildren((String groupID, VisualObject group){
      group.performFunctionOnChildren((String blockID, VisualObject block){

        var defaultSpaceBetween = group.numberOfChildren > 1 ? 0.05 : 0.1;
        double halfSpaceHelper = ((this.spaceBetweenBlocksModifier * defaultSpaceBetween) * numberOrBars);
        double defualtSpaceBetween = ((this.spaceBetweenBlocksModifier * defaultSpaceBetween) * numberOrBars) / this.actualDataObject.numberOfChildren;
        double halfSpace = (MathFunc.PITwice / (numberOrBars + halfSpaceHelper)) * defualtSpaceBetween;

        var scaling = group.scaling * block.scaling;

        /*var begin2 = block.range.end + (halfSpace * 0.5);
        var end2 = block.range.begin;*/


        var begin2 = block.range.end + 0.008;
        var end2 = block.range.begin - 0.008;


        var begin = block.range.end + (halfSpace / 8.0);
        var end = block.range.end;
        
        if((begin - end).abs() > pi/2){
          if(begin > end){
            var helper = begin - (2*pi);
            begin = helper;
          }else{
            var helper = end - (2*pi);
            end = begin;
            begin = helper;
          }
        }

        var rangeLine = new NumberRange.fromNumbers(begin2, end2);
        var rangeText = new NumberRange.fromNumbers(begin, end);

        var scaledRadiusIncrease = radiusIncrease * scaling;
        var radiusIncreaseHalf = scaledRadiusIncrease / 2.0;
        var nextRadius = this.segmentCircle.radius;
        var sum = 0;

        for(int i = 0; i < this.numberOfLine; i++){
          var result = _modifyShape(this._actualDataObject, "circular_line_${blockID}_$i",
              rangeLine, new NumberRange.fromNumbers(0.0, nextRadius),
              ShapeType.line, null, false, 10.0,
              rangeText,
              sum
          )..isDrawable = true;
          if (i < numberOfLine) {
            _modifyShape(
                this._actualDataObject,
                "circular_line_half_${blockID}_$i",
                rangeLine,
                new NumberRange.fromNumbers(0.0, nextRadius + radiusIncreaseHalf),
                ShapeType.line,
                null
            )..borderBaseColor = halfLineColor
              ..isDrawable = true;
          }

          nextRadius += scaledRadiusIncrease;
          sum += block.getRangeBetweenLine(this.maxValue, this.numberOfLine);
        }

      });
    });


    this.numberOfConcentricCircleForEdgeBundling = 2 + pow(numberOfBlocks,1/3).floor();

    this.numberOfHiddenBarsInBlock.forEach((String key, int value){
      if(value > this.maxNumberOfBardLeftOut){
        this.maxNumberOfBardLeftOut = value;
      }
      if(value < this.minNumberOfBardLeftOut){
        this.minNumberOfBardLeftOut = value;
      }
    });

    var barsRangesInBlocks = new Map<String, Map<String, RangeMath<double>>>();

    var sumOfBarRangeLength = 0.0;

    VisualObject blockElement, bar;
    for(String groupID in groupRanges.keys) {
      for(String blockID in blockRanges[groupID].keys) {
        /*segmentsDividedRanges[childID] =
        dataObject.getChildByID(childID).divideRangeEqualParts(segmentRanges[childID], defaultSpaceBetweenParts: 0.0, inOrder: true);*/
        /*segmentsDividedRanges[childID] =
          dataObject.getChildByID(childID).divideRangeEqualParts(segmentRanges[childID], defaultSpaceBetweenParts: 0.0, inOrder: true);*/
        barsRangesInBlocks[blockID] = getSubSegmentRanges(
            this._actualDataObject.getChildByID(blockID, true), blockRanges[groupID][blockID],
            defaultSpaceBetweenParts: 0.0, inOrder: true);


        barsRangesInBlocks[blockID].forEach((String key,
            RangeMath<double> range) {
          bar = this._actualDataObject.getChildByIDs(groupID, 2, blockID, key);
          var valueRange = new NumberRange<double>.fromNumbers(0.0, bar.heightValue);
          var valueRange2 = new NumberRange.fromNumbers(0.0, numberOfIntersectionPerConnection[bar.connection.nameOfConn]);
          sumOfBarRangeLength += range.length;
          _modifyShape(
              this._actualDataObject.getChildByID(key, true), "${key}-${blockID}", range,
              valueRange, ShapeType.simple, bar.parent.getShapeByID(blockID));
          /*_modifyShape(
              this._actualDataObject.getChildByID(key, true), "${key}-${blockID}_bar_label", range,
              valueRange, ShapeType.barLabel, bar.parent.getShapeByID(blockID));*/
          this.numberOfAdditionalLayer = 0;
          //_modifyShape(bar, "${groupID}-${blockID}-${key}-heatmap-barValue", range, valueRange, ShapeType.heatmap, bar.parent.getShapeByID(blockID));
          //this.numberOfAdditionalLayer = 1;
          //_modifyShape(bar, "${groupID}-${blockID}-${key}-heatmap-closeNeighbour", range, valueRange, ShapeType.heatmap, bar.parent.getShapeByID(blockID));
          //this.numberOfAdditionalLayer = 2;
          //_modifyShape(bar, "${groupID}-${blockID}-${key}-heatmap-intersection", range, valueRange, ShapeType.heatmap, bar.parent.getShapeByID(blockID));
        });
      }
    }

    this.averageBarLength = (sumOfBarRangeLength / ConnectionManager.listOfConnection[this._actualDataObject.id].length) * this.drawCircle.radius;

    var beginSegment, endSegment;
    VisConnection conn = ConnectionManager.listOfConnection[this._actualDataObject.id].values.elementAt(2);
    for (VisConnection conn in ConnectionManager.listOfConnection[this._actualDataObject.id].values) {
      beginSegment = conn.direction < 2 ? conn.segmentOne : conn.segmentTwo;
      endSegment = conn.direction > 1 ? conn.segmentOne : conn.segmentTwo;
      if(valueRanges != null && valueRanges.length > 0) {
        for (var i = 0; i < this.valueRanges.length; i++) {
          if (this.valueRanges[i].isValueInRange(conn.segmentOne.value)) {
            if (conn.segmentOne.isHigherDim) {
              this._modifyShape(
                  conn.segmentOne,
                  conn.nameOfConn,
                  barsRangesInBlocks[beginSegment.parent.id][beginSegment.id],
                  barsRangesInBlocks[endSegment.parent.id][endSegment.id],
                  this.connectionType,
                  listOfShapes[conn.segmentOne.id],
                  false,
                  (conn.segmentOne.value as num).toDouble()
              );

              //TODO need to fix dividing poincare line
              //(this._listOfPoincareShapes[conn.nameOfConn] as ShapePoincare)._divideShapeLines(conn.segmentOne.getChildrenValues);
            } else {
              var test = this._modifyShape(
                  conn.segmentOne,
                  conn.nameOfConn,
                  barsRangesInBlocks[conn.segmentOne.parent.id][conn
                      .segmentOne.id],
                  barsRangesInBlocks[conn.segmentTwo.parent.id][conn
                      .segmentTwo.id],
                  this.connectionType,
                  conn.segmentOne.getShapeByID(
                      "${conn.segmentOne.id}-${conn.segmentOne.parent.id}"
                  ),
                  false,
                  (conn.segmentOne.value as num).toDouble(), null, 0,
                  groupRanges[beginSegment.groupId],
                  groupRanges[endSegment.groupId]
              );
              this.listOfShapes[conn.nameOfConn] = test;
            }
            break;
          }
        }
      }else{
        if (conn.segmentOne.isHigherDim) {
          this._modifyShape(
              conn.segmentOne,
              conn.nameOfConn,
              barsRangesInBlocks[conn.segmentOne.parent.id][conn
                  .segmentOne.id],
              barsRangesInBlocks[conn.segmentTwo.parent.id][conn
                  .segmentTwo.id],
              this.connectionType,
              listOfShapes[conn.segmentOne.id],
              false,
              (conn.segmentOne.value as num).toDouble()
          );

          //TODO need to fix dividing poincare line
          //(this._listOfPoincareShapes[conn.nameOfConn] as ShapePoincare)._divideShapeLines(conn.segmentOne.getChildrenValues);
        } else {
          var test = this._modifyShape(
              conn.segmentOne,
              conn.nameOfConn,
              barsRangesInBlocks[conn.segmentOne.parent.id][conn
                  .segmentOne.id],
              barsRangesInBlocks[conn.segmentTwo.parent.id][conn
                  .segmentTwo.id],
              this.connectionType,
              conn.segmentOne.getShapeByID(
                  "${conn.segmentOne.id}-${conn.segmentOne.parent.id}"
              ),
              false,
              (conn.segmentOne.value as num).toDouble(), null, 0,
              groupRanges[beginSegment.groupId],
              groupRanges[endSegment.groupId]
          )..isDrawable = true;
          this.listOfShapes[conn.nameOfConn] = test;

        }
      }
    }

    return true;
  }

  ShapeForm _createShape(VisualObject element, String key, ShapeType type,
      [RangeMath<double> rangeA, RangeMath<double> rangeB,
      ShapeForm parent = null, bool is3D = false, double height = 10.0, RangeMath<double> textRange, int value, RangeMath<double> blockRange, RangeMath<double> blockRange2]){

    /*this._listOfShapes[key] = new ShapeForm(
        element, type, this, ranges, parent, key, is3D, height );*/
    return element.setShapeByID(key, new ShapeForm(
        element, type, this, rangeA, rangeB, parent, key, is3D, height, textRange, value, blockRange, blockRange2));
    /*if(parent == null){
      //this._listOfShapes[key].isDrawable = false;
      element.shape.isDrawable == false;
    }*/
    //return this._listOfShapes[key];
  }

  //TODO remove rangeMath shit and replace with something, which require less performance
  ShapeForm _modifyShape(VisualObject element, String key, RangeMath<double> a, RangeMath<double> b,
      [ShapeType type = ShapeType.simple, ShapeForm parent = null,
      bool is3D = false, double height = 10.0, RangeMath<double> textRange, int value, RangeMath<double> blockRange, RangeMath<double> blockRange2]){
    ShapeForm retVal = null;
    if(element.getShapeByID(key) != null){
      if(type == ShapeType.bezier || type == ShapeType.edgeBundle){
        if(element.getShapeByID(key) is ShapeBezier && type != ShapeType.bezier){
          element.setShapeByID(key, null);
          retVal = this._createShape(
              element, key, type, a, b, parent, is3D, height, textRange, value, blockRange, blockRange2);
        }else if(element.getShapeByID(key) is ShapeEdgeBundle && type != ShapeType.edgeBundle){
          element.setShapeByID(key, null);
          retVal = this._createShape(
              element, key, type, a, b, parent, is3D, height, textRange, value, blockRange, blockRange2);
        }else {
          retVal = element.getShapeByID(key)
            ..modifyGeometry(
                a,
                b,
                parent,
                key,
                is3D,
                height,
                textRange,
                value,
                blockRange,
                blockRange2);
        }
        //return element.getShapeByID(key);

        //return this.listOfShapes[key]..modifyGeometry(a, b, parent, key, is3D, height, blockRange);
        /*return this._createShape(
            element, key, type, a, b, parent, is3D, height, textRange, value)..isDrawable=true;*/
      }else {
        retVal = element.getShapeByID(key)
          ..modifyGeometry(a, b, parent, key, is3D, height, textRange,
              value, blockRange, blockRange2);
      }
    }else{
      retVal = this._createShape(
          element, key, type, a, b, parent, is3D, height, textRange, value, blockRange, blockRange2);
    }

    if(retVal.dataElement == null){
      retVal.dataElement = element;
    }

    return retVal;
    /*if(this._listOfShapes.keys.contains(key)) {
      this._listOfShapes[key].modifyGeometry([a, b], [this._drawCircle]);
    }else{
      this._listOfShapes[key] = this._createShape(
          element, key, type, [a,b], parent, is3D, height);
    }
    return this._listOfShapes[key];*/
  }


  VisConnection getConnectionFromPosition(HomogeneousCoordinate position){
    var helperCircle = this._baseCircle.clone()..radius = this._baseCircle.center.distanceTo(position);
    var polarCoordinate = helperCircle.getPointPolarCoordinate(position).angle;
    if(polarCoordinate < pi/2.0){
      polarCoordinate += MathFunc.PITwice;
    }

    var retVal;
    bool connectionFound = false;
    actualDataObject.performFunctionOnChildren((String groupID, VisualObject group){
      if(!connectionFound && group.range.isValueInRange(polarCoordinate)){
        group.performFunctionOnChildren((String blockID, VisualObject block){
          if(!connectionFound && block.range.isValueInRange(polarCoordinate)){
            block.performFunctionOnChildren((String barID, VisualObject bar){
              if(!connectionFound && bar.range.isValueInRange(polarCoordinate)) {
                connectionFound = true;
                retVal = bar.connection;
              }
            });
          }
        });
      }
    });

    if(retVal == null){
      throw new StateError("No connection at the given position");
    }else{
      return retVal;
    }
  }

  void updateShapeForm(VisualObject element, String rootID, ShapeForm shape, String key) {
    if (shape is ShapeSimple && !(shape is ShapeHeatmap) &&
        !(shape is ShapeText) && !(shape is ShapeBlockConnection)
        && !(shape is ShapeUniqueScaleIndicator) && !(shape is ShapeBarLabel)) {
      if(element.connection == null) return;
      var otherElement = element.connection.getOtherSegment(element);

      var lineColor = element.connection.getLineConfig();
      var shapeColor = element.connection.getSegmentConfig(element.id);
      var connectionColor = element.connection.getSegmentConfig(
          otherElement.id);

      shape.polygonBaseColor =
      new Color.fromArray([shapeColor[0], shapeColor[1], shapeColor[2]]);
      shape.borderBaseColor =
      new Color.fromArray([lineColor[0], lineColor[1], lineColor[2]]);
      shape.connectionColor = new Color.fromArray(
          [connectionColor[0], connectionColor[1], connectionColor[2]]);


      //result.add(shape);

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
    } else if ((shape is ShapeBezier || shape is ShapePoincare || shape is ShapeEdgeBundle) &&
        shape.children == null) {
      //List<double> points = shape.generatePointData()[0];
      //List<double> linePoints = shape.generateOuterLinePointData()[0];

      var lineColor = ConnectionManager.listOfConnection[rootID][key]
          .getLineConfig();
      var shapeColor = ConnectionManager.listOfConnection[rootID][key]
          .getConnectionConfig();

      var connection = ConnectionManager.listOfConnection[rootID][key];

      /*var mixColorPartA = connection.getSegmentConfig(connection.segmentOneID);
      var mixColorPartB = connection.getSegmentConfig(connection.segmentTwoID);

      var newColor = new Color.fromArray([
        (mixColorPartA[0] + mixColorPartB[0]) / 2,
        (mixColorPartA[1] + mixColorPartB[1]) / 2,
        (mixColorPartA[2] + mixColorPartB[2]) / 2,
      ]);*/

      //shape.connectionColor = newColor;

      shape.polygonBaseColor =
      new Color.fromArray([shapeColor[0], shapeColor[1], shapeColor[2], 0.8]);
      //shape.polygonBaseColor = newColor;
      shape.borderBaseColor =
      new Color.fromArray([lineColor[0], lineColor[1], lineColor[2], 0.8]);

      //result.add(shape);

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
    } else if (shape is ShapeLine) {
      //result.add(shape);
    } else if (shape is ShapeBarLabel) {
      //result.add(shape);
      shape.polygonBaseColor = new Color(0x000000);
    } else if (shape is ShapeUniqueScaleIndicator) {

      var barElement = element.getChildren.first;

      shape.polygonBaseColor = new Color.fromArray(barElement.connection.getSegmentConfig(barElement.id));

      shape.borderBaseColor = new Color(0x000000);
      shape.connectionColor = new Color(0xff0000);

    }else if (shape is ShapeBlockConnection) {

      List<double> hslValue = [0.0, 0.0, 0.0];

      element.performFunctionOnChildren((String blockID, VisualObject block){
        var barElement = block.getChildren.first;
        List<double> blockColorHSL = new Color.fromArray(barElement.connection.getSegmentConfig(barElement.id)).HSL;

        int index = 0;
        hslValue = hslValue.map((double value){
          return value += blockColorHSL[index++];
        }).toList(growable: false);

      });

      hslValue = hslValue.map((double value){
        return value / element.numberOfChildren;
      }).toList(growable: false);

      hslValue[1] = 0.4;
      hslValue[2] = 0.9;

      shape.polygonBaseColor = new Color(0xF5EAD8).setHSL(hslValue[0], hslValue[1], hslValue[2]);
      shape.borderBaseColor = new Color(0x000000);
      shape.connectionColor = new Color(0xff0000);

    } else if (shape is ShapeHeatmap) {

      /*var lineColor = new Color(0x000000);
              var shapeColor = new Color(0x0000ff);
              var connectionColor = new Color(0x00ff00);

              shape.polygonBaseColor = new Color.fromArray([shapeColor[0], shapeColor[1], shapeColor[2]]);
              shape.borderBaseColor = new Color.fromArray([lineColor[0], lineColor[1], lineColor[2]]);
              shape.connectionColor = new Color.fromArray([connectionColor[0], connectionColor[1], connectionColor[2]]);*/

      //var visObject = (shape as ShapeHeatmap).visObject;

      var shapeColor = element.role == VisualObjectRole.BAR
          ? element.connection.getSegmentConfig(element.id)
          : element.getChildren.first.connection.getSegmentConfig(element.getChildren.first.id);

      if(key.contains("barValue")){
        //Bars values

        var ratio = 1-(element.value - this.minValue) / (this.maxValue - this.minValue);

        shape.polygonBaseColor = new Color.fromArray(
          element.connection.createColorGradient(
            new Color.fromArray(shapeColor),
            ratio)
        );

      }else if(key.contains("intersection")){
        //Intersection

        var ratio = 1-(this.numberOfIntersectionPerConnection[element.connection.nameOfConn].toDouble() - this.minNumberOfIntersection.toDouble())
            / (this.maxNumberOfIntersection.toDouble() - this.minNumberOfIntersection.toDouble());

        shape.polygonBaseColor = new Color.fromArray(
            element.connection.createColorGradient(
                new Color.fromArray(shapeColor),
                ratio)
        );
      }else if(key.contains("closeNeighbour")){
        //numberOfCloseNeighbour

        var ratio = (element.value - this.minValue) / (this.maxValue - this.minValue);

        var hslValue = new Color.fromArray(shapeColor).HSL;

        if(ratio > 0.95){
          shape.polygonBaseColor = new Color().setHSL(hslValue[0], 1.0, hslValue[2]);
        } else if(ratio < 0.05){
          shape.polygonBaseColor = new Color().setHSL(hslValue[0], hslValue[1], 0.3);
        } else {
          shape.polygonBaseColor = new Color().setHSL(hslValue[0], 0.9, 0.8);
        }



      }else if(key.contains("blockValue")){
        //Block values

        var ratio = 1-(element.value - this.minBlockValue) / (this.maxBlockValue - this.minBlockValue);

        shape.polygonBaseColor = new Color.fromArray(
            element.getChildren.first.connection.createColorGradient(
                new Color(0x472A22),
                ratio)
        );

      }else if(key.contains("hiddenBars")){
        //hidden data

        var ratio = 1 - (this.numberOfHiddenBarsInBlock[element.id].toDouble() - this.minNumberOfBardLeftOut.toDouble())
            / (this.maxNumberOfBardLeftOut.toDouble() - this.minNumberOfBardLeftOut.toDouble());

        ratio = ratio.isNaN ? 1.0 : ratio;

        shape.polygonBaseColor = new Color.fromArray(
            element.getChildren.first.connection.createColorGradient(
                new Color.fromArray(shapeColor),
                ratio)
        );
      }

      // Block values

      /*shape.polygonBaseColor = new Color.fromArray(
          element.getChildren.first.connection.getColorBasedOnValue(
              element.value, this.maxBlockValue, this.minBlockValue));*/

      // hidden data

      /*shape.polygonBaseColor = new Color.fromArray(
          element.getChildren.first.connection.getColorBasedOnValue(
              this.numberOfHiddenBarsInBlock[element.id].toDouble(),
              this.maxNumberOfBardLeftOut.toDouble(), this.minNumberOfBardLeftOut.toDouble()));*/

      // numberOfCloseNeighbour
      /*if(element.value < this.minValue + this.maxValue * 0.05){
        shape.polygonBaseColor = ConnectionVis.maxColor;
      }else{
        shape.polygonBaseColor = ConnectionVis.minColor;
      }*/

      shape.borderBaseColor = new Color(0x000000);
      shape.connectionColor = new Color(0xff0000);

      //result.add(shape);

    } else if (shape is ShapeText) {

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
      //numberOfTextAdded++;
      //var element = rootElement.getChildByID(key, true);

      if (element.role != VisualObjectRole.GROUP) {
        var elementChildren = shape.children.values.toList();

        SimpleCircle<HomogeneousCoordinate> labelCircle = this.outerSegmentCircle.clone()
          ..radius += 10;

        var shapeColorList = element.getChildren.first.connection
            .getLineConfig();

        shape.setLabel(labelCircle, element.label.name, shapeColorList);

      }else{
        SimpleCircle labelCircle = this.directionOuterLineCircle.clone()..radius += 7;
        var shapeColorList = element.getChildren.first.getChildren.first.connection
            .getLineConfig();

        shape.setLabel(labelCircle, element.label.name, shapeColorList);
      }
    }
  }

  List<ShapeForm> getDiagramsShapesPoints(VisualObject rootElement){
    var result = new List<ShapeForm>();
    int numberOfTextAdded = 0;
    int index = 0;

    this._listOfShapes.forEach((String key, ShapeForm shape){
      if((shape is ShapeBezier || shape is ShapePoincare || shape is ShapeEdgeBundle) && shape.children == null){
        //List<double> points = shape.generatePointData()[0];
        //List<double> linePoints = shape.generateOuterLinePointData()[0];

        var lineColor = ConnectionManager.listOfConnection[rootElement.id][key]
            .getLineConfig();
        var shapeColor = ConnectionManager.listOfConnection[rootElement.id][key]
            .getConnectionConfig();

        shape.polygonBaseColor = new Color.fromArray([shapeColor[0], shapeColor[1], shapeColor[2], 0.8]);
        shape.borderBaseColor = new Color.fromArray([lineColor[0], lineColor[1], lineColor[2], 0.8]);

        result.add(shape);
      }
    });

    rootElement.shapeIterable.forEach((String key, ShapeForm shape){
      updateShapeForm(rootElement, rootElement.id, shape, key);
      if(shape.isDrawable){
        result.add(shape);
      }
    });

    rootElement.childrenIterable.forEach((VisualObject group){
      group.shapeIterable.forEach((String key, ShapeForm shape){
        updateShapeForm(group, rootElement.id, shape, key);
        if(shape.isDrawable){
          result.add(shape);
        }
      });
      group.childrenIterable.forEach((VisualObject block){
        block.shapeIterable.forEach((String key, ShapeForm shape){
          updateShapeForm(block, rootElement.id, shape, key);
          if(shape.isDrawable){
            result.add(shape);
          }
        });
        block.childrenIterable.forEach((VisualObject bar){
          bar.shapeIterable.forEach((String key, ShapeForm shape){
            updateShapeForm(bar, rootElement.id, shape, key);
            if(shape.isDrawable){
              if(shape is ShapeBezier || shape is ShapeEdgeBundle){
                var test = 5;
              }else{
                result.add(shape);
              }
            }
          });
        });
      });
    });

    return result;
  }

  void changeElementsIndex(String idOne, String idTwo, int indexOne, int indexTwo){
    if(idOne.isEmpty && idTwo.isEmpty){
      var groupAtNewPos = this._actualDataObject.getChildByIDs(this._actualDataObject.childrenIDsInOrder[indexOne]);
      var groupToMove = this._actualDataObject.getChildByIDs(this._actualDataObject.childrenIDsInOrder[indexTwo]);

      this._actualDataObject.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

    }else if(idTwo.isEmpty){
      var group = this._actualDataObject.getChildByIDs(idOne);
      var blockAtNewPos = group.getChildByIDs(group.childrenIDsInOrder[indexOne]);
      var blockToMove = group.getChildByIDs(group.childrenIDsInOrder[indexTwo]);

      group.swapChildrenIndexValues(blockAtNewPos.id, blockToMove.id);
    }else{
      var block = this._actualDataObject.getChildByIDs(idOne, 1, idTwo);
      var barAtNewPos = block.getChildByIDs(block.childrenIDsInOrder[indexOne]);
      var barToMove = block.getChildByIDs(block.childrenIDsInOrder[indexTwo]);

      block.swapChildrenIndexValues(barAtNewPos.id, barToMove.id);
    }

  }
}
