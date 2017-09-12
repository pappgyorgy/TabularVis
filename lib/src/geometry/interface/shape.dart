part of visualizationGeometry;

enum ShapeType {
  line, mesh, simple, bezier
}

abstract class ShapeForm implements Comparable<ShapeForm>{

  factory ShapeForm(VisualObject element, ShapeType type, Diagram diagram,
      List<RangeMath<double>> ranges, [ShapeForm parent = null, String key = "",
      bool is3D = false, double height = 10.0,  List<RangeMath<double>> textRanges, int value]){
    switch(type){textRanges:
      case ShapeType.simple:
          if(element.parent.label.name.contains("Group")){
            return new ShapeText.fromData(diagram, ranges.first, ranges.last,
                parent, key, is3D, height);
          }else{
            var finalDirection = 0;
            if(element.connection != null) {
              if (element.id == element.connection.segmentOneID) {
                finalDirection = element.connection.direction;
              } else {
                if (element.connection.direction == 1) {
                  finalDirection = 2;
                } else if (element.connection.direction == 2) {
                  finalDirection = 1;
                }
              }
            }
            //print("$key : $finalDirection");
            return new ShapeSimple.fromData(diagram, ranges.first, ranges.last,
                parent, key, is3D, height, finalDirection);
          }

        break;
      case ShapeType.bezier:
          return new ShapeBezier.fromData(
              diagram, ranges.first, ranges.last,
              parent, key, is3D, height);
        break;
      case ShapeType.line:
        return new ShapeLine.fromData(
            diagram, ranges.first, ranges.last, textRanges, value, parent, key, is3D, height);
        break;
      default:
        break;
    }

    return null;
  }

  Color polygonBaseColor;
  Color borderBaseColor;

  List<List<double>> generatePointData();

  List<List<double>> generateOuterLinePointData();

  List<Face3> generateFaceData();

  List<Vector3> generatePolygonData();

  List<LineGeom<double, HomogeneousCoordinate>> get lines;

  bool get isDrawable;

  set isDrawable(bool value);

  bool pointIsInShape(HomogeneousCoordinate point);

  void switchShape(ShapeForm other);

  void modifyGeometry(List<RangeMath<double>> ranges,
      List<SimpleCircle<HomogeneousCoordinate>> circles,
      [ShapeForm parent = null, String key = "",
      bool is3D = false, double height = 10.0]);

  ShapeForm getChildByID(String ID);

  Map<String, ShapeForm> get children;

  ShapeForm get parent;

  void setChild(ShapeForm child, String ID);

  Map<String, ShapeForm> dividedLinesPoint(Map<String, double> values);
}