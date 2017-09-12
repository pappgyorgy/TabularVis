part of visualizationGeometry;

abstract class GeometryData<T extends double,
  F extends HomogeneousCoordinate<dynamic>>{

  factory GeometryData(Diagram diagram,
      List<RangeMath<T>> ranges,
      List<SimpleCircle<F>> circles,
      [bool is3D = false, double height = 10.0]){
    try {
      if (circles.length == 0) {
        return new DataGeometry<T, F>.oneArc(
            diagram, ranges.first, circles.first, is3D, height
        );
      } else if (circles.length == 1) {
        {
          return new DataGeometry<T, F>.twoArc(
              diagram,
              ranges.first, ranges.last,
              circles.first, circles.last, is3D, height
          );
        }
      }
    }catch(error, stacktrace){
      print("Error message: $error\nStacktrace: $stacktrace");
      throw new StateError("wrong array length");
    }

    throw new StateError("wrong gemometry data type");
  }

  static const double defaultHeight = 10.0;

  List<Arc<T,F>> get shapeLines;

  Arc<T,F> get innerArc;

  Arc<T,F> get outerArc;

  set innerArc(Arc<T,F> value);

  set outerArc(Arc<T,F> value);

  double get differenceOfInnerAndOuterArc;

  List<List<F>> get listOfPoints;

  bool get is3D;

  double get height;

  bool toggleBetween2D_3D({double height: defaultHeight});

  void copy(GeometryData<T,F> other);

  void modify(bool is3D,
      SimpleCircle<F> innerCircle,
      T innerRangeBegin, T innerRangeEnd,
      SimpleCircle<F> outerCircle,
      T outerRangeBegin, T outerRangeEnd, Diagram diagram, {double height: 10.0});

  ///Return with the [innerArc] and the [outerArc] circles if one of them is containing the other
  ///The [List<SimpleCircle>] first element is the circle which is containing the other circle and
  ///the other element of the list is the other circle.
  ///If the any of the circles not containing the other then the list will return with zero element.
  ///Geogebra:
  /// Whew i is the distance between the two circle center.
  /// If[(i  <  radiusTwo) ? (radiusTwo - i > radiusOne), true, false]
  List<SimpleCircle> get circleInCircle;

  GeometryData<T, F> clone();
}