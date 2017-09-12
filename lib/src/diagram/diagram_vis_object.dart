part of diagram;

@Entity()
class DiagramVisObject{

  @Property()
  List<double> shapeRawData;

  @Property()
  List<double> lineRawData;

  @Property()
  List<double> color;

  @Property()
  bool isOutlined = true;

  @Property()
  bool isTransparent = true;

  @Property()
  double opacity = 0.8;

  @Property()
  int randomSeedHelper = 0;

  @Property()
  String diagramID;

  @Property()
  String shapeID;

  @Property()
  String newShapeID;

  @Property()
  String label = "";

  @Property()
  List<double> labelMatrix;

  @Property()
  int numberOfShapePoint;

  @Property()
  int numberOfLinePoint;

  @Property()
  bool isThin = false;

  /// type of visObject
  /// 0 segment
  /// 1 connection
  /// 2 label
  @Property()
  int type;

  List<Vector3> shapePoints;

  List<List<Vector3>> listOfShapePoints;

  DiagramVisObject(){
    randomSeedHelper = this.hashCode;
  }

  DiagramVisObject.fromData(this.diagramID, this.shapeID, this.newShapeID,
      this.shapeRawData, this.lineRawData, List<double> lineConfig, List<double> connConfig,
      this.numberOfShapePoint, this.numberOfLinePoint): super(){
    this.color = new List<double>();
    var onlyColor = [connConfig[0], connConfig[1], connConfig[2]];
    this.opacity = connConfig[3];
    this.color.addAll(onlyColor);
    this.color.addAll(onlyColor);
    this.color.addAll(lineConfig);
  }

  bool get isDrawContour => this.label.isEmpty;

  void addShapePoints(List<List<Vector3>> points){
    this.shapePoints = new List<Vector3>();

    points.forEach((List<Vector3> oneLineOfPoints){
      this.shapePoints.addAll(oneLineOfPoints);
    });
  }

  Polygon get visObject{

    if(this.label.isNotEmpty){
      ShapeGeometry fontgeometry;
      Mesh fontmesh;
      var fontshapes = FontUtils.generateShapes(this.label, 20);

      fontgeometry = new ShapeGeometry(fontshapes, curveSegments: 20);

      Matrix4 posMat = new Matrix4.fromList(this.labelMatrix);

      fontgeometry.computeBoundingBox();
      var center = fontgeometry.boundingBox.center;

      Matrix4 mat = new Matrix4.identity();
      mat.translate(-center);
      mat.multiply(posMat);

      for(var i = 0; i < fontgeometry.vertices.length; i++){
        fontgeometry.vertices[i] = fontgeometry.vertices[i].applyMatrix4(mat);
      }

      return new PolygonText(this.label, this.labelMatrix, this.lineColor);

    }else{
      return new PolygonShape(this.shapeRawData, this.lineRawData,
        numberOfShapePoint, numberOfLinePoint, this.materialColor, this.lineColor,
        Triangulation.THREE_DART
      );
    }


  }

  Color get materialColor{
    if(this.color.length > 0) {
      return new Color.fromArray([color[0], color[1], color[2]]);
    }else{
      return new Color(
          new Random(
              new DateTime.now().millisecondsSinceEpoch
                  + randomSeedHelper).nextInt(0xffffff));
    }
  }

  Color get ambientColor{
    if(this.color.length > 3) {
      return new Color.fromArray([color[3], color[4], color[5]]);
    }else{
      return new Color(
          new Random(
              new DateTime.now().millisecondsSinceEpoch
                  + randomSeedHelper + 100).nextInt(0xffffff));
    }
  }

  Color get lineColor{
    if(this.color.length > 6){
      return new Color.fromArray([color[6], color[7], color[8]]);
    }else{
     return new Color(0x000000);
    }
  }

  dynamic get shapeMaterial{
    //print("${opacity}");
    if(isOutlined){
      return [
        new MeshLambertMaterial()
          ..color = materialColor
          ..ambient = ambientColor
          ..transparent = isTransparent
          ..opacity = opacity,
        new LineBasicMaterial(color: lineColor.getHex())
      ];
    }else{
      return new MeshLambertMaterial()
        ..color = materialColor
        ..ambient = ambientColor
        ..transparent = isTransparent
        ..opacity = opacity;
    }
  }
}