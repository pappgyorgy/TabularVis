part of visualizationGeometry;

class ShapePoincare extends ShapeForm {
  List<LineGeom<double, HomogeneousCoordinate>> _lines =
    new List<LineGeom<double, HomogeneousCoordinate>>(8);

  Diagram _diagram;

  bool _isDrawable = true;

  List<LineGeom> get _listOfPoincareLine{
    return [_lines[0], _lines[1]];
  }

  bool _is3D = false;
  double shapeHeight = 10.0;

  ShapeForm _parent;

  Map<String, ShapeForm> _children;

  int _numberOfPolygonFaces;
  int _numberOfBorderFaces;

  int _numberOfPolygonVertices = 0;
  int _polygonVerticesOffset = 0;
  int _numberOfPolygonLines = 0;

  int _numberOfBorderVertices = 0;
  int _borderVerticesOffset = 0;

  Color polygonBaseColor;
  Color borderBaseColor;


  ShapePoincare(this._lines, this._diagram) : super._();

  ShapePoincare.fromData(this._diagram,
      RangeMath<double> rangeOne,
      RangeMath<double> rangeTwo,
      [this._parent = null, String key = "",
      this._is3D = false, double this.shapeHeight = 10.0]) : super._(){

    var poincareCircleOne = _getPoincareCircle(rangeOne.end, rangeTwo.begin);
    var poincareCircleTwo = _getPoincareCircle(rangeTwo.end, rangeOne.begin);

    var poincareOneRange = _getPoincareCircleRange(
        poincareCircleOne, rangeOne.end, rangeTwo.begin);

    var poincareCircleOneDrawCircleStartPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(rangeOne.end);
    var poincareCircleOneDrawCircleEndPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(rangeTwo.begin);

    var poincareTwoRange = _getPoincareCircleRange(
        poincareCircleTwo, rangeTwo.end, rangeOne.begin);

    var poincareCircleTwoDrawCircleStartPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(rangeTwo.end);
    var poincareCircleTwoDrawCircleEndPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(rangeOne.begin);

    if ((poincareOneRange.length as double) > PI) {
      poincareOneRange.begin += MathFunc.PITwice;
    }

    if ((poincareTwoRange.length as double) > PI) {
      poincareTwoRange.begin += MathFunc.PITwice;
    }

    var lineArcWidth = this._diagram.getLineWidthArc(
        this._diagram.lineSegmentCircle);

    var outerRangeOne = new NumberRange.fromNumbers(
        rangeOne.begin + lineArcWidth,
        rangeOne.end - lineArcWidth);

    var outerRangeTwo = new NumberRange.fromNumbers(
        rangeTwo.begin + lineArcWidth,
        rangeTwo.end - lineArcWidth);

    var poincareOuterCircleOne = _getPoincareCircle(outerRangeOne.end, outerRangeTwo.begin);
    var poincareOuterCircleTwo = _getPoincareCircle(outerRangeTwo.end, outerRangeOne.begin);

    var poincareOuterOneRange = _getPoincareCircleRange(
        poincareOuterCircleOne, outerRangeOne.end, outerRangeTwo.begin);

    var poincareOuterCircleOneDrawCircleStartPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeOne.end);
    var poincareOuterCircleOneDrawCircleEndPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeTwo.begin);

    var poincareOuterTwoRange = _getPoincareCircleRange(
        poincareOuterCircleTwo, outerRangeTwo.end, outerRangeOne.begin);

    var poincareOuterCircleTwoDrawCircleStartPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeTwo.end);
    var poincareOuterCircleTwoDrawCircleEndPoint =
      this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeOne.begin);

    if ((poincareOuterOneRange.length as double) > PI) {
      poincareOuterOneRange.begin += MathFunc.PITwice;
    }

    if ((poincareOuterTwoRange.length as double) > PI) {
      poincareOuterTwoRange.begin += MathFunc.PITwice;
    }


    this._lines[0] = new LineGeom(LineType.poincare,
      this._diagram, poincareCircleOne, poincareOneRange,
      poincareCircleOneDrawCircleStartPoint,
      poincareCircleOneDrawCircleEndPoint
    );

    this._lines[1] = new LineGeom(LineType.poincare,
        this._diagram, poincareCircleTwo, poincareTwoRange,
        poincareCircleTwoDrawCircleStartPoint,
        poincareCircleTwoDrawCircleEndPoint
    );

    this._lines[2] = new LineGeom(LineType.simple,
      this._diagram, this._diagram.lineOuterDrawCircle, rangeOne
    );

    this._lines[3] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.lineOuterDrawCircle, rangeTwo
    );

    this._lines[4] = new LineGeom(LineType.poincare,
        this._diagram, poincareOuterCircleOne, poincareOuterOneRange,
        poincareOuterCircleOneDrawCircleStartPoint,
        poincareOuterCircleOneDrawCircleEndPoint
    );

    this._lines[5] = new LineGeom(LineType.poincare,
        this._diagram, poincareOuterCircleTwo, poincareOuterTwoRange,
        poincareOuterCircleTwoDrawCircleStartPoint,
        poincareOuterCircleTwoDrawCircleEndPoint
    );

    this._lines[6] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, outerRangeOne);

    this._lines[7] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, outerRangeTwo);
  }

  ShapePoincare.fromDivideData(this._diagram,
      RangeMath<double> rangeOne,
      RangeMath<double> rangeTwo,
      SimpleCircle<HomogeneousCoordinate> circleOne,
      SimpleCircle<HomogeneousCoordinate> circleTwo,
      [this._parent = null, String key = "",
      this._is3D = false, double this.shapeHeight = 10.0]) : super._(){

    throw new UnimplementedError("Unimplemented constructor for ShapePoincare");

    /*this._lines[0] = new LineGeom(LineType.poincare,
        this._diagram, circleOne, rangeOne
    );

    this._lines[1] = new LineGeom(LineType.poincare,
        this._diagram, circleTwo, rangeTwo
    );

    this._lines[2] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, rangeOne
    );

    this._lines[3] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, rangeTwo
    );*/
  }

  RangeMath<double> _getPoincareCircleRange(
      SimpleCircle poincareCircle, double angleOne, double angleTwo){
    var poincarePointBegin =
      this._diagram.drawCircle.getPointFromPolarCoordinate(angleOne);
    var poincarePointEnd =
      this._diagram.drawCircle.getPointFromPolarCoordinate(angleTwo);

    var poincareRange = new NumberRange.fromNumbers(
        poincareCircle.getPointPolarCoordinate(poincarePointBegin).angle,
        poincareCircle.getPointPolarCoordinate(poincarePointEnd).angle
    );

    return poincareRange;
  }

  SimpleCircle<HomogeneousCoordinate> _getPoincareCircle(
      double angleOne, double angleTwo){
    return MathHomogeneous.getPoincareCircle(
        this._diagram.baseCircle,
        this._diagram.drawCircle.getPointFromPolarCoordinate(angleOne),
        this._diagram.drawCircle.getPointFromPolarCoordinate(angleTwo));
  }

  void modifyGeometry(RangeMath<double> rangeA, RangeMath<double> rangeB,
      [ShapeForm parent = null, String key = "",
      bool is3D = false, double height = 10.0,
        RangeMath<double> textRange, int value, RangeMath<double> blockRange, RangeMath<double> blockRange2]) {

    //TODO unnecessary reinitialization

    if(parent != null){
      this.parent.children.remove(key);
      this._parent = parent;
      this._parent.setChild(this, key);
    }

    var rangeOne = rangeA;
    var rangeTwo = rangeB;

    var poincareCircleOne = _getPoincareCircle(rangeOne.end, rangeTwo.begin);
    var poincareCircleTwo = _getPoincareCircle(rangeTwo.end, rangeOne.begin);

    var poincareOneRange = _getPoincareCircleRange(
        poincareCircleOne, rangeOne.end, rangeTwo.begin);

    var poincareCircleOneDrawCircleStartPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(rangeOne.end);
    var poincareCircleOneDrawCircleEndPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(rangeTwo.begin);

    var poincareTwoRange = _getPoincareCircleRange(
        poincareCircleTwo, rangeTwo.end, rangeOne.begin);

    var poincareCircleTwoDrawCircleStartPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(rangeTwo.end);
    var poincareCircleTwoDrawCircleEndPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(rangeOne.begin);

    if ((poincareOneRange.length as double) > PI) {
      poincareOneRange.begin += MathFunc.PITwice;
    }

    if ((poincareTwoRange.length as double) > PI) {
      poincareTwoRange.begin += MathFunc.PITwice;
    }

    var lineArcWidth = this._diagram.getLineWidthArc(
        this._diagram.lineSegmentCircle);

    var outerRangeOne = new NumberRange.fromNumbers(
        rangeOne.begin + lineArcWidth,
        rangeOne.end - lineArcWidth);

    var outerRangeTwo = new NumberRange.fromNumbers(
        rangeTwo.begin + lineArcWidth,
        rangeTwo.end - lineArcWidth);

    var poincareOuterCircleOne = _getPoincareCircle(outerRangeOne.end, outerRangeTwo.begin);
    var poincareOuterCircleTwo = _getPoincareCircle(outerRangeTwo.end, outerRangeOne.begin);

    var poincareOuterOneRange = _getPoincareCircleRange(
        poincareOuterCircleOne, outerRangeOne.end, outerRangeTwo.begin);

    var poincareOuterCircleOneDrawCircleStartPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeOne.end);
    var poincareOuterCircleOneDrawCircleEndPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeTwo.begin);

    var poincareOuterTwoRange = _getPoincareCircleRange(
        poincareOuterCircleTwo, outerRangeTwo.end, outerRangeOne.begin);

    var poincareOuterCircleTwoDrawCircleStartPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeTwo.end);
    var poincareOuterCircleTwoDrawCircleEndPoint =
    this._diagram.drawCircle.getPointFromPolarCoordinate(outerRangeOne.begin);

    if ((poincareOuterOneRange.length as double) > PI) {
      poincareOuterOneRange.begin += MathFunc.PITwice;
    }

    if ((poincareOuterTwoRange.length as double) > PI) {
      poincareOuterTwoRange.begin += MathFunc.PITwice;
    }


    this._lines[0] = new LineGeom(LineType.poincare,
        this._diagram, poincareCircleOne, poincareOneRange,
        poincareCircleOneDrawCircleStartPoint,
        poincareCircleOneDrawCircleEndPoint
    );

    this._lines[1] = new LineGeom(LineType.poincare,
        this._diagram, poincareCircleTwo, poincareTwoRange,
        poincareCircleTwoDrawCircleStartPoint,
        poincareCircleTwoDrawCircleEndPoint
    );

    this._lines[2] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.lineOuterDrawCircle, rangeOne
    );

    this._lines[3] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.lineOuterDrawCircle, rangeTwo
    );

    this._lines[4] = new LineGeom(LineType.poincare,
        this._diagram, poincareOuterCircleOne, poincareOuterOneRange,
        poincareOuterCircleOneDrawCircleStartPoint,
        poincareOuterCircleOneDrawCircleEndPoint
    );

    this._lines[5] = new LineGeom(LineType.poincare,
        this._diagram, poincareOuterCircleTwo, poincareOuterTwoRange,
        poincareOuterCircleTwoDrawCircleStartPoint,
        poincareOuterCircleTwoDrawCircleEndPoint
    );

    this._lines[6] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, outerRangeOne);

    this._lines[7] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, outerRangeTwo);

  }

  void setChild(ShapeForm child, String ID) {
    this._children[ID] = child;
  }

  ShapeForm get parent {
    return this._parent;
  }

  Map<String, ShapeForm> get children {
    return this._children;
  }

  ShapeForm getChildByID(String ID) {
    return this._children[ID];
  }

  bool get isDrawable => this._isDrawable;

  set isDrawable(bool value) {
    this._isDrawable = value;
  }

  List<HomogeneousCoordinate> _addUniquePointToList(
      List<HomogeneousCoordinate> toAdd,
      List<HomogeneousCoordinate> fromAdd){

    for (HomogeneousCoordinate coordinate in fromAdd) {
        if (!toAdd.contains(coordinate)) {
          toAdd.add(coordinate);
        }
    }
    return toAdd;
  }

  List<List<double>> generatePointData() {
    var result = new List<double>();

    var shapeDistinctPoint = new List<HomogeneousCoordinate>();

    if(this.parent == null){
      var firstDiagramSidePoints  = this._lines[2].getLinePoints();
      var firstPoincareSidePoints = this._lines[0].getLinePoints();
      var secondDiagramSidePoints  = this._lines[3].getLinePoints();
      var secondPoincareSidePoints = this._lines[1].getLinePoints();

      shapeDistinctPoint.addAll(firstDiagramSidePoints);

      _addUniquePointToList(shapeDistinctPoint, firstPoincareSidePoints);
      _addUniquePointToList(shapeDistinctPoint, secondDiagramSidePoints);
      _addUniquePointToList(shapeDistinctPoint, secondPoincareSidePoints);

    }else{
      throw new UnimplementedError("not sure what are we want to doing here");
    }

    shapeDistinctPoint.forEach((HomogeneousCoordinate coordinate) {
      result.addAll(coordinate.listOfCoordinate);
    });

    return [result];
  }

  List<List<double>> generateOuterLinePointData(){
        throw new UnimplementedError("Not implemented yet");
  }

  bool pointIsInShape(HomogeneousCoordinate point) {
    if (!this._diagram.drawCircle.isPointInCircle(point)) return false;

    var circles = this._circleInCircle;

    if (circles.length > 0) {
      return circles.first.isPointInCircle(point) &&
          !circles.last.isPointInCircle(point);
    } else {
      return !this._lines.first.circle.isPointInCircle(point) &&
          !this._lines.last.circle.isPointInCircle(point);
    }
  }

  List<SimpleCircle> get _circleInCircle {
    if(this._lines.first.circle.isCircleInCircle(this._lines.last.circle as SimpleCircle<HomogeneousCoordinate<Vector3>>)){
      return [this._lines.first.circle, this._lines.last.circle];
    }else if(this._lines.last.circle.isCircleInCircle(this._lines.first.circle as SimpleCircle<HomogeneousCoordinate<Vector3>>)){
      return [this._lines.last.circle, this._lines.first.circle];
    }
    return [];
  }

  void switchShape(ShapeForm other) {
    throw new UnimplementedError("need new implementation");
  }

  int compare(Comparable a, Comparable b) {
    return a.compareTo(b);
  }

  int compareTo(ShapeForm other) {
    var result = this._differenceOfInnerAndOuterArc -
        (other as ShapePoincare)._differenceOfInnerAndOuterArc;

    if (result < 0) {
      return -1;
    } else if (result > 0) {
      return 1;
    }
    return 0;
  }

  double get _differenceOfInnerAndOuterArc{
    return (this._lines.first.lineArc.range.length -
        this._lines.last.lineArc.range.length).abs() as double;
  }

  List<List<PolarCoordinate<double, HomogeneousCoordinate>>> _divideShapeLines(List<double> values) {
    throw new UnimplementedError("not sure what are we want to doing here");
    /*var result = new List<List<PolarCoordinate<double, HomogeneousCoordinate>>>()
      ..add(this.listOfPoincareLine.first.divideLine(values,
          type: this._diagram.poincareLinesDivideType))
      ..add(this.listOfPoincareLine.last.divideLine(values,
          type: this._diagram.poincareLinesDivideType));

    return result;*/
  }

  Map<String, ShapeForm> dividedLinesPoint(Map<String, double> values) {
    throw new UnimplementedError("not sure what are we want to doing here");
    /*var dividePoints = this._divideShapeLines(new List.from(values.values));

    this._children = new Map<String, ShapeForm>();

    int index = 0;
    DataGeometry dataGeom;
    for (String key in values.keys) {

      RangeMath<double> rangeOne = new NumberRange.fromNumbers(
          dividePoints.first[index].angle, dividePoints.first[index + 1].angle);
      RangeMath<double> rangeTwo = new NumberRange.fromNumbers(
          dividePoints.last[index].angle, dividePoints.last[index + 1].angle);


      this._children[key] = new ShapePoincare.fromDivideData(
          this._diagram, rangeOne, rangeTwo,
          this._listOfPoincareLine.first.circle,
          this._listOfPoincareLine.last.circle
      ).._parent = this;

      index++;
    }

    return this._children;*/
  }

  List<int> getFaceMaterialIndices(int polygonFaceIndex){
    List<int> retVal = new List.generate(this._numberOfPolygonFaces, (_)=>polygonFaceIndex, growable: true);
    retVal.addAll(new List.generate(this._numberOfBorderFaces, (_)=>0));
    return retVal;
  }

  @override
  List<LineGeom<double, HomogeneousCoordinate>> get lines {
    return this._lines;
  }

  void _addLinesToList(List<Vector3> listToAdd, List<HomogeneousCoordinate> listFrom, [int begin = 0, int end = 0]){
    if(end == 0) end = listFrom.length;
    for(var i = begin; i < end; i++){
      listToAdd.add(new Vector3.array(listFrom[i].coordinate.storage as List<double>));
    }
  }

  @override
  List<Face3> generateFaceData() {
    if(_numberOfPolygonVertices == 0 || _polygonVerticesOffset == 0){
      throw new StateError("Probably the generated vertices are missing");
    }

    var vertexNormal = new Vector3(0.0, 0.0, 1.0);
    List<Vector3> vertexNormals = <Vector3>[vertexNormal, vertexNormal, vertexNormal];
    List<Color> vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

    var listOfFaces = new List<Face3>();
    for(var i = 0; i < this._numberOfPolygonLines - 1; i++){
      for(var j  = 0; j < this._polygonVerticesOffset - 1; j++){
        listOfFaces.add(new Face3Ext.withNormalsColors(
            ((i+1) * this._polygonVerticesOffset) + j, // Face first vertex
            ((i+1) * this._polygonVerticesOffset) + (j + 1), // Face second vertex
            (i * this._polygonVerticesOffset) + j, // Face third vertex
            vertexNormals, vertexColors
        ));
        listOfFaces.add(new Face3Ext.withNormalsColors(
            (i *  this._polygonVerticesOffset) + j,
            ((i+1) * this._polygonVerticesOffset) + (j + 1),
            (i * this._polygonVerticesOffset) + (j + 1),
            vertexNormals, vertexColors
        ));
      }
    }

    this._numberOfPolygonFaces = listOfFaces.length;

    vertexColors = <Color>[borderBaseColor, borderBaseColor, borderBaseColor];

    for(var i = 0; i < this._borderVerticesOffset - 1; i++){
      listOfFaces.add(new Face3Ext.withNormalsColors(
          this._numberOfPolygonVertices + (i + this._borderVerticesOffset), // Face first vertex
          this._numberOfPolygonVertices + i, // Face second vertex
          this._numberOfPolygonVertices + (i + this._borderVerticesOffset + 1), // Face third vertex
          vertexNormals, vertexColors
      ));
      listOfFaces.add(new Face3Ext.withNormalsColors(
          this._numberOfPolygonVertices + (i + this._borderVerticesOffset + 1),
          this._numberOfPolygonVertices + i,
          this._numberOfPolygonVertices + i + 1,
          vertexNormals, vertexColors
      ));
    }

    listOfFaces.add(new Face3Ext.withNormalsColors(
        this._numberOfPolygonVertices + (this._numberOfBorderVertices - 1), // Face first vertex
        this._numberOfPolygonVertices + (this._borderVerticesOffset - 1), // Face second vertex
        this._numberOfPolygonVertices + (this._borderVerticesOffset), // Face third vertex
        vertexNormals, vertexColors
    ));
    listOfFaces.add(new Face3Ext.withNormalsColors(
        this._numberOfPolygonVertices + (this._borderVerticesOffset),
        this._numberOfPolygonVertices + (this._borderVerticesOffset - 1),
        this._numberOfPolygonVertices,
        vertexNormals, vertexColors
    ));

    this._numberOfBorderFaces = listOfFaces.length - this._numberOfPolygonFaces;

    return listOfFaces;
  }

  @override
  List<Vector3> generatePolygonData() {

    var retVal = new List<Vector3>();

    var rangeOne = this._lines[2].lineArc.range;

    var rangeTwo = this._lines[3].lineArc.range;

    double numberOfVerticesOne = max<double>((rangeOne.length as double) * this._diagram.verticesPerRadian, 4.0);

    var resRangesOne = rangeOne.divideEqualParts(numberOfVerticesOne.toInt()-1, defaultSpaceBetweenParts: 0.0);

    var resRangesTwo = rangeTwo.divideEqualParts(numberOfVerticesOne.toInt()-1, defaultSpaceBetweenParts: 0.0);

    var length = resRangesTwo.length - 1;
    for(var i = 0; i <= resRangesTwo.length; i++){
      double start = 0.0;
      double end = 0.0;
      if(i == resRangesTwo.length){
        start = resRangesOne[i-1].end as double;
        end = resRangesTwo[length - (i - 1)].begin as double;
      }else{
        start = resRangesOne[i].begin as double;
        end = resRangesTwo[length - i].end as double;
      }

      var newLineRange = new NumberRange.fromNumbers(
          start,
          end
      );

      var midLinePoincareCircle = _getPoincareCircle(newLineRange.begin, newLineRange.end);

      var midLineRange = _getPoincareCircleRange(
          midLinePoincareCircle, newLineRange.begin, newLineRange.end);

      if ((midLineRange.length as double) > PI) {
        midLineRange.begin += MathFunc.PITwice;
      }

      var poincareCircleMidDrawCircleStartPoint =
        this._diagram.drawCircle.getPointFromPolarCoordinate(newLineRange.begin);
      var poincareCircleMidDrawCircleEndPoint =
        this._diagram.drawCircle.getPointFromPolarCoordinate(newLineRange.end);

      var newLine = new LineGeom(LineType.poincare,
          this._diagram, midLinePoincareCircle, midLineRange,
          poincareCircleMidDrawCircleStartPoint,
          poincareCircleMidDrawCircleEndPoint
      );

      _addLinesToList(retVal, newLine.getLinePoints());

      if(i == 0){
        this._polygonVerticesOffset = retVal.length;
      }
    }

    this._numberOfPolygonLines = resRangesTwo.length + 1;
    this._numberOfPolygonVertices = retVal.length;


    var firstDiagramSidePoints  = this._lines[2].getLinePoints();
    var firstPoincareSidePoints = this._lines[0].getLinePoints();
    var secondDiagramSidePoints  = this._lines[3].getLinePoints();
    var secondPoincareSidePoints = this._lines[1].getLinePoints();

    var firstDiagramSidePointsInner  = this._lines[6].getLinePoints(
        firstDiagramSidePoints.length);
    var firstPoincareSidePointsInner = this._lines[4].getLinePoints();
    var secondDiagramSidePointsInner  = this._lines[7].getLinePoints(
        secondDiagramSidePoints.length);
    var secondPoincareSidePointsInner = this._lines[5].getLinePoints();

    _addLinesToList(retVal, firstDiagramSidePoints, 0);
    _addLinesToList(retVal, firstPoincareSidePoints, 0);
    _addLinesToList(retVal, secondDiagramSidePoints, 0);
    _addLinesToList(retVal, secondPoincareSidePoints, 0);

    this._borderVerticesOffset = retVal.length - this._numberOfPolygonVertices;

    _addLinesToList(retVal, firstDiagramSidePointsInner, 0);
    _addLinesToList(retVal, firstPoincareSidePointsInner, 0);
    _addLinesToList(retVal, secondDiagramSidePointsInner, 0);
    _addLinesToList(retVal, secondPoincareSidePointsInner, 0);

    this._numberOfBorderVertices = retVal.length - this._numberOfPolygonVertices;

    return retVal;

  }
}
