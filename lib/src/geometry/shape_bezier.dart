part of visualizationGeometry;

class ShapeBezier implements ShapeForm {
  List<LineGeom<double, HomogeneousCoordinate>> _lines =
    new List<LineGeom<double, HomogeneousCoordinate>>(8);

  Diagram _diagram;

  bool _isDrawable = true;

  List<LineGeom> get _listOfBezierLine{
    return [_lines[0], _lines[1]];
  }

  int _numberOfPolygonFaces;
  int _numberOfBorderFaces;

  int _numberOfPolygonVertices = 0;
  int _polygonVerticesOffset = 0;
  int _numberOfPolygonLines = 0;

  int _numberOfBorderVertices = 0;
  int _borderVerticesOffset = 0;

  Color polygonBaseColor;
  Color borderBaseColor;

  ShapeForm _parent;

  Map<String, ShapeForm> _children;

  bool _is3D = false;
  double shapeHeight = 10.0;

  ShapeBezier(this._lines, this._diagram) {}

  ShapeBezier.fromData(this._diagram,
      RangeMath<double> rangeOne,
      RangeMath<double> rangeTwo,
      [this._parent = null, String key = "",
      this._is3D = false, this.shapeHeight = 10.0]) {

    var lineArcWidth = this._diagram.getLineWidthArc(
        this._diagram.lineSegmentCircle);

    var outerRangeOne = new NumberRange.fromNumbers(
        rangeOne.begin + lineArcWidth,
        rangeOne.end - lineArcWidth);
    var outerRangeTwo = new NumberRange.fromNumbers(
        rangeTwo.begin + lineArcWidth,
        rangeTwo.end - lineArcWidth);

    var firstInnerSideRange = new NumberRange.fromNumbers(
        outerRangeOne.end,
        outerRangeTwo.begin
    );

    var firstSideRange = new NumberRange.fromNumbers(
      rangeOne.end, rangeTwo.begin
    );

    var secondInnerSideRange = new NumberRange.fromNumbers(
        outerRangeTwo.end,
        outerRangeOne.begin
    );

    var secondSideRange = new NumberRange.fromNumbers(
      rangeTwo.end, rangeOne.begin
    );

    this._lines[0] = new LineGeom(LineType.bezier,
      this._diagram, this._diagram.drawCircle, firstSideRange);

    this._lines[1] = new LineGeom(LineType.bezier,
        this._diagram, this._diagram.drawCircle, secondSideRange);

    this._lines[2] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, rangeOne);

