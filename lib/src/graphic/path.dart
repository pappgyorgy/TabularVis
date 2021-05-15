part of renderer;

/**
 * @author zz85 / http://www.lab4games.net/zz85/blog
 * Creates free form 2d path using series of points, lines or curves.
 *
 **/

class PathAction {
  static const String MOVE_TO = 'moveTo';
  static const String LINE_TO = 'lineTo';
  static const String QUADRATIC_CURVE_TO = 'quadraticCurveTo'; // Bezier quadratic curve
  static const String BEZIER_CURVE_TO = 'bezierCurveTo'; // Bezier cubic curve
  static const String CSPLINE_THRU = 'splineThru'; // Catmull-rom spline
  static const String ARC = 'arc'; // Circle
  static const String ELLIPSE = 'ellipse';

  String action;
  List<dynamic> args;

  PathAction(this.action, this.args);
}

class Path extends CurvePath<Vector2> {

  var useSpacedPoints = false;

  List _points;
  List<PathAction> actions;

  Path([List<Vector2> points])
      : actions = [],
        super() {
    if (points != null) {
      _fromPoints(points);
    }
  }

  // Create path using straight lines to connect all points
  // - vectors: array of Vector2
  factory Path.fromPoints(List<Vector2> vectors) => new Path(vectors);

  void _fromPoints(List<Vector2> vectors) {
    moveTo(vectors[0].x, vectors[0].y);

    for (var v = 1,
        vlen = vectors.length; v < vlen; v++) {
      this.lineTo(vectors[v].x, vectors[v].y);
    }
  }

  void addAction(String action, [List<dynamic> args]) => actions.add(new PathAction(action, args));



  // startPath() endPath()?
  void moveTo(double x, double y) => addAction(PathAction.MOVE_TO, <double>[x, y]);

  void lineTo(double x, double y) {

    var args = [x, y];

    var lastargs = actions.last.args as List<double>;

    var x0 = lastargs[lastargs.length - 2];
    var y0 = lastargs[lastargs.length - 1];

    var curve = new LineCurve(new Vector2(x0, y0), new Vector2(x, y));
    curves.add(curve);

    addAction(PathAction.LINE_TO, args);
  }

  void quadraticCurveTo(double aCPx, double aCPy, double aX, double aY) {

    var args = [aCPx, aCPy, aX, aY];

    var lastargs = actions.last.args as List<double>;

    var x0 = lastargs[lastargs.length - 2].toDouble();
    var y0 = lastargs[lastargs.length - 1].toDouble();

    var curve = new QuadraticBezierCurve(
        new Vector2(x0, y0),
        new Vector2(aCPx.toDouble(), aCPy.toDouble()),
        new Vector2(aX.toDouble(), aY.toDouble()));
    curves.add(curve);

    addAction(PathAction.QUADRATIC_CURVE_TO, args);
  }

  void bezierCurveTo(double aCP1x, double aCP1y, double aCP2x, double aCP2y, double aX, double aY) {

    var args = [aCP1x, aCP1y, aCP2x, aCP2y, aX, aY];

    var lastargs = actions.last.args  as List<double>;

    var x0 = lastargs[lastargs.length - 2];
    var y0 = lastargs[lastargs.length - 1];

    var curve = new CubicBezierCurve(
        new Vector2(x0, y0),
        new Vector2(aCP1x.toDouble(), aCP1y.toDouble()),
        new Vector2(aCP2x.toDouble(), aCP2y.toDouble()),
        new Vector2(aX.toDouble(), aY.toDouble()));
    curves.add(curve);

    addAction(PathAction.BEZIER_CURVE_TO, args);

  }

  void splineThru(List<Vector2> pts) {

    var args = [pts];
    var lastargs = actions.last.args as List<double>;

    var x0 = lastargs[lastargs.length - 2];
    var y0 = lastargs[lastargs.length - 1];
    //---
    var npts = [new Vector2(x0, y0)];
    npts.addAll(pts); //Array.prototype.push.apply( npts, pts );

    var curve = new SplineCurve(npts);
    curves.add(curve);

    addAction(PathAction.CSPLINE_THRU, args);

  }

