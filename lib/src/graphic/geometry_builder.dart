part of renderer;

class GeometryBuilder{

  List<List<Vector3>> vertices;
  List<List<Face3>> faceVertIndices;
  List<List<int>> faceNormals;
  List<List<int>> faceMatIndices;
  List<List<Material>> shapeMaterials;

  GeometryBuilder(){
    vertices = new List<List<Vector3>>();
    faceVertIndices = new List<List<Face3>>();
    faceMatIndices = new List<List<int>>();
    shapeMaterials = new List<List<Material>>();
  }

  Vector3 calculateNormals(Vector3 a, Vector3 b, Vector3 c){
    var first = (b-a);
    var second = (c-a);

    return first.cross(second);
  }


  void addNewPolygon(DiagramVisObject visObject){

    Polygon polygon = visObject.visObject;

    if(visObject.isDrawContour){
      //List test = polygon.contourVertices.toList(growable: true)..addAll(polygon.polygonVertices);
      /*List test = polygon.contourVertices.toList(growable: true)..addAll(polygon.polygonVertices);
      this._addNewShape(
          test as List<Vector3>,
          polygon.contourFaces,
          [0]
      );*/
      if(visObject.isThin){
        this._addNewShape(
            polygon.contourVertices,
            polygon.contourFaces,
            [0]
        );
      }else {
        var shape = new Shape(polygon.contourVertices);
        var shapeHole = new Shape(polygon.polygonVertices.reversed.toList());

        shape.holes.add(shapeHole);

        var shapeGeom = new ShapeGeometry([shape]);

        Color faceVertexColor = new Color(0x000000);
        List<Color> vertexColors = <Color>[
          faceVertexColor, faceVertexColor, faceVertexColor];
        for (var i = 0; i < shapeGeom.faces.length; i++) {
          (shapeGeom.faces[i] as Face3).vertexColors = vertexColors;
        }

        this._addNewShape(
            shapeGeom.vertices,
            shapeGeom.faces as List<Face3>,
            [0]
        );
      }
    }

    this._addNewShape(
        polygon.polygonVertices,
        polygon.polygonFaces,
        [0]
    );

  }

  void addShape(ShapeForm shape, [int materialIndex = 0]){
    if(shape is ShapeBezier){
      this._addNewShape(
          shape.generatePolygonData(),
          shape.generateFaceData(),
          (shape as ShapeBezier).getFaceMaterialIndices(materialIndex)
      );
    }else{
      this._addNewShape(
          shape.generatePolygonData(),
          shape.generateFaceData(),
          [materialIndex]
      );
    }

  }

  void _addNewShape(List<Vector3> shapeVertices, List<Face3> vertIndices,
      [List<int> matIndices = null, List<Material> shapeMat = null]){

    vertices.add(shapeVertices);
    faceVertIndices.add(vertIndices);

    if(matIndices == null){
      this.faceMatIndices.add(new List.generate(vertIndices.length, (_)=>0));
    }else{
      if(matIndices.length == 1){
        int matIndex = matIndices[0];
        if(shapeMat == null){
          if(shapeMaterials.length < 1 || (shapeMaterials.length > 0 && matIndex >= shapeMaterials.first.length)){
            //throw new StateError("The given $matIndex is bigger that the number of available materials");
          }else{
            shapeMaterials.add(shapeMaterials.first);
          }
        }else if(matIndex < shapeMat.length){
          shapeMaterials.add(shapeMat);
        }else{
          //throw new StateError("The given $matIndex is bigger that the number of available materials in the given $shapeMat material parameter list");
        }
        this.faceMatIndices.add(new List.generate(vertIndices.length, (_)=>matIndex));
      }else if(matIndices.length == vertIndices.length) {
        //TODO error check for the material indices
        this.faceMatIndices.add(matIndices);
        if(shapeMat != null) {
          this.shapeMaterials.add(shapeMat);
        }
      }else{
        throw new StateError("The number of material indices is larger then the number of faces");
      }
    }

  }

