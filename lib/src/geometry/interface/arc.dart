part of visualizationGeometry;

abstract class Arc<T extends double, F extends HomogeneousCoordinate<dynamic>> implements Comparable<Arc<T, F>>{

  factory Arc(RangeMath<T> range, SimpleCircle<F> circle, Diagram diagram){
    return new Arc2D<T, F>(range, circle, diagram);
  }

  RangeMath<T> get range;

  set range(RangeMath<T> value);

  SimpleCircle<F> get circle;

  set circle(SimpleCircle<F> value);

  set diagram(Diagram diagram);

  List<F> getListOfPoints([int numberOfVertices = 0]);

  bool isIntersect(Arc another);

  bool isPointInRange(F point);

  F get begin;

  F get end;

  set begin(F point);

  set end(F point);

  T get beginAngle;

  T get endAngle;

  PolarCoordinate<T, F> get beginPolarCoordinate;

  PolarCoordinate<T, F> get endPolarCoordinate;

  set beginAngle(T value);

  set endAngle(T value);

  Arc<T,F> clone();
}