  // FUTURE: Change the API or follow canvas API?
  // TODO ARC ( x, y, x - radius, y - radius, startAngle, endAngle )

  void arc(double aX, double aY, double aRadius, double aStartAngle, double aEndAngle, bool aClockwise) {

    var lastargs = actions[actions.length - 1].args;
    var x0 = lastargs[lastargs.length - 2] as double;
    var y0 = lastargs[lastargs.length - 1] as double;

    absarc(aX + x0, aY + y0, aRadius, aStartAngle, aEndAngle, aClockwise);

  }

  void absarc(double aX, double aY, double aRadius, double aStartAngle, double aEndAngle, bool aClockwise) {

    absellipse(aX, aY, aRadius, aRadius, aStartAngle, aEndAngle, aClockwise);

  }

  void ellipse(double aX, double aY, double xRadius, double yRadius, double aStartAngle, double aEndAngle, bool aClockwise) {

    var lastargs = actions.last.args;
    var x0 = lastargs[lastargs.length - 2] as double;
    var y0 = lastargs[lastargs.length - 1] as double;

    absellipse(aX + x0, aY + y0, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise);

  }

  void absellipse(double aX, double aY, double xRadius, double yRadius, double aStartAngle, double aEndAngle, bool aClockwise) {

    var args = [aX, aY, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise];

    var curve = new EllipseCurve(aX, aY, xRadius, yRadius, aStartAngle, aEndAngle, aClockwise);
    curves.add(curve);

    dynamic lastPoint = curve.getPoint(aClockwise ? 1.0 : 0.0);
    args.add((lastPoint as Vector2).x);
    args.add((lastPoint as Vector2).y);

    addAction(PathAction.ELLIPSE, args);

  }

  List<Vector2> getSpacedPoints([int divisions = 5, bool closedPath = false]) {

    if (divisions == null) divisions = 40;

    var points = <Vector2>[];

    for (var i = 0; i < divisions; i++) {

      points.add(this.getPoint(i / divisions));

      //if( !this.getPoint( i / divisions ) ) throw "DIE";

    }

    // if ( closedPath ) {
    //
    //   points.push( points[ 0 ] );
    //
    // }

    return points;

  }

