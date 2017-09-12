part of visualizationGeometry;

enum Triangulation{
  SIMPLE,
  EAR_CLIP,
  THREE_DART
}

class PolygonShape implements Polygon{

  List<double> _polygonVertices;
  List<double> _polygonInnerContourVertices;
  List<double> _contourVertices;
  List<int> _polygonFaces;
  List<int> _polygonInnerContourFaces;
  List<int> _contourFaces;
  Color polyColor;
  Color contourColor;
  int numberOfShapePoint;
  int numberOfLinePoint;

  PolygonShape(this._polygonVertices, this._contourVertices,
      this.numberOfShapePoint, this.numberOfLinePoint,
      [this.polyColor = null, this.contourColor = null,
        Triangulation triangulator]){
    if(this.polyColor == null){
      this.polyColor = new Color(0x00ff00);
    }
    if(this.contourColor == null){
      this.polyColor = new Color(0x000000);
    }
    if(triangulator == Triangulation.SIMPLE){
      this._simplePolygonConstruction();
    }else if(triangulator == Triangulation.EAR_CLIP){
      this._earClipPolygonConstruction();
    }if(triangulator == Triangulation.THREE_DART){
      this._threeDartPolygonConstruction();
    }

  }

  List<Vector3> get polygonVertices => this._getDataForRender(0);
  List<Vector3> get contourVertices => this._getDataForRender(1);

  List<Face3> get polygonFaces => this._getFacesFromRawData(0);
  List<Face3> get contourFaces => this._getFacesFromRawData(1);

  List<Vector3> _getDataForRender([int type = 0]){
    List<double> pointsToWorks = (type == 0) ? this._polygonVertices : this._contourVertices;
    int numOfPoints = type == 0 ? this.numberOfShapePoint : this.numberOfLinePoint;
    int possNumberOfPoint = pointsToWorks.length ~/ 3;

    if(possNumberOfPoint != numOfPoints){
      /*throw new StateError(
          "Number of point ${numOfPoints} is not equal"
          " with given ${type == 0 ? "shape" : "line"}"
          " raw data points ${possNumberOfPoint}");*/
    }

    var result = new List<Vector3>(possNumberOfPoint);
    var index = 0;
    for (var i = 0; i < pointsToWorks.length; i += 3) {
      result[index++] = new Vector3(pointsToWorks[i], pointsToWorks[i + 1], pointsToWorks[i + 2]);
    }
    return result;
  }

  List<List<JsObject>> _dataForTriangulationJS([int type = 0]){
    List<JsObject> JsContour = <JsObject>[];

    List<double> pointsToWorks = (type == 0) ? this._polygonVertices : this._contourVertices;
    for (var i = 0; i < pointsToWorks.length; i += 3) {
      JsContour.add(_jsPoint(pointsToWorks[i], pointsToWorks[i + 1]));
    }

    return <List<JsObject>>[JsContour];
  }

  List<Vector2> _dataForTriangulationDart([int type = 0]){
    List<double> pointsToWorks = (type == 0) ? this._polygonVertices : this._contourVertices;
    int numOfPoints = type == 0 ? this.numberOfShapePoint : this.numberOfLinePoint;
    int possNumberOfPoint = pointsToWorks.length ~/ 3;

    if(possNumberOfPoint != numOfPoints){
      /*throw new StateError(
          "Number of point ${numOfPoints} is not equal"
          " with given ${type == 0 ? "shape" : "line"}"
          " raw data points ${possNumberOfPoint}");*/
    }

    var result = new List<Vector2>(possNumberOfPoint);
    var index = 0;
    for (var i = 0; i < pointsToWorks.length; i += 3) {
      result[index++] = new Vector2(pointsToWorks[i], pointsToWorks[i + 1]);
    }
    return result;
  }

  JsObject _jsPoint(double x, double y){
    var object = new JsObject(context['Object'] as JsFunction);
    object["x"] = x;
    object["y"] = y;
    return object;
  }

  void _simplePolygonConstruction(){
    var dataForTriangulation = this._dataForTriangulationJS(0);

    this._polygonFaces = new List<int>();
    Triangulator pnltri = new Triangulator();
    (pnltri.triangulate_polygon(dataForTriangulation, false) as List<List<int>>).forEach((List<int> face){
      this._polygonFaces.addAll(face);
    });

    this._contourFaces = new List<int>();
    dataForTriangulation = this._dataForTriangulationJS(1);
    (pnltri.triangulate_polygon(dataForTriangulation, false) as List<List<int>>).forEach((List<int> face){
      this._contourFaces.addAll(face);
    });
  }

  void _earClipPolygonConstruction(){
    var dataForTriangulation = this._dataForTriangulationJS(0);

    this._polygonFaces = new List<int>();
    PolygonData polyData = new PolygonData(dataForTriangulation);
    EarClipTriangulator pnltri = new EarClipTriangulator(polyData);
    bool test = pnltri.triangulate_polygon_no_holes();
    if(test){
      (polyData.getTriangles() as List<List<int>>).forEach((List<int> face){
        this._polygonFaces.addAll(face);
      });
    }

    this._contourFaces = new List<int>();
    polyData = new PolygonData(dataForTriangulation);
    pnltri = new EarClipTriangulator(polyData);
    dataForTriangulation = this._dataForTriangulationJS(1);
    test = pnltri.triangulate_polygon_no_holes();
    if(test){
      (polyData.getTriangles() as List<List<int>>).forEach((List<int> face){
        this._contourFaces.addAll(face);
      });
    }
  }

  void _threeDartPolygonConstruction(){
    var dataForTriangulation = this._dataForTriangulationDart(0);

    this._polygonFaces = new List<int>();
    (ShapeUtils.triangulateShape(dataForTriangulation, <dynamic>[]) as List)
        .forEach((List<int> face){
      this._polygonFaces.addAll(face);
    });

    this._contourFaces = new List<int>();
    var dataForTriangulation2 = this._dataForTriangulationDart(1);
    (ShapeUtils.triangulateShape(dataForTriangulation2, <dynamic>[]) as List)
        .forEach((List<int> face){
      this._contourFaces.addAll(face);
    });
  }

  List<Face3> _getFacesFromRawData(int type){
    List<int> facesToWorks = (type == 0) ? this._polygonFaces : this._contourFaces;
    List<Face3> retVal = new List<Face3>();

    var vertexNormal = new Vector3(0.0, 0.0, 1.0);
    List<Vector3> vertexNormals = <Vector3>[vertexNormal, vertexNormal, vertexNormal];
    Color faceVertexColor = (type == 0) ? this.polyColor : this.contourColor;
    List<Color> vertexColors = <Color>[faceVertexColor, faceVertexColor, faceVertexColor];
    for(var i = 0; i < facesToWorks.length; i+= 3){
      retVal.add(new Face3(
          facesToWorks[i], facesToWorks[i+1], facesToWorks[i+2],
          vertexNormals, vertexColors, 1));
    }

    return retVal;
  }
}