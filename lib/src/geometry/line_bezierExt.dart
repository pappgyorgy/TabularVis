part of visualizationGeometry;

class LineBezierExt<T extends double, F extends HomogeneousCoordinate<dynamic>> implements LineGeom<T, F> {

  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> _geomInfo;

  Diagram _diagram;

  Arc<T, F> _lineArc;

  double groupMiddle = 0.0;
  double groupMiddle2 = 0.0;
  double connMiddleA = 0.0;
  double connMiddleB = 0.0;

  bool updateControlPoints = false;

  List<double> weights = [1.0, 150.0, 350.0, 100.0, 350.0, 150.0, 1.0];

  //List<double> weights = [1.0, 200.0, 25.0, 300.0, 1050.0, 1200.0, 1500.0, 3000.0, 3000.0, 3000.0, 1500.0, 1200.0, 1050.0, 300.0, 25.0, 200.0, 1.0];

  //List<double> weights = [1.0, 200.0, 25.0, 300.0, 650.0, 650.0, 400.0, 300.0, 300.0, 300.0, 400.0, 650.0, 650.0, 300.0, 25.0, 200.0, 1.0];

  //List<double> weights = [1.0, 100.0, 150.0, 150.0, 150.0, 100.0, 1.0];

  //List<double> weights = [1.0, 25.0, 100.0, 150.0, 100.0, 1.0, 50.0, 100.0, 10.0, 5.0, 1.0];

  //List<double> weights = [1.0, 25.0, 100.0, 150.0, 300.0, 400.0, 300.0, 150.0, 100.0, 25.0, 1.0];

  //List<double> weights = [1.0, 25.0, 100.0, 200.0, 800.0, 200.0, 100.0, 25.0, 1.0];

  //List<double> weights2 = [1.0, 25.0, 100.0, 300.0, 700.0, 300.0, 100.0, 25.0, 1.0];

  SimpleCircle<F> fractionCircle;

  List<F> listOfControlPoints = new List<F>(17);

  //List<double> weights = [1.0, 3.0, 8.0, 3.0, 1.0];

  //percent
  static double crest = 0.0;
  static double bezier_radius = 0.0;
  static double bezier_radius_purity = 1.0;

  double cosAngleBetweenBlockMiddleAndEndPoint;

  bool secondary;

  double get radius {
    return this._diagram.baseCircle.radius;
  }

  double get effectiveBezierRadius {
    //return this._diagram.baseCircle.center.distanceTo(this.bezierControlPoint);

    var midPointDist = this._diagram.baseCircle.center.distanceTo(
        this.connectionMiddlePoint);
    var deltaRadius = midPointDist - bezierRadius;
    return bezierRadius + ((1 - bezier_radius_purity) * deltaRadius);
  }

  double get bezierRadius => bezier_radius * radius;

  F connectionMiddlePoint;
  F directionVector;

  int get segmentNumber => this._diagram.lineSegment;


  factory LineBezierExt(RangeMath<T> range, SimpleCircle<F> circle,
      Diagram diagram, double groupMiddle, double groupMiddle2, double connMiddleA, double connMiddleB, bool secondary){
    var lineArc = new Arc<T, F>(range, circle, diagram);
    secondary = secondary == null ? false : secondary;
    return new LineBezierExt.newLineFromPoint(lineArc, diagram, groupMiddle, groupMiddle2, connMiddleA, connMiddleB, secondary);
  }

  LineBezierExt.newLineFromPoint(this._lineArc, this._diagram,
      this.groupMiddle, this.groupMiddle2, double connMiddleA, double connMiddleB, this.secondary){
    this.connMiddleA = connMiddleA;
    this.connMiddleB = connMiddleB;
    this.update();
  }

