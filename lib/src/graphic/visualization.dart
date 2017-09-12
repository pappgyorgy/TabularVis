part of renderer;

enum ShapeMove{
  move,
  rotate,
  zoom
}

@Injectable()
class Visualization {
  Map<String, Object3D> _diagrams;
  Rendering _render;

  Rendering get render => this._render;
  Map<String, Object3D> get diagrams => this._diagrams;
  GeometryBuilder geometryBuilder = new GeometryBuilder();

  int latestRenderDepth = 0;
  bool _freeMovementEnabled = false;
  bool get freeMovementEnabled => _freeMovementEnabled;

  Matrix4 diagramPosition;

  RangeMath _colorRange;

  List<String> _drawnDiagrams;

  Visualization.customFrame(double devicePixelRatio, double width, double height){
    this._render = new Rendering(devicePixelRatio, width, height);
    this._render.animate(60);

    this._diagrams = new Map<String, Object3D>();
    this._colorRange = new ColorRange();
    this._drawnDiagrams = new List();
    diagramPosition = new Matrix4.identity();
  }

  Visualization() : this.customFrame(1.0, 640.0, 480.0);

  bool toogleFreeMovement(){
    _freeMovementEnabled = !_freeMovementEnabled;
    return _freeMovementEnabled;
  }

  dynamic get renderCanvasElement{
    return this._render.canvasElement;
  }

  Future<String> get canvasDataURL{
    return this._render.image;
  }

  void changeRendererSize(double width, double height){
    this._render._changeRenderSize(width, height);
  }

  bool get isDiagramDrawn => this._drawnDiagrams.length > 0;

  bool isDiagramAlreadyDrawn(String ID){
    return this._diagrams.containsKey(ID);
  }

  void modifyDiagram(String diagramID, List<DiagramVisObject> listOfVisObj) {

    this._render._removeFromScene(diagramID);
    this._diagrams[diagramID] = new Object3D();

    listOfVisObj.forEach((DiagramVisObject visObj){

      //this._diagrams[diagramID].add(visObj.visObject);
      //this._diagrams[diagramID].add(visObj.visObject);

      /*var shape = this._diagrams[diagramID]
          .getChildByName(visObj.newShapeID, true);

      List<Vector3> listOfVec = visObj.points;

      var newGeom = new ShapeGeometry([new Shape(listOfVec)], curveSegments: 20)
        ..isDynamic = true
        ..verticesNeedUpdate = true;

      shape.geometry.vertices = newGeom.vertices;
      shape.geometry.faces = newGeom.faces;
      shape.geometry.verticesNeedUpdate = true;
      shape.geometry.isDynamic = true;
      shape.isDynamic = true;*/

      /*var shape = this._diagrams[diagramID]
          .getChildByName(visObj.newShapeID, true);

      List<Vector3> listOfVec = visObj.points;
      if(listOfVec.length == shape.children.first.geometry.vertices.length){
        for(var i = 0; i < listOfVec.length; i++){
          shape.children.first.geometry.vertices[i] = listOfVec[i];
          shape.children.last.geometry.vertices[i] = listOfVec[i];
        }
      }else{
        throw new StateError("The number of shape verticies is not equals with number of points");
      }

      shape.children.first.geometry.verticesNeedUpdate = true;
      shape.children.last.geometry.verticesNeedUpdate = true;

      shape.children.first.material.color = visObj.materialColor;
      shape.children.first.material.transparent = visObj.isTransparent;
      shape.children.first.material.opacity = visObj.opacity;
      shape.children.first.material.needsUpdate = true;*/

    });

    this._render.addToScene(this._diagrams[diagramID], diagramID);
  }

  Future<bool> drawDiagram(
      String diagramID,
      List<ShapeForm> listOfVisObj) async{
    try{
      var material = new MeshBasicMaterial(color: 0xffffff,
          shading: FlatShading,
          vertexColors: VertexColors,
          side: DoubleSide
      );

      listOfVisObj.forEach((ShapeForm visObj){
        var geom = new Geometry();
        geom.vertices = visObj.generatePolygonData();
        geom.faces = visObj.generateFaceData();
        var mesh = new Mesh(geom, material);
        this._diagrams[diagramID].add(mesh);

        //Object3D obj = visObj.visObject;
        //this._diagrams[diagramID].add(obj);
      });


      this._diagrams[diagramID].applyMatrix(diagramPosition);

      this._render.addToScene(this._diagrams[diagramID], diagramID);
      this._drawnDiagrams.add(diagramID);
      return true;
    }catch(error){
      return false;
    }
  }

