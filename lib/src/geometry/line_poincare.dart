part of visualizationGeometry;

class LinePoincare<T extends double, F extends HomogeneousCoordinate<dynamic>> implements LineGeom<T, F>{

  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> _geomInfo;

  F drawCircleStartPoint, drawCircleEndPoint;

  Arc<T, F> _lineArc;

  Diagram _diagram;

  List<PolarCoordinate<T, F>> _dividePoints;

  LinePoincare(RangeMath<T> range, SimpleCircle<F> circle, this.drawCircleStartPoint, this.drawCircleEndPoint, this._diagram){
    this._lineArc = new Arc<T,F>(range, circle, this._diagram);
  }

  ///Returns with pointU and pointV
  List<F> _getIntersectBaseAndPoincareCircle(){
    return this._lineArc.circle.getCircleIntersectPoint(
        this._diagram.baseCircle as SimpleCircle<F>);
  }

  List<SimpleCircle> get apollonianCircle{
    var returnValue = new List<SimpleCircle>();
    for(PolarCoordinate point in _dividePoints){
      returnValue.add(point.circle);
    }
    return returnValue;
  }

  SimpleCircle<F> get circle => this._lineArc.circle;

  double get lengthOfLine{
    /// collisionPoints.first = pointU
    /// collisionPoints.last = pointV
    /// this._startPoint.coordinate = pointQ
    /// this._endPoint.coordinate = pointP

    var collisionPoints = this._getIntersectBaseAndPoincareCircle();

    if(collisionPoints.first == collisionPoints.last){
      throw new StateError("Can not measure length because U and V points are equals");
    }

    var up = collisionPoints.first.distanceTo(this._lineArc.end);
    var pv = this._lineArc.end.distanceTo(collisionPoints.last);

    var uq = collisionPoints.first.distanceTo(this._lineArc.begin);
    var qv = this._lineArc.begin.distanceTo(collisionPoints.last);

    return log((up/pv)*(qv/uq)).abs();
  }

  List<F> getLinePoints([int numberOfSegment = 0]){
    if(numberOfSegment == 0){
      numberOfSegment = this._diagram.lineSegment;
    }

    if(this._lineArc.range.length > 0.0001){
      return this._lineArc.getListOfPoints(numberOfSegment);
    }else{

      SegmentLine lineHelper = new SegmentLine.fromTwoHPoint(this.drawCircleStartPoint as HomogeneousCoordinate, this.drawCircleEndPoint as HomogeneousCoordinate);

      var linePoints = lineHelper.divideLine(numberOfSegment);

      return linePoints as List<F>;

    }
  }

  @Deprecated("Alredy not used")
  // ignore: unused_element
  int get _movingDirection{
    return this._lineArc.range.direction;
  }

  List<PolarCoordinate<T, F>> _divideBasedOnPolarCoordinate(List<T> value){
    this._dividePoints = new List<PolarCoordinate<T, F>>();

    this._dividePoints.add(this._lineArc.beginPolarCoordinate);
    for(RangeMath range in this._lineArc.range.dividePartsByValue(value, defaultSpaceBetweenParts: 0.0 as T)){
      this._dividePoints.add(new PolarCoordinate<T, F>(range.end as T, this._lineArc.circle));
    }
    this._dividePoints[this._dividePoints.length-1] = (this._lineArc.endPolarCoordinate);

    return this._dividePoints;
  }

  /*void defineInnerLinesPoint(){

    var vectorVUNorm = pointU.clone().sub(pointV);
    vectorVUNorm.normalize();

    dividePoints = new List();

    var vec = line[0].point.clone().sub(line.last.point);

    if(vec.y < 0){
      dividePoints.add(line.last);
    }else{
      dividePoints.add(line.first);
    }
    var i = 30;
    for(double length in divideLengths){

      var a = MathFunc.getInverseLn(length);
      var b = getPointRatio(dividePoints.last.point);

      var actRatio = a/b;

      //v distanceUV / (ratio - 1)
      //print(actRatio);
      if(actRatio > 1.0 && (actRatio < 1.0 + pow(10,-6))){
        actRatio = 1.0 + pow(10, -6);
        //print(actRatio);
      }else if(actRatio < 1.0 && (actRatio > 1.0 - pow(10,-6))){
        actRatio = 1.0 - pow(10, -6);
        //print(actRatio);
      }else if(sameValue){
        if(actRatio < 1.0){
          actRatio = 1.0 - pow(10, -6);
        }else{
          actRatio = 1.0 + pow(10, -6);
        }
      }


      var translateVector = vectorVUNorm.clone().scale(lengthUV / (actRatio-1.0));

      var pointOnCircle = pointU + translateVector;

      var translateVector2 = vectorVUNorm.clone().scale(lengthUV / (actRatio+1.0));

      var pointOnCircle2 = pointU - translateVector2;

      var checkRatio2 = getPointRatioReverse(pointOnCircle2);
      var checkRatio3 = getPointRatioReverse(pointOnCircle);

      var appCircle = new Circle();

      appCircle.radius = (actRatio / (pow(actRatio, 2) - 1.0).abs())*lengthUV;

      appCircle.circleCenter = MathFunc.gettwoPointsMidPoint(pointOnCircle, pointOnCircle2);

      appollonianCircles.add(appCircle);



      var listOfIntersectPoint = appCircle.getCircleCircleIntersectPoint(poincareCircle);
      if(drawCircle.isPointInCircleVec2(listOfIntersectPoint[0])){
        dividePoints.add(new PoincarePoints.formVec2Point(listOfIntersectPoint[0], this.poincareCircle));
      }else{
        dividePoints.add(new PoincarePoints.formVec2Point(listOfIntersectPoint[1], this.poincareCircle));
      }

    }
    dividePoints.removeAt(0);
  }*/

