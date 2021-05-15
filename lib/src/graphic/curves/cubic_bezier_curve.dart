part of renderer;

class CubicBezierCurve extends Curve2D {
  Vector2 v0, v1, v2, v3;

  CubicBezierCurve(this.v0, this.v1, this.v2, this.v3) : super();

  getPoint(t) {

    double tx, ty;

    tx = b3(t, v0.x, v1.x, v2.x, v3.x);
    ty = b3(t, v0.y, v1.y, v2.y, v3.y);

    return new Vector2(tx, ty);

  }

  Vector2 getTangent(double t) {

    double tx, ty;

    tx = tangentCubicBezier(t, v0.x, v1.x, v2.x, v3.x);
    ty = tangentCubicBezier(t, v0.y, v1.y, v2.y, v3.y);

    return new Vector2(tx, ty)..normalize();

  }
}
