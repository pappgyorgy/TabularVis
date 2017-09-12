part of visualizationGeometry;

class ShapeSimple implements ShapeForm {

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

  int _direction = 0;

  Map<String, ShapeForm> _children = new Map<String, ShapeForm>();

  ShapeSimple(this._lines, this._diagram, [this._parent = null]);

  ShapeSimple.fromData(this._diagram, RangeMath<double> range,
      RangeMath<double> radius, [this._parent = null, String key = "",
      this._is3D = false, this._shapeHeight = 10.0, this._direction = 0]){


    this._innerRange = new NumberRange.fromNumbers(
        range.begin + this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle),
        range.end - this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle));

    this._innerInnerRange = new NumberRange.fromNumbers(
        this._innerRange.begin + this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle),
        this._innerRange.end - this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle));

    var segmentOuterCircle = this._diagram.outerSegmentCircle.clone();

    var lineSegmentCircle = this._diagram.lineOuterSegmentCircle.clone();

    if(this._diagram.wayToCreateSegments
        == MatrixValueRepresentation.segmentsHeight || true) {
      if (radius != null && radius.length != null) {
        var radiusUnitValue = this._diagram.maxSegmentRadius /
            this._diagram.maxValue;

        var segmentOuterCircleRadius = (radius.length as double) *
            radiusUnitValue;

        segmentOuterCircle = this._diagram.segmentCircle.clone()
          ..radius += segmentOuterCircleRadius;
        lineSegmentCircle = this._diagram.lineSegmentCircle.clone()
          ..radius += segmentOuterCircleRadius;
      }
    }

    //Inner side black line
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        this._diagram.lineSegmentCircle,
        this._innerRange
    ));

    //Outer side black line
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        lineSegmentCircle,
        this._innerRange
    ));

    //Inner side
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        this._diagram.segmentCircle,
        range
    ));

    //Outer side
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        segmentOuterCircle,
        range
    ));

    //directions outer side between the segments
    if(this._direction == 2 || this._direction == 0){
      this._lines.add(new LineGeom(
          LineType.simple,
          this._diagram,
          this._diagram.directionCircle,
          this._innerRange
      ));
    }else{
      this._lines.add(new LineGeom(
          LineType.simple,
          this._diagram,
          this._diagram.directionCircle,
          this._innerInnerRange
      ));
    }

    //directions outer side line between the segments
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        this._diagram.directionOuterLineCircle.clone(),
        range
    ));

    if(this._direction == 0){
      //No direction shape inner
      this._lines.add(new LineGeom(
          LineType.simple,
          this._diagram,
          this._diagram.directionLowerCircle.clone(),
          _innerRange
      ));


      //No direction shape lowerShapeOuter
      this._lines.add(new LineGeom(
          LineType.simple,
          this._diagram,
          this._diagram.directionLowerCircle.clone()..radius -= this._diagram.lineWidth,
          range
      ));
    }

    if (this._parent != null) {
      this._parent.setChild(this, key);
    }
  }

  void modifyGeometry(List<RangeMath<double>> ranges,
      List<SimpleCircle<HomogeneousCoordinate>> circles,
      [ShapeForm parent = null, String key = "",
      bool is3d = false, double height = 10.0]) {

      if(parent != null){
        this.parent.children.remove(key);
        this._parent = parent;
        this._parent.setChild(this, key);
      }

      this._is3D = is3d;
      this._shapeHeight = height;

      var segmentOuterCircleRadius = this._diagram.outerSegmentCircle.radius;

      if(this._diagram.wayToCreateSegments
          == MatrixValueRepresentation.segmentsHeight){
        var radius = ranges.last;

        if(radius != null && radius.length != null){
          var radiusUnitValue = this._diagram.maxSegmentRadius /
              this._diagram.maxValue;

          var segmentNewRadiusToAdd = (radius.length as double) * radiusUnitValue;

          segmentOuterCircleRadius = this._diagram.segmentCircle.radius + segmentNewRadiusToAdd;
        }
      }

      this._lines.first.lineArc.range = ranges.first;
      this._lines.last.lineArc.range = ranges.first;
      this._lines.last.circle.radius = segmentOuterCircleRadius;
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

  bool get isDrawable => this._isDrawable;

  set isDrawable(bool value){
    this._isDrawable = value;
  }

  ShapeForm getChildByID(String ID) {
    return this._children[ID];
  }

  List<List<double>> generatePointData() {
    var result = new List<double>();
    var lineOne = this._lines.first.getLinePoints();
    var lineTwo = this._lines.last.getLinePoints();

    //print("conn: ${lineOne.last} --- ${lineTwo.last}");

    for (HomogeneousCoordinate coordinate in lineOne) {
      result.addAll(coordinate.listOfCoordinate);
    }
    for (HomogeneousCoordinate coordinate in lineTwo.reversed) {
      result.addAll(coordinate.listOfCoordinate);
    }

    return [result];
  }

  List<List<double>> generateOuterLinePointData() {
    var result = new List<double>();
    var lineOne = this._outerLines.first.getLinePoints();
    var lineTwo = this._outerLines.last.getLinePoints();

    //print("conn: ${lineOne.last} --- ${lineTwo.last}");

    for (HomogeneousCoordinate coordinate in lineOne) {
      result.addAll(coordinate.listOfCoordinate);
    }
    for (HomogeneousCoordinate coordinate in lineTwo.reversed) {
      result.addAll(coordinate.listOfCoordinate);
    }

    return [result];
  }

  Vector3 _getDirectionMidPoint(int direction){
    var range = this._lines[2].lineArc.range;
    var directionMidPointAngle = range.begin +
        (range.direction * ((range.length as double) / 2));
    switch(direction){
      case 0:
          var point = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(directionMidPointAngle).coordinate.storage as List<double>)..z = 0.0;
          return point;
        break;
      case 2:
          var point = new Vector3.array(this._diagram.directionUpperCircle.getPointFromPolarCoordinate(directionMidPointAngle).coordinate.storage as List<double>)..z = 0.0;
          return point;
        break;
      case 1:
          var point = new Vector3.array(this._diagram.directionLowerCircle.getPointFromPolarCoordinate(directionMidPointAngle).coordinate.storage as List<double>)..z = 0.0;
          return point;
        break;
      default:
        throw new StateError("Wrong direction type");
    }
  }

  Vector3 getInnerPointFromContour(Vector3 a, Vector3 b, Vector3 c){

    var right = (a - b).normalize();
    var left = (c - b).normalize();
    var rotateVec = new Vector3(left.y, -left.x, 0.0).normalize();
    var midVec = (left + right).normalize();

    midVec = midVec * midVec.dot(rotateVec).sign;

    var g = acos(midVec.dot(right));
    var h = this._diagram.lineWidth / sin(g);

    return b + (midVec * h);

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

    _addLinesToList(retVal, this._lines[4].getLinePoints(this._borderOffset));
    this._directionOffset = retVal.length - (this._numberOfPolygonVertices + this._numberOfBorderVertices);

    _addLinesToList(retVal, this._lines[5].getLinePoints(this._borderOffset));
    this._numberOfDirectionVertices = retVal.length - (this._numberOfPolygonVertices + this._numberOfBorderVertices);

    var midPoint = this._getDirectionMidPoint(this._direction);

    var directionIndicatorHeight = this._diagram.directionCircle.radius - this._diagram.directionUpperCircle.radius;

    if(this._direction == 0){

      _addLinesToList(retVal, this._lines[6].getLinePoints(this._borderOffset).reversed.toList());
      this._directionOffsetLower = retVal.length - (this._numberOfDirectionVertices + this._numberOfPolygonVertices + this._numberOfBorderVertices);

      _addLinesToList(retVal, this._lines[7].getLinePoints(this._borderOffset).reversed.toList());
      this._numberOfDirectionVerticesLower = retVal.length - (this._numberOfDirectionVertices + this._numberOfPolygonVertices + this._numberOfBorderVertices);

    }if(this._direction == 1){

      var range = this._lines[2].lineArc.range;
      var circleForEnd = this._direction == 1 ? this._diagram.directionUpperCircle : this._diagram.directionLowerCircle;
      /*var beginPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>);
    var endPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>);*/
      var beginPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>)..z = 0.0;
      var endPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>)..z = 0.0;

      retVal.add(midPoint);
      retVal.add(endPoint);
      retVal.add(beginPoint);

      var newPoint2 = getInnerPointFromContour(beginPoint, midPoint, endPoint);
      var newPoint3 = getInnerPointFromContour(retVal[this._numberOfPolygonVertices + this._numberOfBorderVertices], beginPoint, midPoint);
      var newPoint4 = getInnerPointFromContour(midPoint, endPoint, retVal[this._numberOfPolygonVertices + this._numberOfBorderVertices + this._numberOfDirectionVertices - 1]);

      var circleForSecondEnd = circleForEnd.clone()..radius = 137.0;

      var modifiedDirectionIndicatorHeight = (directionIndicatorHeight) / (1 / (this._innerRange.length as double));

      if(modifiedDirectionIndicatorHeight > directionIndicatorHeight){
        modifiedDirectionIndicatorHeight = directionIndicatorHeight * 0.5;
      }

      if(modifiedDirectionIndicatorHeight < this._diagram.lineWidth){
        modifiedDirectionIndicatorHeight = this._diagram.lineWidth;
      }


      var listOfPoint = this._diagram.drawCircle.center.getDescartesCoordinate().storage;
      Vector3 middle = new Vector3(listOfPoint[0], listOfPoint[1], 0.0);
      var midPoint2 = ((newPoint2 - middle).normalize() * modifiedDirectionIndicatorHeight) + newPoint2;
      var newPoint5 = getInnerPointFromContour(beginPoint, midPoint2, endPoint);

      /*var innerInnerRange = this._lines[4].lineArc.range;
      innerInnerRange.begin += this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle);
      innerInnerRange.end -= this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle);*/

      var newPoint6 = new Vector3.array(this._diagram.directionOuterLineCircle.getPointFromPolarCoordinate(this._innerInnerRange.begin).coordinate.storage as List<double>)..z = 0.0;
      var newPoint7 = new Vector3.array(this._diagram.directionOuterLineCircle.getPointFromPolarCoordinate(this._innerInnerRange.end).coordinate.storage as List<double>)..z = 0.0;

      var newPoint8 = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(this._innerRange.begin).coordinate.storage as List<double>)..z = 0.0;
      var newPoint9 = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(this._innerRange.end).coordinate.storage as List<double>)..z = 0.0;

      retVal.add(newPoint2);
      retVal.add(newPoint3);
      retVal.add(newPoint4);
      retVal.add(midPoint2);
      retVal.add(newPoint5);
      retVal.add(newPoint6);
      retVal.add(newPoint7);
      retVal.add(newPoint8);
      retVal.add(newPoint9);

    }else if (this._direction == 2){

      var range = this._lines[2].lineArc.range;
      var circleForEnd = this._direction == 1 ? this._diagram.directionUpperCircle : this._diagram.directionLowerCircle;
      /*var beginPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>);
      var endPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>);*/
      var beginPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>)..z = 0.0;
      var endPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>)..z = 0.0;

      var listOfPoint = this._diagram.drawCircle.center.getDescartesCoordinate().storage;
      Vector3 middle = new Vector3(listOfPoint[0], listOfPoint[1], 0.0);
      midPoint = ((midPoint - middle).normalize() * ((directionIndicatorHeight*0.5) - this._diagram.lineWidth)) + midPoint;
      var midPoint2 = ((midPoint - middle).normalize() * ((-directionIndicatorHeight*0.5) - this._diagram.lineWidth)) + midPoint;

      retVal.add(midPoint);
      retVal.add(endPoint);
      retVal.add(beginPoint);

      var differenceBetweenDirectionAndUpperDirection = this._diagram.directionCircle.radius - this._diagram.directionUpperCircle.radius;
      var newPoint6 = ((beginPoint - middle).normalize() * (directionIndicatorHeight)) + beginPoint;
      var newPoint7 = ((endPoint - middle).normalize() * (directionIndicatorHeight)) + endPoint;

      var newPoint5 = getInnerPointFromContour(beginPoint, midPoint2, endPoint);

      var newPoint2 = getInnerPointFromContour(newPoint6, midPoint, newPoint7);
      var newPoint3 = getInnerPointFromContour(newPoint6, beginPoint, midPoint2);
      var newPoint4 = getInnerPointFromContour(midPoint2, endPoint, newPoint7);

      var newPoint8 = getInnerPointFromContour(midPoint, newPoint6, beginPoint);
      var newPoint9 = getInnerPointFromContour(endPoint, newPoint7, midPoint);

      var newPoint10 = getInnerPointFromContour(retVal[this._numberOfBorderVertices + this._numberOfPolygonVertices], newPoint6, newPoint2);
      var newPoint11 = getInnerPointFromContour(newPoint2, newPoint7, retVal[this._numberOfBorderVertices + this._numberOfPolygonVertices + this._directionOffset - 1]);


      retVal.add(newPoint2); // 3
      retVal.add(newPoint3);
      retVal.add(newPoint4); // 5
      retVal.add(midPoint2);
      retVal.add(newPoint5); // 7
      retVal.add(newPoint6);
      retVal.add(newPoint7); // 9
      retVal.add(newPoint8);
      retVal.add(newPoint9); // 11
      retVal.add(newPoint10);
      retVal.add(newPoint11); // 13

