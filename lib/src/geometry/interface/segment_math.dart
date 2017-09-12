part of visualizationGeometry;

abstract class SegmentMath<T>{

  List<double> getLineYEquation();

  List<double> getLineGeneralEquation();

  bool isLineIntersect(SegmentMath other);

  SegmentMath getPerpendicularLineForPoint(HomogeneousCoordinate<T> point);

  bool isPointOnLine(HomogeneousCoordinate<T> point);

  HomogeneousCoordinate get linePlaneNormal;

  set linePlaneNormal(HomogeneousCoordinate vector);

  HomogeneousCoordinate<T> getLineIntersectionPoint(SegmentMath<T> other);

  HomogeneousCoordinate<T> argumentsToHCoordinate();

  List<HomogeneousCoordinate<T>> divideLine([int numberOfPieces = 2, bool reversed = false]);

  SegmentMath<T> clone();

  bool get isVertical;
}