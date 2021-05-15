part of renderer;

/*
  contour - array of vector2 for contour
  holes   - array of array of vector2
*/
Map<String, dynamic> removeHoles(List<Vector2> contour, List<List<Vector2>> holes) {

  var shape = new List<Vector2>.from(contour); // work on this shape
  var allpoints = new List<Vector2>.from(shape);

  /* For each isolated shape, find the closest points and break to the hole to allow triangulation */

  int prevShapeVert, nextShapeVert, prevHoleVert, nextHoleVert;

  int holeIndex, shapeIndex;

  String shapeId,
      shapeGroup;
  int h,
      h2,
      p;
  var verts = <List<Vector2>>[];
  var hole = <Vector2>[];
  double shortest, d;
  Vector2 pts1, pts2;
  List<Vector2> tmpShape1, tmpShape2, tmpHole1, tmpHole2;

  for (h = 0; h < holes.length; h++) {

    hole = holes[h];

    /*
    shapeholes[ h ].concat(); // preserves original
    holes.push( hole );
    */

    allpoints.addAll(hole); //Array.prototype.push.apply( allpoints, hole );

    shortest = double.INFINITY;


    // Find the shortest pair of pts between shape and hole

    // Note: Actually, I'm not sure now if we could optimize this to be faster than O(m*n)
    // Using distanceToSquared() intead of distanceTo() should speed a little
    // since running square roots operations are reduced.

    for (h2 = 0; h2 < hole.length; h2++) {

      pts1 = hole[h2];
      var dist = <double>[];

      for (p = 0; p < shape.length; p++) {

        pts2 = shape[p];
        d = (pts1 - pts2).length2;

        dist.add(d);

        if (d < shortest) {

          shortest = d;
          holeIndex = h2;
          shapeIndex = p;

        }

      }

    }

    //console.log("shortest", shortest, dist);

    prevShapeVert = (shapeIndex - 1) >= 0 ? shapeIndex - 1 : shape.length - 1;
    prevHoleVert = (holeIndex - 1) >= 0 ? holeIndex - 1 : hole.length - 1;

    var areaapts = [hole[holeIndex], shape[shapeIndex], shape[prevShapeVert]];

    var areaa = area(areaapts);

    var areabpts = [hole[holeIndex], hole[prevHoleVert], shape[shapeIndex]];

    var areab = area(areabpts);

    var shapeOffset = 1;
    var holeOffset = -1;

    var oldShapeIndex = shapeIndex,
        oldHoleIndex = holeIndex;
    shapeIndex += shapeOffset;
    holeIndex += holeOffset;

    if (shapeIndex < 0) {
      shapeIndex += shape.length;
    }
    shapeIndex %= shape.length;

    if (holeIndex < 0) {
      holeIndex += hole.length;
    }
    holeIndex %= hole.length;

    prevShapeVert = (shapeIndex - 1) >= 0 ? shapeIndex - 1 : shape.length - 1;
    prevHoleVert = (holeIndex - 1) >= 0 ? holeIndex - 1 : hole.length - 1;

    areaapts = [hole[holeIndex], shape[shapeIndex], shape[prevShapeVert]];

    var areaa2 = area(areaapts);

    areabpts = [hole[holeIndex], hole[prevHoleVert], shape[shapeIndex]];

    var areab2 = area(areabpts);
    //console.log(areaa,areab ,areaa2,areab2, ( areaa + areab ),  ( areaa2 + areab2 ));

    if ((areaa + areab) > (areaa2 + areab2)) {

      // In case areas are not correct.
      //console.log("USE THIS");

      shapeIndex = oldShapeIndex;
      holeIndex = oldHoleIndex;

      if (shapeIndex < 0) {
        shapeIndex += shape.length;
      }
      shapeIndex %= shape.length;

      if (holeIndex < 0) {
        holeIndex += hole.length;
      }
      holeIndex %= hole.length;

      prevShapeVert = (shapeIndex - 1) >= 0 ? shapeIndex - 1 : shape.length - 1;
      prevHoleVert = (holeIndex - 1) >= 0 ? holeIndex - 1 : hole.length - 1;

    } else {

      //console.log("USE THAT ")

    }

    tmpShape1 = shape.getRange(0, shapeIndex).toList();
    tmpShape2 = shape.getRange(shapeIndex, shape.length).toList();
    tmpHole1 = hole.getRange(holeIndex, hole.length).toList();
    tmpHole2 = hole.getRange(0, holeIndex).toList();

    // Should check orders here again?

    var trianglea = [hole[holeIndex], shape[shapeIndex], shape[prevShapeVert]];

    var triangleb = [hole[holeIndex], hole[prevHoleVert], shape[shapeIndex]];

    verts.add(trianglea);
    verts.add(triangleb);

    shape = [];
    shape.addAll(tmpShape1);
    shape.addAll(tmpHole1);
    shape.addAll(tmpHole2);
    shape.addAll(tmpShape2);

  }

  return <String, dynamic>{

    "shape": shape,
    /* shape with no holes */
    "isolatedPts": verts,
    /* isolated faces */
    "allpoints": allpoints

  };


}

