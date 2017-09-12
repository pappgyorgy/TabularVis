part of poincareMath;

abstract class PolarCoordinate<T extends double, F extends HomogeneousCoordinate<dynamic>>
    implements Comparable<PolarCoordinate<T,F>>{

  T get angle;
  F get coordinate;
  F get center;
  F get coordinate3D;

  factory PolarCoordinate(T angle, SimpleCircle<F> circle){
    return new CoordinatePolar<T, F>(angle, circle);
  }

  SimpleCircle get circle;

  T increaseAngle([T increaseValue = null]);
  T decreaseAngle([T decreaseValue = null]);

  double operator +(PolarCoordinate<T,F> other);

  double operator -(PolarCoordinate<T,F> other);

  bool operator <(PolarCoordinate<T,F> other);

  bool operator >(PolarCoordinate<T,F> other);

  bool operator ==(Object other);

  @override
  String toString() {
    return "${this.angle} => ${this.coordinate.toString()}";
  }
}