  /* Return an array of vectors based on contour of the path */
  List<Vector2> getPoints([int divisions = null, closedPath = false]) {

    if (useSpacedPoints) {
      return getSpacedPoints(divisions, closedPath);
    }

    if (divisions == null) divisions = 12;

    List<Vector2> points = [];

    int i, il;
    PathAction item;
    String action;
    List<dynamic> args;
    double cpx, cpy, cpx2, cpy2, cpx1, cpy1, cpx0, cpy0;
    Vector2 lasteVector;
    List<dynamic> lasteArgs;
    int j;
    double t, tx, ty;

    for (i = 0; i < actions.length; i++) {

      item = actions[i];

      action = item.action;
      args = item.args;

      switch (action) {

        case PathAction.MOVE_TO:

          points.add(new Vector2(args[0] as double, args[1] as double));

          break;

        case PathAction.LINE_TO:

          points.add(new Vector2(args[0] as double, args[1] as double));

          break;

        case PathAction.QUADRATIC_CURVE_TO:

          cpx = args[2] as double;
          cpy = args[3] as double;

          cpx1 = args[0] as double;
          cpy1 = args[1] as double;

          if (points.length > 0) {

            lasteVector = points[points.length - 1];

            cpx0 = lasteVector.x;
            cpy0 = lasteVector.y;

          } else {

            lasteArgs = actions[i - 1].args as List<double>;

            cpx0 = lasteArgs[lasteArgs.length - 2] as double;
            cpy0 = lasteArgs[lasteArgs.length - 1] as double;

          }

          for (j = 1; j <= divisions; j++) {

            t = j / divisions;

            tx = b2(t, cpx0, cpx1, cpx);
            ty = b2(t, cpy0, cpy1, cpy);

            points.add(new Vector2(tx, ty));

          }

          break;

        case PathAction.BEZIER_CURVE_TO:

          cpx = args[4] as double;
          cpy = args[5] as double;

          cpx1 = args[0] as double;
          cpy1 = args[1] as double;

          cpx2 = args[2] as double;
          cpy2 = args[3] as double;

          if (points.length > 0) {

            lasteVector = points[points.length - 1];

            cpx0 = lasteVector.x;
            cpy0 = lasteVector.y;

          } else {

            lasteArgs = actions[i - 1].args as List<dynamic>;

            cpx0 = lasteArgs[lasteArgs.length - 2] as double;
            cpy0 = lasteArgs[lasteArgs.length - 1] as double;

          }


          for (j = 1; j <= divisions; j++) {

            t = j / divisions;

            tx = b3(t, cpx0, cpx1, cpx2, cpx);
            ty = b3(t, cpy0, cpy1, cpy2, cpy);

            points.add(new Vector2(tx, ty));

          }

          break;

        case PathAction.CSPLINE_THRU:

          lasteArgs = actions[i - 1].args;

          var last = new Vector2(lasteArgs[lasteArgs.length - 2] as double, lasteArgs[lasteArgs.length - 1] as double);
          var spts = <Vector2>[last];

          var n = divisions * (args[0] as List).length;

          spts.addAll((args[0] as List<Vector2>));

          var spline = new SplineCurve(spts);

          for (j = 1; j <= n; j++) {

            points.add(spline.getPointAt(j / n));

          }

          break;

        case PathAction.ARC:

          lasteArgs = actions[i - 1].args;

          var aX = args[0] as double,
              aY = args[1]  as double,
              aRadius = args[2] as double,
              aStartAngle = args[3] as double,
              aEndAngle = args[4] as double,
              aClockwise = !!(args[5] as bool);


          var deltaAngle = aEndAngle - aStartAngle;
          double angle;
          var tdivisions = divisions * 2;

          for (j = 1; j <= tdivisions; j++) {

            t = j / tdivisions;

            if (!aClockwise) {

              t = 1 - t;

            }

            angle = aStartAngle + t * deltaAngle;

            tx = aX + aRadius * cos(angle);
            ty = aY + aRadius * sin(angle);

            //console.log('t', t, 'angle', angle, 'tx', tx, 'ty', ty);

            points.add(new Vector2(tx, ty));

          }

          //console.log(points);

          break;

        case PathAction.ELLIPSE:

          var aX = args[0] as double,
              aY = args[1] as double,
              xRadius = args[2] as double,
              yRadius = args[3] as double,
              aStartAngle = args[4] as double,
              aEndAngle = args[5] as double,
              aClockwise = !!(args[6] as bool);


          var deltaAngle = aEndAngle - aStartAngle;
          double angle;
          var tdivisions = divisions * 2;

          for (j = 1; j <= tdivisions; j++) {

            t = j / tdivisions;

            if (!aClockwise) {

              t = 1 - t;

            }

            angle = aStartAngle + t * deltaAngle;

            tx = aX + xRadius * cos(angle);
            ty = aY + yRadius * sin(angle);

            //console.log('t', t, 'angle', angle, 'tx', tx, 'ty', ty);

            points.add(new Vector2(tx, ty));

          }

          //console.log(points);

          break;
      } // end switch

    }



    // Normalize to remove the closing point by default.
    var lastPoint = points[points.length - 1];
    var EPSILON = 0.0000000001;
    if ((lastPoint.x - points[0].x).abs() < EPSILON && (lastPoint.y - points[0].y).abs() < EPSILON) {
      points.removeLast();
    }
    if (closedPath) {
      points.add(points[0]);
    }

    return points;

  }



