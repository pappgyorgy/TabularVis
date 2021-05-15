part of visualizationGeometry;

class ShapeText extends ShapeSimple {

  Color polygonBaseColor;
  Color borderBaseColor;

  String _label = "";
  Matrix4 _labelMatrix;

  TextGeometryBuilder fontGeometry;
  TextGeometryBuilder baseFontGeometry;

  ShapeText(List<LineGeom<double, HomogeneousCoordinate>> lines,
      Diagram diagram, [ShapeForm parent = null, this._label])
      : super(lines, diagram, parent);

  ShapeText.fromData(Diagram diagram, RangeMath<double> range,
      RangeMath<double> radius, [ShapeForm parent = null, String key = "",
        bool is3D = false, double shapeHeight = 10.0, this._label])
      : super.fromData(diagram, range, radius, parent, key, is3D, shapeHeight){
    _labelMatrix = new Matrix4.identity();
  }

  void setLabel(SimpleCircle<HomogeneousCoordinate> labelCircle,
      String label, List<double> polygonColor){

    this._labelMatrix = new Matrix4.identity();

    this.polygonBaseColor = new Color.fromArray([
      polygonColor[0],
      polygonColor[1],
      polygonColor[2]]);

    this._label = label;

    var fontShapes = generateShapes(this._label, 6);
    this.fontGeometry = new TextGeometryBuilder(fontShapes, 20);

    fontGeometry.computeBoundingBox();
    var center = fontGeometry.boundingBox.center;
    center.y = 0.0;

    Matrix4 mat = new Matrix4.identity();

    double label_polar_pos = (this.lines.first.lineArc.range.length /
        2.0) + (this.lines.first.lineArc.range.begin) as double;

    var pos = labelCircle.getPointFromPolarCoordinate(label_polar_pos);
    var vec2 = pos.getDescartesCoordinate() as Vector2;

    var helper = (pos.getDescartesCoordinate() as Vector2)..normalize();
    var textVector = new Vector2(1.0, 0.0);
    var rotValue = 0.0;
    if(this._diagram.textDirection == 0) {
      /*if (label_polar_pos >= pi / 2 && label_polar_pos < (pi)) {
        textVector = new Vector2(-1.0, 0.0);
        rotValue = ((pi / 2) - acos(helper.dot(textVector)));
        //center = new Vector3(center.x, -center.y, 0.0);
      } else if (label_polar_pos >= pi && label_polar_pos < (3 * (pi / 2))) {
        textVector = new Vector2(-1.0, 0.0);
        rotValue = ((pi / 2) + acos(helper.dot(textVector)));
        rotValue += pi;
        vec2 += helper.clone()..scale(fontGeometry.boundingBox.max.y as double);
        //center = new Vector3(-center.x, center.y, 0.0);
      } else
      if (label_polar_pos >= (3 * (pi / 2)) && label_polar_pos < (2 * pi)) {
        textVector = new Vector2(1.0, 0.0);
        rotValue = (((pi / 2) - acos(helper.dot(textVector))) + pi);
        rotValue += pi;
        vec2 += helper.clone()..scale(fontGeometry.boundingBox.max.y as double);
        //center = new Vector3(-center.x, center.y, 0.0);
      } else {
        textVector = new Vector2(1.0, 0.0);
        rotValue = ((2 * pi) - ((pi / 2) - acos(helper.dot(textVector))));
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
    }else {
      if (label_polar_pos >= pi / 2 && label_polar_pos < (pi)) {
        textVector = new Vector2(-1.0, 0.0);
        rotValue = ((pi / 2) - acos(helper.dot(textVector)));
        rotValue -= (pi / 2);
        vec2 +=
            helper.clone()..scale(fontGeometry.boundingBox.max.x / 2 as double);
        //center = new Vector3(center.x, -center.y, 0.0);
      } else if (label_polar_pos >= pi && label_polar_pos < (3 * (pi / 2))) {
        textVector = new Vector2(-1.0, 0.0);
        rotValue = ((pi / 2) + acos(helper.dot(textVector)));
        rotValue += pi;
        rotValue += (pi / 2);
        vec2 +=
            helper.clone()..scale(fontGeometry.boundingBox.max.x / 2 as double);
        //center = new Vector3(-center.x, center.y, 0.0);
      } else
      if (label_polar_pos >= (3 * (pi / 2)) && label_polar_pos < (2 * pi)) {
        textVector = new Vector2(1.0, 0.0);
        rotValue = (((pi / 2) - acos(helper.dot(textVector))) + pi);
        rotValue += pi;
        rotValue -= (pi / 2);
        vec2 +=
            helper.clone()..scale(fontGeometry.boundingBox.max.x / 2 as double);
        //center = new Vector3(-center.x, center.y, 0.0);
      } else {
        textVector = new Vector2(1.0, 0.0);
        rotValue = ((2 * pi) - ((pi / 2) - acos(helper.dot(textVector))));
        rotValue += (pi / 2);
        vec2 +=
            helper.clone()..scale(fontGeometry.boundingBox.max.x / 2 as double);
        //center = new Vector3(-center.x, -center.y, 0.0);
      }
    }

    mat.translate(new Vector3(vec2.x, vec2.y, 0.0));
    mat.rotateZ(rotValue);
    mat.translate(-center);


    for(var i = 0; i < fontGeometry.vertices.length; i++){
      fontGeometry.vertices[i] = mat.transform3(fontGeometry.vertices[i]);
    }

    this.polygonBaseColor = new Color(0x000000);

    var vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

    for(var i = 0; i < fontGeometry.faces.length; i++){
      fontGeometry.faces[i].vertexColors = vertexColors;
    }
  }

  @override
  List<Face3> generateFaceData() {
    /*var vertexNormal = new Vector3(0.0, 0.0, 1.0);
    List<Vector3> vertexNormals = <Vector3>[vertexNormal, vertexNormal, vertexNormal];
    var vertexColors = <Color>[polygonBaseColor, polygonBaseColor, polygonBaseColor];

    var face1 = new Face3(0, 4, 1, vertexNormals, vertexColors);
    var face2 = new Face3(1, 4, 2, vertexNormals, vertexColors);
    var face3 = new Face3(2, 4, 3, vertexNormals, vertexColors);

    return [face1, face2, face3];*/
    return fontGeometry.faces as List<Face3>;
  }

  @override
  List<Vector3> generatePolygonData() {

    /*var min = fontGeometry.boundingBox.min as Vector3;
    var max = fontGeometry.boundingBox.max as Vector3;
    var center = fontGeometry.boundingBox.center;
    var center2 = fontGeometry.boundingBox.center.clone();
    //center2.y = 0.0;

    var bottomRight = new Vector3(max.x, min.y, 0.0);
    var topLeft = new Vector3(min.x, max.y, 0.0);

    Matrix4 mat = new Matrix4.identity();

    double label_polar_pos = (this.lines.first.lineArc.range.length /
        2.0) + (this.lines.first.lineArc.range.begin) as double;

    var labelCircle = this._diagram.drawCircle.clone()..radius = 185.0;
    var pos = labelCircle.getPointFromPolarCoordinate(label_polar_pos);
    var vec2 = pos.getDescartesCoordinate() as Vector2;

    var helper = (pos.getDescartesCoordinate() as Vector2).normalize();
    var textVector = new Vector2(1.0, 0.0);
    var rotValue = 0.0;
    if(label_polar_pos >= PI / 2 && label_polar_pos < (PI)){
      textVector = new Vector2(-1.0, 0.0);
      rotValue = ((PI / 2) - acos(helper.dot(textVector)));
      rotValue -= (PI / 2);
      vec2 += helper.clone().scale(fontGeometry.boundingBox.max.x/2 as double);
      //center = new Vector3(center.x, -center.y, 0.0);
    }else if(label_polar_pos >= PI && label_polar_pos < (3 * (PI/2))){
      textVector = new Vector2(-1.0, 0.0);
      rotValue = ((PI / 2) + acos(helper.dot(textVector)));
      rotValue += PI;
      rotValue += (PI / 2);
      vec2 += helper.clone().scale(fontGeometry.boundingBox.max.x/2 as double);
      //center = new Vector3(-center.x, center.y, 0.0);
    }else if(label_polar_pos >= (3 * (PI/2)) && label_polar_pos < (2 * PI)){
      textVector = new Vector2(1.0, 0.0);
      rotValue = (((PI / 2) - acos(helper.dot(textVector))) + PI);
      rotValue += PI;
      rotValue += (PI / 2);
      vec2 += helper.clone().scale(fontGeometry.boundingBox.max.x/2 as double);
      //center = new Vector3(-center.x, center.y, 0.0);
    }else{
      textVector = new Vector2(1.0, 0.0);
      rotValue = ((2*PI) - ((PI / 2) - acos(helper.dot(textVector))));
      rotValue -= (PI / 2);
      vec2 += helper.clone().scale(fontGeometry.boundingBox.max.x/2 as double);
      //center = new Vector3(-center.x, -center.y, 0.0);
    }

    mat.translate(new Vector3(vec2.x, vec2.y, 0.0));
    mat.rotateZ(rotValue);
    mat.translate(-center2);


    return [mat.transform3(bottomRight), mat.transform3(min), mat.transform3(topLeft), mat.transform3(max), mat.transform3(center)];*/

    //return [new Vector3(0.0, 0.0, 0.0), new Vector3(-10.0, 0.0, 0.0), new Vector3(-10.0, -10.0, 0.0)];
    return fontGeometry.vertices;
  }



}