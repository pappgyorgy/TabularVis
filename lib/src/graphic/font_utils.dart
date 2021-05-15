part of renderer;

var _face = "Open Sans",
    _weight = "normal",
    _style = "normal";
num _size = 150.0;
int _divisions = 10;

/// Map of [FontFace] of Map<String, Map> (before parsing)
Map<String, Map<String, Map<String, Map<String, dynamic>>>> _faces = {};

Map<String, dynamic> getFace() => _faces[_face][_weight][_style];

Map<String, dynamic> loadFace(MapBase<String, dynamic> data) {

  var family = data["familyName"].toLowerCase();

  if (_faces[family] == null) _faces[family] = {};

  if (_faces[family][data["cssFontWeight"]] == null) _faces[family][data["cssFontWeight"]] = {};
  _faces[family][data["cssFontWeight"]][data["cssFontStyle"]] = data;

  // TODO - Parse data
  var face = _faces[family][data["cssFontWeight"]][data["cssFontStyle"]] = data;

  return data;

}

Map<String, dynamic> drawText(String text) {

  //var characterPts = [],
  //    allPts = [];

  // RenderText

  int i;
  Map<String, dynamic> face = getFace();
  double scale = (_size / (face["resolution"] as num)).toDouble();

  num offset = 0;
  List<String> chars = text.split('');
  int length = chars.length;

  var fontPaths = <dynamic>[];

  for (i = 0; i < length; i++) {

    var path = new Path();

    var ret = extractGlyphPoints(chars[i], face, scale, offset, path);
    offset += (ret["offset"] as num);

    fontPaths.add(ret["path"]);

  }

  // get the width

  num width = offset / 2;
  //
  // for ( p = 0; p < allPts.length; p++ ) {
  //
  //  allPts[ p ].x -= width;
  //
  // }

  //var extract = this.extractPoints( allPts, characterPts );
  //extract.contour = allPts;

  //extract.paths = fontPaths;
  //extract.offset = width;

  return <String, dynamic>{
    "paths": fontPaths,
    "offset": width
  };

}

Map extractGlyphPoints(String c, Map<String, dynamic> face, double scale, num offset, Path path) {

  List<Vector2> pts = [];

  int i, i2;
  int divisions;
  List<String> outline;
  String action;
  int length;
  double scaleX, scaleY, x, y;
  double cpx, cpy, cpx0, cpy0, cpx1, cpy1, cpx2, cpy2;
  Vector2 laste;

  Map<String, dynamic> glyph = face["glyphs"][c];
  if (glyph == null) glyph = face["glyphs"]['?'];

  if (glyph == null) return null;

  if (glyph["o"] != null) {

    outline = glyph["_cachedOutline"] as List<String>;
    if (outline == null) {
      glyph["_cachedOutline"] = glyph["o"].split(' ');
      outline = glyph["_cachedOutline"] as List<String>;
    }
    length = outline.length;

    scaleX = scale;
    scaleY = scale;

    for (i = 0; i < length; ) {

      action = outline[i++];

      //console.log( action );

      switch (action) {

        case 'm':

        // Move To

          x = int.parse(outline[i++]) * scaleX + offset;
          y = int.parse(outline[i++]) * scaleY;

          path.moveTo(x, y);
          break;

        case 'l':

        // Line To

          x = int.parse(outline[i++]) * scaleX + offset;
          y = int.parse(outline[i++]) * scaleY;
          path.lineTo(x, y);
          break;

        case 'q':

        // QuadraticCurveTo

          cpx = int.parse(outline[i++]) * scaleX + offset;
          cpy = int.parse(outline[i++]) * scaleY;
          cpx1 = int.parse(outline[i++]) * scaleX + offset;
          cpy1 = int.parse(outline[i++]) * scaleY;

          path.quadraticCurveTo(cpx1, cpy1, cpx, cpy);

          if (pts.length > 0) laste = pts[pts.length - 1];

          if (laste != null) {

            cpx0 = laste.x;
            cpy0 = laste.y;

            for (i2 = 1; i2 <= divisions; i2++) {

              var t = i2 / divisions;
              var tx = b2(t, cpx0, cpx1, cpx);
              var ty = b2(t, cpy0, cpy1, cpy);
            }

          }

          break;

        case 'b':

        // Cubic Bezier Curve

          cpx = int.parse(outline[i++]) * scaleX + offset;
          cpy = int.parse(outline[i++]) * scaleY;
          cpx1 = int.parse(outline[i++]) * scaleX + offset;
          cpy1 = int.parse(outline[i++]) * -scaleY;
          cpx2 = int.parse(outline[i++]) * scaleX + offset;
          cpy2 = int.parse(outline[i++]) * -scaleY;

          path.bezierCurveTo(cpx, cpy, cpx1, cpy1, cpx2, cpy2);

          if (pts.length > 0) laste = pts[pts.length - 1];

          if (laste != null) {

            cpx0 = laste.x;
            cpy0 = laste.y;

            for (i2 = 1; i2 <= divisions; i2++) {

              var t = i2 / divisions;
              var tx = b3(t, cpx0, cpx1, cpx2, cpx);
              var ty = b3(t, cpy0, cpy1, cpy2, cpy);

            }

          }

          break;

      }

    }
  }

  return <String, dynamic>{
    "offset": glyph["ha"] * scale,
    "path": path
  };
}

