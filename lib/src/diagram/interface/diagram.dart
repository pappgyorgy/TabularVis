part of diagram;

enum DiagramType{
  basic,
  sphere,
  halfPlane
}

abstract class Diagram{
  int numberOfAdditionalLayer = 0;

  bool drawGroupLabel = false;

  SimpleCircle<HomogeneousCoordinate> get drawCircle;
  SimpleCircle<HomogeneousCoordinate> get baseCircle;
  SimpleCircle<HomogeneousCoordinate> get segmentCircle;
  SimpleCircle<HomogeneousCoordinate> get directionCircle;
  SimpleCircle<HomogeneousCoordinate> get directionUpperCircle;
  SimpleCircle<HomogeneousCoordinate> get directionLowerCircle;
  SimpleCircle<HomogeneousCoordinate> get outerSegmentCircle;
  SimpleCircle<HomogeneousCoordinate> get lineSegmentCircle;
  SimpleCircle<HomogeneousCoordinate> get lineOuterSegmentCircle;
  SimpleCircle<HomogeneousCoordinate> get lineOuterDrawCircle;
  SimpleCircle<HomogeneousCoordinate> get directionOuterLineCircle;

  int get lineSegment;

  ShapeType connectionType = ShapeType.poincare;

  double angleShift = 0.0;

  factory Diagram(DiagramType type, [VisualObject diagramData = null, MatrixValueRepresentation wayToCreateSegments = null]){
    switch(type){
      case DiagramType.basic:
        return diagramData == null ? new Diagram2D.empty() : new Diagram2D(diagramData, wayToCreateSegments);
        break;
      default:
        throw new StateError("Only basic diagram type is available");
        break;
    }
  }

  MatrixValueRepresentation wayToCreateSegments;

  /// Indicates the direction of the blocks' label
  /// 0 - horizontal
  /// 1 - vertical
  int textDirection = 0;

  Map<String, VisualObject> dataObjects;

  bool isAscendingOrder = true;

  double lineWidth = 0.035;
  double getLineWidthArc(SimpleCircle<HomogeneousCoordinate> circle);

  double spaceBetweenBlocksModifier = 0.5;

  double directionShapeHeightsModifier = 20.0;

  int get verticesPerRadian;

  double averageValue = 1.0;

  double averageBarLength = 1.0;

  int numberOfConcentricCircleForEdgeBundling = 3;

  num maxValue = 0.0;

  num minValue = 0.0;

  double get maxSegmentRadius;

  bool drawLabelNum = false;

  List<RangeMath<double>> valueRanges;

  void updateCirclesRadius();

  ShapeForm getShape(String id);

  Map<String, ShapeForm> get listOfShapes;

  DivideType get poincareLinesDivideType;

  set poincareLinesDivideType(DivideType value);

  bool get isVisible;

  bool toggleVisibility();

  bool modifyDiagram();

  List<ShapeForm> getDiagramsShapesPoints(VisualObject rootElement);

  VisConnection getConnectionFromPosition(HomogeneousCoordinate position);

  VisualObject get actualDataObject;

  VisConnection get defaultConnection;

  void changeElementsIndex(String idOne, String idTwo, int indexOne, int indexTwo);

  double get directionsHeight;
}