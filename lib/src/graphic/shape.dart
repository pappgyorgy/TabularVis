part of renderer;

/**
 * @author zz85 / http://www.lab4games.net/zz85/blog
 * Defines a 2d shape plane using paths.
 **/

// STEP 1 Create a path.
// STEP 2 Turn path into shape.
// STEP 3 ExtrudeGeometry takes in Shape/Shapes
// STEP 3a - Extract points from each shape, turn to vertices
// STEP 3b - Triangulate each shape, add faces.

class Shape extends Path {

  List<CurvePath> holes;

  Shape([List<Vector2> points])
      : holes = <CurvePath>[],
        super(points);

  // Convenience method to return ExtrudeGeometry
  /*ExtrudeGeometry extrude({amount: 100, bevelThickness: 6.0, bevelSize: null, bevelSegments: 3, bevelEnabled: true, curveSegments: 12,
    steps: 1, bendPath, extrudePath, material, extrudeMaterial}) {

    if (bevelSize == null) bevelSize = bevelThickness - 2.0;

    return new ExtrudeGeometry(
        [this],
        amount: amount,
        bevelThickness: bevelThickness,
        bevelSize: bevelSize,
        bevelSegments: bevelSegments,
        bevelEnabled: bevelEnabled,
        curveSegments: curveSegments,
        steps: steps,
        bendPath: bendPath,
        extrudePath: extrudePath,
        material: material,
        extrudeMaterial: extrudeMaterial);
  }*/


  // Get points of holes
  List<dynamic> getPointsHoles(int divisions) {

    int i,
        il = holes.length;
    var holesPts = new List<dynamic>(il);

    for (i = 0; i < il; i++) {

      holesPts[i] = holes[i].getTransformedPoints(divisions, bends: _bends);

    }

    return holesPts;

  }

  // Get points of holes (spaced by regular distance)
  List<dynamic> getSpacedPointsHoles(int divisions) {

    int i,
        il = holes.length;
    var holesPts = new List<dynamic>(il);

    for (i = 0; i < il; i++) {

      holesPts[i] = holes[i].getTransformedSpacedPoints(divisions, _bends);

    }

    return holesPts;

  }


  // Get points of shape and holes (keypoints based on segments parameter)
  Map<String, dynamic> extractAllPoints(int divisions) {

    return <String, dynamic>{

      "shape": getTransformedPoints(divisions),
      "holes": getPointsHoles(divisions)

    };

  }

  Map<String, dynamic> extractPoints([int divisions]) {

    if (useSpacedPoints) {
      return extractAllSpacedPoints(divisions);
    }

    return extractAllPoints(divisions);

  }

  //
  // THREE.Shape.prototype.extractAllPointsWithBend = function ( divisions, bend ) {
  //
  //   return {
  //
  //     shape: this.transform( bend, divisions ),
  //     holes: this.getPointsHoles( divisions, bend )
  //
  //   };
  //
  // };

  // Get points of shape and holes (spaced by regular distance)
  Map<String, dynamic> extractAllSpacedPoints([int divisions]) {
    return <String, dynamic>{
      "shape": getTransformedSpacedPoints(divisions),
      "holes": getSpacedPointsHoles(divisions)

    };
  }

}