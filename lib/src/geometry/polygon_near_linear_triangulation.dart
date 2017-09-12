@JS()
library PNLTRI;

import 'package:js/js.dart';
import 'dart:js';

@JS("PNLTRI.Triangulator")
class Triangulator{
  external factory Triangulator();
  external List<int> triangulate_polygon(List<List<JsObject>> inPolygonChains, bool inForceTrapezoidation);
}

@JS("PNLTRI.EarClipTriangulator")
class EarClipTriangulator{
  external factory EarClipTriangulator(PolygonData inPolygonData);
  external bool triangulate_polygon_no_holes();
}

@JS("PNLTRI.PolygonData")
class PolygonData{
  external factory PolygonData(List<List<JsObject>> inPolygonChains);
  external List<int> getTriangles();
}