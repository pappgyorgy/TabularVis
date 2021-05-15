part of poincareMath;

class HCoordinate3D implements HomogeneousCoordinate<Vector4>{

  Vector4 _coordinate;

  HCoordinate3D(this._coordinate);

  HCoordinate3D.fromDescartesCoordinate(Vector3 vector){
    this._coordinate = new Vector4(vector.x, vector.y, vector.z, 1.0);
  }


  Vector3 getDescartesCoordinate() {
    return new Vector3.zero()
      ..setValues(
        this._coordinate.x / this._coordinate.w,
        this._coordinate.y / this._coordinate.w,
        this._coordinate.z / this._coordinate.w
    );
  }

  double distanceTo(HomogeneousCoordinate<Vector4> point) {
    var otherDesc = point.getDescartesCoordinate() as Vector3;
    var thisDesc = this.getDescartesCoordinate();
    return thisDesc.distanceTo(otherDesc);
  }

  ///Plane through three point
  HomogeneousCoordinate<Vector4> crossProduct(List<HomogeneousCoordinate> point) {
    /*var descartes = this.getDescartesCoordinate();
    var pointDescartes = point.getDescartesCoordinate();

    //{y1 z2 - z1 y2; z1 x2 - x1 z2; x1 y2 - y1 x2}
    return new HCoordinate3D.fromDescartesCoordinates(new Vector3(
        descartes.y * pointDescartes.z - descartes.z * pointDescartes.y,
        descartes.z * pointDescartes.x - descartes.x * pointDescartes.z,
        descartes.x * pointDescartes.y - descartes.y * pointDescartes.x
    ));*/
    throw new UnimplementedError("Maybe later");
  }

  set coordinate(Vector4 value) {
    this._coordinate = value;
  }


  get coordinate => this._coordinate;


  get h => this._coordinate.w;


  get z => this._coordinate.z;


  get y => this._coordinate.y;


  get x => this._coordinate.x;


  HomogeneousCoordinate<Vector4> normalize() {
    if(this._coordinate.w != 0.0) {
      if(this._coordinate.w != 1.0){
        this._coordinate.x /= this._coordinate.w;
        this._coordinate.y /= this._coordinate.w;
        this._coordinate.z /= this._coordinate.w;
        this._coordinate.w = 1.0;
      }
    }
    return this;
  }

  HomogeneousCoordinate<Vector4> normalized() {
    return this.clone()..normalize();
  }

  HomogeneousCoordinate<Vector4> get unitVector {
    return this.clone()..toUnitVector();
  }

  HomogeneousCoordinate<Vector4> toUnitVector() {
    if(this.isVector){
      this._coordinate.xyz = this._coordinate.xyz..normalize();
    }else{
      this._coordinate.xyz = this.getDescartesCoordinate()..normalize();
      this._coordinate.w = 0.0;
    }
    return this;
  }

  bool get isVector => this._coordinate.storage.last == 0.0 ? true : false;

  bool togglePointVector() {
    var isVectorCoord = this.isVector;

    if(isVectorCoord){
      this._coordinate.w = 1.0;
    }else{
      this.normalize();
      this._coordinate.w = 0.0;
    }

    return !isVectorCoord;
  }

  double dotProduct(HomogeneousCoordinate point){
    return this.normalized().toUnitVector().coordinate.dot(point.normalized().toUnitVector().coordinate);
  }

  HomogeneousCoordinate<Vector4> translate(dynamic point) {
    Vector3 vec3 = point as Vector3;
    var transMat = new Matrix4.translation(vec3);
    transMat.transform(this._coordinate);
    return this;
  }

  HomogeneousCoordinate<Vector4> scaleWithVector(dynamic point) {
    Vector3 vec3 = point as Vector3;
    var scaleMat = new Matrix4.diagonal3(vec3);
    scaleMat.transform(this._coordinate);
    return this;
  }

  HomogeneousCoordinate<Vector4> scale(double point) {
    var scaleMat = new Matrix4.diagonal3Values(point, point, point);
    scaleMat.transform(this._coordinate);
    return this;
  }

  HomogeneousCoordinate<Vector4> rotateAroundOrigin(double angle) {
    var rotateMat = new Matrix4.rotationZ(angle);
    rotateMat.transform(this._coordinate);
    return this;
  }

  HomogeneousCoordinate<Vector4> rotateAroundPoint(dynamic point, double angle) {
    Vector3 vec3 = point as Vector3;
    var rotateMatrix = new Matrix4.zero();
    rotateMatrix.rotate(vec3, angle);
    rotateMatrix.transform(this._coordinate);
    return this;
  }

  List<double> get listOfCoordinate {
    var descartes = this.getDescartesCoordinate();
    return [descartes.x, descartes.y, descartes.z];
  }

  HomogeneousCoordinate<Vector4> clone() {
    return new HCoordinate3D(this._coordinate.clone());
  }

  operator ==(Object other){
    var a = this.getDescartesCoordinate();
    var b = (other as HomogeneousCoordinate).getDescartesCoordinate() as Vector3;
    return a.storage[0] == b.storage[0] && a.storage[1] == b.storage[1] && a.storage[2] == b.storage[2];
  }

  operator -(HomogeneousCoordinate<Vector4> other){
    var a = this.clone()..normalize();
    var b = other.clone()..normalize();
    return new HCoordinate3D(a.coordinate-b.coordinate)..normalize();
  }

  operator +(HomogeneousCoordinate<Vector4> other){
    var a = this.clone()..normalize();
    var b = other.clone()..normalize();
    return new HCoordinate3D(a.coordinate+b.coordinate)..normalize();
  }

  @override
  String toString() {
    return this._coordinate.toString();
  }

  @override
  set h(double h) {
    this._coordinate.w = h;
  }

  @override
  set x(double x) {
    this._coordinate.x = x;
  }

  @override
  set y(double y) {
    this._coordinate.y = y;
  }

  @override
  set z(double z) {
    this._coordinate.z = z;
  }
  // TODO: implement length
  @override
  double get length => this._coordinate.length;

  @override
  HomogeneousCoordinate<Vector4> negate() {
    this._coordinate.negate();
    return this;
  }
}