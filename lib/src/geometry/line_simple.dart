part of visualizationGeometry;

class LineSimple<T extends double, F extends HomogeneousCoordinate<dynamic>> implements LineGeom<T, F>{

  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> _geomInfo;

  Arc<T, F> _lineArc;

  Diagram _diagram;

  List<PolarCoordinate<T, F>> _dividePoints;

  bool _isDivided = false;

  LineSimple(RangeMath<T> range, SimpleCircle<F> circle, this._diagram){
    this._lineArc = new Arc<T,F>(range, circle, this._diagram);
  }

  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> get geomInfo{
    return this._geomInfo;
  }

  Arc<T, F> get lineArc{
    return this._lineArc;
  }

  Diagram get diagram{
    return this._diagram;
  }

  List<PolarCoordinate<T, F>> get dividePoints{
    return this._dividePoints;
  }

  SimpleCircle<F> get circle{
    return this._lineArc.circle;
  }

  double get lengthOfLine{
    return this._lineArc.circle.radius * (this._lineArc.range.length as T);
  }

  List<F> getLinePoints([int numberOfSegment = 0]){
    return this._lineArc.getListOfPoints(numberOfSegment);
  }

  List<PolarCoordinate<T, F>> divideLine(
      List<T> values, {DivideType type: DivideType.angle}){

    this._isDivided = true;

    this._dividePoints = new List<PolarCoordinate<T, F>>();

    this._dividePoints.add(this._lineArc.beginPolarCoordinate);
    for(RangeMath range in this._lineArc.range.dividePartsByValue(values, defaultSpaceBetweenParts: 0.0 as T)){
      this._dividePoints.add(new PolarCoordinate<T, F>(range.end as T, this._lineArc.circle));
    }
    this._dividePoints[this._dividePoints.length-1] = (this._lineArc.endPolarCoordinate);

    return this._dividePoints;
  }

  bool get isDivided{
    return this._isDivided;
  }

  @override
  void update() => super.update();
}