  List<PolarCoordinate<T, F>> _divideBasedOnPoincareLength(List<T> listOfValues){

    var pointUV = this._getIntersectBaseAndPoincareCircle();

    var vectorVUNorm = (pointUV.first - pointUV.last).toUnitVector();

    var sameValue = listOfValues.length == 2 && listOfValues.first == listOfValues.last
      ? true
      : false;

    this._dividePoints = new List<PolarCoordinate<T, F>>();

    this._dividePoints.add(this._lineArc.beginPolarCoordinate);

    var lengthUV = pointUV.first.distanceTo(pointUV.last);

    var sumOfValues = listOfValues.reduce((a,b) => (a+b) as T);

    var oneLength = this.lengthOfLine / sumOfValues;

    for(var i = 0; i < listOfValues.length-1; i++){

      var a = MathFunc.getInverseLn(oneLength * listOfValues[i]);
      var b = getPointRatio(_dividePoints.last.coordinate, pointUV.first, pointUV.last);

      var actRatio = a/b;

      //v distanceUV / (ratio - 1)
      //print(actRatio);
      if(actRatio > 1.0 && (actRatio < 1.0 + pow(10,-6))){
        actRatio = 1.0 + pow(10, -6);
        //print(actRatio);
      }else if(actRatio < 1.0 && (actRatio > 1.0 - pow(10,-6))){
        actRatio = 1.0 - pow(10, -6);
        //print(actRatio);
      }else if(sameValue){
        if(actRatio < 1.0){
          actRatio = 1.0 - pow(10, -6);
        }else{
          actRatio = 1.0 + pow(10, -6);
        }
      }

      var pointA = pointUV.first.clone().translate(vectorVUNorm.clone().scale(lengthUV / (actRatio-1.0)).getDescartesCoordinate());

      var pointBStorage = pointUV.first.clone().translate(vectorVUNorm.clone().scale(lengthUV / (actRatio+1.0))).getDescartesCoordinate().storage;

      var pointBHelper = new HomogeneousCoordinate<T>(
          T is Vector3 ? CoordinateType.threeDim : CoordinateType.twoDim,
          pointBStorage[0], pointBStorage[1], pointBStorage[2]
      );

      var pointB = pointBHelper.negate();

      var apollonianCircle = new HCircle2D(MathHomogeneous.getTwoHPointsMidPoint(pointA, pointB) as HCoordinate2D,
        (actRatio / (pow(actRatio, 2) - 1.0).abs())*lengthUV
      );

      var listOfIntersectPoint = apollonianCircle.getCircleIntersectPoint(this._lineArc.circle);
      if(this._diagram.drawCircle.isPointInCircle(listOfIntersectPoint.first)){
        this._dividePoints.add(
            this._lineArc.circle.getPointPolarCoordinate(
                listOfIntersectPoint.first) as PolarCoordinate<T, F>);
      }else{
        this._dividePoints.add(
            this._lineArc.circle.getPointPolarCoordinate(
                listOfIntersectPoint.last) as PolarCoordinate<T, F>);
      }

    }

    this._dividePoints.add(this._lineArc.endPolarCoordinate);

    return this._dividePoints;
  }

  List<PolarCoordinate<T, F>> divideLine(List<T> values, {DivideType type: DivideType.angle}){
    switch(type){
      case DivideType.apollonian :
        return this._divideBasedOnPoincareLength(values);
      case DivideType.angle :
        return this._divideBasedOnPolarCoordinate(values);
      default:
        throw new StateError("Wrong divide type was given: $type");
    }
  }

  bool get isDivided => this._dividePoints != null && this._dividePoints.length > 0;

  double getPointRatio(HomogeneousCoordinate point,
                       HomogeneousCoordinate pointU,
                       HomogeneousCoordinate pointV){
    return point.distanceTo(pointU)/ point.distanceTo(pointV);
  }

  double getPointRatioReverse(HomogeneousCoordinate point,
                              HomogeneousCoordinate pointU,
                              HomogeneousCoordinate pointV){
    return 1.0 / getPointRatio(point, pointU, pointV);
  }

  @override
  @Deprecated("GemetryData class will be deleted")
  GeometryData<T, F> get geomInfo {
    return this._geomInfo;
  }

  @override
  List<PolarCoordinate<T, F>> get dividePoints {
    return this._dividePoints;
  }

  @override
  Diagram get diagram {
    return this._diagram;
  }

  @override
  Arc<T, F> get lineArc {
    return this._lineArc;
  }

  @override
  void update(){

  }
}