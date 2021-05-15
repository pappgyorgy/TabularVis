part of renderer;

class LineCurve extends Curve2D {

  Vector2 v1, v2;

  LineCurve(this.v1, this.v2) : super();

  Vector2 getPoint(t) {
    Vector2 point = v2 - v1;
    var scaledPoint = point.scaled(t) + (v1);
    return scaledPoint;
  }

  // Line curve is linear, so we can overwrite default getPointAt
  Vector2 getPointAt(u) => getPoint(u);

  Vector2 getTangent(t) => (v2 - v1)..normalize();

}
