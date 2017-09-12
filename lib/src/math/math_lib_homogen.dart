part of poincareMath;


class MathHomogeneous{

  ///Return with the vector between the two points [a], [b]
  static HomogeneousCoordinate vectorBetweenTwoHPoints(HomogeneousCoordinate a, HomogeneousCoordinate b) {
    return b - a;
  }

  ///Return with the normalized vector of the two points [a], [b]
  static dynamic vectorBetweenTwoHPointsNormalized(HomogeneousCoordinate a, HomogeneousCoordinate b) {
    return vectorBetweenTwoHPoints(a,b).toUnitVector();
  }

  ///Scale the vector that the two points ([a],[b]) are defined
  static dynamic scaleVectorBetweenHTwoPoints(HomogeneousCoordinate a, HomogeneousCoordinate b, num scaleValue) {
    return vectorBetweenTwoHPointsNormalized(a, b).scaled(scaleValue.toDouble());
  }

  /// Return with the center of the circle which is go trough the two given points.
  /// The two given points [firstPointOnCircle], [secondPointOnCircle] are on the given [circle]
  HomogeneousCoordinate someCircle(SimpleCircle circle,
                             HomogeneousCoordinate firstPointOnCircle,
                             HomogeneousCoordinate secondPointOnCircle) {
    var firstLine = new Line2DH.fromTwoHPoint(circle.center as HCoordinate2D, firstPointOnCircle as HCoordinate2D);
    var secondLine = new Line2DH.fromTwoHPoint(circle.center as HCoordinate2D, secondPointOnCircle as HCoordinate2D);

    return firstLine.getPerpendicularLineForPoint(firstPointOnCircle as HCoordinate2D).getLineIntersectionPoint(
      secondLine.getPerpendicularLineForPoint(secondPointOnCircle as HCoordinate2D)
    );
  }

  static HomogeneousCoordinate getTwoHPointsMidPoint(HomogeneousCoordinate a, HomogeneousCoordinate b){
    return (a+b);
  }

  ///Return with the distance between the two point [a], [b]
  static double getTwoHPointsDistance(HomogeneousCoordinate a, HomogeneousCoordinate b) {
    return a.distanceTo(b);
  }

  ///Return with the [CircleOne] and [circleTwo] circles intersection points
  static List<HomogeneousCoordinate> getTwoCircleIntersectPoint(SimpleCircle circleOne, SimpleCircle circleTwo) {
    return circleOne.getCircleIntersectPoint(circleTwo);
  }

  static List<HomogeneousCoordinate> getCircleLineIntersectPoint(LineMath line,
                                                          SimpleCircle circle) {

    Vector2 circleCenterDesc = circle.center.getDescartesCoordinate() as Vector2;
    //first => m ; last => b
    var yEquation = line.getLineYEquation();

    if (!line.isVertical) {

      var a = 1 + (pow(yEquation.first, 2));
      var b = 2 * (yEquation.first * yEquation.last - yEquation.first * circleCenterDesc.x - circleCenterDesc.x);
      var c = pow(circleCenterDesc.x, 2) - (2 * yEquation.last * circleCenterDesc.y)
        + pow(circleCenterDesc.y, 2) - pow(circle.radius, 2) + pow(yEquation.last, 2);

      var discriminant = sqrt(pow(b, 2) - 4 * a * c);

      var x1 = (-b + discriminant) / (2 * a);
      var x2 = (-b - discriminant) / (2 * a);
      var y1 = yEquation.first * x1 + yEquation.last;
      var y2 = yEquation.first * x2 + yEquation.last;

      return [new HCoordinate2D.fromDescartesCoordinate(new Vector2(x1, y1)),
              new HCoordinate2D.fromDescartesCoordinate(new Vector2(x2, y2))
      ];
    }else{
      var a = 1;
      var b = -2 * circleCenterDesc.y;
      var c = pow((yEquation.last - circleCenterDesc.x), 2) + pow(circleCenterDesc.y, 2) - pow(circle.radius, 2);

      var x = yEquation.last;
      var y1 = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
      var y2 = (-b - sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);

      return [new HCoordinate2D.fromDescartesCoordinate(new Vector2(x, y1)),
              new HCoordinate2D.fromDescartesCoordinate(new Vector2(x, y2))
      ];
    }
  }

  static double getPolarCoordinateAngleRangeTwoPI(HomogeneousCoordinate a, SimpleCircle circle) {
    var result = getPolarCoordinateAngle(a, circle);
    return result < 0
      ? result + MathFunc.PITwice
      : result;
  }

  static double getPolarCoordinateAngle(HomogeneousCoordinate a, SimpleCircle circle) {
    dynamic circleCenter = circle.getCircleCenterNegate().getDescartesCoordinate();
    if(!(circleCenter is Vector2)){
      circleCenter = new Vector2((circleCenter as Vector2).x, (circleCenter as Vector2).y);
    }
    var translatedPoint = a.translate(circleCenter);

    return atan2(translatedPoint.y, translatedPoint.x);
  }

  static HomogeneousCoordinate get2DPolarCoordinatesOrigin(SimpleCircle circle, double angle) {
    return new HCoordinate2D.fromDescartesCoordinate(new Vector2(circle.radius * cos(angle), circle.radius * sin(angle)));
  }

  static HomogeneousCoordinate get3DPolarCoordinatesOrigin(SimpleCircle circle, double angle) {
    return new HCoordinate3D.fromDescartesCoordinate(new Vector3(circle.radius * cos(angle), circle.radius * sin(angle), 0.0));
  }

  static HomogeneousCoordinate get2DPolarCoordinates(SimpleCircle circle, double angle) {
    return get2DPolarCoordinatesOrigin(circle, angle).translate(circle.center.getDescartesCoordinate());
  }

  static HomogeneousCoordinate get3DPolarCoordinates(SimpleCircle circle, double angle) {
    var values = circle.center.getDescartesCoordinate().storage;
    Vector3 vector = new Vector3(values[0], values[1], 0.0);
    return get3DPolarCoordinatesOrigin(circle, angle).translate(vector);
  }

  static double getAngleBetweenHCoordinates(HomogeneousCoordinate a,
                                     HomogeneousCoordinate b,
                                     SimpleCircle circle) {

    return getPolarCoordinateAngleRangeTwoPI(a, circle) - getPolarCoordinateAngleRangeTwoPI(b, circle);
  }

  static List<double> transformAngleDependsOnStartEndPoint(Vector3 point1, Vector3 point2, Vector3 origCircleCenter, Vector3 poincareCircleCenter, bool InnerCircle) {
    throw new UnimplementedError("I think this is not necessery");
  }

  static SimpleCircle<HomogeneousCoordinate> getPoincareCircle(SimpleCircle circle,
                               HomogeneousCoordinate a,
                               HomogeneousCoordinate b,
                               {bool isLongLine: false}) {

    HomogeneousCoordinate inversePoint = circle.getInversePointOfCircle(a);

    return new HCircle2D.fromTrianglePoints(a,b,inversePoint);

  }
}