/// Direction indicated with triangle at top os the segments

      /*var range = this._lines[3].lineArc.range;
      var circleForMidPoint = this._lines[3].lineArc.circle.clone()..radius += 7.0;
      var directionMidPointAngle = range.begin +
          (range.direction * ((range.length as double) / 2));

      var midPoint = new Vector3.array(circleForMidPoint.getPointFromPolarCoordinate(directionMidPointAngle).coordinate.storage as List<double>)..z = 0.0;

      var circleForEnd = this._lines[3].lineArc.circle.clone()..radius += 2.0;
      /*var beginPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>);
    var endPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>);*/
      var beginPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>)..z = 0.0;
      var endPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>)..z = 0.0;

      retVal.add(midPoint);
      retVal.add(endPoint);
      retVal.add(beginPoint);

      var newPoint2 = getInnerPointFromContour(endPoint, midPoint, beginPoint);
      var newPoint3 = getInnerPointFromContour(midPoint, beginPoint, retVal[0]);
      var newPoint4 = getInnerPointFromContour(retVal[this._borderOffset-1], endPoint, midPoint);

      retVal.add(newPoint2);
      retVal.add(newPoint3);
      retVal.add(newPoint4);*/

/// Direction without indicates of the connections end comment out everything
      /*var range = this._lines[2].lineArc.range;
      var circleForEnd = this._direction == 1 ? this._diagram.directionUpperCircle : this._diagram.directionLowerCircle;
      /*var beginPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>);
    var endPoint = new Vector3.array(this._diagram.directionCircle.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>);*/
      var beginPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.begin).coordinate.storage as List<double>)..z = 0.0;
      var endPoint = new Vector3.array(circleForEnd.getPointFromPolarCoordinate(range.end).coordinate.storage as List<double>)..z = 0.0;

      retVal.add(midPoint);
      retVal.add(endPoint);
      retVal.add(beginPoint);

      var directionMidPointAngle = range.begin +
          (range.direction * ((range.length as double) / 2));

      var newPoint2 = getInnerPointFromContour(beginPoint, midPoint, endPoint);
      var newPoint3 = getInnerPointFromContour(retVal[this._numberOfBorderVertices-1], beginPoint, midPoint);
      var newPoint4 = getInnerPointFromContour(midPoint, endPoint, retVal[this._borderOffset]);

      var circleForSecondEnd = circleForEnd.clone()..radius = 142.0;
      var circleForThirdEnd = circleForEnd.clone()..radius = 137.0;

      var point = new Vector3.array(circleForSecondEnd.getPointFromPolarCoordinate(directionMidPointAngle).coordinate.storage as List<double>)..z = 0.0;

      var secondBeginPoint = new Vector3.array(circleForThirdEnd.getPointFromPolarCoordinate(this._innerRange.begin).coordinate.storage as List<double>)..z = 0.0;
      var secondEndPoint = new Vector3.array(circleForThirdEnd.getPointFromPolarCoordinate(this._innerRange.end).coordinate.storage as List<double>)..z = 0.0;

      retVal.add(newPoint2);
      retVal.add(newPoint3);
      retVal.add(newPoint4);*/
    }

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
      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + ((this._numberOfPolygonVertices - 1) - i),     // Face first vertex
          this._numberOfBorderVertices + i,                                    // Face second vertex
          this._numberOfBorderVertices + ((this._numberOfPolygonVertices  - 1)- (i + 1)),  // Face third vertex
          vertexNormals, vertexColors
      ));
      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + ((this._numberOfPolygonVertices - 1) - (i + 1)),
          this._numberOfBorderVertices + i,
          this._numberOfBorderVertices + i + 1,
          vertexNormals, vertexColors
      ));
    }

    // Contour faces

    vertexColors = <Color>[borderBaseColor, borderBaseColor, borderBaseColor];
    for(var i = 0; i < this._numberOfPolygonVertices - 1; i++){
      listOfFaces.add(new Face3(
          i + this._numberOfBorderVertices, // Face first vertex
          i, // Face second vertex
          i + this._numberOfBorderVertices + 1, // Face third vertex
          vertexNormals, vertexColors
      ));
      listOfFaces.add(new Face3(
          i + this._numberOfBorderVertices + 1,
          i,
          i + 1,
          vertexNormals, vertexColors
      ));


    }

    listOfFaces.add(new Face3(
        (this._numberOfBorderVertices + this._numberOfPolygonVertices) - 1, // Face first vertex
        this._numberOfBorderVertices - 1, // Face second vertex
        this._numberOfBorderVertices, // Face third vertex
        vertexNormals, vertexColors
    ));
    listOfFaces.add(new Face3(
        this._numberOfBorderVertices,
        this._numberOfBorderVertices - 1,
        0,
        vertexNormals, vertexColors
    ));

    //Direction faces

    var directionInnerStart = this._numberOfBorderVertices + this._numberOfPolygonVertices;
    var directionBorderStart = directionInnerStart + this._directionOffset;
    var directionShapePointsStart = directionInnerStart + this._numberOfDirectionVertices;

    if(this._direction == 0){

      /*listOfFaces.add(new Face3(
          directionBorderStart + (this._directionOffset + (this._numberOfDirectionVerticesLower - 1)),     // Face first vertex
          directionBorderStart,                                    // Face second vertex
          directionBorderStart + ((this._numberOfDirectionVerticesLower - 1) - 1),  // Face third vertex
          vertexNormals, vertexColors
      ));*/

      for(var i = 0; i < this._polygonOffset - 1; i++){
        listOfFaces.add(new Face3(
            directionBorderStart + (this._directionOffset + (this._numberOfDirectionVerticesLower - 1) - i),     // Face first vertex
            directionBorderStart + i,                                    // Face second vertex
            directionBorderStart + (this._directionOffset + (this._numberOfDirectionVerticesLower - 1) - (i+1)),  // Face third vertex
            vertexNormals, vertexColors
        ));
        listOfFaces.add(new Face3(
            directionBorderStart + (this._directionOffset + (this._numberOfDirectionVerticesLower - 1) - (i+1)),
            directionBorderStart + i,
            directionBorderStart + i + 1,
            vertexNormals, vertexColors
        ));
      }

      vertexColors = <Color>[connectionColor, connectionColor, connectionColor];

      for(var i = 0; i < this._polygonOffset - 1; i++){
        listOfFaces.add(new Face3(
            directionInnerStart + (this._directionOffset + (this._numberOfDirectionVerticesLower - 1) - i),     // Face first vertex
            directionInnerStart + i,                                    // Face second vertex
            directionInnerStart + (this._directionOffset + (this._numberOfDirectionVerticesLower - 1) - (i+1)),  // Face third vertex
            vertexNormals, vertexColors
        ));
        listOfFaces.add(new Face3(
            directionInnerStart + (this._directionOffset + (this._numberOfDirectionVerticesLower - 1) - (i+1)),
            directionInnerStart + i,
            directionInnerStart + i + 1,
            vertexNormals, vertexColors
        ));
      }

    }else if(this._direction == 1){

      // border

      listOfFaces.add(new Face3(
          directionShapePointsStart,
          directionShapePointsStart + 2,
          directionBorderStart,
          vertexNormals, vertexColors
      ));

      for(var i = directionBorderStart; i < directionShapePointsStart - 1; i++){
        listOfFaces.add(new Face3(
            directionShapePointsStart,
            i,
            i + 1,
            vertexNormals, vertexColors
        ));
      }

      listOfFaces.add(new Face3(
          directionShapePointsStart,
          directionShapePointsStart - 1,
          directionShapePointsStart + 1,
          vertexNormals, vertexColors
      ));

      // Inner triangle

      vertexColors = <Color>[connectionColor, connectionColor, connectionColor];

      for(var i = directionInnerStart; i < directionBorderStart - 1; i++){
        listOfFaces.add(new Face3(
            directionShapePointsStart + 7,
            i,
            i + 1,
            vertexNormals, vertexColors
        ));
      }

      // outer shape

      vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

      // begins side

      listOfFaces.add(new Face3(
          directionShapePointsStart + 3,
          directionShapePointsStart + 4,
          directionShapePointsStart + 10,
          vertexNormals, vertexColors
      ));

      listOfFaces.add(new Face3(
          directionShapePointsStart + 3,
          directionShapePointsStart + 10,
          directionShapePointsStart + 6,
          vertexNormals, vertexColors
      ));

      // end side

      listOfFaces.add(new Face3(
          directionShapePointsStart + 3,
          directionShapePointsStart + 6,
          directionShapePointsStart + 11,
          vertexNormals, vertexColors
      ));

      listOfFaces.add(new Face3(
          directionShapePointsStart + 3,
          directionShapePointsStart + 11,
          directionShapePointsStart + 5,
          vertexNormals, vertexColors
      ));

/////////////////////////////////////////////////////////////////////////////////////
    } else if (this._direction == 2){

      //Border
      listOfFaces.add(new Face3(
          directionShapePointsStart + 6,
          directionShapePointsStart + 2,
          directionBorderStart,
          vertexNormals, vertexColors
      ));

      for(var i = directionBorderStart; i < directionShapePointsStart - 1; i++){
        listOfFaces.add(new Face3(
            directionShapePointsStart + 6,
            i,
            i + 1,
            vertexNormals, vertexColors
        ));
      }

      listOfFaces.add(new Face3(
          directionShapePointsStart + 6,
          directionShapePointsStart - 1,
          directionShapePointsStart + 1,
          vertexNormals, vertexColors
      ));


      // Direction part
      vertexColors = <Color>[connectionColor, connectionColor, connectionColor];

      // Begin side
      listOfFaces.add(new Face3(
          directionShapePointsStart + 7,
          directionShapePointsStart + 4,
          directionShapePointsStart + 10,
          vertexNormals, vertexColors
      ));

      listOfFaces.add(new Face3(
          directionShapePointsStart + 7,
          directionShapePointsStart + 10,
          directionShapePointsStart,
          vertexNormals, vertexColors
      ));

      // End side
      listOfFaces.add(new Face3(
          directionShapePointsStart + 7,
          directionShapePointsStart,
          directionShapePointsStart + 11,
          vertexNormals, vertexColors
      ));

      listOfFaces.add(new Face3(
          directionShapePointsStart + 7,
          directionShapePointsStart + 11,
          directionShapePointsStart + 5,
          vertexNormals, vertexColors
      ));

      // Indicate other segment

      vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

      listOfFaces.add(new Face3(
          directionShapePointsStart + 3,
          directionShapePointsStart + 12,
          directionInnerStart,
          vertexNormals, vertexColors
      ));

      /*listOfFaces.add(new Face3(
          directionShapePointsStart + 3,
          directionInnerStart,
          directionInnerStart + 1,
          vertexNormals, vertexColors
      ));*/

      for(var i = directionInnerStart; i < directionBorderStart - 1; i++){
        listOfFaces.add(new Face3(
            directionShapePointsStart + 3,
            i,
            i + 1,
            vertexNormals, vertexColors
        ));
      }

      listOfFaces.add(new Face3(
          directionShapePointsStart + 3,
          directionBorderStart - 1,
          directionShapePointsStart + 13,
          vertexNormals, vertexColors
      ));

      //Black box
      /*listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 2,
          this._numberOfBorderVertices - 1,
          this._borderOffset,
          vertexNormals, vertexColors
      ));

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 2,
          this._borderOffset,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 1,
          vertexNormals, vertexColors
      ));*/

      vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

      /*listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 4,
          this._numberOfBorderVertices + this._numberOfPolygonVertices - 1,
          vertexNormals, vertexColors
      ));

      for(var i = (this._numberOfBorderVertices + this._numberOfPolygonVertices) - 1; i > (this._numberOfBorderVertices + this._polygonOffset); i--){
        listOfFaces.add(new Face3(
            this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
            i,
            i - 1,
            vertexNormals, vertexColors
        ));
      }

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 5,
          this._numberOfBorderVertices + this._polygonOffset,
          vertexNormals, vertexColors
      ));

      //Color grey = new Color(0x777777);
      vertexColors = <Color>[connectionColor, connectionColor, connectionColor];

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 2,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 1,
          vertexNormals, vertexColors
      ));*/

/// Direction indicated with triangle at top os the segments
      /*listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 2,
          this._numberOfBorderVertices - 1,
          vertexNormals, vertexColors
      ));

      for(var i = this._numberOfBorderVertices - 1; i > this._borderOffset; i--){
        listOfFaces.add(new Face3(
            this._numberOfBorderVertices + this._numberOfPolygonVertices,
            i,
            i - 1,
            vertexNormals, vertexColors
        ));
      }

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices,
          this._borderOffset,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 1,
          vertexNormals, vertexColors
      ));

      vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 4,
          this._numberOfBorderVertices + this._numberOfPolygonVertices - 1,
          vertexNormals, vertexColors
      ));

      for(var i = (this._numberOfBorderVertices + this._numberOfPolygonVertices) - 1; i > (this._numberOfBorderVertices + this._polygonOffset); i--){
        listOfFaces.add(new Face3(
            this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
            i,
            i - 1,
            vertexNormals, vertexColors
        ));
      }

      /*listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
          this._numberOfBorderVertices + this._numberOfPolygonVertices - 1,
          this._numberOfBorderVertices + this._polygonOffset,
          vertexNormals, vertexColors
      ));*/

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 5,
          this._numberOfBorderVertices + this._polygonOffset,
          vertexNormals, vertexColors
      ));*/

/// Direction without indicates of the connections end comment out everything
      /*listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 2,
          this._numberOfBorderVertices - 1,
          vertexNormals, vertexColors
      ));

      for(var i = this._numberOfBorderVertices - 1; i > this._borderOffset; i--){
        listOfFaces.add(new Face3(
            this._numberOfBorderVertices + this._numberOfPolygonVertices,
            i,
            i - 1,
            vertexNormals, vertexColors
        ));
      }

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices,
          this._borderOffset,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 1,
          vertexNormals, vertexColors
      ));

      vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 4,
          this._numberOfBorderVertices + this._numberOfPolygonVertices - 1,
          vertexNormals, vertexColors
      ));

      for(var i = (this._numberOfBorderVertices + this._numberOfPolygonVertices) - 1; i > (this._numberOfBorderVertices + this._polygonOffset); i--){
        listOfFaces.add(new Face3(
            this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
            i,
            i - 1,
            vertexNormals, vertexColors
        ));
      }

      listOfFaces.add(new Face3(
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 3,
          this._numberOfBorderVertices + this._numberOfPolygonVertices + 5,
          this._numberOfBorderVertices + this._polygonOffset,
          vertexNormals, vertexColors
      ));*/
    }

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
