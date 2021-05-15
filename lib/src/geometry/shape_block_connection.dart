part of visualizationGeometry;

class ShapeBlockConnection extends ShapeSimple {

  List<LineGeom<double, HomogeneousCoordinate>> _lines =
    new List<LineGeom<double, HomogeneousCoordinate>>();

  @Deprecated("Now")
  List<LineGeom<double, HomogeneousCoordinate>> _outerLines =
  new List<LineGeom<double, HomogeneousCoordinate>>();

  Diagram _diagram;

  bool _isDrawable = true;

  ShapeForm _parent;

  RangeMath<double> _innerRange;
  RangeMath<double> _innerInnerRange;

  bool _is3D = false;
  double _shapeHeight = 10.0;

  Color polygonBaseColor;
  Color borderBaseColor;
  Color connectionColor;

  int _numberOfPolygonVertices;
  int _polygonOffset;
  int _numberOfBorderVertices;
  int _borderOffset;
  int _numberOfDirectionVertices;
  int _directionOffset;
  int _numberOfDirectionVerticesLower;
  int _directionOffsetLower;

  int direction = 0;

  Map<String, ShapeForm> _children = new Map<String, ShapeForm>();

  ShapeBlockConnection(this._lines, this._diagram, [this._parent = null]) : super.empty();

