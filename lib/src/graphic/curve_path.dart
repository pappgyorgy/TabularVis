part of renderer;

/**
 * @author zz85 / http://www.lab4games.net/zz85/blog
 *
 **/

/**************************************************************
 *  Curved Path - a curve path is simply a array of connected
 *  curves, but retains the api of a curve
 **************************************************************/

class CurvePath<V> extends Curve<V> {

  List<Curve<V>> curves;
  List<Curve> _bends;

  bool autoClose; // Automatically closes the path

  List<double> cacheLengths = null;

  CurvePath()
      : curves = <Curve<V>>[],
        _bends = <Curve>[],
        autoClose = false,
        super();

  void add(Curve<V> curve) => curves.add(curve);

  void checkConnection() {
    // TODO
    // If the ending of curve is not connected to the starting
    // or the next curve, then, this is not a real path
  }

  bool closePath() {
    // TODO Test
    // and verify for vector3 (needs to implement equals)
    // Add a line curve if start and end of lines are not connected
    var startPoint = curves[0].getPoint(0.0);
    var endPoint = curves[curves.length - 1].getPoint(1.0);

    /*if (!startPoint.equals(endPoint)) {
      this.curves.add(new LineCurve(endPoint, startPoint));
    }*/

  }

  // To get accurate point with reference to
  // entire path distance at time t,
  // following has to be done:

  // 1. Length of each sub path have to be known
  // 2. Locate and identify type of curve
  // 3. Get t for the curve
  // 4. Return curve.getPointAt(t')
  V getPoint(num t) {

    var d = t * this.length;
    var curveLengths = this.getCurveLengths();
    var i = 0;
    double diff;
    Curve curve;

    // To think about boundaries points.

    while (i < curveLengths.length) {

      if (curveLengths[i] >= d) {

        diff = curveLengths[i] - d;
        curve = this.curves[i];

        var u = 1 - diff / curve.length;

        return curve.getPointAt(u) as V;

      }

      i++;

    }

    return null;

    // loop where sum != 0, sum > d , sum+1 <d

  }


  // We cannot use the default THREE.Curve getPoint() with getLength() because in
  // THREE.Curve, getLength() depends on getPoint() but in THREE.CurvePath
  // getPoint() depends on getLength
  double get length => getCurveLengths().last;

  // Compute lengths and cache them
  // We cannot overwrite getLengths() because UtoT mapping uses it.

  List<double> getCurveLengths() {

    // We use cache values if curves and cache array are same length

    if (this.cacheLengths != null && this.cacheLengths.length == this.curves.length) {

      return this.cacheLengths;

    }

    // Get length of subsurve
    // Push sums into cached array

    var lengths = <double>[];
    double sums = 0.0;
    int i;
    int il = this.curves.length;

    for (i = 0; i < il; i++) {

      sums += this.curves[i].length;
      lengths.add(sums);

    }

    this.cacheLengths = lengths;

    return lengths;

  }


  // Returns min and max coordinates, as well as centroid
  Map<String, dynamic> getBoundingBox() {

    var points = getPoints();

    double maxX, maxY, maxZ;
    double minX, minY, minZ;

    maxX = maxY = double.NEGATIVE_INFINITY;
    minX = minY = double.INFINITY;

    V p;
    int i;
    Vector sum;

    var v3 = points[0] is Vector3;

    sum = (v3) ? new Vector3.zero() : new Vector2.zero();

    int il = points.length;
    for (i = 0; i < il; i++) {

      p = points[i];

      if ((p as Vector).storage[0] > maxX) {
        maxX = (p as Vector).storage[0];
      } else if ((p as Vector).storage[0] < minX) minX = (p as Vector).storage[0];

      if ((p as Vector).storage[1] > maxY) {
        maxY = (p as Vector).storage[1];
      } else if ((p as Vector).storage[1] < minY) minY = (p as Vector).storage[1];

      if (v3) {
        if ((p as Vector).storage[2] > maxZ) {
          maxZ = (p as Vector).storage[2];
        } else if ((p as Vector).storage[2] < minZ) minZ = (p as Vector).storage[2];

        (sum as Vector3).add(new Vector3.array((p as Vector).storage));
      } else {
        (sum as Vector2).add(new Vector2.array((p as Vector).storage));
      }
    }

    var ret = <String, dynamic>{

      "minX": minX,
      "minY": minY,
      "maxX": maxX,
      "maxY": maxY,
      "centroid": (sum as dynamic).scale(1.0 / il)

    };

    if (v3) {

      ret["maxZ"] = maxZ;
      ret["minZ"] = minZ;

    }

    return ret;
  }

