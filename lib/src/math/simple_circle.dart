part of poincareMath;

abstract class SimpleCircle<T extends HomogeneousCoordinate<dynamic>>{

  T get center;
  double get radius;
  double get diameter;

  set radius(double values);

  set center(T values);

  set centerFromList(List<double> values);

  void setRadiusFromTwoPoint(T pointOne, T pointTwo);

  void setCenterFromValues(double x, double y, double z, {double h : 1.0});

  List<double> getCirclePoints();

  bool isPointInCircle(T point);

  T getCircleCenterNegate();

  T getInversePointOfCircle(T point);

  bool isCircleIntersect(SimpleCircle otherCircle);

  bool isCircleOnSameZCoordinate(SimpleCircle other);

  static bool isTwoCircleIntersect(SimpleCircle oneCircle, SimpleCircle twoCircle){
    return (oneCircle.center.distanceTo(twoCircle.center) as num) < (oneCircle.radius + twoCircle.radius)
      ? true
      : false;
  }

  List<T> getCircleIntersectPoint(SimpleCircle<T> otherCircle);

  PolarCoordinate<double, T> getPointPolarCoordinate(HomogeneousCoordinate point);

  HomogeneousCoordinate getPointFromPolarCoordinate(double angle, [bool is3D = false]);

  bool isCircleInCircle(SimpleCircle<HomogeneousCoordinate<Vector3>> other);

  List<double> get listOfPoints;

  @override
  String toString();

  SimpleCircle<T> clone();

}