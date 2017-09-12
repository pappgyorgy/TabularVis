part of poincareMath;

abstract class LineMath<T>{

  List<double> getLineYEquation();

  List<double> getLineGeneralEquation();

  bool isLineIntersect(LineMath other);

  LineMath getPerpendicularLineForPoint(HomogeneousCoordinate<T> point);

  bool isPointOnLine(HomogeneousCoordinate<T> point);

  HomogeneousCoordinate<Vector4> get linePlaneNormal;

  set linePlaneNormal(HomogeneousCoordinate<Vector4> vector);

  HomogeneousCoordinate<T> getLineIntersectionPoint(LineMath other);

  HomogeneousCoordinate<T> argumentsToHCoordinate();

  LineMath<T> clone();

  bool get isVertical;
}