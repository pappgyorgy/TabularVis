part of poincareMath;

enum CoordinateType{
  twoDim,
  threeDim
}

abstract class HomogeneousCoordinate<T>{

  double get x;
  set x(double x);
  double get y;
  set y(double y);
  double get z;
  set z(double z);
  double get h;
  set h(double h);

  factory HomogeneousCoordinate(CoordinateType type,
      [double x = 0.0, double y = 0.0, double z = 0.0, double w = 1.0]){

    switch(type){
      case CoordinateType.twoDim:
          return new HCoordinate2D(new Vector3(x,y,w)) as HomogeneousCoordinate<T>;
        break;
      case CoordinateType.threeDim:
          return new HCoordinate3D(new Vector4(x,y,z,w)) as HomogeneousCoordinate<T>;
        break;
      default:
        throw new StateError("The given coordinate type is not exists");
        break;
    }

    return null;
  }

  Vector getDescartesCoordinate();

  double distanceTo(HomogeneousCoordinate<T> point);

  HomogeneousCoordinate<T> crossProduct(List<HomogeneousCoordinate> point);

  HomogeneousCoordinate<T> translate(dynamic point);

  HomogeneousCoordinate<T> scaleWithVector(dynamic point);

  HomogeneousCoordinate<T> scale(double point);

  HomogeneousCoordinate<T> rotateAroundOrigin(double angle);

  HomogeneousCoordinate<T> rotateAroundPoint(dynamic point, double angle);

  HomogeneousCoordinate<T> normalize();

  HomogeneousCoordinate<T> normalized();

  T get coordinate;
  set coordinate(T value);

  bool get isVector => this.h == 0.0 ? true : false;

  HomogeneousCoordinate<T> get unitVector;

  HomogeneousCoordinate<T> toUnitVector();

  /// convert the point to vector and the vector to point
  /// returns true if [this] is vector and false if it's a point
  bool togglePointVector(){
    var isVectorCoord = this.isVector;

    if(isVectorCoord){
      this.h = 1.0;
    }else{
      this.normalize();
      this.h = 0.0;
    }

    return !isVectorCoord;
  }

  List<double> get listOfCoordinate;

  HomogeneousCoordinate<T> clone();

  bool operator ==(Object other);

  HomogeneousCoordinate<T> operator -(HomogeneousCoordinate<T> other);

  HomogeneousCoordinate<T> operator +(HomogeneousCoordinate<T> other);

  @override
  String toString() {
    return this.coordinate.toString();
  }

  double get length;

  double dotProduct(HomogeneousCoordinate<T> point);

  HomogeneousCoordinate<T> negate();

}