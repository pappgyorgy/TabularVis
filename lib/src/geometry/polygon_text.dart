part of visualizationGeometry;

class PolygonText implements Polygon{

  TextGeometryBuilder fontGeometry;
  List<double> _labelMatrix;

  PolygonText(String text, this._labelMatrix, [Color polyColor = null]){
    if(polyColor == null){
      polyColor = new Color(0x000000);
    }

    var fontshapes = generateShapes(text, 20);
    fontGeometry = new TextGeometryBuilder(fontshapes, 20);

    Matrix4 posMat = new Matrix4.fromList(this._labelMatrix);

    fontGeometry.computeBoundingBox();
    var center = fontGeometry.boundingBox.center;

    Matrix4 mat = new Matrix4.identity();
    mat.translate(-center);
    mat.multiply(posMat);

    for(var i = 0; i < fontGeometry.vertices.length; i++){
      fontGeometry.vertices[i].applyMatrix4(mat);
    }

    for(var i = 0; i < fontGeometry.faces.length; i++){
      fontGeometry.faces[i].color = polyColor;
    }

  }

  @override
  List<Face3> get contourFaces {
    throw new StateError("Text doesn't have contour");
  }

  @override
  List<Face3> get polygonFaces {
    return fontGeometry.faces as List<Face3>;
  }

  @override
  List<Vector3> get contourVertices {
    throw new StateError("Text doesn't have contour");
  }

  @override
  List<Vector3> get polygonVertices {
    return fontGeometry.vertices;
  }


}