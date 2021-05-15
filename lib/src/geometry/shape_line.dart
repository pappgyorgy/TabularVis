part of visualizationGeometry;

class ShapeLine extends ShapeForm {

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

  SimpleCircle cloneCircle;

  int _numberOfPolygonVertices;
  int _polygonOffset;
  int _numberOfBorderVertices;
  int _borderOffset;
  int _numberOfDirectionVertices;
  int _directionOffset;

  int _direction = 0;
  String _label = "";

  RangeMath<double> textRange;
  List<TextGeometryBuilder> fontGeometries;
  List<Matrix4> _labelMatrices;

  int value = 0;

  Map<String, ShapeForm> _children = new Map<String, ShapeForm>();

  ShapeLine(this._lines, this._diagram, [this._parent = null]) : super._();

  ShapeLine.fromData(this._diagram, RangeMath<double> range,
      RangeMath<double> radius, [this.textRange = null, this.value = 0, this._parent = null, String key = "",
        this._is3D = false, this._shapeHeight = 10.0, this._direction = 0]) : super._(){

    borderBaseColor = new Color(0x000000);
    double radius2 = (radius.length as double) + this._diagram.lineWidth*2;


    //Inner side black line
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        this._diagram.drawCircle.clone()..radius = radius.length as double,
        range
    ));

    //Outer side black line
    this._lines.add(new LineGeom(
        LineType.simple,
        this._diagram,
        this._diagram.drawCircle.clone()..radius = radius2,
        range
    ));

    if (this._parent != null) {
      this._parent.setChild(this, key);
    }

    if(this._diagram.drawLabelNum) {
      cloneCircle = this._lines.last.lineArc.circle.clone();
      //cloneCircle.radius = cloneCircle.radius -= 0.15;
      //cloneCircle.radius = cloneCircle.radius -= 2.15;
      cloneCircle.radius -= 1.5;

      if (this.textRange != null) {

        /*if(this.value > 100){
          this.textRange.end -= this.textRange.length;
        } else if(this.value > 1000){
          this.textRange.end -= this.textRange.length * 2;
        }*/

        this._labelMatrices = new List<Matrix4>();

        this._label = "${this.value}";
        this.fontGeometries = new List<TextGeometryBuilder>();

        int textSize = 2;

        var prevBegin = this.textRange.begin;

        if(this.textRange.length >= 0.009){
          this.textRange.begin += 0.008;
          textSize += 1;
          cloneCircle.radius -= 0.325;
        }
        if(this.textRange.length >= 0.012){
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

    this.textRange = textRange;
    this.value = value;

    this._is3D = is3d;
    this._shapeHeight = height;

    double radius2 = (rangeB.length as double) + this._diagram.lineWidth*2;

    this._lines.first.lineArc.range = rangeA;
    this._lines.first.lineArc.circle.radius = rangeB.length as double;
    this._lines.last.lineArc.range = rangeA;
    this._lines.last.lineArc.circle.radius = radius2;

    if(this._diagram.drawLabelNum) {
      cloneCircle = this._lines.last.lineArc.circle.clone();
      //cloneCircle.radius = cloneCircle.radius -= 2.15;
      //cloneCircle.radius = cloneCircle.radius -= 0.15;
      cloneCircle.radius -= 1.5;

      if (this.textRange != null) {

        /*if(this.value > 100){
          this.textRange.end -= this.textRange.length / 2;
        } else if(this.value > 1000){
          this.textRange.end -= this.textRange.length;
        }*/

        this._labelMatrices = new List<Matrix4>();

        this._label = "${this.value}";
        this.fontGeometries = new List<TextGeometryBuilder>();

        int textSize = 2;

        var prevBegin = this.textRange.begin;

        if(this.textRange.length >= 0.009){
          this.textRange.begin += 0.008;
          textSize += 1;
          cloneCircle.radius -= 0.325;

        }else if(this.textRange.length >= 0.012){
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
    throw new UnimplementedError();
  }

  Vector3 getInnerPointFromContour(Vector3 a, Vector3 b, Vector3 c){

    var right = (a - b)..normalize();
    var left = (c - b)..normalize();
    Vector3 rotateVec = new Vector3(left.y, -left.x, 0.0)..normalize();
    Vector3 midVec = (left + right)..normalize();

    midVec = midVec * (midVec.dot(rotateVec)).sign;

    var g = acos(midVec.dot(right));
    var h = this._diagram.lineWidth / sin(g);

    return b + (midVec * h);

  }

  List<HomogeneousCoordinate> getListOfPoints([SimpleCircle circle, RangeMath<double> range, int numberOfVertices = 0]){
    if(numberOfVertices == 0) {
      numberOfVertices = max<double>(
          (range.length as double) * this._diagram.verticesPerRadian,
          4.0).toInt();
    }
    double step = (range.length / numberOfVertices) as double;

    var retVal = new List<HomogeneousCoordinate>();
    double closeRangeHalf = this._diagram.getLineWidthArc(circle) / 1.0;

    var resRanges = range.divideEqualParts(numberOfVertices.toInt()-1, defaultSpaceBetweenParts: 0.0);

    for(RangeMath range in resRanges){
      double beginPointAngle = (range.begin + closeRangeHalf) as double;
      double endPointAngle = (range.begin - closeRangeHalf) as double;
      retVal.add(circle.getPointFromPolarCoordinate(beginPointAngle, true));
      retVal.add(circle.getPointFromPolarCoordinate(endPointAngle, true));
    }

    double beginPointAngle = (resRanges.last.end + closeRangeHalf) as double;
    double endPointAngle = (resRanges.last.end - closeRangeHalf) as double;
    retVal.add(circle.getPointFromPolarCoordinate(
        beginPointAngle, true));
    retVal.add(circle.getPointFromPolarCoordinate(
        endPointAngle, true));

    //print(retVal.length);

    return retVal;

    /*return this._range.loopOverRangeElement(step, (T value){
      return this._circle.getPointFromPolarCoordinate(value, true);
    }) as List<F>;*/
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

  List<Vector3> generatePolygonData(){

    var retVal = new List<Vector3>();

    _addLinesToList(retVal, getListOfPoints(this._lines[1].circle, this._lines[1].lineArc.range, 0));
    this._borderOffset = retVal.length;
    _addLinesToList(retVal, getListOfPoints(this._lines[0].circle, this._lines[0].lineArc.range, 0));
    this._numberOfBorderVertices = retVal.length;

    if(this._diagram.drawLabelNum) {
      if (this.textRange != null) {
        for (TextGeometryBuilder fontGeom in this.fontGeometries) {
          retVal.addAll(fontGeom.vertices);
        }
      }
    }

    return retVal;
  }

  void _addLinesToList(List<Vector3> listToAdd, List<HomogeneousCoordinate> listFrom, [int begin = 0, int end = 0]){
    if(end == 0) end = listFrom.length;
    for(var i = begin; i < end; i++){
      listToAdd.add(new Vector3.array(listFrom[i].coordinate.storage as List<double>)..z = -0.1);
    }
  }

  List<Face3> generateFaceData(){

    if(_numberOfPolygonVertices == 0 || _polygonOffset == 0){
      throw new StateError("Probably the generated vertices are missing");
    }

    var vertexNormal = new Vector3(0.0, 0.0, 1.0);
    List<Vector3> vertexNormals = <Vector3>[vertexNormal, vertexNormal, vertexNormal];
    List<Color> vertexColors = <Color>[borderBaseColor, borderBaseColor, borderBaseColor];

    var listOfFaces = new List<Face3>();

    /*listOfFaces.add(new Face3(
        this._borderOffset, // Face first vertex
        0, // Face second vertex
        this._borderOffset + 1, // Face third vertex
        vertexNormals, vertexColors
    ));

    listOfFaces.add(new Face3(
        this._borderOffset + 1, // Face first vertex
        0, // Face second vertex
        1, // Face third vertex
        vertexNormals, vertexColors
    ));*/

    for(var i = 0; i < this._borderOffset - 1; i += 2){
      listOfFaces.add(new Face3Ext.withNormalsColors(
          i + this._borderOffset, // Face first vertex
          i, // Face second vertex
          i + this._borderOffset + 1, // Face third vertex
          vertexNormals, vertexColors
      ));
      listOfFaces.add(new Face3Ext.withNormalsColors(
          i + this._borderOffset + 1,
          i,
          i + 1,
          vertexNormals, vertexColors
      ));
    }

    if(this._diagram.drawLabelNum) {
      if (this.textRange != null) {
        int offset = this._numberOfBorderVertices;
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

  @override
  List<List<double>> generateOuterLinePointData() {
    throw new UnimplementedError("Under refactor");
  }
}
