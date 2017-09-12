part of visualizationGeometry;

/*class UniformShape<T extends double, F extends HomogeneousCoordinate<dynamic>> implements ShapeForm<T, F>{

  List<Line<T, F>> _lines = <Line<T, F>>[];

  Diagram _diagram;

  bool _isDrawable = true;

  ShapeForm<T, F> _parent;

  Map<String, ShapeForm<T, F>> _children = new Map<String, ShapeForm<T, F>>();

  UniformShape(LineType lineType,
      RangeMath<T> rangeOne, RangeMath<T> rangeTwo,
      SimpleCircle<F> circleOne, SimpleCircle<F> circleTwo,
      this._diagram){

    this._lines.add(new Line(lineType, this._diagram, circleOne, rangeOne));
    this._lines.add(new Line(lineType, this._diagram, circleTwo, rangeTwo));
  }

  @override
  List<List<T>> generatePointData() {

  }

  @override
  Map<String, ShapeForm<T, F>> get children {
    return this._children;
  }

  @override
  ShapeForm<T, F> getChildByID(String ID) {
    return this._children[ID];
  }

  @override
  set isDrawable(bool value) {
    this._isDrawable = value;
  }

  @override
  int compareTo(ShapeForm other) {

  }

  @override
  Map<String, ShapeForm> dividedLinesPoint(Map<String, double> values) {

  }

  @override
  void setChild(ShapeForm<T, F> child, String ID) {
    this._children[ID] = child;
  }

  @override
  ShapeForm<T, F> get parent {

  }

  @override
  void modifyGeometry(bool is3D,
      SimpleCircle<HomogeneousCoordinate> innerCircle, double innerRangeBegin,
      double innerRangeEnd, SimpleCircle<HomogeneousCoordinate> outerCircle,
      double outerRangeBegin, double outerRangeEnd, Diagram diagram, [ShapeForm<
          double,
          HomogeneousCoordinate> parent = null, String key = "", double height = 10.0]) {

  }

  @override
  void switchShape(ShapeForm other) {

  }

  @override
  bool pointIsInShape(F point) {

  }

  @override
  bool get isDrawable {

  }

  @override
  GeometryData<T, F> get geometryInformation {

  }


}*/