  List<F> getLinePoints([int numberOfSegment = 0]) {
    List<F> retVal = new List<F>();

    numberOfSegment =
    numberOfSegment == 0 ? this.segmentNumber : numberOfSegment;

    //this.listOfControlPoints = this.listOfControlPoints.reversed.toList();
    //this.weights = this.weights.reversed.toList();

    List<double> listOfBernsteinPolynom = new List<double>(7);
    for (var t = 0.0; t < 1.0; t += 1.0 / numberOfSegment) {
      int n = 6;
      double sumOfBernsteinPolynom = 0.0,
          x = 0.0,
          y = 0.0;
      for (int i = 0; i < 7; i++) {
        listOfBernsteinPolynom[i] =
            BinomialCoefficient(n, i) * pow(1 - t, n - i) * pow(t, i) *
                weights[i];
        sumOfBernsteinPolynom += listOfBernsteinPolynom[i];
      }
      for (int i = 0; i < 7; i++) {
        x += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
            this.listOfControlPoints[i].x;
        y += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
            this.listOfControlPoints[i].y;
      }
      retVal.add(
          new HomogeneousCoordinate(CoordinateType.threeDim, x, y, 0.0, 1.0));
    }


    return retVal;
  }

  List<F> getLinePoints3([int numberOfSegment = 0]) {
    List<F> retVal = new List<F>();

    numberOfSegment =
    numberOfSegment == 0 ? this.segmentNumber : numberOfSegment;

    //this.listOfControlPoints = this.listOfControlPoints.reversed.toList();
    //this.weights = this.weights.reversed.toList();

    List<double> listOfBernsteinPolynom = new List<double>(9);
    for (var t = 0.0; t < 1.0; t += 1.0 / numberOfSegment) {
      int n = 8;
      double sumOfBernsteinPolynom = 0.0,
          x = 0.0,
          y = 0.0;
      for (int i = 0; i < 9; i++) {
        listOfBernsteinPolynom[i] =
            BinomialCoefficient(n, i) * pow(1 - t, n - i) * pow(t, i) *
                weights[i];
        sumOfBernsteinPolynom += listOfBernsteinPolynom[i];
      }
      for (int i = 0; i < 9; i++) {
        x += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
            this.listOfControlPoints[i].x;
        y += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
            this.listOfControlPoints[i].y;
      }
      retVal.add(
          new HomogeneousCoordinate(CoordinateType.threeDim, x, y, 0.0, 1.0));
    }


    return retVal;
  }

  List<F> getLinePoints2([int numberOfSegment = 0]) {
    List<F> retVal = new List<F>();

    numberOfSegment =
    numberOfSegment == 0 ? this.segmentNumber : numberOfSegment;

    //this.listOfControlPoints = this.listOfControlPoints.reversed.toList();
    //this.weights = this.weights.reversed.toList();

    List<double> listOfBernsteinPolynom = new List<double>(11);
    for (var t = 0.0; t < 1.0; t += 1.0 / numberOfSegment) {
      int n = 10;
      double sumOfBernsteinPolynom = 0.0,
          x = 0.0,
          y = 0.0;
      for (int i = 0; i < 11; i++) {
        listOfBernsteinPolynom[i] =
            BinomialCoefficient(n, i) * pow(1 - t, n - i) * pow(t, i) *
                weights[i];
        sumOfBernsteinPolynom += listOfBernsteinPolynom[i];
      }
      for (int i = 0; i < 11; i++) {
        x += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
            this.listOfControlPoints[i].x;
        y += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
            this.listOfControlPoints[i].y;
      }
      retVal.add(
          new HomogeneousCoordinate(CoordinateType.threeDim, x, y, 0.0, 1.0));
    }


    return retVal;
  }

  F get begin{
    if(this.listOfControlPoints[0] == null || this.updateControlPoints){
      this.calculateEndPoints();
    }
    return this.listOfControlPoints[0];
  }

  F get end{
    if(this.listOfControlPoints[10] == null || this.updateControlPoints){
      this.calculateEndPoints();
    }
    return this.listOfControlPoints[10];
  }

  F _blockMidPoint;
  F get blockMidPoint{
    if(this._blockMidPoint == null){
      this._blockMidPoint = this._diagram.drawCircle.getPointFromPolarCoordinate(this.groupMiddle);
    }
    return this._blockMidPoint;
  }

  void calculateEndPoints(){ // P0 and O
    listOfControlPoints[0] = this._lineArc.end;
    listOfControlPoints[10] = this._lineArc.begin;
  }

  void calculateAngleBetweenBlockMidAndEndPoint(){
    //this.cosAngleBetweenBlockMiddleAndEndPoint = (this.begin as HomogeneousCoordinate).dotProduct(this.blockMidPoint);
    this.cosAngleBetweenBlockMiddleAndEndPoint = (this.begin as HomogeneousCoordinate).dotProduct(this.end);
  }

