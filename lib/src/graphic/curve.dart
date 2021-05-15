part of renderer;


double tangentQuadraticBezier(double t, double p0, double p1, double p2) => 2 * (1 - t) * (p1 - p0) + 2 * t * (p2 - p1);

// Puay Bing, thanks for helping with this derivative!
double tangentCubicBezier(double t, double p0, double p1, double p2, double p3) {
  return -3 * p0 * (1 - t) * (1 - t) + 3 * p1 * (1 - t) * (1 - t) - 6 * t * p1 * (1 - t) + 6 * t * p2 * (1 - t) -
      3 * t * t * p2 +
      3 * t * t * p3;
}

double tangentSpline(double t, double p0, double p1, double p2, double p3) {

  // To check if my formulas are correct

  var h00 = 6 * t * t - 6 * t; // derived from 2t^3 − 3t^2 + 1
  var h10 = 3 * t * t - 4 * t + 1; // t^3 − 2t^2 + t
  var h01 = -6 * t * t + 6 * t; // − 2t3 + 3t2
  var h11 = 3 * t * t - 2 * t; // t3 − t2

  return h00 + h10 + h01 + h11;

}


/** Catmull-Rom*/
double interpolate(double p0, double p1, double p2, double p3, double t) {
  var v0 = (p2 - p0) * 0.5;
  var v1 = (p3 - p1) * 0.5;
  var t2 = t * t;
  var t3 = t * t2;
  return (2 * p1 - 2 * p2 + v0 + v1) * t3 + (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 + v0 * t + p1;
}

/**************************************************************
 *  Abstract Curve base class
 **************************************************************/
abstract class Curve<V> {

  int _arcLengthDivisions = null;
  List<double> cacheArcLengths = null;
  bool needsUpdate = false;

  // Virtual base class method to overwrite and implement in subclasses
  //  - t [0 .. 1]
  V getPoint(double t);

  // Get point at relative position in curve according to arc length
  // - u [0 .. 1]
  V getPointAt(double u) {
    var t = getUtoTmapping(u);
    return getPoint(t);
  }

  // Get sequence of points using getPoint( t )
  // TODO(nelsonsilva) - closedPath is only used in Path
  List<V> getPoints([int divisions = null, bool closedPath = false]) {

    if (divisions == null) divisions = 5;

    int d;
    List<V> pts = [];

    for (d = 0; d <= divisions; d++) {
      pts.add(this.getPoint(d / divisions));
    }

    return pts;
  }

  // Get sequence of points using getPointAt( u )
  // TODO(nelsonsilva) - closedPath is only used in Path
  List<V> getSpacedPoints([int divisions = 5, bool closedPath = false]) {


    int d;
    List<V> pts = [];

    for (d = 0; d <= divisions; d++) {
      pts.add(this.getPointAt(d / divisions));
    }

    return pts;
  }

  // Get sequence of points using getPointAt( u )
  // TODO(tiagocardoso) - closedPath is only used in Path
  List<V> getUPoints([List<double> uList, bool closedPath = false]) {
    List<V> pts = [];

    for (double u in uList) {
      pts.add(this.getPointAt(u));
    }

    return pts;
  }


  // Get total curve arc length
  double get length => getLengths().last;

  // Get list of cumulative segment lengths
  List<double> getLengths({int divisions: null}) {

    if (divisions == null) divisions = (_arcLengthDivisions != null) ? (_arcLengthDivisions) : 200;

    if (cacheArcLengths != null && (cacheArcLengths.length == divisions + 1) && !needsUpdate) {

      //console.log( "cached", this.cacheArcLengths );
      return cacheArcLengths;
    }

    needsUpdate = false;

    var cache = <double>[];
    V current;
    V last = getPoint(0.0);
    double sum = 0.0;

    cache.add(0.0);

    for (var p = 1; p <= divisions; p++) {

      current = getPoint(p / divisions);

      double distance;

      // TODO(nelsonsilva) - Must move distanceTo to IVector interface os create a new IHasDistance
      if (current is Vector3) {
        distance = (current as Vector3).absoluteError(last as Vector3);
      } else {
        distance = (current as Vector2).absoluteError(last as Vector2);
      }

      sum += distance;
      cache.add(sum);
      last = current;

    }

    cacheArcLengths = cache;

    return cache; // { sums: cache, sum:sum }; Sum is in the last element.
  }


  void updateArcLengths() {
    needsUpdate = true;
    getLengths();
  }

  /// Given u ( 0 .. 1 ), get a t to find p. This gives you points which are equi distance
  double getUtoTmapping(double u, {double distance: null}) {

    var arcLengths = getLengths();

    int i = 0,
        il = arcLengths.length;

    double targetArcLength; // The targeted u distance value to get

    if (distance != null) {
      targetArcLength = distance;
    } else {
      targetArcLength = u * arcLengths[il - 1];
    }

    //var time = Date.now();

    // binary search for the index with largest value smaller than target u distance.

    var low = 0,
        high = il - 1;
    double comparison;

    while (low <= high) {

      i = (low + (high - low) / 2).floor().toInt();

      // less likely to overflow, though probably not issue here
      // JS doesn't really have integers, all numbers are floats.
      comparison = arcLengths[i] - targetArcLength;

      if (comparison < 0) {

        low = i + 1;
        continue;

      } else if (comparison > 0) {

        high = i - 1;
        continue;

      } else {

        high = i;
        break;

        // DONE

      }

    }

    i = high;

    //console.log('b' , i, low, high, Date.now()- time);

    if (arcLengths[i] == targetArcLength) {

      var t = i / (il - 1);
      return t;

    }

    // we could get finer grain at lengths, or use simple interpolatation between two points

    var lengthBefore = arcLengths[i];
    var lengthAfter = arcLengths[i + 1];

    var segmentLength = lengthAfter - lengthBefore;

    // determine where we are between the 'before' and 'after' points

    var segmentFraction = (targetArcLength - lengthBefore) / segmentLength;

    // add that fractional amount to t

    var t = (i + segmentFraction) / (il - 1);

    return t;
  }


  // Returns a unit vector tangent at t
  // In case any sub curve does not implement its tangent / normal finding,
  // we get 2 points with a small delta and find a gradient of the 2 points
  // which seems to make a reasonable approximation
  dynamic getTangent(double t) {

    var delta = 0.0001;
    var t1 = t - delta;
    var t2 = t + delta;

    // Capping in case of danger

    if (t1 < 0) t1 = 0.0;
    if (t2 > 1) t2 = 1.0;

    V pt1 = getPoint(t1);
    V pt2 = getPoint(t2);

    if(pt1 is Vector3){
      Vector3 vec = (pt2 as Vector3) - (pt1 as Vector3);
      return vec..normalize();
    }else{
      Vector2 vec = (pt2 as Vector2) - (pt1 as Vector2);
      return vec..normalize();
    }

  }

  dynamic getTangentAt(double u) {
    double t = getUtoTmapping(u);
    return getTangent(t);
  }

}

abstract class Curve2D extends Curve<Vector2> {
  // In 2D space, there are actually 2 normal vectors,
  // and in 3D space, infinte
  // TODO this should be depreciated.
  Vector2 getNormalVector(double t) {
    var vec = this.getTangent(t) as Vector2;
    return new Vector2(-vec.y, vec.x);
  }
}

abstract class Curve3D extends Curve<Vector3> {
}
