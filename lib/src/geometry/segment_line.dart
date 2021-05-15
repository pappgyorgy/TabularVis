part of visualizationGeometry;

//TODO contstructo with hommogeneous coordinate
class SegmentLine<T extends Vector> implements SegmentMath<T>{

  List<double> _arguments;
  HomogeneousCoordinate _planeNormal;
  HomogeneousCoordinate<T> begin;
  HomogeneousCoordinate<T> end;

  bool _showDirection = false;

  SegmentLine(this._arguments, {HomogeneousCoordinate planeNormal}){
    this._setPlaneNormal(planeNormal);
    var coordinateDim = this._coordinatesDim;
    this.begin = new HomogeneousCoordinate<T>(
        coordinateDim, 1.0, this._getYCoordinate(1.0), 0.0
    );

    this.end = new HomogeneousCoordinate<T>(
        coordinateDim, 2.0, this._getYCoordinate(2.0), 0.0
    );
  }


  SegmentLine.fromTwoHPoint(this.begin, this.end, {HomogeneousCoordinate planeNormal}){
    var helper = new List<HomogeneousCoordinate>();
    helper.add(this.end);
    this._arguments = begin.crossProduct(helper).coordinate.storage;
    this._setPlaneNormal(planeNormal);
  }

  CoordinateType get _coordinatesDim{
    return (T is Vector3) ? CoordinateType.threeDim : CoordinateType.twoDim;
  }

  @deprecated
  SegmentLine.fromTwoPointVector(Vector2 pointOne, Vector2 pointTwo, {HomogeneousCoordinate planeNormal}){
    var difference = pointTwo - pointOne;
    double m, b;
    if (difference.x != 0) {
      m = difference.y / difference.x;
      b = (m * -pointTwo.x) + pointTwo.y;
    } else {
      m = 0.0;
      b = pointTwo.x;
    }
    this._arguments = [-m, 1.0, b];
    this._setPlaneNormal(planeNormal);
  }

  void _setPlaneNormal(HomogeneousCoordinate planeNormal){
    if(planeNormal != null){
      this._planeNormal = planeNormal;
    }else{
      this._planeNormal = new HomogeneousCoordinate<dynamic>(
          CoordinateType.threeDim, 0.0, 0.0, 1.0
      );
    }
  }

  List<double> getLineYEquation() {
    if(this._arguments[1] != 0) {
      return [-(_arguments[0] / _arguments[1]), (-(this._arguments[2]) / _arguments[1])];
    }else{
      return [-(_arguments[0]), -(_arguments[2])];
    }
  }

  List<double> getLineGeneralEquation() {
    return [this._arguments[0], this._arguments[1], this._arguments[2]];
  }

  bool isLineIntersect(SegmentMath other) {
    return true;
  }

  List<HomogeneousCoordinate<T>> divideLine([int numberOfPieces = 2, bool reversed = false]){

    List<HomogeneousCoordinate<T>> retVal = new List<HomogeneousCoordinate<T>>();

    HomogeneousCoordinate<T> step = this._directionVector.scale(this.length / (numberOfPieces - 1));

    HomogeneousCoordinate<T> start = this.begin;
    if(reversed){
      step = step.negate();
      start = this.end;
    }

    retVal.add(start.clone());

    for(var i = 0; i < numberOfPieces - 1; i++){
      retVal.add(retVal.last + step);
    }

    return retVal;
  }

  @deprecated
  SegmentMath getPerpendicularLineForPointSlopeFormula(HCoordinate2D point) {
    var lineYEquation = this.getLineYEquation();
    var pointDesc = point.getDescartesCoordinate();

    var isHorizontal = (lineYEquation.first > -pow(10,-5)) && (lineYEquation.first < pow(10,-5)) ? true : false;

    if(isHorizontal){
      return new SegmentLine([1.0, 0.0, pointDesc.x]);
    }else{
      var slopeOfPerpendicular = (-1) / lineYEquation.first;

      var yIntercept = pointDesc.y - (slopeOfPerpendicular * pointDesc.x);

      return new SegmentLine([-slopeOfPerpendicular, 1.0, yIntercept]);
    }


  }

