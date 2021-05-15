part of renderer;

class ShapeBuilder{

  List<List<Vector3>> vertices;
  List<List<Face3>> faceVertIndices;
  List<List<int>> faceNormals;
  List<List<int>> faceMatIndices;
  List<List<Material>> shapeMaterials;
  List<Vector3> allVertices;
  List<Vector3> allNormals;
  List<Vector4> allColors;


  ShapeBuilder(){
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
        throw new UnimplementedError("Unimplemented because of missing three.dart features");
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
    }else if(shape is ShapePoincare){
      this._addNewShape(
          shape.generatePolygonData(),
          shape.generateFaceData(),
          (shape as ShapePoincare).getFaceMaterialIndices(materialIndex)
      );
    } else {
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

  List<Vector3> colors = <Vector3>[new Vector3(1.0, 0.0, 0.0), new Vector3(0.0, 1.0, 0.0)];
  bool actColor = true;

  void addFace3ExtToGeometryBuilder(GeometryBuilder gb, List<Face3> listOFFaces){

    listOFFaces.forEach((Face3 face){
      Face3Ext helper = face as Face3Ext;
      gb.AddFace3(face.a, face.b, face.c);
      if(helper.vertexNormals != null && helper.vertexNormals.length > 0){
        this.allNormals[face.a] = helper.vertexNormals[0];
        this.allNormals[face.b] = helper.vertexNormals[1];
        this.allNormals[face.c] = helper.vertexNormals[2];
      }else{
        this.allNormals[face.a] = new Vector3(0.0, 0.0, 1.0);
        this.allNormals[face.b] = new Vector3(0.0, 0.0, 1.0);
        this.allNormals[face.c] = new Vector3(0.0, 0.0, 1.0);
      }

      if(helper.vertexColors[0] == null || helper.vertexColors[1] == null || helper.vertexColors[2] == null){
        helper.vertexColors[0] = helper.vertexColors[1] = helper.vertexColors[2] = new Color(0xff0000);
      }
      this.allColors[face.a] = helper.vertexColors[0].toVector4;
      this.allColors[face.b] = helper.vertexColors[1].toVector4;
      this.allColors[face.c] = helper.vertexColors[2].toVector4;

    });

    for(var i = 0; i  < this.allColors.length; i++){
      if(allColors[i] == null){
        print("wrongTriangulation");
        //throw new StateError("wrongTriangulation");
      }
    }

  }

  GeometryBuilder get mergedGeometry{

    this.allNormals = new List<Vector3>();
    this.allColors = new List<Vector4>();
    this.allVertices = new List<Vector3>();

    GeometryBuilder gb = new GeometryBuilder();
    List<Vector3> allVerticesForGeometry;
    //retVal.faces = new List();
    int faceVertexOffset = 0;
    int materialOffset = 0;
    List<int> indicateUsedVertices;
    for(var i = 0; i < vertices.length; i++){
      //gb.AddVertices(this.vertices[i]);
      indicateUsedVertices = new List<int>.generate(this.vertices[i].length, (_)=>0);

      int faceMaterialIndex = 0;

      for(var k = 0; k < faceVertIndices[i].length; k++){
        if(faceVertIndices[i][k].a > this.vertices[i].length || faceVertIndices[i][k].b > this.vertices[i].length || faceVertIndices[i][k].c> this.vertices[i].length){
          throw new StateError("Errow, index outside of range");
        }

        if(indicateUsedVertices[faceVertIndices[i][k].a] > 0){
          this.vertices[i].add(this.vertices[i][faceVertIndices[i][k].a]);
          faceVertIndices[i][k].a = this.vertices[i].length - 1;
        }else{
          indicateUsedVertices[faceVertIndices[i][k].a] = 1;
        }

        if(indicateUsedVertices[faceVertIndices[i][k].b] > 0){
          this.vertices[i].add(this.vertices[i][faceVertIndices[i][k].b]);
          faceVertIndices[i][k].b = this.vertices[i].length - 1;
        }else{
          indicateUsedVertices[faceVertIndices[i][k].b] = 1;
        }

        if(indicateUsedVertices[faceVertIndices[i][k].c] > 0){
          this.vertices[i].add(this.vertices[i][faceVertIndices[i][k].c]);
          faceVertIndices[i][k].c = this.vertices[i].length - 1;
        }else{
          indicateUsedVertices[faceVertIndices[i][k].c] = 1;
        }

        faceVertIndices[i][k].a += faceVertexOffset;
        faceVertIndices[i][k].b += faceVertexOffset;
        faceVertIndices[i][k].c += faceVertexOffset;

        if(faceVertIndices[i][k] is Face3Ext){
          (faceVertIndices[i][k] as Face3Ext).materialIndex = faceMatIndices[i][faceMaterialIndex++] + materialOffset;
        }
        if(faceVertIndices[i][k].a > this.vertices[i].length + faceVertexOffset || faceVertIndices[i][k].b > this.vertices[i].length + faceVertexOffset || faceVertIndices[i][k].c> this.vertices[i].length + faceVertexOffset){
          throw new StateError("Errow, index outside of range");
        }
      }

      this.allColors.addAll(new List.generate(this.vertices[i].length, (_)=>new Vector4(0.0, 0.0, 0.0, 0.0)));
      this.allNormals.addAll(this.vertices[i]);
      this.allVertices.addAll(this.vertices[i]);
      addFace3ExtToGeometryBuilder(gb, faceVertIndices[i]);
      faceVertexOffset = this.allVertices.length;
      //materialOffset += this.shapeMaterials[i].length;
    }

    gb.AddVertices(this.allVertices);

    if(!gb.HasAttribute(aNormal)){
      gb.EnableAttribute(aNormal);
    }

    gb.AddAttributesVector3(aNormal, this.allNormals);

    if(!gb.HasAttribute(aColorAlpha)){
      gb.EnableAttribute(aColorAlpha);
    }
    gb.AddAttributesVector4(aColorAlpha, this.allColors);


   /* MeshFaceMaterial materials = new MeshFaceMaterial(<Material>[]);
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
    );*/


    /*var shaderInformation = ShaderLib["phong"];



    shader = new ShaderMaterial(
      uniforms: UniformsUtils.clone(shaderInformation["uniforms"]),
      vertexShader: shaderInformation["vertexShader"],
      fragmentShader: shaderInformation["fragmentShader"]
    );*/

    //materials = new MeshFaceMaterial(<Material>[shader, shader2, shader3, shader4, shader5, shader6, shader7]);

    //return new Mesh(retVal, materials);
    return gb;
  }

}