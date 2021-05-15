part of renderer;

class QuadraticBezierCurve extends Curve2D {

  Vector2 v0, v1, v2;

  QuadraticBezierCurve(this.v0, this.v1, this.v2);

  getPoint(t) {

    double tx, ty;

    tx = b2(t, v0.x, v1.x, v2.x);
    ty = b2(t, v0.y, v1.y, v2.y);

    return new Vector2(tx, ty);
  }


  Vector2 getTangent(t) {

    double tx, ty;

    tx = tangentQuadraticBezier(t, v0.x, v1.x, v2.x);
    ty = tangentQuadraticBezier(t, v0.y, v1.y, v2.y);

    // returns unit vector
    return new Vector2(tx, ty)..normalize();
  }
}
