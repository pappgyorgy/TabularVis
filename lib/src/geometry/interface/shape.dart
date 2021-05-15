part of visualizationGeometry;

enum ShapeType {
  line, mesh, simple, poincare, bezier, heatmap, edgeBundle, blockConnection, uniqueScaleIndicator, barLabel
}

abstract class ShapeForm implements Comparable<ShapeForm>{

  factory ShapeForm(VisualObject element, ShapeType type, Diagram diagram,
      [RangeMath<double> rangeA, RangeMath<double> rangeB,
        ShapeForm parent = null, String key = "",
        bool is3D = false, double height = 10.0,
        RangeMath<double> textRange, int value, RangeMath<double> blockRange, RangeMath<double> blockRange2]){
    switch(type){textRanges:
      case ShapeType.simple:
          if(element.role == VisualObjectRole.BLOCK || element.role == VisualObjectRole.GROUP){
            return new ShapeText.fromData(diagram, rangeA, rangeB,
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
            return new ShapeSimple.fromData(diagram, rangeA, rangeB,
                parent, key, is3D, height, finalDirection);
          }

        break;
      case ShapeType.blockConnection:
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
        return new ShapeBlockConnection.fromData(diagram, rangeA, rangeB,
            parent, key, is3D, height, finalDirection);
        break;
      case ShapeType.barLabel:
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
        return new ShapeBarLabel.fromData(diagram, rangeA, rangeB,
            parent, key, is3D, height, finalDirection);
        break;
      case ShapeType.uniqueScaleIndicator:
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
        return new ShapeUniqueScaleIndicator.fromData(diagram, rangeA, rangeB,
            parent, key, is3D, height, finalDirection);
        break;
      case ShapeType.poincare:
          return new ShapePoincare.fromData(
              diagram, rangeA, rangeB,
              parent, key, is3D, height);
        break;
      case ShapeType.bezier:
          return new ShapeBezier.fromData(
              diagram, rangeA, rangeB,
              parent, key, is3D, height);
        break;
      case ShapeType.line:
        return new ShapeLine.fromData(
            diagram, rangeA, rangeB, textRange, value, parent, key, is3D, height);
        break;
      case ShapeType.heatmap:
        return new ShapeHeatmap.fromData(
            diagram, rangeA, rangeB, parent, key, is3D, height);
        break;
      case ShapeType.bezier:
        return new ShapeBezier.fromData(
            diagram, rangeA, rangeB,
            parent, key, is3D, height);
      case ShapeType.edgeBundle:
        return new ShapeEdgeBundle.fromData(
            diagram, rangeA, rangeB,
            parent, key, is3D, height, blockRange, blockRange2);
      default:
        break;
    }

    return null;
  }

  ShapeForm._(){
    if(this.parent == null){
      this.isDrawable = false;
    }
  }

  VisualObject dataElement;

  Color polygonBaseColor;
  Color borderBaseColor;

  List<List<double>> generatePointData();

  List<List<double>> generateOuterLinePointData();

  List<Face3> generateFaceData();

  List<Vector3> generatePolygonData();

  List<LineGeom<double, HomogeneousCoordinate>> get lines;

  bool get isDrawable;

  set isDrawable(bool value);

  int direction = 0;

  bool pointIsInShape(HomogeneousCoordinate point);

  void switchShape(ShapeForm other);

  void modifyGeometry(RangeMath<double> a, RangeMath<double> b,
      [ShapeForm parent = null, String key = "",
      bool is3D = false, double height = 10.0,
      RangeMath<double> textRange, int value, RangeMath<double> blockRange, RangeMath<double> blockRange2]);

  ShapeForm getChildByID(String ID);

  Map<String, ShapeForm> get children;

  ShapeForm get parent;

  void setChild(ShapeForm child, String ID);

  Map<String, ShapeForm> dividedLinesPoint(Map<String, double> values);
}