  /**************************************************************
   *  Create Geometries Helpers
   **************************************************************/

  /// Generate geometry from path points (for Line or ParticleSystem objects)
  GeometryBuilder createPointsGeometry({int divisions}) {
    var pts = this.getPoints(divisions, true);
    return this.createGeometry(pts);
  }

  // Generate geometry from equidistance sampling along the path
  GeometryBuilder createSpacedPointsGeometry([int divisions]) {
    var pts = this.getSpacedPoints(divisions, true);
    return this.createGeometry(pts);
  }

  GeometryBuilder createGeometry(List<V> points) {

    var gb = new GeometryBuilder();
    List<Vector3> listOfPoints = new List<Vector3>();

    for (var i = 0; i < points.length; i++) {
      var z = (points[i] is Vector3) ? (points[i] as Vector3).z : 0.0;
      listOfPoints.add(new Vector3((points[i] as Vector).storage[0], (points[i] as Vector).storage[1], z));
    }

    gb.AddVertices(listOfPoints);

    return gb;
  }


  /**************************************************************
   *  Bend / Wrap Helper Methods
   **************************************************************/

  // Wrap path / Bend modifiers?

  void addWrapPath(Curve bendpath) => _bends.add(bendpath);

  List<dynamic> getTransformedPoints(int segments, {List<Curve> bends: null}) {

    List<dynamic> oldPts = this.getPoints(segments); // getPoints getSpacedPoints
    int i, il;

    if (bends == null) {
      bends = _bends;
    }

    for (i = 0; i < bends.length; i++) {
      oldPts = this.getWrapPoints(oldPts, bends[i]);
    }

    return oldPts;

  }

  List<dynamic> getTransformedSpacedPoints([int segments, List<Curve> bends = null]) {

    List<dynamic> oldPts = getSpacedPoints(segments);

    int i, il;

    if (bends == null) {
      bends = _bends;
    }

    for (i = 0; i < bends.length; i++) {
      oldPts = this.getWrapPoints(oldPts, bends[i]);
    }

    return oldPts;
  }

  // This returns getPoints() bend/wrapped around the contour of a path.
  // Read http://www.planetclegg.com/projects/WarpingTextToSplines.html

  List<dynamic> getWrapPoints(List<dynamic> oldPts, Curve path) {

    var bounds = getBoundingBox();

    int i, il;
    Vector p;
    double oldX, oldY, xNorm;

    for (i = 0; i < oldPts.length; i++) {

      if(oldPts[i] is Vector3){
        p = new Vector3((oldPts[i] as Vector3).x, (oldPts[i] as Vector3).y, (oldPts[i] as Vector3).z);
      }else{
        p = new Vector2((oldPts[i] as Vector2).x, (oldPts[i] as Vector2).y);
      }

      oldX = p.storage[0];
      oldY = p.storage[1];

      xNorm = oldX / (bounds["maxX"] as double);

      // If using actual distance, for length > path, requires line extrusions.

      xNorm = path.getUtoTmapping(xNorm, distance: oldX);

      // check for out of bounds?

      dynamic pathPt = path.getPoint(xNorm);
      dynamic normal = path.getTangentAt(xNorm).scale(oldY);

      p.storage[0] = (pathPt as Vector).storage[0] + (normal as Vector).storage[0];
      p.storage[1] = (pathPt as Vector).storage[1] + (normal as Vector).storage[1];

    }

    return oldPts;

  }
}