  void drawDiagram2(
    String diagramID,
    List<ShapeForm> listOfVisObj){

    this._drawnDiagrams.add(diagramID);

    GeometryBuilder gb = new GeometryBuilder();

    List<ShapeLine> shapeLine = new List<ShapeLine>();
    List<ShapeBezier> shapeBezier = new List<ShapeBezier>();
    List<ShapeSimple> shapeSimple = new List<ShapeSimple>();
    List<ShapeText> shapeText = new List<ShapeText>();



    for(var h = 0; h < listOfVisObj.length; h++) {
      if(listOfVisObj[h] is ShapeLine){
        shapeLine.add(listOfVisObj[h] as ShapeLine);
      }else if(listOfVisObj[h] is ShapeBezier){
        shapeBezier.add(listOfVisObj[h] as ShapeBezier);
      }else if(listOfVisObj[h] is ShapeText){
        shapeText.add(listOfVisObj[h] as ShapeText);
      }else{
        shapeSimple.add(listOfVisObj[h] as ShapeSimple);
      }
    }

    shapeText.forEach((ShapeForm shape){
      gb.addShape(shape, 0);
    });

    shapeBezier.sort(((ShapeBezier a, ShapeBezier b){
      return (a.shapeHeight - b.shapeHeight).toInt();
    }));

    shapeLine.forEach((ShapeForm shape){
      gb.addShape(shape, 0);
    });

    shapeSimple.forEach((ShapeForm shape){
      gb.addShape(shape, 0);
    });

    int numberToChange = shapeBezier.length ~/ 6;
    int index = 0;
    int matIndex = 1;

    shapeBezier.forEach((ShapeForm shape){
      /*if(index >= numberToChange){
        index = 0;
        if(matIndex + 1 > 6){
          matIndex = 1;
        }else{
          matIndex++;
        }
      }*/
      gb.addShape(shape, matIndex);
      index++;
    });

    /*var pointGeom = new Geometry();
    pointGeom.vertices = [new Vector3(0.0,0.0,0.0)];
    this._diagrams[diagramID].add(new ParticleSystem(pointGeom, new ParticleBasicMaterial(color: 0xff0000, size: 5.0)));

    SimpleCircle<HomogeneousCoordinate> textCircle =
      new HCircle2D(new HCoordinate2D(new Vector3(0.0, 0.0, 1.0)), 185.0);

    var listOfCirclePoints = textCircle.listOfPoints;

    var lineGeom = new Geometry();

    for(var i = 0; i < listOfCirclePoints.length; i+=3){
      lineGeom.vertices.add(new Vector3(listOfCirclePoints[i], listOfCirclePoints[i+1], listOfCirclePoints[i+2]));
    }

    var line = new Line(lineGeom, new LineBasicMaterial(color: 0x000000));
    this._diagrams[diagramID].add(line);*/

    /*for(var h = 0; h < listOfVisObj.length; h++) {

      /*var newGeometry = new Geometry()..vertices = listOfVisObj[h].visObject.polygonVertices;
      var line = new Line(newGeometry, new LineBasicMaterial(color: 0x000000), LineStrip);

      this._diagrams[diagramID].add(line);*/

      //gb.addNewPolygon(listOfVisObj[h]);

      /*List<List<Vector3>> vertForFacing = listOfVisObj[h].listOfShapePoints;

      var listOfFaces = new List<List<int>>();
      var offset = vertForFacing.first.length;
      for(var i = 0; i < vertForFacing.length - 1; i++){
        for(var j  = 0; j < offset - 1; j += 1){
          listOfFaces.add([((i+1) * offset) + j, ((i+1) * offset) + (j + 1), (i * offset) + j]);
          listOfFaces.add([(i *  offset) + j, ((i+1) * offset) + (j + 1), (i * offset) + (j + 1)]);
        }
      }

      var geomShape = new Geometry();
      geomShape.vertices = listOfVisObj[h].shapePoints;
      geomShape.faces = new List<Face3>();
      listOfFaces.forEach((List<int> faceInd){
        geomShape.faces.add(new Face3(faceInd[0], faceInd[1], faceInd[2]));
      });

      var meshShape = new Mesh(geomShape, new MeshBasicMaterial(color: 0x00ff00));
      this._diagrams[diagramID].add(meshShape);

      var pointGeom = new Geometry();
      pointGeom.vertices = listOfVisObj[h].shapePoints;
      this._diagrams[diagramID].add(new ParticleSystem(pointGeom, new ParticleBasicMaterial(color: 0xff0000, size: 1.0)));*/

      /*var geomShape = new Geometry();
      geomShape.vertices = (listOfVisObj[h] as ShapeBezier).generatePolygonData();
      geomShape.faces = (listOfVisObj[h] as ShapeBezier).generateFaceData();

      Material shader = new MeshBasicMaterial(color: 0xffffff,
          shading: FlatShading,
          vertexColors: VertexColors, side: DoubleSide);
      var meshShape = new Mesh(geomShape, shader);
      this._diagrams[diagramID].add(meshShape);*/

      /*var pointGeom = new Geometry();
      pointGeom.vertices = geomShape.vertices;
      this._diagrams[diagramID].add(new ParticleSystem(pointGeom, new ParticleBasicMaterial(color: 0x0000ff, size: 1.0)));*/

      //gb.addShape(listOfVisObj[h]);

    }*/

    var mesh = gb.mergedGeometry;

    this._diagrams[diagramID].add(mesh);


    /*var pointGeom = new Geometry();
    pointGeom.vertices = mesh.geometry.vertices;
    this._diagrams[diagramID].add(new ParticleSystem(pointGeom, new ParticleBasicMaterial(color: 0xff0000, size: 2.0)));*/

