part of visualizationGeometry;

enum DivideType{
  angle, apollonian
}

enum LineType{
  simple, poincare, bezier, bezierExt
}

abstract class LineGeom<T extends double, F extends HomogeneousCoordinate<dynamic>>{

  factory LineGeom(LineType type, Diagram diagram, SimpleCircle<F> circle, RangeMath<T> range, [F pointOne, F pointTwo, double blockMiddle, double blockMiddle2, double connMiddleA, double connMiddleB, bool secondary]){
    switch(type){
      case LineType.simple:
          return new LineSimple(range, circle, diagram);
        break;
      case LineType.poincare:
          return new LinePoincare(range, circle, pointOne, pointTwo, diagram);
        break;
      case LineType.bezier:
        return new LineBezier(range, circle, diagram);
        break;
      case LineType.bezierExt:
        return new LineBezierExt(range, circle, diagram, blockMiddle, blockMiddle2, connMiddleA, connMiddleB, secondary);
        break;
      default:
          throw new StateError("This LineType: $type not exists");
        break;
    }
  }

  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> get geomInfo;

  Arc<T, F> get lineArc;

  Diagram get diagram;

  List<PolarCoordinate<T, F>> get dividePoints;

  SimpleCircle<F> get circle;

  double get lengthOfLine;

  List<F> getLinePoints([int numberOfSegment = 0]);

  List<PolarCoordinate<T, F>> divideLine(
      List<T> values, {DivideType type: DivideType.angle});

  bool get isDivided;

  void update(){
    print("No need for further update");
  }
}