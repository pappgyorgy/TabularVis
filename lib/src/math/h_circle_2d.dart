part of poincareMath;

class HCircle2D implements SimpleCircle<HomogeneousCoordinate>{

  HCoordinate2D _center;
  double _radius;

  HCircle2D(this._center, this._radius);

  HCircle2D.fromTwoPoint(HomogeneousCoordinate center, HomogeneousCoordinate pointOnCircle){
    this._center = center as HCoordinate2D;
    this.radius = center.distanceTo(pointOnCircle);
  }

  HCircle2D.unit():
    this._center = new HCoordinate2D(new Vector3.zero()),
    this._radius = 1.0;

  HCircle2D.fromTrianglePoints(HomogeneousCoordinate a,
                               HomogeneousCoordinate b,
                               HomogeneousCoordinate c){
    var midPointAC = MathHomogeneous.getTwoHPointsMidPoint(a,c);
    var midPointBC = MathHomogeneous.getTwoHPointsMidPoint(b,c);

    this._center = (new Line2DH.fromTwoHPoint(a as HCoordinate2D,
        c as HCoordinate2D).getPerpendicularLineForPoint(midPointAC).
          getLineIntersectionPoint(new Line2DH.fromTwoHPoint(
              b as HCoordinate2D, c as HCoordinate2D).
                getPerpendicularLineForPoint(midPointBC)
    )..normalize()) as HCoordinate2D;

    this._radius = this._center.distanceTo(a as HCoordinate2D);

  }

  HCoordinate2D get center => this._center;

  double get radius => this._radius;

  double get diameter => (this._radius * 2);


  List<double> get listOfPoints {
    return new NumberRange<double>.fromNumbers(0.0, MathFunc.PITwice).getRangeAllElement(0.001, (double value){
      return this.getPointFromPolarCoordinate(value, true).listOfCoordinate;
    });

  }

  List<HCoordinate2D> getCircleIntersectPoint(SimpleCircle<HomogeneousCoordinate> otherCircle) {

    var otherCenterDesc = otherCircle.center.getDescartesCoordinate() as Vector2;
    var centerDesc = this._center.getDescartesCoordinate();

    var a2 = pow(centerDesc.x,2);
    var b2 = pow(centerDesc.y,2);
    var c1r2 = pow(this.radius, 2);
    var c2r2 = pow(otherCircle.radius, 2);
    var c2 = pow(otherCenterDesc.x,2);
    var d2 = pow(otherCenterDesc.y,2);

    var z = -a2-b2+c2+d2+c1r2-c2r2;
    //var z2 = pow(z,2);
    var k = 2*(-centerDesc.y + otherCenterDesc.y);
    //var k2 = pow(k,2)
    var h = 2*(-centerDesc.x + otherCenterDesc.x);
    var h2 = pow(h,2);

    var fva = pow(k,2) + h2;
    var fvb = -2*z*k+2*k*centerDesc.x*h-2*centerDesc.y*h2;
    var fvc = pow(z,2) - 2*z*centerDesc.x*h+a2*h2+b2*h2-c1r2*h2;

    var discriminant = sqrt(pow(fvb, 2) - 4 * fva * fvc);

    var y1 = (-fvb + discriminant) / (2 * fva);
    var y2 = (-fvb - discriminant) / (2 * fva);

    var x1 = (z-y1*k)/h;
    var x2 = (z-y2*k)/h;

    return [new HCoordinate2D( new Vector3(x1, y1, 1.0)),
            new HCoordinate2D( new Vector3(x2, y2, 1.0))];
  }

  bool isCircleIntersect(SimpleCircle otherCircle) {
    return this.center.distanceTo(otherCircle.center as HomogeneousCoordinate<Vector3>) < (this.radius + otherCircle.radius)
      ? true
      : false;
  }

  HomogeneousCoordinate getInversePointOfCircle(HomogeneousCoordinate point) {

    var pointDesc = point.getDescartesCoordinate() as Vector2;
    var centerDesc = this._center.getDescartesCoordinate();

    var alpha = (pow(this._radius, 2)) / (pow(pointDesc.x - centerDesc.x, 2) + pow(pointDesc.y - centerDesc.y, 2));

    //(alpha (x(C) - x(A)) + x(A), alpha (y(C) - y(A)) + y(A))
    return new HCoordinate2D(new Vector3(
        (alpha * (pointDesc.x - centerDesc.x)) + centerDesc.x,
        (alpha * (pointDesc.y - centerDesc.y)) + centerDesc.y,
        1.0));
  }

  HomogeneousCoordinate getCircleCenterNegate() {
    return new HCoordinate2D.fromDescartesCoordinate(this._center.getDescartesCoordinate()..negate());
  }

  bool isCircleOnSameZCoordinate(SimpleCircle other){
    throw new UnimplementedError("In 2D it is not a supported method");
  }

  bool isPointInCircle(HomogeneousCoordinate point) {
    var pointDescartes = point.getDescartesCoordinate() as Vector2;
    var centerDescartes = this._center.getDescartesCoordinate();
    if ((pow((pointDescartes.x - centerDescartes.x),2) + pow((point.y - centerDescartes.y),2))
        < pow(this._radius,2)){
      return true;
    }else{
      return false;
    }
  }

  @Deprecated("Next refactor")
  List<double> getCirclePoints() {
    var points = new List<double>();

    var stepSize = ((2 * PI) / 36000);

    for (var d = 0.0; d <= (2 * PI) - stepSize; d += stepSize) {
      //TODO need polar coordinate function
      //var point = MathFunc.getPolarCoordinatesPushBack(this, d);
      //points.add(point);
    }

    //points.add(points[0]);

    return points;
  }

  HomogeneousCoordinate getPointFromPolarCoordinate(double angle, [bool is3D = false]) {
    return is3D
      ? MathHomogeneous.get3DPolarCoordinates(this, angle)
      : MathHomogeneous.get2DPolarCoordinates(this, angle);
  }

  PolarCoordinate<double, HomogeneousCoordinate> getPointPolarCoordinate(HomogeneousCoordinate point) {
    return new CoordinatePolar(MathHomogeneous.getPolarCoordinateAngleRangeTwoPI(point, this), this);
  }

  void setCenterFromValues(double x, double y, double z, {double h : 1.0}) {
    this._center = new HCoordinate2D(new Vector3(x, y, z));
  }


  void setRadiusFromTwoPoint(HomogeneousCoordinate pointOne, HomogeneousCoordinate pointTwo) {
    this._radius = pointOne.distanceTo(pointTwo);
  }


  set centerFromList(List<double> values) {
    if(values.length < 3)
      throw new StateError("The length of the list is less then three");

    this._center = new HCoordinate2D(new Vector3(values[0], values[1], values[2]));
  }


  bool isCircleInCircle(SimpleCircle<HomogeneousCoordinate<Vector3>> other) {
      //If[(i  <  radiusTwo) ? (radiusTwo - i > radiusOne), true, false]
      var i = this._center.distanceTo(other.center);
      return i < this._radius && (this._radius - i > other.radius)
        ? true
        : false;

  }

  set center(HomogeneousCoordinate values) {
    this._center = values as HCoordinate2D;
  }


  set radius(double values) {
    this._radius = values;
  }

  SimpleCircle<HomogeneousCoordinate> clone() {
    return new HCircle2D(this._center.clone() as HCoordinate2D, this._radius);
  }


}