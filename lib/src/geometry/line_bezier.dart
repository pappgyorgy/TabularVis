part of visualizationGeometry;

class Segment<F extends HomogeneousCoordinate<dynamic>>{

  F A;
  F B;

  Segment(this.A, this.B);

  F getPointBasedOnRatio(double ratio){
    var aHelper = A.scale(ratio)..h  = 0.0;
    var bHelper = B.scale(1-ratio)..h = 1.0;
    return (aHelper + bHelper) as F;
  }

  F getPointBasedOnLength(double length){
    var unitVec = (B - A).toUnitVector();
    return (A + unitVec.scale(length)) as F;
  }

}

class LineBezier<T extends double, F extends HomogeneousCoordinate<dynamic>> implements LineGeom<T, F>{

  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> _geomInfo;

  Diagram _diagram;

  Arc<T, F> _lineArc;


  //percent
  static double crest = 0.0;
  static double bezier_radius = 0.0;
  static double bezier_radius_purity = 1.0;

  double get radius{
    return this._diagram.baseCircle.radius;
  }

  double get effectiveBezierRadius{
    //return this._diagram.baseCircle.center.distanceTo(this.bezierControlPoint);

    var midPointDist = this._diagram.baseCircle.center.distanceTo(this.connectionMiddlePoint);
    var deltaRadius = midPointDist - bezierRadius;
    return bezierRadius + ((1-bezier_radius_purity) * deltaRadius);
  }

  double get bezierRadius => bezier_radius * radius;

  F connectionMiddlePoint;
  F directionVector;

  Segment<F> bezierControlPointHelper;
  Segment<F> crestControlPointHelperOne;
  Segment<F> crestControlPointHelperTwo;

  int get segmentNumber => this._diagram.lineSegment;

  factory LineBezier(RangeMath<T> range, SimpleCircle<F> circle, Diagram diagram){
    var lineArc = new Arc<T,F>(range, circle, diagram);
    return new LineBezier.newLineFromPoint(lineArc, diagram);
  }

  LineBezier.newLineFromPoint(this._lineArc, this._diagram){
    this.update();
  }

  List<F> getLinePoints([int numberOfSegment = 0]){
    List<F> retVal = new List<F>();

    var controlPoints = allControlPoints;
    var increaseNumber = 1.0/segmentNumber;
    if(numberOfSegment != 0){
      increaseNumber = 1.0/numberOfSegment;
    }

    for(var t = 0.0; t < 1.0; t += increaseNumber){
      HomogeneousCoordinate res = new HCoordinate3D(new Vector4(0.0,0.0,0.0,1.0));
      int n = 4;
      for (int i = 0; i < 5; i++)
      {
        var biCoeff = BinomialCoefficient(n, i);
        var oneMinusT = pow(1 - t, n - i);
        var powT = pow(t, i);
        res.x += biCoeff * oneMinusT * powT * controlPoints[i].x;
        res.y += biCoeff * oneMinusT * powT * controlPoints[i].y;
      }
      retVal.add(res.clone() as F);
    }
    return retVal;
  }

  F get bezierControlPoint{
    var basicBezierControlPoint = bezierControlPointHelper.getPointBasedOnLength(this.effectiveBezierRadius);
    //var deltaRadiusVec = this.connectionMiddlePoint - basicBezierControlPoint;
    return basicBezierControlPoint;
    /*var deltaRadius = basicBezierControlPoint.distanceTo(this.connectionMiddlePoint);
    return (basicBezierControlPoint +
        this.directionVector.scale(
            (1.0 - bezier_radius_purity) *
                deltaRadius)..h = 0.0) as F;*/
  }

  List<F> get crestControlPoints{
    var retVal = new List<F>();
    var crestLength = (radius + (this.effectiveBezierRadius - radius)) * crest;
    retVal.add(crestControlPointHelperOne.getPointBasedOnLength(crestLength));
    retVal.add(crestControlPointHelperTwo.getPointBasedOnLength(crestLength));
    return retVal;
  }

  List<HomogeneousCoordinate> get allControlPoints{
    var retVal = crestControlPoints;
    retVal.insert(0,this._lineArc.begin);
    retVal.insert(2, bezierControlPoint);
    retVal.add(this._lineArc.end);
    return retVal;
  }

  double BinomialCoefficient(int n, int k)
  {
    if (k > n - k)
      k = n - k;

    var c = 1.0;

    for (int i = 0; i < k; i++)
    {
      c = c * (n - i);
      c = c / (i + 1);
    }
    return c;
  }

  @override
  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> get geomInfo {
    return this._geomInfo;
  }

  @override
  bool get isDivided {
    throw new UnimplementedError("This function is not implemented");
  }

  @override
  List<PolarCoordinate<T, F>> divideLine(List<double> values,
      {DivideType type: DivideType.angle}) {
    throw new UnimplementedError("This function is not implemented");
  }

  @override
  double get lengthOfLine {
    throw new UnimplementedError("This function is not implemented");
  }

  @override
  SimpleCircle<F> get circle {
    throw new UnimplementedError("This function is not implemented");
  }

  @override
  List<PolarCoordinate<T, F>> get dividePoints {
    throw new UnimplementedError("This function is not implemented");
  }

  @override
  Diagram get diagram {
    return this._diagram;
  }

  @override
  Arc<T, F> get lineArc {
    return this._lineArc;
  }

  @override
  void update() {
    this.connectionMiddlePoint = (this._lineArc.begin + this._lineArc.end) as F; //It was already divided because of the implementation of the addition
    this.directionVector = (this.connectionMiddlePoint - (this._diagram.baseCircle.center)).unitVector as F;
    HCoordinate2D finalVector = (this.directionVector.clone() as HCoordinate2D)..scale(this._diagram.baseCircle.radius);
    HCoordinate2D finalPoint = this._diagram.baseCircle.center + finalVector as HCoordinate2D;
    //TODO optimization

    this.bezierControlPointHelper = new Segment<F>(this._diagram.baseCircle.center as F, finalPoint as F);
    this.crestControlPointHelperOne = new Segment<F>(this._lineArc.begin, this._diagram.baseCircle.center as F);
    this.crestControlPointHelperTwo = new Segment<F>(this._lineArc.end, this._diagram.baseCircle.center as F);
  }

}



/*// Control points used to calculate the position
public List<Transform> controlPoints = new List<Transform>();

// This method is used by the Incoming object class to calculate its next position
public override Vector2 CalculatePosition(float t)
{
  Vector2 res = new Vector2(0.0f, 0.0f);
  int n = controlPoints.Count - 1;
  for (int i = 0; i < controlPoints.Count; i++)
  {
    float biCoeff = BinomialCoefficient((float)n, (float)i);
    float oneMinusT = Mathf.Pow(1 - t, n - i);
    float powT = Mathf.Pow(t, i);
    res.x += (float)biCoeff * oneMinusT * powT * controlPoints[(int)i].position.x;
res.y += (float)biCoeff * oneMinusT * powT * controlPoints[(int)i].position.y;
}
return res;
}

// Helper
private float BinomialCoefficient(float n, float k)
{
  if (k > n - k)
    k = n - k;

  float c = 1;

  for (int i = 0; i < k; i++)
  {
    c = c * (n - i);
    c = c / (i + 1);
  }
  return c;
}*/