    this._lines[3] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.drawCircle, rangeTwo);


    this._lines[4] = new LineGeom(LineType.bezier,
        this._diagram, this._diagram.lineOuterDrawCircle, firstInnerSideRange);

    this._lines[5] = new LineGeom(LineType.bezier,
        this._diagram, this._diagram.lineOuterDrawCircle, secondInnerSideRange);

    this._lines[6] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.lineOuterDrawCircle, outerRangeOne);

    this._lines[7] = new LineGeom(LineType.simple,
        this._diagram, this._diagram.lineOuterDrawCircle, outerRangeTwo);

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

  @override
  List<List<double>> generatePointData() {
    var result = new List<double>();

    var shapeDistinctPoint = new List<HomogeneousCoordinate>();

    if(this.parent == null || this.parent is ShapeSimple){
      var firstDiagramSidePoints  = this._lines[6].getLinePoints();
      var firstPoincareSidePoints = this._lines[4].getLinePoints();
      var secondDiagramSidePoints  = this._lines[7].getLinePoints();
      var secondPoincareSidePoints = this._lines[5].getLinePoints();

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

  List<Vector3> generatePolygonData(){

    var retVal = new List<Vector3>();

    /*var collectPoints = new List<List<Vector3>>();
    _addHCoordinateAsVectorToTheList(collectPoints, this._lines[6].linePoints.reversed.toList());

    var length = collectPoints.last.length;

    var firstPoincareSidePoints = this._lines[4].linePoints;
    var lastPoincareSidePoints = this._lines[5].linePoints.reversed.toList();

    for(var i = 1; i < this._diagram.lineSegment-1; i++){
      var line = new SegmentLine<Vector3>.fromTwoHPoint(
          new HCoordinate2D(firstPoincareSidePoints[i].getDescartesCoordinate() as Vector3),
          new HCoordinate2D(lastPoincareSidePoints[i].getDescartesCoordinate() as Vector3)
      );
      var linePoints = line.divideLine(length);
      _addHCoordinateAsVectorToTheList(collectPoints, linePoints);
    }
    _addHCoordinateAsVectorToTheList(collectPoints, this._lines[7].linePoints);*/


    /*for(var j = 0; j < length; j++) {
      retVal.add(new List<Vector3>());
      for (var i = 0; i < collectPoints.length; i++) {
        retVal.last.add(collectPoints[i][j]);
      }
    }*/

    var rangeOne = this._lines[6].lineArc.range;

    var rangeTwo = this._lines[7].lineArc.range;

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

      var newLine = new LineGeom(LineType.bezier,
          this._diagram, this._diagram.lineOuterDrawCircle, newLineRange);

      _addLinesToList(retVal, newLine.getLinePoints());

      if(i == 0){
        this._polygonVerticesOffset = retVal.length;
      }
    }

    this._numberOfPolygonLines = resRangesTwo.length + 1;
    this._numberOfPolygonVertices = retVal.length;


    //TODO add list directly to the getLinePoints function, and this will add the point directly to the list instead of creating list
    //Add border points
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

    _addLinesToList(retVal, firstDiagramSidePoints, 1);
    _addLinesToList(retVal, firstPoincareSidePoints, 1);
    _addLinesToList(retVal, secondDiagramSidePoints, 1);
    _addLinesToList(retVal, secondPoincareSidePoints, 1);

    this._borderVerticesOffset = retVal.length - this._numberOfPolygonVertices;

    _addLinesToList(retVal, firstDiagramSidePointsInner, 1);
    _addLinesToList(retVal, firstPoincareSidePointsInner, 1);
    _addLinesToList(retVal, secondDiagramSidePointsInner, 1);
    _addLinesToList(retVal, secondPoincareSidePointsInner, 1);

    this._numberOfBorderVertices = retVal.length - this._numberOfPolygonVertices;

    return retVal;
  }

  void _addLinesToList(List<Vector3> listToAdd, List<HomogeneousCoordinate> listFrom, [int begin = 0, int end = 0]){
    if(end == 0) end = listFrom.length;
    for(var i = begin; i < end; i++){
      listToAdd.add(new Vector3.array(listFrom[i].coordinate.storage as List<double>));
    }
  }

  List<int> getFaceMaterialIndices(int polygonFaceIndex){
    List<int> retVal = new List.generate(this._numberOfPolygonFaces, (_)=>polygonFaceIndex, growable: true);
    retVal.addAll(new List.generate(this._numberOfBorderFaces, (_)=>0));
    return retVal;
  }

  List<Face3> generateFaceData(){
    if(_numberOfPolygonVertices == 0 || _polygonVerticesOffset == 0){
      throw new StateError("Probably the generated vertices are missing");
    }

    var vertexNormal = new Vector3(0.0, 0.0, 1.0);
    List<Vector3> vertexNormals = <Vector3>[vertexNormal, vertexNormal, vertexNormal];
    List<Color> vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

    var listOfFaces = new List<Face3>();
    for(var i = 0; i < this._numberOfPolygonLines - 1; i++){
      for(var j  = 0; j < this._polygonVerticesOffset - 1; j++){
        listOfFaces.add(new Face3(
          ((i+1) * this._polygonVerticesOffset) + j, // Face first vertex
          ((i+1) * this._polygonVerticesOffset) + (j + 1), // Face second vertex
          (i * this._polygonVerticesOffset) + j, // Face third vertex
          vertexNormals, vertexColors
        ));
        listOfFaces.add(new Face3(
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
      listOfFaces.add(new Face3(
          this._numberOfPolygonVertices + (i + this._borderVerticesOffset), // Face first vertex
          this._numberOfPolygonVertices + i, // Face second vertex
          this._numberOfPolygonVertices + (i + this._borderVerticesOffset + 1), // Face third vertex
          vertexNormals, vertexColors
      ));
      listOfFaces.add(new Face3(
          this._numberOfPolygonVertices + (i + this._borderVerticesOffset + 1),
          this._numberOfPolygonVertices + i,
          this._numberOfPolygonVertices + i + 1,
          vertexNormals, vertexColors
      ));
    }

    listOfFaces.add(new Face3(
        this._numberOfPolygonVertices + (this._numberOfBorderVertices - 1), // Face first vertex
        this._numberOfPolygonVertices + (this._borderVerticesOffset - 1), // Face second vertex
        this._numberOfPolygonVertices + (this._borderVerticesOffset), // Face third vertex
        vertexNormals, vertexColors
    ));
    listOfFaces.add(new Face3(
        this._numberOfPolygonVertices + (this._borderVerticesOffset),
        this._numberOfPolygonVertices + (this._borderVerticesOffset - 1),
        this._numberOfPolygonVertices,
        vertexNormals, vertexColors
    ));

    this._numberOfBorderFaces = listOfFaces.length - this._numberOfPolygonFaces;

    return listOfFaces;
  }

  List<List<double>> generateOuterLinePointData() {
    var result = new List<double>();

    var shapeDistinctPoint = new List<HomogeneousCoordinate>();

    if(this.parent == null || this.parent is ShapeSimple){
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


  @override
  bool pointIsInShape(HomogeneousCoordinate point) {
    throw new UnimplementedError("Under refactor");
  }

  @override
  void switchShape(ShapeForm other) {
    throw new UnimplementedError("Under refactor");
  }

  @override
  void modifyGeometry(List<RangeMath<double>> ranges,
      List<SimpleCircle<HomogeneousCoordinate>> circles,
      [ShapeForm parent = null, String key = "",
      bool is3D = false, double height = 10.0]) {

    var rangeOne = ranges.first;
    var rangeTwo = ranges.last;

    var firstSideRange = new NumberRange.fromNumbers(
        rangeOne.end, rangeTwo.begin
    );

    var secondSideRange = new NumberRange.fromNumbers(
        rangeTwo.end, rangeOne.begin
    );

    var lineArcWidth = this._diagram.getLineWidthArc(
        this._diagram.lineSegmentCircle);

    var outerRangeOne = new NumberRange.fromNumbers(
        rangeOne.begin + lineArcWidth,
        rangeOne.end - lineArcWidth);
    var outerRangeTwo = new NumberRange.fromNumbers(
        rangeTwo.begin + lineArcWidth,
        rangeTwo.end - lineArcWidth);

    var firstInnerSideRange = new NumberRange.fromNumbers(
        outerRangeOne.end,
        outerRangeTwo.begin
    );

    var secondInnerSideRange = new NumberRange.fromNumbers(
        outerRangeTwo.end,
        outerRangeOne.begin
    );

    this._lines[0].lineArc.range =  firstSideRange;

    this._lines[1].lineArc.range = secondSideRange;

    this._lines[2].lineArc.range =  rangeOne;

    this._lines[3].lineArc.range = rangeTwo;

    this._lines[4].lineArc.range =  firstInnerSideRange;

    this._lines[5].lineArc.range = secondInnerSideRange;

    this._lines[6].lineArc.range =  outerRangeOne;

    this._lines[7].lineArc.range = outerRangeTwo;

    this._lines[0].update();
    this._lines[1].update();

    this._lines[4].update();
    this._lines[5].update();


  }

  @override
  ShapeForm get parent {
    return this._parent;
  }

  @override
  void setChild(ShapeForm child, String ID) {
    this._children[ID] = child;
  }

  @override
  Map<String, ShapeForm> dividedLinesPoint(Map<String, double> values) {
    throw new UnimplementedError("Under refactor");
  }

  @override
  int compareTo(ShapeForm other) {
    throw new UnimplementedError("Under refactor");
  }

  @override
  bool get isDrawable => this._isDrawable;

  @override
  set isDrawable(bool value){
    this._isDrawable = value;
  }

  @override
  ShapeForm getChildByID(String ID) {
    return this._children[ID];
  }

  @override
  Map<String, ShapeForm> get children {
    return this._children;
  }

  @override
  List<LineGeom<double, HomogeneousCoordinate>> get lines => this._lines;


}