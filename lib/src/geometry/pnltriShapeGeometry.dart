part of visualizationGeometry;

class PnltriShapeGeometry extends ShapeGeometry{

  PnltriShapeGeometry(
      List<Shape> shapes,
      {int curveSegments: 12, int material,
      ExtrudeGeometryWorldUVGenerator UVGenerator})
        : super(shapes, curveSegments: curveSegments, material: material,
          UVGenerator: UVGenerator
        ){
  }

  JsObject JsPoint(double x, double y){
    var object = new JsObject(context['Object'] as JsFunction);
    object["x"] = x;
    object["y"] = y;
    return object;
  }

  @override
  void addShape(Shape shape, num curveSegments, int material, [ExtrudeGeometryWorldUVGenerator UVGenerator = null]) {

    // set UV generator
    var uvgen = (UVGenerator != null) ? UVGenerator : new ExtrudeGeometryWorldUVGenerator();

    int i;
    List<Vector2> hole, s;

    var shapesOffset = this.vertices.length;
    Map<String, List<List<Vector2>>> shapePoints = shape.extractPoints(curveSegments) as Map<String, List<List<Vector2>>>;

    List vertices = shapePoints["shape"];
    List<List<Vector2>> holes = shapePoints["holes"];

    bool isClockWise = ShapeUtils.isClockWise(vertices) as bool;

    var reverse = !isClockWise;

    if (reverse) {

      vertices = vertices.reversed.toList();

      // Maybe we should also check if holes are in the opposite direction, just to be safe...

      for (i = 0; i < holes.length; i++) {

        hole = holes[i];

        bool isHoleClockWise = ShapeUtils.isClockWise(hole) as bool;

        if (isHoleClockWise) {

          holes[i] = hole.reversed.toList();

        }

      }

      reverse = false;

    }


    List<List<JsObject>> dataForTriangulation = <List<JsObject>>[];
    List<JsObject> JsContour = <JsObject>[];
    vertices.forEach((Vector2 vec){
      JsContour.add(JsPoint(vec.x, vec.y));
    });
    dataForTriangulation.add(JsContour);

    Triangulator pnltri = new Triangulator();
    List<num> faces = pnltri.triangulate_polygon(dataForTriangulation, false);

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
    num flen = faces.length;
    num cont,
        clen = contour.length;

    for (i = 0; i < vlen; i++) {

      vert = vertices[i] as Vector2;

      this.vertices.add(new Vector3((vert.x).toDouble(), (vert.y).toDouble(), 0.0));

    }

    for (i = 0; i < flen; i++) {

      face = faces[i] as List<int>;

      var a = face[0] + shapesOffset;
      var b = face[1] + shapesOffset;
      var c = face[2] + shapesOffset;

      this.faces.add(new Face3(a, b, c, null, null, material));
      faceVertexUvs[0].add(uvgen.generateBottomUV(this, shape, null, a, b, c));

    }
  }

}