  ShapeBlockConnection.fromData(this._diagram, RangeMath<double> range,
      RangeMath<double> radius, [this._parent = null, String key = "",
      this._is3D = false, this._shapeHeight = 10.0, this.direction = 0]) : super.empty(){

    var halfHeight = radius.length;

    this._innerRange = new NumberRange.fromNumbers(
        range.begin - 2*this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle),
        range.end + 2*this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle));

    this._innerInnerRange = new NumberRange.fromNumbers(
        this._innerRange.begin + this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle),
        this._innerRange.end - this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle));

    var segmentOuterCircle = this._diagram.outerSegmentCircle.clone()..radius -= this._diagram.lineWidth;

    var lineSegmentCircle = this._diagram.lineSegmentCircle.clone();

    lineSegmentCircle = this._diagram.segmentCircle.clone()
      ..radius -= (15.0 + this._diagram.lineWidth);


    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        this._diagram.directionCircle.clone()..radius += 3*this._diagram.lineWidth,
        range
    ));


    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        lineSegmentCircle,
        range
    ));

    //Inner side
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        this._diagram.directionCircle.clone(),
        this._innerRange
    ));

    //Outer side
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        lineSegmentCircle,
        this._innerRange
    ));

    if (this._parent != null) {
      this._parent.setChild(this, key);
    }
  }

  void modifyGeometry(RangeMath<double> rangeA, RangeMath<double> rangeB,
      [ShapeForm parent = null, String key = "",
      bool is3d = false, double height = 10.0,
        RangeMath<double> textRange, int value, RangeMath<double> blockRange, RangeMath<double> blockRange2]) {

      var halfHeight = rangeB.length;

      if(parent != null){
        this.parent.children.remove(key);
        this._parent = parent;
        this._parent.setChild(this, key);
      }

      this._is3D = is3d;
      this._shapeHeight = height;

      this._innerRange = new NumberRange.fromNumbers(
          rangeA.begin - 2*this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle),
          rangeA.end + 2*this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle));

      var lineSegmentCircleRadius = this._diagram.segmentCircle.clone().radius -= (15.0 + this._diagram.lineWidth);


      //segmentOuterCircleRadius += halfHeight;

      this._lines[2].lineArc.range = this._innerRange;
      //this._lines[0].lineArc.circle.radius = this._diagram.lineSegmentCircle.radius - halfHeight;

      this._lines[3].lineArc.range = this._innerRange;
      this._lines[3].lineArc.circle.radius = lineSegmentCircleRadius;


      this._lines[0].lineArc.range = rangeA;
      //this._lines[2].lineArc.circle.radius = this._diagram.segmentCircle.radius - halfHeight;

      this._lines[1].lineArc.range = rangeA;
      this._lines[1].lineArc.circle.radius = lineSegmentCircleRadius;

  }

  List<Vector3> generatePolygonData(){

    var retVal = new List<Vector3>();

    _addLinesToList(retVal, this._lines[3].getLinePoints());
    this._borderOffset = retVal.length;
    _addLinesToList(retVal, this._lines[2].getLinePoints(this._borderOffset).reversed.toList());
    this._numberOfBorderVertices = retVal.length;

    _addLinesToList(retVal, this._lines[1].getLinePoints(this._borderOffset));
    this._polygonOffset = retVal.length - this._numberOfBorderVertices;
    _addLinesToList(retVal, this._lines[0].getLinePoints(this._borderOffset).reversed.toList());
    this._numberOfPolygonVertices = retVal.length - this._numberOfBorderVertices;

    return retVal;
  }

  void _addLinesToList(List<Vector3> listToAdd, List<HomogeneousCoordinate> listFrom, [int begin = 0, int end = 0]){
    if(end == 0) end = listFrom.length;
    for(var i = begin; i < end; i++){
      listToAdd.add(new Vector3.array(listFrom[i].coordinate.storage as List<double>));
    }
  }

  List<Face3> generateFaceData(){
    if(_numberOfPolygonVertices == 0 || _polygonOffset == 0){
      throw new StateError("Probably the generated vertices are missing");
    }

    var vertexNormal = new Vector3(0.0, 0.0, 1.0);
    List<Vector3> vertexNormals = <Vector3>[vertexNormal, vertexNormal, vertexNormal];
    List<Color> vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

    var listOfFaces = new List<Face3>();

    bool changeColor = false;
    int prevColor = 0;
    for(var i = 0; i < this._polygonOffset - 1; i++){
      /*if(i % 5 == 0 && i != 0){
        if(prevColor == 1){
          vertexColors = <Color>[borderBaseColor, borderBaseColor, borderBaseColor];
        }else{
          vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];
        }
      }*/
      listOfFaces.add(new Face3Ext.withNormalsColors(
          this._numberOfBorderVertices + ((this._numberOfPolygonVertices - 1) - i),     // Face first vertex
          this._numberOfBorderVertices + i,                                    // Face second vertex
          this._numberOfBorderVertices + ((this._numberOfPolygonVertices  - 1)- (i + 1)),  // Face third vertex
          vertexNormals, vertexColors
      ));
      listOfFaces.add(new Face3Ext.withNormalsColors(
          this._numberOfBorderVertices + ((this._numberOfPolygonVertices - 1) - (i + 1)),
          this._numberOfBorderVertices + i,
          this._numberOfBorderVertices + i + 1,
          vertexNormals, vertexColors
      ));
    }

    // Contour faces

    vertexColors = <Color>[borderBaseColor, borderBaseColor, borderBaseColor];
    for(var i = this._borderOffset-1; i < this._numberOfPolygonVertices - 1; i++){
      listOfFaces.add(new Face3Ext.withNormalsColors(
          i + this._numberOfBorderVertices, // Face first vertex
          i, // Face second vertex
          i + this._numberOfBorderVertices + 1, // Face third vertex
          vertexNormals, vertexColors
      ));
      listOfFaces.add(new Face3Ext.withNormalsColors(
          i + this._numberOfBorderVertices + 1,
          i,
          i + 1,
          vertexNormals, vertexColors
      ));


    }

    listOfFaces.add(new Face3Ext.withNormalsColors(
        (this._numberOfBorderVertices + this._numberOfPolygonVertices) - 1, // Face first vertex
        this._numberOfBorderVertices - 1, // Face second vertex
        this._numberOfBorderVertices, // Face third vertex
        vertexNormals, vertexColors
    ));
    listOfFaces.add(new Face3Ext.withNormalsColors(
        this._numberOfBorderVertices,
        this._numberOfBorderVertices - 1,
        0,
        vertexNormals, vertexColors
    ));

    return listOfFaces;
  }

  bool pointIsInShape(HomogeneousCoordinate point) {
    return this._lines.first.lineArc.isPointInRange(point);
  }

  void switchShape(ShapeForm other) {
    throw new UnimplementedError("I dont not use this method");
  }

  int compare(Comparable a, Comparable b) {
    return a.compareTo(b);
  }

  int compareTo(ShapeForm other) {
    return this._lines.first.lineArc
        .compareTo(other.lines.first.lineArc);
  }

  List<List<PolarCoordinate>> _divideShapeLines(List<double> values) {
    var dividePoints = new List<List<PolarCoordinate>>(2);

    List<RangeMath<double>> ranges =
        this._lines.first.lineArc.range.dividePartsByValue(values);

    dividePoints[0] = new List<PolarCoordinate>();
    dividePoints[1] = new List<PolarCoordinate>();

    dividePoints.first.add(this._lines.first.lineArc.beginPolarCoordinate);

    for (RangeMath<double> range in ranges) {
      dividePoints.first.add(new CoordinatePolar(
          dividePoints.first.last.angle + (range.length as double),
          this._lines.first.lineArc.circle));
    }

    dividePoints.last.add(this._lines.last.lineArc.beginPolarCoordinate);
    for (RangeMath<double> range in ranges) {
      dividePoints.last.add(new CoordinatePolar(
          dividePoints.last.last.angle + (range.length as double),
          this._lines.last.lineArc.circle));
    }

    dividePoints.first.removeAt(0);
    dividePoints.last.removeAt(0);

    return dividePoints;
  }

  Map<String, ShapeForm> dividedLinesPoint(Map<String, double> values) {
    /*var result = new List<List<HomogeneousCoordinate>>();

    var dividePoints = this._divideShapeLines(values);

    var arc =
        new Arc2D(new NumberRange(), this._diagram.baseCircle, this._diagram);

    for (var i = 0; i < dividePoints.first.length; i++) {
      arc.begin = dividePoints.first[i].angle;
      arc.end = dividePoints.last[i].angle;
      result.add(arc.listOfPoints);
    }

    //return result;*/
    throw new UnimplementedError("Under refactor");
  }

  @override
  List<LineGeom<double, HomogeneousCoordinate>> get lines {
    return this._lines;
  }
}
