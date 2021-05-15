part of renderer;

class EllipseCurve extends Curve2D {
  double aX, aY;
  double xRadius, yRadius;
  double aStartAngle, aEndAngle;
  bool aClockwise;

  EllipseCurve(this.aX, this.aY, this.xRadius, this.yRadius, this.aStartAngle, this.aEndAngle, this.aClockwise)
      : super();

  Vector2 getPoint(t) {

    var deltaAngle = aEndAngle - aStartAngle;

    if (!aClockwise) {
      t = 1 - t;
    }

    var angle = aStartAngle + t * deltaAngle;

    var tx = aX + xRadius * cos(angle);
    var ty = aY + yRadius * sin(angle);

    return new Vector2(tx, ty);

  }
}
