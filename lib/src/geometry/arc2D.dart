part of visualizationGeometry;

class Arc2D<T extends double, F extends HomogeneousCoordinate<dynamic>> implements Arc<T, F> {

  RangeMath<T> _range;

  SimpleCircle<F> _circle;

  Diagram _diagram;

  set diagram(Diagram diagram){
    this._diagram = diagram;
  }

  Arc2D(this._range, this._circle, this._diagram);

  RangeMath<T> get range => this._range;

  SimpleCircle<F> get circle => this._circle;

  List<F> getListOfPoints([int numberOfVertices = 0]){
    if(numberOfVertices == 0) {
      numberOfVertices = max<double>(
          (this._range.length as double) * this._diagram.verticesPerRadian,
          4.0).toInt();
    }
    T step = (this._range.length / numberOfVertices) as T;

    var retVal = new List<F>();

    var resRanges = this._range.divideEqualParts(numberOfVertices.toInt()-1, defaultSpaceBetweenParts: 0.0 as T);

    for(RangeMath range in resRanges){
      retVal.add(this._circle.getPointFromPolarCoordinate(range.begin as double, true) as F);
    }

    retVal.add(this._circle.getPointFromPolarCoordinate(
        resRanges.last.end as double, true) as F);

    //print(retVal.length);

    return retVal;

    /*return this._range.loopOverRangeElement(step, (T value){
      return this._circle.getPointFromPolarCoordinate(value, true);
    }) as List<F>;*/
  }

  bool isIntersect(Arc another) {
    return !RangeMath.isRangesDisjoint(this._range, another.range);
  }


  bool isPointInRange(F point) {
    return this._range.isValueInRange(
        MathHomogeneous.getPolarCoordinateAngleRangeTwoPI(
            point, this._circle) as T);
  }

  F get end =>
    MathHomogeneous.get2DPolarCoordinates(this._circle, this._range.end) as F;


  F get begin =>
    MathHomogeneous.get2DPolarCoordinates(this._circle, this._range.begin) as F;

  T get beginAngle => this._range.begin;

  T get endAngle => this._range.end;

  PolarCoordinate<T, F> get beginPolarCoordinate =>
      new PolarCoordinate(this._range.begin, this._circle);

  PolarCoordinate<T, F> get endPolarCoordinate =>
      new PolarCoordinate(this._range.end, this._circle);

  set endAngle(T value) {
    this._range.end = value;
  }

  set beginAngle(T value) {
    this._range.begin = value;
  }


  set end(F point) {
    this._range.end =
        MathHomogeneous.getPolarCoordinateAngleRangeTwoPI(
            point, this._circle) as T;
  }


  set begin(F point) {
    this._range.begin =
        MathHomogeneous.getPolarCoordinateAngleRangeTwoPI(
            point, this._circle) as T;
  }

  int compare(Comparable a, Comparable b) {
    return a.compareTo(b);
  }


  int compareTo(Arc<T, F> other) {
    return this._range.compareTo(other.range);
  }

  Arc<T, F> clone() {
    return new Arc2D<T, F>(
        new NumberRange.fromNumbers(
            this._range.begin, this.range.end),
            this._circle.clone(), this._diagram);
  }

  set circle(SimpleCircle<F> value) {
    this._circle = value;
  }

  @override
  set range(RangeMath<T> value) {
    this._range = value;
  }


}