  Object3D get mergedGeometry{
    Geometry retVal = new Geometry();
    //retVal.faces = new List();
    int faceVertexOffset = 0;
    int materialOffset = 0;
    for(var i = 0; i < vertices.length; i++){
      retVal.vertices.addAll(this.vertices[i]);
      int faceMaterialIndex = 0;

      for(var k = 0; k < faceVertIndices[i].length; k++){
        if(faceVertIndices[i][k].a > retVal.vertices.length || faceVertIndices[i][k].b > retVal.vertices.length || faceVertIndices[i][k].c> retVal.vertices.length){
          throw new StateError("Errow, index outside of range");
        }
        faceVertIndices[i][k].a += faceVertexOffset;
        faceVertIndices[i][k].b += faceVertexOffset;
        faceVertIndices[i][k].c += faceVertexOffset;
        faceVertIndices[i][k].materialIndex = faceMatIndices[i][faceMaterialIndex++] + materialOffset;
        if(faceVertIndices[i][k].a > retVal.vertices.length || faceVertIndices[i][k].b > retVal.vertices.length || faceVertIndices[i][k].c> retVal.vertices.length){
          throw new StateError("Errow, index outside of range");
        }
        retVal.faces.add(faceVertIndices[i][k]);
      }
      faceVertexOffset = retVal.vertices.length;
      //materialOffset += this.shapeMaterials[i].length;
    }

    MeshFaceMaterial materials = new MeshFaceMaterial(<Material>[]);
    for(var h = 0; h < shapeMaterials.length; h++){
      shapeMaterials[h].forEach((Material mat){
        materials.materials.add(mat);
      });
    }

    Material shader = new MeshBasicMaterial(color: 0xffffff,
        shading: FlatShading,
        vertexColors: VertexColors,
        side: DoubleSide
    );

    /*Material shader = new MeshBasicMaterial(color: 0xff0000,
        side: DoubleSide
    );*/

    Material shader2 = new MeshBasicMaterial(color: 0xffffff,
        shading: FlatShading,
        vertexColors: VertexColors,
        transparent: true,
        opacity: 0.8,
        depthTest: false,
        depthWrite: false
    );

    Material shader3 = new MeshBasicMaterial(color: 0xffffff,
        shading: FlatShading,
        vertexColors: VertexColors,
        transparent: true,
        opacity: 0.8,
        depthTest: false,
        depthWrite: false
    );

    Material shader4 = new MeshBasicMaterial(color: 0xffffff,
        shading: FlatShading,
        vertexColors: VertexColors,
        transparent: true,
        opacity: 0.8,
        depthTest: false,
        depthWrite: false
    );


    Material shader5 = new MeshBasicMaterial(color: 0xffffff,
        shading: FlatShading,
        vertexColors: VertexColors,
        transparent: true,
        opacity: 0.8,
        depthTest: false,
        depthWrite: false
    );


    Material shader6 = new MeshBasicMaterial(color: 0xffffff,
        shading: FlatShading,
        vertexColors: VertexColors,
        transparent: true,
        opacity: 0.8,
        depthTest: false,
        depthWrite: false
    );

    Material shader7 = new MeshBasicMaterial(color: 0xffffff,
        shading: FlatShading,
        vertexColors: VertexColors,
        transparent: true,
        opacity: 0.8,
        depthTest: false,
        depthWrite: false
    );


    /*var shaderInformation = ShaderLib["phong"];



    shader = new ShaderMaterial(
      uniforms: UniformsUtils.clone(shaderInformation["uniforms"]),
      vertexShader: shaderInformation["vertexShader"],
      fragmentShader: shaderInformation["fragmentShader"]
    );*/

    materials = new MeshFaceMaterial(<Material>[shader, shader2, shader3, shader4, shader5, shader6, shader7]);

    return new Mesh(retVal, materials);
  }

}