library visualizationGeometry;

import '../math/math.dart';
import 'dart:math';
import '../diagram/diagram_manager.dart';
import 'package:vector_math/vector_math.dart';
import 'package:three/three.dart';
import 'package:three/extras/core/shape_utils.dart' as ShapeUtils;
import 'package:three/extras/font_utils.dart' as FontUtils;
import 'polygon_near_linear_triangulation.dart';
import 'dart:js';
import '../data/data_processing.dart' show VisualObject;

part 'interface/geometry_data.dart';
part 'data_geometry.dart';
part 'interface/shape.dart';
part 'shape_simple.dart';
part 'interface/arc.dart';
part 'arc2D.dart';
part 'interface/line.dart';
part 'line_bezier.dart';
part 'line_simple.dart';
part 'shape_bezier.dart';
part 'shape_uniform.dart';
part 'pnltriShapeGeometry.dart';
part 'interface/polygon.dart';
part 'polygon_shape.dart';
part 'polygon_text.dart';
part 'interface/segment_math.dart';
part 'segment_line.dart';
part 'shape_text.dart';
part 'shape_line.dart';