  //I n + (1 - n) F
  F get connectionMidPoint{ //P2
    if(this.listOfControlPoints[4] == null || this.updateControlPoints){
      double blockMiddleOpposite = this.groupMiddle + pi;
      var maxMidPointPos = this.fractionCircle.getPointFromPolarCoordinate(blockMiddleOpposite);
      var ratio = max(-this.cosAngleBetweenBlockMiddleAndEndPoint, 0);

      this.listOfControlPoints[4] = (maxMidPointPos.scale(ratio)..z = 0.0) + (this.circleMidPoint.scale(1-ratio)..z = 0.0);
    }

    return this.listOfControlPoints[4]..z = 1.0;

  }

  F get circleMidPoint{
    if(this.listOfControlPoints[6] == null || this.updateControlPoints){
      this.listOfControlPoints[6] = this._diagram.baseCircle.center.clone();
    }
    return this.listOfControlPoints[6];

  }

  F get midPointPartATangent{ // P3
    if(this.listOfControlPoints[3] == null || this.updateControlPoints) {
      var ratio = (this.cosAngleBetweenBlockMiddleAndEndPoint + 1) / 2;
      this.listOfControlPoints[3] = (this.begin.clone().scale(ratio)..z = 0.0) +
          (this.connectionMidPoint.clone().scale(1 - ratio)..z = 0.0);
    }
    return this.listOfControlPoints[3]..z = 1.0;
  }

  F get midPointPartBTangent{ // P4
    if(this.listOfControlPoints[5] == null || this.updateControlPoints) {
      var ratio = (this.cosAngleBetweenBlockMiddleAndEndPoint + 1) / 2;
      this.listOfControlPoints[5] = (this.end.clone().scale(ratio)..z = 0.0) +
          (this.connectionMidPoint.clone().scale(1 - ratio)..z = 0.0);
    }
    return this.listOfControlPoints[5]..z = 1.0;
  }

  // Point(C, Vector(UnitVector(Vector(p_0, F)) test_2 Distance(L, I)))
  // Test2 = If(a_1 < π / 2, d_1, decVal)
  // a_1 = acos(UnitVector(Vector(F, p_0)) UnitVector(Vector(F, L)))
  // b_ 1 = sgn(t)
  // t = cos(a_1)
  F get partAFractionPoint{
    if(this.listOfControlPoints[1] == null || this.updateControlPoints) {
      double blockMiddleOpposite = this.groupMiddle + pi;
      var blockMidPointPosOpposite = this._diagram.drawCircle.getPointFromPolarCoordinate(blockMiddleOpposite);
      var t = (this.begin as HomogeneousCoordinate).dotProduct(blockMidPointPosOpposite);
      var angleBetwwenEndAndStartOpposite = acos(t);
      var dist = this._diagram.drawCircle.radius - this.fractionCircle.radius;

      var ratio = max(-this.cosAngleBetweenBlockMiddleAndEndPoint, 0);

      var decreaseVal = -(sin(angleBetwwenEndAndStartOpposite - ratio / 2)).abs()*dist;

      var s = -cos(pi - pi / 4);
      var o = 1 - (cos(angleBetwwenEndAndStartOpposite * 2)).abs();

      var p = (1 - s) * this.fractionCircle.radius * o;

      var test = angleBetwwenEndAndStartOpposite < (pi/2) ? p : decreaseVal;

      this.listOfControlPoints[1] = (this.fractionCircle.clone()
        ..radius -= test).getPointFromPolarCoordinate(this.lineArc.range.end);
    }
    return this.listOfControlPoints[1];
  }

  F get partBFractionPointA{
    if(this.listOfControlPoints[9] == null || this.updateControlPoints) {
      this.listOfControlPoints[9] = this.fractionCircle.getPointFromPolarCoordinate(this.lineArc.range.begin);
    }
    return this.listOfControlPoints[9];
  }

  double sinh(double x){
    return (1 - exp(-2*x)) / (2 * exp(-x));
  }

  double cosh(double x){
    return (1 + exp(-2*x)) / (2 * exp(-x));
  }

  double tanh(double x){
    return sinh(x) / cosh(x);
  }

