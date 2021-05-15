part of renderer;

class BoundingBox {

  Aabb3 _aabb3;

  Vector3 get min => _aabb3.min;
  Vector3 get max => _aabb3.max;

  BoundingBox({Vector3 min, Vector3 max}) : _aabb3 = new Aabb3.minMax(min, max);

  BoundingBox.fromPoints(Iterable<Vector3> points) {
    _aabb3 = new Aabb3.minMax(points.first, points.first);
    points.skip(1).forEach((point) => _aabb3.hullPoint(point));
  }

  BoundingBox.fromCenterAndSize(Vector3 center, Vector3 size) {
    var halfSize = size * 0.5;
    _aabb3 = new Aabb3.minMax(center - halfSize, center + halfSize);
  }

  /*BoundingBox.fromObject(Object3D object) {
    object.updateMatrixWorld(force: true);
    object.traverse((node) {
      var geometry = node.geometry;
      if (geometry is BufferGeometry) {
        if (geometry.aPosition != null) {
          var position = new Vector3.zero();
          var a = geometry.aPosition.array;
          var il = a.length;
          for (var i = 0; i < il; i += 3) {
            position.setValues(a[i], a[i + 1], a[i + 2]).applyProjection(node.matrixWorld);
            if (_aabb3 == null) {
              _aabb3 = new Aabb3.minMax(position, position);
            } else {
              _aabb3.hullPoint(position);
            }
          }
        }
      } else if (geometry is Geometry) {
        geometry.vertices.forEach((vertice) {
          var transfVertice = new Vector3.copy(vertice).applyProjection(node.matrixWorld);
          if (_aabb3 == null) {
            _aabb3 = new Aabb3.minMax(transfVertice, transfVertice);
          } else {
            _aabb3.hullPoint(transfVertice);
          }
        });
      }
    });
    if (_aabb3 == null) {
      _aabb3 = new Aabb3();
    }
  }*/

  set copy(BoundingBox box) => _aabb3.copyFrom(box._aabb3);

  bool get isEmpty => (this.max.x < this.min.x) || (this.max.y < this.min.y) || (this.max.z < this.min.z);

  Vector3 get center => _aabb3.center;

  Vector3 get size => (this.max)-(this.min);

  void expandByPoint(Vector3 point) => _aabb3.hullPoint(point);

  void expandByVector(Vector3 vector) => _aabb3 = new Aabb3.minMax(_aabb3.min..sub(vector), _aabb3.max..add(vector));

  void expandByScalar(double scalar) =>
      _aabb3 = new Aabb3.minMax(_aabb3.min - new Vector3.all(scalar), _aabb3.max + new Vector3.all(scalar));

  bool containsPoint(Vector3 point) => _aabb3.containsVector3(point);

  bool containsBox(BoundingBox box) => _aabb3.containsAabb3(new Aabb3.minMax(box.min, box.max));

  Vector3 getParameter(Vector3 point) =>
      new Vector3.array(
          [(point.x - min.x) / (max.x - min.x), (point.y - min.y) / (max.y - min.y), (point.z - min.z) / (max.z - min.z)]);

  bool isIntersectionBox(BoundingBox box) => _aabb3.intersectsWithAabb3(new Aabb3.minMax(box.min, box.max));

  //todo: clampPoint

  //todo: distanceToPoint

  BoundingSphere get boundingSphere => new BoundingSphere(radius: size.length * 0.5, center: center);

  void intersect(BoundingBox box) {
    Vector3.max(_aabb3.min, box.min, _aabb3.min);
    Vector3.min(_aabb3.max, box.max, _aabb3.max);
  }

  void union(BoundingBox box) {
    Vector3.min(_aabb3.min, box.min, _aabb3.min);
    Vector3.min(_aabb3.max, box.max, _aabb3.max);
  }

  void applyMatrix4(Matrix4 matrix) {
    _aabb3.transform(matrix);
  }

  void translate(Vector3 offset) {
    _aabb3.min.add(offset);
    _aabb3.max.add(offset);
  }

  bool operator ==(Object box){
    if(!(box is BoundingBox)){
      return false;
    }
    return min == (box as BoundingBox).min && max == (box as BoundingBox).max;
  }

  BoundingBox clone() => new BoundingBox(min: min, max: max);

}

class BoundingSphere {
  num radius;
  Vector3 center;
  BoundingSphere({this.radius, this.center});
}