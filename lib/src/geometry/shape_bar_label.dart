part of visualizationGeometry;

class ShapeBarLabel extends ShapeForm {

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

  SimpleCircle cloneCircle;
  RangeMath<double> textRange;
  List<TextGeometryBuilder> fontGeometries;
  List<Matrix4> _labelMatrices;
  String _label = "";

  Map<String, ShapeForm> _children = new Map<String, ShapeForm>();

  ShapeBarLabel.empty(): super._();

  ShapeBarLabel(this._lines, this._diagram, [this._parent = null]) : super._();

  ShapeBarLabel.fromData(this._diagram, RangeMath<double> range,
      RangeMath<double> radius, [this._parent = null, String key = "",
      this._is3D = false, this._shapeHeight = 10.0, this.direction = 0]) : super._(){


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
        var radiusUnitValue = 0.0;

        if(this.dataElement != null && this.dataElement.role == VisualObjectRole.BAR
            && this.dataElement.parent.label.uniqueScale){
          radiusUnitValue = this._diagram.maxSegmentRadius
              / this.dataElement.parent.getMaxValueOfChildren();
        }else{
          radiusUnitValue = this._diagram.maxSegmentRadius
              / this._diagram.maxValue;
        }

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
        segmentOuterCircle,
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
        lineSegmentCircle,
        range
    ));

    //directions outer side between the segments
    if(this.direction == 2 || this.direction == 0){
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

    if(this.direction == 0){
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

    cloneCircle = segmentOuterCircle.clone()..radius += 2.0;
    //cloneCircle.radius = cloneCircle.radius -= 0.15;
    //cloneCircle.radius = cloneCircle.radius -= 2.15;
    //cloneCircle.radius -= 1.5;

    this.textRange = new NumberRange.fromNumbers(range.getMinValue(), range.getMaxValue());

    if (this.textRange != null) {

      /*if(this.value > 100){
          this.textRange.end -= this.textRange.length;
        } else if(this.value > 1000){
          this.textRange.end -= this.textRange.length * 2;
        }*/

      this._labelMatrices = new List<Matrix4>();

      this._label = "${radius.length}";
      this.fontGeometries = new List<TextGeometryBuilder>();

      num textSize = 2.0;

      var prevBegin = this.textRange.begin;

      textSize = min(4, 30 * (this.textRange.length / 0.6));

      /*if(this.textRange.length >= 0.009){
        //this.textRange.begin -= 0.008;
        textSize += 1;
        //cloneCircle.radius -= 0.325;
      }
      if(this.textRange.length >= 0.04){
        //this.textRange.begin -= 0.008;
        textSize += 1;
        //cloneCircle.radius -= 0.325;
      }else{
        //this.textRange.begin += 0.01;
      }*/

      var fontshapes = generateShapes(this._label, textSize, 4, "open sans", "bold");
      this.fontGeometries.add(
          new TextGeometryBuilder(fontshapes, 5));

      this.setLabels(this.textRange, this.fontGeometries.last);

      this.textRange.begin = prevBegin;

      /*for (RangeMath<double> range in this.textRanges) {
          var fontshapes = generateShapes(this._label, 2);
          this.fontGeometries.add(
              new TextGeometryBuilder(fontshapes, 5));

          this.setLabels(range, this.fontGeometries.last);
        }*/
    }
  }

  void modifyGeometry(RangeMath<double> rangeA, RangeMath<double> rangeB,
      [ShapeForm parent = null, String key = "",
      bool is3d = false, double height = 10.0,
        RangeMath<double> textRange, int value, RangeMath<double> blockRange, RangeMath<double> blockRange2]) {

      if(parent != null){
        this.parent.children.remove(key);
        this._parent = parent;
        this._parent.setChild(this, key);
      }

      this._is3D = is3d;
      this._shapeHeight = height;

      this._innerRange = new NumberRange.fromNumbers(
          rangeA.begin + this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle),
          rangeA.end - this._diagram.getLineWidthArc(this._diagram.lineSegmentCircle));

      this._innerInnerRange = new NumberRange.fromNumbers(
          this._innerRange.begin + this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle),
          this._innerRange.end - this._diagram.getLineWidthArc(this._diagram.directionOuterLineCircle));

      var segmentOuterCircleRadius = this._diagram.segmentCircle.radius;
      var lineSegmentCircleRadius = this._diagram.lineSegmentCircle.radius;

      if(this._diagram.wayToCreateSegments
          == MatrixValueRepresentation.segmentsHeight || true) {
        if (rangeB != null && rangeB.length != null) {

          var radiusUnitValue = 0.0;

          if(this.dataElement != null && this.dataElement.role == VisualObjectRole.BAR
              && this.dataElement.parent.label.uniqueScale){
            radiusUnitValue = this._diagram.maxSegmentRadius
                / this.dataElement.parent.getMaxValueOfChildren();
          }else{
            radiusUnitValue = this._diagram.maxSegmentRadius
                / this._diagram.maxValue;
          }

          var newRadius = (rangeB.length as double) *
              radiusUnitValue;

          segmentOuterCircleRadius += newRadius;
          lineSegmentCircleRadius += newRadius;
        }
      }

      this._lines[0].lineArc.range = this._innerRange;

      this._lines[1].lineArc.range = this._innerRange;
      this._lines[1].lineArc.circle.radius = segmentOuterCircleRadius;

      this._lines[2].lineArc.range = rangeA;

      this._lines[3].lineArc.range = rangeA;
      this._lines[3].lineArc.circle.radius = lineSegmentCircleRadius;

      if(this.direction == 2 || this.direction == 0) {
        this._lines[4].lineArc.range = this._innerRange;
      }else{
        this._lines[4].lineArc.range = this._innerInnerRange;
      }

      this._lines[5].lineArc.range = rangeA;

      if(this.direction == 0){
        this._lines[6].lineArc.range = this._innerRange;

        this._lines[7].lineArc.range = rangeA;
      }

      cloneCircle.radius = (segmentOuterCircleRadius + 2);

      this.textRange = new NumberRange.fromNumbers(rangeA.getMinValue(), rangeA.getMaxValue());

      if (this.textRange != null) {

        /*if(this.value > 100){
          this.textRange.end -= this.textRange.length / 2;
        } else if(this.value > 1000){
          this.textRange.end -= this.textRange.length;
        }*/

        this._labelMatrices = new List<Matrix4>();

        this._label = "${rangeB.length}";
        this.fontGeometries = new List<TextGeometryBuilder>();

        int textSize = 2;

        var prevBegin = this.textRange.begin;

        if(this.textRange.length >= 0.02){
          this.textRange.begin += 0.008;
          textSize += 1;
          cloneCircle.radius -= 0.325;

        }else if(this.textRange.length >= 0.04){
          this.textRange.begin += 0.008;
          textSize += 1;
          cloneCircle.radius -= 0.325;
        }else{
          this.textRange.begin += 0.01;
        }

        var fontshapes = generateShapes(this._label, textSize, 4, "open sans", "bold");
        this.fontGeometries.add(
            new TextGeometryBuilder(fontshapes, 5));

        this.setLabels(this.textRange, this.fontGeometries.last);

        this.textRange.begin = prevBegin;

        /*for (RangeMath<double> range in this.textRanges) {
          var fontshapes = generateShapes(this._label, 2);
          this.fontGeometries.add(
              new TextGeometryBuilder(fontshapes, 5));

          this.setLabels(range, this.fontGeometries.last);
        }*/
      }
  }

  void setLabels(RangeMath<double> range, TextGeometryBuilder fontGeom){

    this._labelMatrices.add(new Matrix4.identity());

    fontGeom.computeBoundingBox();
    var center = fontGeom.boundingBox.center;
    center.y = 0.0;

    Matrix4 mat = new Matrix4.identity();

    double label_polar_pos = (range.length / 2.0) + (range.begin) as double;

    var pos = cloneCircle.getPointFromPolarCoordinate(label_polar_pos);
    var vec2 = pos.getDescartesCoordinate() as Vector2;

    var helper = (pos.getDescartesCoordinate() as Vector2)..normalize();
    var textVector = new Vector2(1.0, 0.0);
    var rotValue = 0.0;

    /*if (label_polar_pos >= PI / 2 && label_polar_pos < (PI)) {
      textVector = new Vector2(-1.0, 0.0);
      rotValue = ((PI / 2) - acos(helper.dot(textVector)));
      //center = new Vector3(center.x, -center.y, 0.0);
    } else if (label_polar_pos >= PI && label_polar_pos < (3 * (PI / 2))) {
      textVector = new Vector2(-1.0, 0.0);
      rotValue = ((PI / 2) + acos(helper.dot(textVector)));
      rotValue += PI;
      vec2 += helper.clone()..scale(fontGeom.boundingBox.max.y as double);
      //center = new Vector3(-center.x, center.y, 0.0);
    } else
    if (label_polar_pos >= (3 * (PI / 2)) && label_polar_pos < (2 * PI)) {
      textVector = new Vector2(1.0, 0.0);
      rotValue = (((PI / 2) - acos(helper.dot(textVector))) + PI);
      rotValue += PI;
      vec2 += helper.clone()..scale(fontGeom.boundingBox.max.y as double);
      //center = new Vector3(-center.x, center.y, 0.0);
    } else {
      textVector = new Vector2(1.0, 0.0);
      rotValue = ((2 * PI) - ((PI / 2) - acos(helper.dot(textVector))));
      //center = new Vector3(-center.x, -center.y, 0.0);
    }*/

    var valueToDecide = (label_polar_pos % MathFunc.PITwice) / pi;
    if (valueToDecide <= 1.0) {
      textVector = new Vector2(1.0, 0.0);
      rotValue = ((2 * pi) - ((pi / 2) - acos(helper.dot(textVector))));
    }else if(valueToDecide <= 1.5){
      textVector = new Vector2(-1.0, 0.0);
      rotValue = (pi/2) + acos(helper.dot(textVector));
    }else{
      textVector = new Vector2(1.0, 0.0);
      rotValue = (pi + (pi/2) - acos(helper.dot(textVector)));
    }

    mat.translate(new Vector3(vec2.x, vec2.y, 0.0));
    mat.rotateZ(rotValue);
    mat.translate(-center);


    for(var i = 0; i < fontGeom.vertices.length; i++){
      //var helper = mat.rotate3(fontGeom.vertices[i]);
      fontGeom.vertices[i] = mat.transform3(fontGeom.vertices[i]);
      //fontGeom.vertices[i] = mat.transform3(fontGeom.vertices[i]);
      //fontGeometry.vertices[i].x += (vec2.x - center.x);
      //fontGeometry.vertices[i].y += (vec2.y - center.y);
      //var alma = 5;
    }

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

    var right = (a - b)..normalize();
    var left = (c - b)..normalize();
    var rotateVec = new Vector3(left.y, -left.x, 0.0)..normalize();
    var midVec = (left + right)..normalize();

    midVec = midVec * midVec.dot(rotateVec).sign;

    var g = acos(midVec.dot(right));
    var h = this._diagram.lineWidth / sin(g);

    return b + (midVec * h);

  }

  List<Vector3> generatePolygonData(){

    var retVal = new List<Vector3>();

    if (this.textRange != null) {
      for (TextGeometryBuilder fontGeom in this.fontGeometries) {
        retVal.addAll(fontGeom.vertices);
      }
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

    var vertexNormal = new Vector3(0.0, 0.0, 1.0);
    List<Vector3> vertexNormals = <Vector3>[vertexNormal, vertexNormal, vertexNormal];
    List<Color> vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

    var listOfFaces = new List<Face3>();

    if (this.textRange != null) {
      int offset = 0;
      for (TextGeometryBuilder fontGeom in this.fontGeometries) {
        for (var i = 0; i < fontGeom.faces.length; i++) {
          fontGeom.faces[i].vertexColors = vertexColors;
          (fontGeom.faces[i] as Face3).a += offset;
          (fontGeom.faces[i] as Face3).b += offset;
          (fontGeom.faces[i] as Face3).c += offset;
        }
        offset += fontGeom.vertices.length;
        listOfFaces.addAll(fontGeom.faces as List<Face3>);
      }
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