  // This was used for testing purposes. Should be removed soon.
  List<dynamic> transform(Curve path, int segments) {

    var bounds = getBoundingBox();
    var oldPts = getPoints(segments); // getPoints getSpacedPoints

    //console.log( path.cacheArcLengths() );
    //path.getLengths(400);
    //segments = 40;

    return getWrapPoints(oldPts, path);

  }

  // Breaks path into shapes
  List<Shape> toShapes() {

    int i, il;
    PathAction item;
    String action;
    List<dynamic> args;

    List<Path> subPaths = [];
    var lastPath = new Path();

    for (i = 0; i < actions.length; i++) {

      item = actions[i];

      args = item.args;
      action = item.action;

      if (action == PathAction.MOVE_TO) {

        if (lastPath.actions.length != 0) {

          subPaths.add(lastPath);
          lastPath = new Path();

        }

      }

      lastPath._applyAction(action, args);

    }

    if (lastPath.actions.length != 0) {

      subPaths.add(lastPath);

    }

    // console.log(subPaths);

    if (subPaths.length == 0) return [];

    Path tmpPath;
    Shape tmpShape;
    List<Shape> shapes = [];

    var holesFirst = !isClockWise(subPaths[0].getPoints() as List<Vector2>);
    // console.log("Holes first", holesFirst);

    if (subPaths.length == 1) {
      tmpPath = subPaths[0];
      tmpShape = new Shape();
      tmpShape.actions = tmpPath.actions;
      tmpShape.curves = tmpPath.curves;
      shapes.add(tmpShape);
      return shapes;
    }

    if (holesFirst) {

      tmpShape = new Shape();

      for (i = 0; i < subPaths.length; i++) {

        tmpPath = subPaths[i];

        if (isClockWise(tmpPath.getPoints())) {

          tmpShape.actions = tmpPath.actions;
          tmpShape.curves = tmpPath.curves;

          shapes.add(tmpShape);
          tmpShape = new Shape();

          //console.log('cw', i);

        } else {

          tmpShape.holes.add(tmpPath);

          //console.log('ccw', i);

        }

      }

    } else {

      // Shapes first

      for (i = 0; i < subPaths.length; i++) {

        tmpPath = subPaths[i];

        if (isClockWise(tmpPath.getPoints())) {


          if (tmpShape != null) shapes.add(tmpShape);

          tmpShape = new Shape();
          tmpShape.actions = tmpPath.actions;
          tmpShape.curves = tmpPath.curves;

        } else {

          tmpShape.holes.add(tmpPath);

        }

      }

      shapes.add(tmpShape);

    }

    //console.log("shape", shapes);

    return shapes;

  }


  // TODO(nelsonsilva) - Come up with a better way to invoke the action
  void _applyAction(String action, List<dynamic> args) {
    switch (action) {
      case PathAction.MOVE_TO:
        moveTo(args[0] as double, args[1] as double);
        break;
      case PathAction.LINE_TO:
        lineTo(args[0] as double, args[1] as double);
        break;
      case PathAction.QUADRATIC_CURVE_TO:
        quadraticCurveTo(args[0] as double, args[1] as double, args[2] as double, args[3] as double);
        break;
      case PathAction.BEZIER_CURVE_TO:
        bezierCurveTo(args[0] as double, args[1] as double, args[2] as double, args[3] as double, args[4] as double, args[5] as double);
        break;
      case PathAction.CSPLINE_THRU:
        splineThru(args[0] as List<Vector2>);
        break;
      case PathAction.ARC:
        arc(args[0] as double, args[1] as double, args[2] as double, args[3] as double, args[4] as double, args[5] as bool);
        break;
      case PathAction.ELLIPSE:
        ellipse(args[0] as double, args[1] as double, args[2] as double, args[3] as double, args[4] as double, args[5] as double, args[6] as bool);
        break;
    }
  }
}
