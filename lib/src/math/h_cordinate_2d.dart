part of poincareMath;

class HCoordinate2D implements HomogeneousCoordinate<Vector3>{

  Vector3 _coordinate;

  HCoordinate2D(this._coordinate);

  HCoordinate2D.fromDescartesCoordinate(Vector2 vector){
    this._coordinate = new Vector3(vector.x, vector.y, 1.0);
  }

  get x => this._coordinate.x;
  get y => this._coordinate.y;
  get z => this._coordinate.z;
  get h => this._coordinate.z;

  set h(double h) { this._coordinate.z = h; }


  set z(double z) { this._coordinate.z = z; }


  set y(double y) { this._coordinate.y = y; }


  set x(double x) { this._coordinate.x = x; }

  Vector2 getDescartesCoordinate(){
    if(!isVector) {
      if (this._coordinate.z == 1) {
        return this._coordinate.xy;
      } else {
        return new Vector2(this._coordinate.x / this._coordinate.z,
        this._coordinate.y / this._coordinate.z);
      }
    }else{
      return this._coordinate.xy;
    }
  }

  double distanceTo(HomogeneousCoordinate<Vector3> point){
    return this.getDescartesCoordinate().distanceTo(point.getDescartesCoordinate() as Vector2);
  }

  HCoordinate2D crossProduct(List<HomogeneousCoordinate<Vector3>> point){
    //{y1 z2 - z1 y2; z1 x2 - x1 z2; x1 y2 - y1 x2}
    return new HCoordinate2D(new Vector3(
        this.y * point.first.z - this.z * point.first.y,
        this.z * point.first.x - this.x * point.first.z,
        this.x * point.first.y - this.y * point.first.x
    ));
  }

  get coordinate => this._coordinate;
  set coordinate(Vector3 value){this._coordinate = value;}

  HomogeneousCoordinate<Vector3> rotateAroundPoint(dynamic point, double angle) {
    this.translate((point as Vector2).clone().negate());
    this.rotateAroundOrigin(angle);
    this.translate(point as Vector2);

    return this;
  }


  HomogeneousCoordinate<Vector3> rotateAroundOrigin(double angle) {
    new Matrix3.columns(
        new Vector3(cos(angle), -sin(angle), 0.0),
        new Vector3(sin(angle), cos(angle), 0.0),
        new Vector3(0.0, 0.0, 1.0)
    ).transform(this._coordinate);

    return this;
  }


  HomogeneousCoordinate<Vector3> scale(double value) {
    new Matrix3.columns(
        new Vector3(value, 0.0, 0.0),
        new Vector3(0.0, value, 0.0),
        new Vector3(0.0, 0.0, value)
    ).transform(this._coordinate);

    return this;
  }


  HomogeneousCoordinate<Vector3> scaleWithVector(dynamic point) {
    Vector2 vec2 = (point as Vector2);
    new Matrix3.columns(
        new Vector3(vec2.x, 0.0, 0.0),
        new Vector3(0.0, vec2.y, 0.0),
        new Vector3(0.0, 0.0, 1.0)
    ).transform(this._coordinate);

    return this;
  }


  HomogeneousCoordinate<Vector3> translate(dynamic point) {
    Vector2 vec2 = (point as Vector2);
    new Matrix3.columns(
        new Vector3(1.0, 0.0, 0.0),
        new Vector3(0.0, 1.0, 0.0),
        new Vector3(vec2.x, vec2.y, 1.0)
    ).transform(this._coordinate);

    return this;
  }


  HomogeneousCoordinate<Vector3> normalize(){
    if(this._coordinate.z != 0.0) {
      if(this._coordinate.z != 1.0){
        this._coordinate.x /= this._coordinate.z;
        this._coordinate.y /= this._coordinate.z;
        this._coordinate.z = 1.0;
      }
    }
    return this;
  }

  HomogeneousCoordinate<Vector3> normalized(){
    return this.clone()..normalize();
  }

  List<double> get listOfCoordinate {
    var descartes = this.getDescartesCoordinate();
    return [descartes.y, descartes.y];
  }

  HomogeneousCoordinate<Vector3> clone() {
    return new HCoordinate2D(this._coordinate.clone());
  }


  ///If [this] was a point then it converts to vector and the returns with it's unit vector
  ///If [this] was a vector then returns with it's unit vector
  HomogeneousCoordinate<Vector3> get unitVector {
    return this.clone()..toUnitVector();
  }


  HomogeneousCoordinate<Vector3> toUnitVector(){
    if(this.isVector){
      this._coordinate.xy = this._coordinate.xy.normalize();
    }else{
      this._coordinate.xy = this.getDescartesCoordinate().normalize();
      this._coordinate.z = 0.0;
    }
    return this;
  }

  bool get isVector => this._coordinate.storage.last == 0 ? true : false;

  bool togglePointVector() {
    var isVectorCoord = this.isVector;

    if(isVectorCoord){
      this._coordinate.z = 1.0;
    }else{
      this.normalize();
      this._coordinate.z = 0.0;
    }

    return !isVectorCoord;
  }

  bool operator ==(Object other){

    var a = this.getDescartesCoordinate();
    Vector2 b = (other as HomogeneousCoordinate).getDescartesCoordinate() as Vector2;
    return a.storage[0] == b.storage[0] && a.storage[1] == b.storage[1];
  }

  operator -(HomogeneousCoordinate<Vector3> other){
    var a = this.clone()..normalize();
    var b = other.clone()..normalize();
    return new HCoordinate2D(a.coordinate-b.coordinate)..normalize();
  }

  operator +(HomogeneousCoordinate<Vector3> other){
    var a = this.clone()..normalize();
    var b = other.clone()..normalize();
    return new HCoordinate2D(a.coordinate + b.coordinate)..normalize();
  }

  @override
  String toString() {
    return this._coordinate.toString();
  }

  // TODO: implement length
  @override
  double get length => this._coordinate.length;

  @override
  HomogeneousCoordinate<Vector3> negate() {
    this._coordinate.negate();
    return this;
  }
}