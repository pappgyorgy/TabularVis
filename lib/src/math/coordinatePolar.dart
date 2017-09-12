part of poincareMath;

class CoordinatePolar<T extends double, F extends HomogeneousCoordinate<dynamic>>
    implements PolarCoordinate<T, F>{

  T _angle;
  SimpleCircle<F> _circle;

  CoordinatePolar(this._angle, this._circle);

  F get center => this._circle.center;

  T get angle => this._angle;

  SimpleCircle get circle => this._circle;

  F get coordinate {
    return MathHomogeneous.get2DPolarCoordinates(this._circle, this._angle) as F;
  }

  F get coordinate3D {
    return MathHomogeneous.get3DPolarCoordinates(this._circle, this._angle) as F;
  }

  T increaseAngle([T increaseValue = null]) {
    increaseValue = increaseValue == null
        ? 0.1 as T
        : increaseValue;
    this._angle = this._angle + increaseValue as T;
    return this._angle;
  }

  T decreaseAngle([T decreaseValue = null]) {
    decreaseValue = decreaseValue == null
      ? 0.1 as T
      : decreaseValue;
    this._angle = this._angle - decreaseValue as T;
    return this._angle;
  }

  int compare(Comparable a, Comparable b) {
    return a.compareTo(b);
  }


  int compareTo(PolarCoordinate<T, F> other) {
    var result = this - other;

    if(result < 0){
      return -1;
    }else if(result > 0){
      return 1;
    }
    return 0;
  }


  bool _isCenterEqual(PolarCoordinate other){
    return this._circle.center == other.center;
  }

  double operator +(PolarCoordinate<T, F> other){
    if(this._isCenterEqual(other)){
      return this._angle + other.angle;
    }else{
      throw new StateError("The polar coordinates center is not equals");
    }
  }

  double operator -(PolarCoordinate<T, F> other){
    if(this._isCenterEqual(other)){
      return this._angle - other.angle;
    }else{
      throw new StateError("The polar coordinates center is not equals");
    }
  }

  bool operator <(PolarCoordinate<T, F> other){
    if(this._isCenterEqual(other)){
      return this._angle < other.angle;
    }else{
      throw new StateError("The polar coordinates center is not equals");
    }
  }

  bool operator >(PolarCoordinate<T, F> other){
    if(this._isCenterEqual(other)){
      return this._angle > other.angle;
    }else{
      throw new StateError("The polar coordinates center is not equals");
    }
  }

  bool operator ==(Object other){
    PolarCoordinate<T, F> objToCompare =
      other as PolarCoordinate<T, F>;
    if(this._isCenterEqual(objToCompare)){
      return this._angle == objToCompare.angle;
    }else{
      return false;
    }
  }


}