  //from Ax + By  + c = 0
  // => y = -(Ax + c) / B
  double _getYCoordinate(double x){
    return -( this._arguments[0] * x + this._arguments[2]) / this._arguments[1];
  }

  //from Ax + By + c = 0
  // => x = -(By + c) / A
  double _getXCoordinate(double y){
    return -( this._arguments[1] * y + this._arguments[2]) / this._arguments[1];
  }


  //return MathHomogeneous.vectorBetweenTwoHPoints(point,
  //new HCoordinate2D(new Vector3(point.x, this._getYCoordinate(point.x + 1.0), 1.0)));

  HomogeneousCoordinate<T> get _directionVector{
    return (this.end-this.begin).unitVector;
  }

  double get length{
    return (this.end-this.begin).length;
  }

  HomogeneousCoordinate getLineDirectionVector(HomogeneousCoordinate<T> point){
    Vector pointDesc = point.getDescartesCoordinate();

    var helperOne = new Vector2(
        pointDesc.storage[0],
        this._getYCoordinate(pointDesc.storage[0])
    );

    //from Ax + By = c
    // => x = (-By + c) / A
    // => y = (-Ax + c) / B
    var helperTwo = new Vector2(
        pointDesc.storage[0] + 1.0,
        this._getYCoordinate(pointDesc.storage[0] + 1.0)
    );

    var res1 = MathHomogeneous.vectorBetweenTwoHPoints(point,
        new HCoordinate2D(new Vector3(point.x + 1.0, this._getYCoordinate(point.x + 1.0), 1.0)));

    //var res2 = new HCoordinate2D.fromDescartesCoordinate(helperTwo.clone().sub(helperOne).normalize());

    return res1;
  }

  SegmentMath getPerpendicularLineForPoint(HomogeneousCoordinate<T> point) {
     Vector pointDesc = point.getDescartesCoordinate();

    var lineDirectionVector = getLineDirectionVector(point).getDescartesCoordinate();

    var lineDirectionVector3D = new Vector3(
        lineDirectionVector.storage[0],
        lineDirectionVector.storage[1],
        0.0
    );

    var newPerpendicularLineDirectionVector = lineDirectionVector3D.cross(
        new Vector3.array(this._planeNormal.getDescartesCoordinate().storage)
    );

    var newPoint = new Vector2(pointDesc.storage[0], pointDesc.storage[1]) + (newPerpendicularLineDirectionVector.xy);
    var pointTwo = new HomogeneousCoordinate<Vector2>(CoordinateType.twoDim, newPoint.x, newPoint.y);

    return new SegmentLine.fromTwoHPoint(point, pointTwo, planeNormal: this._planeNormal);
  }

  bool isPointOnLine(HomogeneousCoordinate<T> point) {
    var descartesPoint = point.getDescartesCoordinate();
    return this._arguments[0] * descartesPoint.storage[0] + this._arguments[1] * descartesPoint.storage[1] + this._arguments[2] == 0;
  }

  HomogeneousCoordinate<T> getLineIntersectionPoint(SegmentMath<T> other) {
    return this.argumentsToHCoordinate().crossProduct([other.argumentsToHCoordinate()]);
  }


  set linePlaneNormal(HomogeneousCoordinate vector) {
    this._planeNormal = vector;
  }


  HomogeneousCoordinate get linePlaneNormal => this._planeNormal;

  HomogeneousCoordinate<T> argumentsToHCoordinate(){
    if(T is Vector3){
      return new HomogeneousCoordinate<T>(CoordinateType.threeDim, this._arguments[0], this._arguments[1], this._arguments[2]);
    }else{
      return new HomogeneousCoordinate<T>(CoordinateType.twoDim, this._arguments[0], this._arguments[1]);
    }

  }


  bool get isVertical {
    return this.getLineYEquation()[0] == 0.0
        ? true
        : false;
  }

  SegmentMath<T> clone(){
    return new SegmentLine<T>(this._arguments, planeNormal: this._planeNormal);
  }
}