List<List<int>> triangulateShape(List<Vector2> contour, List<List<Vector2>> holes) {

  Map<String, dynamic> shapeWithoutHoles = removeHoles(contour, holes);

  List<Vector2> shape = shapeWithoutHoles["shape"] as List<Vector2>;
  List<Vector2> allpoints = shapeWithoutHoles["allpoints"] as List<Vector2>;
  List<List<Vector2>> isolatedPts = shapeWithoutHoles["isolatedPts"] as List<List<Vector2>>;

  List<List<dynamic>> triangles = process(shape, false); // True returns indices for points of spooled shape

  // To maintain reference to old shape, one must match coordinates, or offset the indices from original arrays.
  // It's probably easier to do the first.

  //console.log( "triangles",triangles, triangles.length );
  //console.log( "allpoints",allpoints, allpoints.length );

  int i,
      il,
      f;
  List<dynamic> face;
  String key;
  int index;
  Map<String, dynamic> allPointsMap = <String, dynamic>{};
  Map<String, dynamic> isolatedPointsMap = <String, dynamic>{};

  // prepare all points map

  for (i = 0; i < allpoints.length; i++) {

    key = "${allpoints[ i ].x}:${allpoints[ i ].y}";

    if (allPointsMap.containsKey(key)) {

      print("Duplicate point $key");

    }

    allPointsMap[key] = i;

  }

  List<List<int>> facesIndices = new List<List<int>>(triangles.length + isolatedPts.length);

  // check all face vertices against all points map

  for (i = 0; i < triangles.length; i++) {

    face = triangles[i];

    facesIndices[i] = new List<int>(3);

    for (f = 0; f < 3; f++) {

      key = "${face[ f ].x}:${face[ f ].y}";

      if (allPointsMap.containsKey(key)) {

        facesIndices[i][f] = allPointsMap[key];

      }

    }

  }

  // check isolated points vertices against all points map

  for (i = 0; i < isolatedPts.length; i++) {

    face = isolatedPts[i];

    facesIndices[triangles.length + i] = new List<int>(3);

    for (f = 0; f < 3; f++) {

      key = "${face[ f ].x}:${face[ f ].y}";

      if (allPointsMap.containsKey(key)) {

        facesIndices[triangles.length + i][f] = allPointsMap[key];

      }

    }

  }

  //triangles.addAll(isolatedPts);
  return facesIndices;

}

bool isClockWise(List<Vector2> pts) => area(pts) < 0;


// Bezier Curves formulas obtained from
// http://en.wikipedia.org/wiki/B%C3%A9zier_curve

// Quad Bezier Functions

double b2p0(double t, double p) {

  var k = 1 - t;
  return k * k * p;

}

double b2p1(double t, double p) => 2 * (1 - t) * t * p;

double b2p2(double t, double p) => t * t * p;

double b2(double t, double p0, double p1, double p2) => b2p0(t, p0) + b2p1(t, p1) + b2p2(t, p2);



// Cubic Bezier Functions

double b3p0(double t, double p) {
  var k = 1 - t;
  return k * k * k * p;
}

double b3p1(double t, double p) {

  var k = 1 - t;
  return 3 * k * k * t * p;

}

double b3p2(double t, double p) {

  var k = 1 - t;
  return 3 * k * t * t * p;

}

double b3p3(double t, double p) => t * t * t * p;


double b3(double t, double p0, double p1, double p2, double p3) => b3p0(t, p0) + b3p1(t, p1) + b3p2(t, p2) + b3p3(t, p3);





  // calculate area of the contour polygon



/*double area( List<Vector3> contour ) {

  var n = contour.length;

  var a = 0.0;

  for ( var p = n - 1, q = 0; q < n; p = q ++ ) {

    a += contour[ p ].x * contour[ q ].y - contour[ q ].x * contour[ p ].y;

  }

  return a * 0.5;


}*/




List<List<int>> triangulateShapeEarClip ( List<Vector2> contour, List<dynamic> holes ) {

  var vertices = <double>[]; // flat array of vertices like [ x0,y0, x1,y1, x2,y2, ... ]
  var holeIndices = <int>[]; // array of hole indices
  var faces = <List<int>>[]; // final array of vertex indices like [ [ a,b,d ], [ b,c,d ] ]

  removeDupEndPts( contour );
  addContour( vertices, contour );

  //
  var holeIndex = contour.length;

  holes.forEach((dynamic hole){
    removeDupEndPts( hole as List<Vector2> );
  });

  for ( var i = 0; i < holes.length; i ++ ) {

    holeIndices.add( holeIndex );
    holeIndex += (holes[ i ] as List<Vector2>).length;
    addContour( vertices, holes[ i ] as List<Vector2> );

  }
  //
  var earcut = new Earcut();
  List<int> triangles = new List.from(earcut.triangulate( vertices, holeIndices, 2 ));
  //
  for ( var i = 0; i < triangles.length; i += 3 ) {
    faces.add( (triangles.sublist( i, i + 3 ) as List<int>) );
  }

  return faces;
}





void removeDupEndPts( List<Vector2> points ) {

  var l = points.length;

  if ( l > 2 && points[ l - 1 ] == ( points[ 0 ] ) ) {

    points.removeLast();

  }

}



void addContour( List<double> vertices, List<Vector2> contour ) {

  for ( var i = 0; i < contour.length; i ++ ) {

    vertices.add( contour[ i ].x );

    vertices.add( contour[ i ].y );

  }

}