List<Shape> generateShapes(String text, [num size = 100.0, int curveSegments = 4, String font = "open sans",
  String weight = "normal", String style = "normal"]) {

  Map<String, dynamic> face = _faces[font][weight][style];

  if (_faces == null) {
    face = <String, dynamic>{"face": new FontFace(size: size, divisions: curveSegments)};
    _faces[font][weight][style] = face;
  }

  _size = size;
  _divisions = curveSegments;

  _face = font;
  _weight = weight;
  _style = style;

  // Get a Font data json object

  var data = drawText(text);

  var paths = data["paths"];

  var shapes = <Shape>[];
  paths.forEach((p) { shapes.addAll(p.toShapes()); });
  return shapes;
}

class Glyph {
  String o;
  /// outline
  List _cachedOutline;

  num ha;
}

class FontFace {
  Map<String, Map> _data;

  Map<String, Glyph> glyphs;

  num size, divisions;

  num resolution;

  FontFace({this.size: 150, this.divisions: 10}) : glyphs = {};

  Map operator [](String weight) => _data[weight];
}

/**
 * This code is a quick port of code written in C++ which was submitted to
 * flipcode.com by John W. Ratcliff  // July 22, 2000
 * See original code and more information here:
 * http://www.flipcode.com/archives/Efficient_Polygon_Triangulation.shtml
 *
 * ported to actionscript by Zevan Rosser
 * www.actionsnippet.com
 *
 * ported to javascript by Joshua Koo
 * http://www.lab4games.net/zz85/blog
 *
 */


var EPSILON = 0.0000000001;

// takes in an contour array and returns
List<List<dynamic>> process(List<Vector2> contour, bool indices) {

  var n = contour.length;

  if (n < 3) return null;

  var result = <List<Vector2>>[],
      verts = new List<int>(n),
      vertIndices = <int>[];

  /* we want a counter-clockwise polygon in verts */

  int u, v, w;

  if (area(contour) > 0.0) {

    for (v = 0; v < n; v++) verts[v] = v;

  } else {

    for (v = 0; v < n; v++) verts[v] = (n - 1) - v;

  }

  int nv = n;

  /*  remove nv - 2 vertices, creating 1 triangle every time */

  var count = 2 * nv;
  /* error detection */

  for (v = nv - 1; nv > 2; ) {

    /* if we loop, it is probably a non-simple polygon */

    if ((count--) <= 0) {

      //** Triangulate: ERROR - probable bad polygon!

      //throw ( "Warning, unable to triangulate polygon!" );
      //return null;
      // Sometimes warning is fine, especially polygons are triangulated in reverse.
      print("Warning, unable to triangulate polygon!");

      //if (indices) return vertIndices;
      return result;

    }

    /* three consecutive vertices in current polygon, <u,v,w> */

    u = v;
    if (nv <= u) u = 0;
    /* previous */
    v = u + 1;
    if (nv <= v) v = 0;
    /* new v    */
    w = v + 1;
    if (nv <= w) w = 0;
    /* next     */

    if (snip(contour, u, v, w, nv, verts)) {

      int a, b, c, s, t;

      /* true names of the vertices */

      a = verts[u];
      b = verts[v];
      c = verts[w];

      /* output Triangle */

      result.add([contour[a], contour[b], contour[c]]);


      vertIndices.addAll([verts[u], verts[v], verts[w]]);

      /* remove v from the remaining polygon */
      s = v;
      for (t = v + 1; t < nv; t++) {

        verts[s] = verts[t];
        s++;
      }

      nv--;

      /* reset error detection counter */

      count = 2 * nv;

    }

  }

  //if (indices) return vertIndices;
  return result;

}

// calculate area of the contour polygon
double area(List<Vector2> contour) {

  var n = contour.length;
  var a = 0.0;

  for (var p = n - 1,
      q = 0; q < n; p = q++) {

    a += contour[p].x * contour[q].y - contour[q].x * contour[p].y;

  }

  return a * 0.5;

}

// see if p is inside triangle abc
bool insideTriangle(num ax, num ay, num bx, num by, num cx, num cy, num px, num py) {

  num aX, aY, bX, bY;
  num cX, cY, apx, apy;
  num bpx, bpy, cpx, cpy;
  num cCROSSap, bCROSScp, aCROSSbp;

  aX = cx - bx;
  aY = cy - by;
  bX = ax - cx;
  bY = ay - cy;
  cX = bx - ax;
  cY = by - ay;
  apx = px - ax;
  apy = py - ay;
  bpx = px - bx;
  bpy = py - by;
  cpx = px - cx;
  cpy = py - cy;

  aCROSSbp = aX * bpy - aY * bpx;
  cCROSSap = cX * apy - cY * apx;
  bCROSScp = bX * cpy - bY * cpx;

  return ((aCROSSbp >= 0.0) as bool) && ((bCROSScp >= 0.0) as bool) && ((cCROSSap >= 0.0) as bool);

}


bool snip(List<Vector2> contour, int u, int v, int w, int n, List<int> verts) {

  int p;
  num ax, ay, bx, by;
  num cx, cy, px, py;

  ax = contour[verts[u]].x;
  ay = contour[verts[u]].y;

  bx = contour[verts[v]].x;
  by = contour[verts[v]].y;

  cx = contour[verts[w]].x;
  cy = contour[verts[w]].y;

  if (EPSILON > (((bx - ax) * (cy - ay)) - ((by - ay) * (cx - ax)))) return false;

  for (p = 0; p < n; p++) {

    if ((p == u) || (p == v) || (p == w)) continue;

    px = contour[verts[p]].x;
    py = contour[verts[p]].y;

    if (insideTriangle(ax, ay, bx, by, cx, cy, px, py)) return false;

  }

  return true;

}


//namespace.Triangulate = process;
//namespace.Triangulate.area = area;