    this._diagrams[diagramID].applyMatrix(diagramPosition);

    this._render.addToScene(this._diagrams[diagramID], diagramID);
  }

  void clearCanvas(){
    latestRenderDepth = 0;
    this._drawnDiagrams.forEach((String ID){
      this._render._removeFromScene(ID);
    });
    this._drawnDiagrams.clear();
  }

  List<HomogeneousCoordinate> _getWorldCoord(List<Point<num>> screenCoord){
    var retVal = new List<HomogeneousCoordinate>();
    try{
      screenCoord.forEach((Point<num> p)
        =>retVal.add(this._render.getMousePosition(p)));
    }catch(error, stacktrace){
      print("$error\n $stacktrace");
    }
    return retVal;
  }

  HomogeneousCoordinate _getMovingVector(List<HomogeneousCoordinate> points){
    return points.first - points.last;
  }

  double _getRadDifference(List<HomogeneousCoordinate> points){
    HCoordinate2D p1 = points.first.clone() as HCoordinate2D;
    HCoordinate2D p2 = points.last.clone() as HCoordinate2D;
    var circleOne = new HCircle2D.fromTwoPoint(
        new HomogeneousCoordinate<Vector3>(CoordinateType.twoDim), p1);
    var circleTwo = new HCircle2D.fromTwoPoint(
        new HomogeneousCoordinate<Vector3>(CoordinateType.twoDim),p2);

    PolarCoordinate<double, HomogeneousCoordinate> first = circleOne.getPointPolarCoordinate(p1);
    PolarCoordinate<double, HomogeneousCoordinate> second = circleTwo.getPointPolarCoordinate(p2);
    //print("${first.coordinate}:${first.angle.toStringAsFixed(4)} - ${second.coordinate}:${second.angle.toStringAsFixed(4)} = ${first.angle - second.angle}");
    return first.angle - second.angle;
  }

  Future<bool> moveShape(ShapeMove move, String ID, List<dynamic> options) async{
    Matrix4 transformation = new Matrix4.identity();
    switch(move){
      case ShapeMove.move:
        if(options.length < 2){
          return false;
        }
        var worldCoord = _getWorldCoord(options as List<Point<num>>);
        var movingVec = _getMovingVector(worldCoord);
        transformation.translate(movingVec.x, movingVec.y, movingVec.z);
        break;
      case ShapeMove.rotate:
        if(options.length < 2){
          return false;
        }
        List<HomogeneousCoordinate> worldCoord = _getWorldCoord(options as List<Point<num>>);
        //print("${worldCoord.first} - ${worldCoord.last}");
        var difference = _getRadDifference(worldCoord);
        var a = worldCoord.first.toUnitVector();
        var b = worldCoord.last.toUnitVector();
        //print("${a.x.toStringAsFixed(3)},${a.y.toStringAsFixed(3)} || ${b.x.toStringAsFixed(3)},${b.y.toStringAsFixed(3)} == $difference");
        var axis = this._render._camera.position.normalized();
        //print("$axis");
        transformation.translate(this._diagrams[ID].position);
        transformation.rotate(axis, difference);
        transformation.translate(-this._diagrams[ID].position);

        /*this._diagrams[ID].children.forEach((Object3D child){
          if(child.name == "label"){
            var boundingbox = child.geometry.boundingBox;
            var vectorToMove = child.position + boundingbox.center;
            Matrix4 transform = new Matrix4.identity();
            transform.translate(vectorToMove);
            transform.rotate(axis, -difference);
            transform.translate(-(vectorToMove));
            child.applyMatrix(transform);
          }
        });*/

        break;
      case ShapeMove.zoom:
        if(options.length < 1){
          return false;
        }
        transformation.translate(0.0,0.0, -options[0] as double);
        break;
      default:
        break;
    }
    this._diagrams[ID].applyMatrix(transformation);
    diagramPosition = this._diagrams[ID].matrix;
    return true;
  }

  HomogeneousCoordinate getMousePosition(Point<num> mouseClick){
    HomogeneousCoordinate mouseClickPos = this.render.getMousePosition(mouseClick);

    var rawPoint = mouseClickPos.getDescartesCoordinate() as Vector2;
    var homogeneousRawPoint = new Vector4(rawPoint.x, rawPoint.y, 0.0, 1.0);

    Matrix3 rotation = diagramPosition.getRotation();
    Vector3 translation = diagramPosition.getTranslation();

    Matrix3 rotationInverse = new Matrix3.identity()..copyInverse(rotation);
    Matrix3 rotationInverseNegative = rotationInverse.scaled(-1.0);

    Vector3 inverseTranslation = (rotationInverseNegative * translation) as Vector3;

    var inverseTransformation = new Matrix4.identity();
    inverseTransformation.setTranslation(inverseTranslation);
    inverseTransformation.setRotation(rotationInverse);

    homogeneousRawPoint.applyMatrix4(inverseTransformation);

    return new HomogeneousCoordinate<Vector3>(CoordinateType.twoDim, homogeneousRawPoint.x, homogeneousRawPoint.y);
  }
}
