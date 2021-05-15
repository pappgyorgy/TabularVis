part of renderer;

class Face3Ext extends Face3{
  Vector3 centroid;
  Vector3 normal;
  Color color;
  List<Vector3> vertexNormals;
  List<Color> vertexColors;
  int materialIndex = 0;

  Face3Ext(int a, int b, int c): super(a, b, c){
    this.centroid = new Vector3.zero();
    this.normal = new Vector3.zero();
    this.color = new Color();
    this.vertexNormals = new List<Vector3>();
    this.vertexColors = new List<Color>();
  }

  Face3Ext.fromFace(Face3 face): super(face.a, face.b, face.c){
    this.centroid = new Vector3.zero();
    this.normal = new Vector3.zero();
    this.color = new Color();
    this.vertexNormals = new List<Vector3>();
    this.vertexColors = new List<Color>();
  }

  Face3Ext.withNormalsColors(int a, int b, int c, List<Vector3> normalOrVertexNormals, List<Color> colorOrVertexColors, [int materialIndex = 0]): super(a, b, c){
    this.centroid = new Vector3.zero();

    normal = normalOrVertexNormals.length == 1 ? normalOrVertexNormals.first : new Vector3.zero();
    vertexNormals = normalOrVertexNormals.length > 1 ? normalOrVertexNormals : <Vector3>[];

    color = colorOrVertexColors.length == 1 ? colorOrVertexColors.first : new Color();
    vertexColors = colorOrVertexColors.length > 1 ? colorOrVertexColors : <Color>[];
  }

  Face3 get face3 => new Face3(this.a, this.b, this.c);

  List<int> get indices => <int>[this.a, this.b, this.c];

  int get size => 3;
}

class TextGeometryBuilder extends GeometryBuilder{

  List<Face3Ext> faces;

  List<Shape> listOfShapes;

  Map<String, dynamic> shapebb;

  BoundingBox boundingBox;

  static Triangulator pnltri = new Triangulator();

  TextGeometryBuilder(this.listOfShapes, [int curveSegments = 12, int material])
        : super(){

    this.faces = new List<Face3Ext>();

    shapebb = listOfShapes.last.getBoundingBox();

    addShapeList(listOfShapes, curveSegments, material);

    computeCentroids();
    computeFaceNormals();
  }

  JsObject JsPoint(double x, double y){
    var object = new JsObject(context['Object'] as JsFunction);
    object["x"] = x;
    object["y"] = y;
    return object;
  }

  void addShapeList(List<Shape> shapes, int curveSegments, int material) {
    var sl = shapes.length;

    for (var s = 0; s < sl; s++) {
      var shape = shapes[s];
      addShape(shape, curveSegments, material);
    }
  }


