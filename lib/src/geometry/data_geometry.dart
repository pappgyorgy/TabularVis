part of visualizationGeometry;

class DataGeometry<T extends double, F extends HomogeneousCoordinate<dynamic>> implements GeometryData<T, F> {

  bool _is3D;
  List<Arc<T, F>> _shapeLines =
    new List<Arc<T, F>>();
  double _height;

  Diagram _diagram;

  DataGeometry(this._is3D, this._shapeLines, this._height, this._diagram);

  DataGeometry.fromData(this._diagram, RangeMath<T> rangeOne, RangeMath<T> rangeTwo,
      SimpleCircle<F> circleOne,
      SimpleCircle<F> circleTwo,
      [bool this._is3D = false, double this._height = 10.0]){

    this._shapeLines[0] = new Arc<T, F>(rangeOne,
        circleOne, this._diagram);
    this._shapeLines[1] = new Arc<T, F>(rangeTwo,
        circleTwo, this._diagram);
  }

  DataGeometry.oneArc(this._diagram, RangeMath<T> range, SimpleCircle<F> circle,
      [bool this._is3D = false, double this._height = 10.0]){

    this._shapeLines.add(new Arc<T, F>(range, circle, this._diagram));
  }

  DataGeometry.twoArc(this._diagram,
      RangeMath<T> rangeOne, RangeMath<T> rangeTwo,
      SimpleCircle<F> circleOne, SimpleCircle<F> circleTwo,
      [bool this._is3D = false, double this._height = 10.0]){

    this._shapeLines.add(new Arc<T, F>(rangeOne,
        circleOne, this._diagram));
    this._shapeLines.add(new Arc<T, F>(rangeTwo,
        circleTwo, this._diagram));
  }

  DataGeometry.fromRawData(this._is3D, SimpleCircle<F> innerCircle, double innerRangeBegin, double innerRangeEnd,
                           SimpleCircle<F> outerCircle, double outerRangeBegin, double outerRangeEnd, this._diagram, {double height: 10.0}){
    this._shapeLines = new List(2);
    this._shapeLines[0] = new Arc<T, F>(
        new NumberRange.fromNumbers(
            innerRangeBegin, innerRangeEnd) as RangeMath<T>,
            innerCircle, this._diagram);
    this._shapeLines[1] = new Arc<T, F>(
        new NumberRange.fromNumbers(
            outerRangeBegin, outerRangeEnd) as RangeMath<T>,
            outerCircle, this._diagram);
    if(this._is3D){
      this._height = height;
    }
  }

  DataGeometry.fromDefaultValues(this._is3D, double innerRangeBegin, double innerRangeEnd,
                                 double outerRangeBegin, double outerRangeEnd, this._diagram){
    throw new UnimplementedError("Need default values to implement this feature");
  }

  DataGeometry.fromOneCircle(this._is3D, SimpleCircle<F> innerCircle, double innerRangeBegin, double innerRangeEnd,
                             double outerCircleDistance, double outerRangeBegin, double outerRangeEnd,
                             this._diagram, {double height: 10.0}){
    this._shapeLines = new List(2);
    this._shapeLines[0] = new Arc<T,F>(
        new NumberRange.fromNumbers(
            innerRangeBegin, innerRangeEnd) as RangeMath<T>,
        innerCircle, this._diagram);
    this._shapeLines[1] = new Arc<T,F>(
        new NumberRange.fromNumbers(
            outerRangeBegin, outerRangeEnd) as RangeMath<T>,
        new HCircle2D(
            innerCircle.center as HCoordinate2D,
            innerCircle.radius + outerCircleDistance) as SimpleCircle<F>,
        this._diagram);
    if(this._is3D){
      this._height = height;
    }
  }

  void modify(bool is3D,
      SimpleCircle<F> innerCircle,
      T innerRangeBegin, T innerRangeEnd,
      SimpleCircle<F> outerCircle,
      T outerRangeBegin, T outerRangeEnd, Diagram diagram, {double height: 10.0}){

    this._shapeLines[0].range.begin = innerRangeBegin;
    this._shapeLines[0].range.end = innerRangeEnd;
    this._shapeLines[0].circle = innerCircle;
    this._shapeLines[0].diagram = diagram;

    this._shapeLines[1].range.begin = outerRangeBegin;
    this._shapeLines[1].range.end = outerRangeEnd;
    this._shapeLines[1].circle = outerCircle;
    this._shapeLines[1].diagram = diagram;

    if(is3D){
      this._height = height;
    }
  }

  List<Arc<T, F>> get shapeLines {
    return this._shapeLines.toList(growable: false);
  }


  List<List<F>> get listOfPoints {
    var result = new List<List<F>>();

    for (Arc<T, F> line in this._shapeLines) {
      result.add(line.getListOfPoints());
    }

    return result;
  }


  List<SimpleCircle> get circleInCircle {
    if(this._shapeLines.first.circle.isCircleInCircle(this._shapeLines.last.circle as SimpleCircle<HomogeneousCoordinate<Vector3>>)){
      return [this._shapeLines.first.circle, this._shapeLines.last.circle];
    }else if(this._shapeLines.last.circle.isCircleInCircle(this._shapeLines.first.circle as SimpleCircle<HomogeneousCoordinate<Vector3>>)){
      return [this._shapeLines.last.circle, this._shapeLines.first.circle];
    }
    return [];
  }

  bool get is3D => this._is3D;

  double get height => this._height;

  bool toggleBetween2D_3D({double height: GeometryData.defaultHeight}) {
    this._is3D = !this._is3D;
    if (this._is3D) {
      this._height = height;
    } else {
      this._height = 0.0;
    }
    return this._is3D;
  }

  double get differenceOfInnerAndOuterArc{
    return (this._shapeLines.first.range.length - this._shapeLines.last.range.length).abs() as double;
  }

  Arc<T, F> get innerArc => this._shapeLines.first;

  Arc<T, F> get outerArc => this._shapeLines.last;

  set innerArc(Arc<T, F> value) {
    this._shapeLines[0] = value;
  }

  set outerArc(Arc<T, F> value) {
    this._shapeLines[1] = value;
  }

  GeometryData<T, F> clone() {
    return new DataGeometry.fromRawData(this._is3D, this.innerArc.circle,
                                        this.innerArc.beginAngle, this.innerArc.endAngle,
                                        this.outerArc.circle, this.outerArc.beginAngle,
                                        this.outerArc.endAngle, this._diagram, height: this.height);
  }

  void copy(GeometryData<T, F> other) {
    this._is3D = other.is3D;
    this._shapeLines[0] = other.innerArc.clone();
    this._shapeLines[1] = other.outerArc.clone();
    this._height = other.height;
  }

}