  F get partBFractionPointB{
    if(this.listOfControlPoints[7] == null || this.updateControlPoints) {
      var a = this.groupMiddle;
      double b = this.lineArc.range.begin;

      var pointA = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleA);
      var pointB = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleB);

      var t = acos((pointA as HomogeneousCoordinate).dotProduct(pointB));

      var test = t < (pi/4) ? min(sin(t) * 3, 1.0) : 0;

      var range = b * test + a * (1-test);

      this.listOfControlPoints[7] = this.fractionCircle.getPointFromPolarCoordinate(range);
    }
    return this.listOfControlPoints[7];
  }

  F get partAFractionMid{
    if(this.listOfControlPoints[2] == null || this.updateControlPoints) {
      this.listOfControlPoints[2] = ((this.partAFractionPoint..z = 0.0) + (this.midPointPartATangent..z = 0.0)).scale(0.5);
    }
    return this.listOfControlPoints[2]..z = 1.0;
  }

  F get partBFractionMid{
    if(this.listOfControlPoints[8] == null || this.updateControlPoints) {
      this.listOfControlPoints[8] = ((this.partBFractionPointA..z = 0.0) + (this.partBFractionPointB..z = 0.0)).scale(0.5);
    }
    return this.listOfControlPoints[8]..z = 1.0;
  }

  double BinomialCoefficient(int n, int k) {
    if (k > n - k)
      k = n - k;

    var c = 1.0;

    for (int i = 0; i < k; i++) {
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

  F getSumOfBernstenDerivative(double t){
    List<double> listOfBernsteinPolynom = new List<double>(10);

    int n = 9;
    double x = 0.0, y = 0.0;
    for (int i = 0; i < 10; i++) {
      listOfBernsteinPolynom[i] =
          BinomialCoefficient(n, i) * pow(1 - t, n - i) * pow(t, i);
    }
    for (int i = 0; i < 10; i++) {
      x += (listOfBernsteinPolynom[i]) * (this.weights[i+1] - this.weights[i]);
      y += (listOfBernsteinPolynom[i]) * (this.weights[i+1] - this.weights[i]);
    }

    return new HomogeneousCoordinate(CoordinateType.threeDim, n*x, n*y, 0.0, 1.0);
  }

  F getBezierDerivative(double t){

    List<double> listOfBernsteinPolynom = new List<double>(10);

    int n = 9;
    double x = 0.0, y = 0.0;
    for (int i = 0; i < 10; i++) {
      listOfBernsteinPolynom[i] =
          BinomialCoefficient(n, i) * pow(1 - t, n - i) * pow(t, i);
    }
    for (int i = 0; i < 10; i++) {
      x += (listOfBernsteinPolynom[i]) *
          ((this.listOfControlPoints[i + 1].x * this.weights[i+1]) -
              (this.listOfControlPoints[i].x * this.weights[i]));
      y += (listOfBernsteinPolynom[i]) *
          ((this.listOfControlPoints[i + 1].y * this.weights[i+1]) -
              (this.listOfControlPoints[i].y * this.weights[i]));
    }

    return new HomogeneousCoordinate(CoordinateType.threeDim, n*x, n*y, 0.0, 1.0);
  }

  F getValue(double t){
    List<double> listOfBernsteinPolynom = new List<double>(11);
    int n = 10;
    double sumOfBernsteinPolynom = 0.0,
        x = 0.0,
        y = 0.0;
    for (int i = 0; i < 11; i++) {
      listOfBernsteinPolynom[i] =
          BinomialCoefficient(n, i) * pow(1 - t, n - i) * pow(t, i) *
              weights[i];
      sumOfBernsteinPolynom += listOfBernsteinPolynom[i];
    }
    for (int i = 0; i < 11; i++) {
      x += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
          this.listOfControlPoints[i].x;
      y += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
          this.listOfControlPoints[i].y;
    }
    return new HomogeneousCoordinate(CoordinateType.threeDim, x, y, 0.0, 1.0);
  }

  F getTanget(double t){
    List<double> listOfBernsteinPolynom = new List<double>(11);
    int n = 10;
    double sumOfBernsteinPolynom = 0.0,
        x = 0.0,
        y = 0.0;
    for (int i = 0; i < 11; i++) {
      listOfBernsteinPolynom[i] =
          BinomialCoefficient(n, i) * pow(1 - t, n - i) * pow(t, i) *
              weights[i];
      sumOfBernsteinPolynom += listOfBernsteinPolynom[i];
    }
    for (int i = 0; i < 11; i++) {
      x += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
          this.listOfControlPoints[i].x;
      y += (listOfBernsteinPolynom[i] / sumOfBernsteinPolynom) *
          this.listOfControlPoints[i].y;
    }

    var stDerive = getBezierDerivative(t);
    var wtDerive = getSumOfBernstenDerivative(t);

    var tangentX = (stDerive.x - wtDerive.x * x) / sumOfBernsteinPolynom;
    var tangentY = (stDerive.y - wtDerive.y * y) / sumOfBernsteinPolynom;

    return new HomogeneousCoordinate(CoordinateType.threeDim, tangentX, tangentY, 0.0, 1.0);
  }

  F getFalseTangent(F pointA, F pointB){
    var res = (pointA - pointB).normalize().toUnitVector();
    var helper = res.x;
    res.x = -res.y;
    res.y = helper;
    return res;
  }

  RangeMath<double> convertBack(RangeMath<double> range){
    double a = (range.begin % (2*pi));
    double b = (range.end % (2*pi));
    var retVal = new NumberRange.fromNumbers(a, b);
    if((a-b).abs() > pi){
      if(retVal.begin < retVal.end){
        retVal.begin += 2*pi;
      }else{
        retVal.end += 2*pi;
      }
    }

    return retVal;
  }

  @override
  void update() {

    this.updateControlPoints = true;

    this.calculateEndPoints();
    this.calculateAngleBetweenBlockMidAndEndPoint();
    this.fractionCircle = this._diagram.drawCircle.clone()..radius *= 0.95;

    this.blockMidPoint;

    //this.begin;
    //this.end;
    /*this.circleMidPoint;
    this.connectionMidPoint;
    this.midPointPartATangent;
    this.midPointPartBTangent;
    this.partAFractionPoint;
    this.partBFractionPointA;
    this.partBFractionPointB;
    this.partAFractionMid;
    this.partBFractionMid;*/

    this.listOfControlPoints[0] = this._lineArc.end;
    this.listOfControlPoints[6] = this._lineArc.begin;

    List<RangeMath<double>> ratioRanges = new NumberRange<double>.fromNumbers(0.1,0.3).divideEqualParts(3, defaultSpaceBetweenParts: 0.0);

    //var radiusRatio = (((cos(limitedRange.begin - limitedRange.end) + 1) / 2.0) * 0.8) + 0.2;
    var radiusRatio = ((((cos(connMiddleA - connMiddleB) + 1) / 2.0) * 0.2) + 0.1);

    var finalRatio = 0.9;
    /*if(radiusRatio > 0.1) {
      for (var i = 0; i < ratioRanges.length; i++) {
        if (ratioRanges[i].isValueInRange(radiusRatio)) {
          finalRatio = 1-ratioRanges[i].begin;
          break;
        }
      }
    }*/

    //finalRatio = 1-radiusRatio;

    var innerCircle = this.fractionCircle.clone()..radius *= finalRatio;

    this.listOfControlPoints[1] = innerCircle.getPointFromPolarCoordinate(this.lineArc.range.end);

    this.listOfControlPoints[5] = innerCircle.getPointFromPolarCoordinate(this.lineArc.range.begin);

    this.listOfControlPoints[4] = innerCircle.getPointFromPolarCoordinate(this.groupMiddle);

    this.listOfControlPoints[3] = this._diagram.baseCircle.center.clone();

    this.listOfControlPoints[2] = innerCircle.getPointFromPolarCoordinate(this.groupMiddle2);

    /*this.listOfControlPoints[0] = this._lineArc.end;
    this.listOfControlPoints[16] = this._lineArc.begin;

    var limitedRange = convertBack(this.lineArc.range);

    var connMidRange = MathFunc.getMidRange(limitedRange.begin, limitedRange.end);

    var connMidRangeA = MathFunc.getMidRange(min(limitedRange.begin, connMidRange), max(limitedRange.begin, connMidRange));

    var connMidRangeB = MathFunc.getMidRange(min(limitedRange.end, connMidRange), max(limitedRange.end, connMidRange));

    //var lowestValue = secondary ? 0.35 : 0.4;

    List<RangeMath<double>> ratioRanges = new NumberRange<double>.fromNumbers(0.2,1.0).divideEqualParts(this.diagram.numberOfConcentricCircleForEdgeBundling, defaultSpaceBetweenParts: 0.0);

    //var radiusRatio = (((cos(limitedRange.begin - limitedRange.end) + 1) / 2.0) * 0.8) + 0.2;
    //var radiusRatio = (((cos(connMiddleA - connMiddleB) + 1) / 2.0) * (1.0 - 0.2)) + 0.2;
    var radiusRatio = tanh((cos((connMiddleA - connMiddleB)/2.0)).abs()) * (0.8/tanh(1.0)) + 0.2;

    //var finalRatio = radiusRatio;

    var finalRatio = 0.1;
    if(radiusRatio > 0.2){
      for(var i = 0; i < ratioRanges.length; i++){
        if(ratioRanges[i].isValueInRange(radiusRatio)){
          finalRatio = ratioRanges[i].begin;
          break;
        }
      }
    }

    var innerCircle = this.fractionCircle.clone()..radius = (this.fractionCircle.clone().radius * finalRatio);

    if(secondary){
      if(radiusRatio > 0.2){
        innerCircle.radius += min(this._diagram.averageBarLength, 5.0);
      }else
        innerCircle.radius += min(this._diagram.averageBarLength, 5.0);
    }

    var innerCircle2 = (innerCircle.clone()..radius *= 1.2);

    this.listOfControlPoints[1] = this.fractionCircle.getPointFromPolarCoordinate(this.lineArc.range.end);

    var a2 = this.groupMiddle2;
    double b2 = this.lineArc.range.end;

    var pointA2 = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleA);
    var pointB2 = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleB);

    var t2 = acos((pointA2 as HomogeneousCoordinate).dotProduct(pointB2));

    var test2 = t2 < (pi/4) ? min(sin(t2) * 4, 1.0) : 0;

    var range2 = b2 * test2 + a2 * (1-test2);

    this.listOfControlPoints[2] = this.fractionCircle.getPointFromPolarCoordinate(range2);

    this.listOfControlPoints[4] = innerCircle.getPointFromPolarCoordinate(range2);

    this.listOfControlPoints[3] = ((this.listOfControlPoints[2]..z = 0.0) + (this.listOfControlPoints[4]..z = 0.0)).scale(0.5);



    this.listOfControlPoints[15] = this.fractionCircle.getPointFromPolarCoordinate(this.lineArc.range.begin);

    var a = this.groupMiddle;
    double b = this.lineArc.range.begin;

    var pointA = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleA);
    var pointB = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleB);

    var t = acos((pointA as HomogeneousCoordinate).dotProduct(pointB));

    var test = t < (pi/4) ? min(sin(t) * 4, 1.0) : 0;

    var range = b * test + a * (1-test);

    this.listOfControlPoints[14] = this.fractionCircle.getPointFromPolarCoordinate(range);

    this.listOfControlPoints[12] = innerCircle.getPointFromPolarCoordinate(range);

    this.listOfControlPoints[13] = ((this.listOfControlPoints[12]..z = 0.0) + (this.listOfControlPoints[14]..z = 0.0)).scale(0.5);



    List<RangeMath> ranges = this.convertBack(
        new NumberRange<double>.fromNumbers(range, range2)
    ).divideEqualParts(8, defaultSpaceBetweenParts: 0.0);

    this.listOfControlPoints[5] = innerCircle.getPointFromPolarCoordinate(ranges[6].end);

    this.listOfControlPoints[6] = innerCircle2.getPointFromPolarCoordinate(ranges[5].end);

    this.listOfControlPoints[7] = innerCircle.getPointFromPolarCoordinate(ranges[4].end);

    this.listOfControlPoints[8] = innerCircle.getPointFromPolarCoordinate(ranges[3].end);

    this.listOfControlPoints[9] = innerCircle.getPointFromPolarCoordinate(ranges[2].end);

    this.listOfControlPoints[10] = innerCircle2.getPointFromPolarCoordinate(ranges[1].end);

    this.listOfControlPoints[11] = innerCircle.getPointFromPolarCoordinate(ranges[0].end);*/


    var breakValue = 0;

    //this.listOfControlPoints[1] = this._diagram.baseCircle.center.clone();

    //this.listOfControlPoints[5] = this._diagram.baseCircle.center.clone();

    //this.listOfControlPoints[2] = this._diagram.baseCircle.center.clone();

    //this.listOfControlPoints[3] = this._diagram.baseCircle.center.clone();

    //this.listOfControlPoints[4] = this._diagram.baseCircle.center.clone();

    /*this.listOfControlPoints[0] = this._lineArc.end;
    this.listOfControlPoints[8] = this._lineArc.begin;

    this.listOfControlPoints[7] = this.fractionCircle.getPointFromPolarCoordinate(this.lineArc.range.begin);

    var a = this.blockMiddle;
    double b = this.lineArc.range.begin;

    var pointA = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleA);
    var pointB = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleB);

    var t = acos((pointA as HomogeneousCoordinate).dotProduct(pointB));

    var test = t < (pi/4) ? min(sin(t) * 3, 1.0) : 0;

    var range = b * test + a * (1-test);

    this.listOfControlPoints[5] = this.fractionCircle.getPointFromPolarCoordinate(range);


    this.listOfControlPoints[6] = ((this.listOfControlPoints[7]..z = 0.0) + (this.listOfControlPoints[5]..z = 0.0)).scale(0.5);


    this.listOfControlPoints[1] = this.fractionCircle.getPointFromPolarCoordinate(this.lineArc.range.end);

    var a2 = this.blockMiddle2;
    double b2 = this.lineArc.range.end;

    var pointA2 = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleA);
    var pointB2 = this._diagram.drawCircle.getPointFromPolarCoordinate(this.connMiddleB);

    var t2 = acos((pointA2 as HomogeneousCoordinate).dotProduct(pointB2));

    var test2 = t2 < (pi/4) ? min(sin(t2) * 3, 1.0) : 0;

    var range2 = b2 * test2 + a2 * (1-test2);

    this.listOfControlPoints[3] = this.fractionCircle.getPointFromPolarCoordinate(range2);


    this.listOfControlPoints[2] = ((this.listOfControlPoints[1]..z = 0.0) + (this.listOfControlPoints[3]..z = 0.0)).scale(0.5);

    var dir = ((((this.lineArc.end..z = 0.0) - (this.lineArc.begin..z=0.0))..z = 1.0).toUnitVector());

    if(secondary){
      this.listOfControlPoints[4] = new HomogeneousCoordinate(CoordinateType.threeDim, -dir.y, dir.x, 0.0, 1.0);
    }else{
      this.listOfControlPoints[4] = new HomogeneousCoordinate(CoordinateType.threeDim, dir.y, -dir.x, 0.0, 1.0);
    }*/

    //this.listOfControlPoints[4] = this._diagram.baseCircle.center.clone();

    /*var blockMidPoint = this._diagram.drawCircle.getPointFromPolarCoordinate(this.blockMiddle + pi/2);

    var midCircle = this._diagram.baseCircle.clone()..radius *= 0.5;

    var blockOppositeA = midCircle.getPointFromPolarCoordinate(this.blockMiddle  + pi/2);
    var blockOppositeB = midCircle.getPointFromPolarCoordinate(this.blockMiddle2 + pi/2);

    var midPoint = this._diagram.baseCircle.center.clone();

    var ratio = (this.cosAngleBetweenBlockMiddleAndEndPoint + 1) / 2;

    this.listOfControlPoints[4] = (blockMidPoint.clone().scale(ratio)..z = 0.0) +
        (midPoint.clone().scale(1 - ratio)..z = 0.0);*/

    /*this.listOfControlPoints[4] = (this.listOfControlPoints[3].clone().scale(ratio)..z = 0.0) +
        (midPoint.clone().scale(1 - ratio)..z = 0.0);*/


    /*this.listOfControlPoints[5] = (midPoint.clone().scale(ratio)..z = 0.0) +
        (blockMidPoint.clone().scale(1 - ratio)..z = 0.0);*/

    this.updateControlPoints = false;

  }

}