  void addShape(Shape shape, int curveSegments, int material) {

    int i;
    List<Vector2> hole, s;

    var shapesOffset = this.vertices.length;
    Map<String, dynamic> shapePoints = shape.extractPoints(curveSegments);

    List<Vector2> vertices = shapePoints["shape"] as List<Vector2>;
    List<dynamic> holes = shapePoints["holes"];

    bool isClockWiseShape = isClockWise(vertices) as bool;

    var reverse = !isClockWiseShape;

    if (reverse) {

      vertices = vertices.reversed.toList();

      // Maybe we should also check if holes are in the opposite direction, just to be safe...

      for (i = 0; i < holes.length; i++) {

        hole = holes[i] as List<Vector2>;

        bool isHoleClockWise = isClockWise(hole) as bool;

        if (isHoleClockWise) {

          holes[i] = hole.reversed.toList();

        }

      }

      reverse = false;

    }

    /*List<List<JsObject>> dataForTriangulation = <List<JsObject>>[];
    List<JsObject> JsContour = <JsObject>[];
    vertices.forEach((Vector2 vec){
      JsContour.add(JsPoint(vec.x, vec.y));
    });

    dataForTriangulation.add(JsContour);

    List<List<JsObject>> JsHoles = new List<List<JsObject>>();
    int index = 0;
    holes.forEach((List<Vector2> actHole){
      JsHoles.add(new List<JsObject>());
      actHole.forEach((Vector2 vec){
        JsHoles[index].add(JsPoint(vec.x, vec.y));
      });
      index++;
    });

    dataForTriangulation.addAll(JsHoles);

    Triangulator pnltri = new Triangulator();
    List<num> faces2 = pnltri.triangulate_polygon(dataForTriangulation, true);*/

    /*List<List<JsObject>> dataForTriangulation = <List<JsObject>>[];
    List<JsObject> JsContour = <JsObject>[];
    vertices.forEach((Vector2 vec){
      JsContour.add(JsPoint(vec.x, vec.y));
    });

    List<List<JsObject>> JsHoles = new List<List<JsObject>>();
    int index = 0;
    holes.forEach((List<Vector2> actHole){
      JsHoles.add(new List<JsObject>());
      actHole.forEach((Vector2 vec){
        JsHoles[index].add(JsPoint(vec.x, vec.y));
      });
      index++;
    });
    dataForTriangulation.add(JsContour);
    dataForTriangulation.addAll(JsHoles);

    List<num> faces2 = pnltri.triangulate_polygon(dataForTriangulation, false);*/


    /*List<List<JsObject>> dataForTriangulation = <List<JsObject>>[];
    List<JsObject> JsContour = <JsObject>[];
    vertices.forEach((Vector2 vec){
      JsContour.add(JsPoint(vec.x, vec.y));
    });

    //List<List<JsObject>> JsHoles = new List<List<JsObject>>();
    dataForTriangulation.add(JsContour);
    int index = 0;
    holes.forEach((List<Vector2> actHole){
      dataForTriangulation.add(new List<JsObject>());
      actHole.forEach((Vector2 vec){
        dataForTriangulation.last.add(JsPoint(vec.x, vec.y));
      });
      index++;
    });*/

    //dataForTriangulation.addAll(JsHoles);

    //Triangulator pnltri = new Triangulator();
    //List<num> faces = pnltri.triangulate_polygon(dataForTriangulation, false);

    List<List<int>> faces2 = triangulateShapeEarClip(vertices, holes);
    //List<List<int>> faces2 = triangulateShape(vertices, holes);

    // Vertices

    var contour = vertices;

    for (i = 0; i < holes.length; i++) {

      hole = holes[i];

      vertices = new List<Vector2>.from(vertices);
      vertices.addAll(hole);

    }

    //

    Vector2 vert;
    num vlen = vertices.length;
    List<int> face;
    num flen = faces2.length;

    for (i = 0; i < vlen; i++) {

      vert = vertices[i] as Vector2;

      this.vertices.add(new Vector3((vert.x).toDouble(), (vert.y).toDouble(), 0.0));

    }

    for (i = 0; i < flen; i++) {

      face = faces2[i] as List<int>;

      var a = face[0] + shapesOffset;
      var b = face[1] + shapesOffset;
      var c = face[2] + shapesOffset;

      this.faces.add(new Face3Ext(a, b, c));

    }
  }

  void computeCentroids() {

    faces.forEach((Face3Ext face) {

      face.centroid.setValues(0.0, 0.0, 0.0);

      face.indices.forEach((idx) {
        face.centroid.add(vertices[idx]);
      });

      face.centroid /= face.size.toDouble();

    });
  }

  /// Computes face normals.
  void computeFaceNormals() {
    faces.forEach((face) {

      var vA = vertices[face.a],
          vB = vertices[face.b],
          vC = vertices[face.c];

      Vector3 cb = vC - vB;
      Vector3 ab = vA - vB;
      cb = cb.cross(ab);

      cb.normalize();

      face.normal = cb;

    });
  }

  void computeBoundingBox() {
    if (boundingBox == null) {
      boundingBox = new BoundingBox.fromPoints(this.vertices);
    }
  }

}