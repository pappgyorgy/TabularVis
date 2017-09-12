part of poincareMath;

//TODO contstructo with hommogeneous coordinate
class Line2DH implements LineMath<Vector3>{

  Vector3 _arguments;
  HCoordinate3D _planeNormal;

  Line2DH(this._arguments, {HCoordinate3D planeNormal}){
    this._setPlaneNormal(planeNormal);
  }


  Line2DH.fromTwoHPoint(HCoordinate2D pointOne, HCoordinate2D pointTwo, {HCoordinate3D planeNormal}){
    this._arguments = pointOne.crossProduct([pointTwo])._coordinate;
    this._setPlaneNormal(planeNormal);
  }

  @deprecated
  Line2DH.fromTwoPoint(HCoordinate2D pointOne, HCoordinate2D pointTwo, {HCoordinate3D planeNormal})
    : this.fromTwoPointVector(
      pointOne.getDescartesCoordinate(),
      pointTwo.getDescartesCoordinate(),
      planeNormal: planeNormal
    );

  @deprecated
  Line2DH.fromTwoPointVector(Vector2 pointOne, Vector2 pointTwo, {HCoordinate3D planeNormal}){
    var difference = pointTwo.clone().sub(pointOne);
    double m, b;
    if (difference.x != 0) {
      m = difference.y / difference.x;
      b = (m * -pointTwo.x) + pointTwo.y;
    } else {
      m = 0.0;
      b = pointTwo.x;
    }
    this._arguments = new Vector3(-m, 1.0, b);
    this._setPlaneNormal(planeNormal);
  }

  void _setPlaneNormal(HCoordinate3D planeNormal){
    if(planeNormal != null){
      this._planeNormal = planeNormal;
    }else{
      this._planeNormal = new HCoordinate3D.fromDescartesCoordinate(
          new Vector3(0.0,0.0,1.0)
      );
    }
  }

  List<double> getLineYEquation() {
    if(this._arguments.y != 0) {
      return [-(_arguments.x / _arguments.y), (-_arguments.z / _arguments.y)];
    }else{
      return [-(_arguments.x), (-_arguments.z)];
    }
  }

  List<double> getLineGeneralEquation() {
    return [this._arguments.x, this._arguments.y, this._arguments.z];
  }

  bool isLineIntersect(LineMath other) {
    return true;
  }

  @deprecated
  LineMath getPerpendicularLineForPointSlopeFormula(HCoordinate2D point) {
    var lineYEquation = this.getLineYEquation();
    var pointDesc = point.getDescartesCoordinate();

    var isHorizontal = (lineYEquation.first > -pow(10,-5)) && (lineYEquation.first < pow(10,-5)) ? true : false;

    if(isHorizontal){
      return new Line2DH(new Vector3(1.0, 0.0, pointDesc.x));
    }else{
      var slopeOfPerpendicular = (-1) / lineYEquation.first;

      var yIntercept = pointDesc.y - (slopeOfPerpendicular * pointDesc.x);

      return new Line2DH(new Vector3(-slopeOfPerpendicular, 1.0, yIntercept));
    }


  }


  //from Ax + By  + c = 0
  // => y = -(Ax + c) / B
  double _getYCoordinate(double x){
    return -( this._arguments.x * x + this._arguments.z) / this._arguments.y;
  }

  //from Ax + By + c = 0
  // => x = -(By + c) / A
  double _getXCoordinate(double y){
    return -( this._arguments.y * y + this._arguments.z) / this._arguments.x;
  }


  //return MathHomogeneous.vectorBetweenTwoHPoints(point,
  //new HCoordinate2D(new Vector3(point.x, this._getYCoordinate(point.x + 1.0), 1.0)));

  HomogeneousCoordinate getLineDirectionVector(HomogeneousCoordinate point){
    Vector2 pointDesc = point.getDescartesCoordinate() as Vector2;

    var helperOne = new Vector2(
        pointDesc.x,
        this._getYCoordinate(pointDesc.x)
    );

    //from Ax + By = c
    // => x = (-By + c) / A
    // => y = (-Ax + c) / B
    var helperTwo = new Vector2(
        pointDesc.x + 1.0,
        this._getYCoordinate(pointDesc.x + 1.0)
    );

    var res1 = MathHomogeneous.vectorBetweenTwoHPoints(point,
      new HCoordinate2D(new Vector3(point.x + 1.0, this._getYCoordinate(point.x + 1.0), 1.0)));

    //var res2 = new HCoordinate2D.fromDescartesCoordinate(helperTwo.clone().sub(helperOne).normalize());

    return res1;
  }

  LineMath getPerpendicularLineForPoint(HomogeneousCoordinate point) {
    Vector2 pointDesc = point.getDescartesCoordinate() as Vector2;

    Vector2 lineDirectionVector = getLineDirectionVector(point).getDescartesCoordinate() as Vector2;

    var lineDirectionVector3D = new Vector3(
      lineDirectionVector.x,
      lineDirectionVector.y,
      0.0
    );

    var newPerpendicularLineDirectionVector = lineDirectionVector3D.cross(
        this._planeNormal.getDescartesCoordinate()
    );

    var pointTwo = new HCoordinate2D.fromDescartesCoordinate(pointDesc.clone().add(newPerpendicularLineDirectionVector.xy));

    return new Line2DH.fromTwoHPoint(point as HCoordinate2D, pointTwo, planeNormal: this._planeNormal);
  }

  bool isPointOnLine(HomogeneousCoordinate point) {
    Vector2 descartesPoint = point.getDescartesCoordinate() as Vector2;
    return this._arguments.x * descartesPoint.x + this._arguments.y * descartesPoint.y + this._arguments.z == 0
      ? true
      : false;
  }

  HCoordinate2D getLineIntersectionPoint(LineMath other) {
    return this.argumentsToHCoordinate().crossProduct([other.argumentsToHCoordinate() as HomogeneousCoordinate<Vector3>]);
  }


  set linePlaneNormal(HomogeneousCoordinate<Vector4> vector) {
    this._planeNormal = new HCoordinate3D(vector.coordinate);
  }


  HCoordinate3D get linePlaneNormal => this._planeNormal;

  HCoordinate2D argumentsToHCoordinate(){
    return new HCoordinate2D(this._arguments);
  }


  bool get isVertical {
    return this.getLineYEquation()[0] == 0.0
      ? true
      : false;
  }

  Line2DH clone(){
    return new Line2DH(this._arguments, planeNormal: this._planeNormal);
  }
}