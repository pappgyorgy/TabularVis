part of visualizationGeometry;

abstract class Polygon{

  List<Vector3> get polygonVertices;
  List<Vector3> get contourVertices;

  List<Face3> get polygonFaces;
  List<Face3> get contourFaces;

}