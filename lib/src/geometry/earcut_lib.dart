@JS()
library Earcut;

import 'package:js/js.dart';
import 'dart:js';

@JS()
class Earcut{
  external factory Earcut();
  external List<int> triangulate(List<double> vertices, List<int> holeIndices, int dimension);
}
