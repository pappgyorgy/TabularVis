library renderer;

import 'package:angular/core.dart';
import 'package:chronosgl/chronosgl.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'dart:core';
import 'dart:html' as HTML;
import "dart:math";
import "dart:async";
import 'dart:js';
import 'dart:collection';
import '../math/math.dart';
import '../diagram/diagram_manager.dart' show DiagramVisObject;
import '../geometry/geometry.dart' show Polygon, PolygonShape, PolygonText,
      ShapeForm, ShapeBezier, ShapeLine, ShapeSimple, ShapeText,
      ShapePoincare, ShapeHeatmap, ShapeEdgeBundle, ShapeBlockConnection,
      ShapeBarLabel,
      ShapeUniqueScaleIndicator, Triangulator, Earcut;

part 'visualization.dart';
part 'shape_builder.dart';
part 'color.dart';
part 'font_utils.dart';
part 'curve.dart';
part 'curve_path.dart';
part 'path.dart';
part 'shape.dart';
part 'shape_utils.dart';
part 'curves/cubic_bezier_curve.dart';
part 'curves/ellipse_curve.dart';
part 'curves/line_curve.dart';
part 'curves/quadratic_bezier_curve.dart';
part 'curves/spline_curve.dart';
part 'text_geometry_builder.dart';
part 'bounding_box.dart';
part 'perspective_ext.dart';

const double DOT_SCALE = 2.0;
const double RGB_SHIFT_AMOUNT = 0.009;

ShaderObject faceVertexColorVertexShader = new ShaderObject("FixedVertexColorV")
  ..AddAttributeVars([aPosition, aColorAlpha, aNormal])
  ..AddUniformVars([uPerspectiveViewMatrix, uModelMatrix]);


ShaderObject faceVertexColorFragmentShader = new ShaderObject("FixedVertexColorF");

@Injectable()
class Rendering{
  ChronosGL _chronosGL;

  FlyingCamera _flyingCamera;
  RenderProgram _progBasic;
  RenderPhase _phase;
  PerspectiveExt _perspective;
  StatsFps _fps;
  Scene _scene;
  double near = 0.1, far = 1000.0, fov;

  int canvasWidth, canvasHeight;
  HTML.CanvasElement _canvas;
  HTML.HtmlElement stats;
  Material material;

  List<String> _listOfSceneObjectID;
  bool _rendereImageToDataURL = false;
  Completer<String> imageData;
  var camAspect = 1;
  Node torusNode;

  static const cameraZPosDef = 500;

  RenderPhase getRenderer() => _phase;

  Rendering([this.canvasWidth = 640, this.canvasHeight = 480]){

    if(this._canvas == null){
      this._canvas = new HTML.CanvasElement(width: this.canvasWidth, height: this.canvasHeight);
    }

    this.stats = new HTML.DivElement();
    this._fps = new StatsFps(stats, "blue", "gray");

    this._listOfSceneObjectID = new List();

    IntroduceNewShaderVar("vColorAlpha", new ShaderVarDesc(VarTypeVec4, "for aplha blending"));
    faceVertexColorVertexShader
      ..AddVaryingVars(["vColorAlpha"])
      ..SetBodyWithMain([
        StdVertexBody,
        "vColorAlpha = aColorAlpha;",
      ], prolog: [
        StdLibShader
      ]);

    faceVertexColorFragmentShader
      ..AddVaryingVars(["vColorAlpha"])
      ..SetBodyWithMain(["${oFragColor} = vColorAlpha;"]);

    //this.material = new Material.Transparent("test-mat", new TheBlendEquation(GL_FUNC_ADD, GL_ONE, GL_ONE));
    this.material = new Material("test-mat");
    this.material = new Material.Transparent("test-mat", BlendEquationStandard);

    _chronosGL = new ChronosGL(this.canvasElement);
    Color backgroundColor = new Color(0xFBFAF4);
    this._chronosGL.clearColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, 1.0);

    this._flyingCamera = new FlyingCamera();
    this._flyingCamera.setPos(0.0, 0.0, 500.0);
    this._flyingCamera.lookAt(new Vector3(0.0, 0.0, -1.0), new Vector3(0.0, 1.0, 0.0));
    this._perspective = new PerspectiveExt(this._flyingCamera, near, far);
    this._perspective.AdjustAspect(this.canvasWidth, this.canvasHeight);

    this._progBasic = new RenderProgram(
        "basic", this._chronosGL, faceVertexColorVertexShader, faceVertexColorFragmentShader);

    this._phase = new RenderPhase("main", this._chronosGL);
    this._changeRenderSize(this.canvasWidth, this.canvasHeight);

    this._scene = new Scene(
        "objects",
        this._progBasic,
        [this._perspective]);
    this._phase.add(this._scene);
  }


  void _changeRenderSize(int width, int height){
    this._canvas.width = width;
    this._canvas.height = height;
    this._perspective.AdjustAspect(width, height);
    this._phase.viewPortW = width;
    this._phase.viewPortH = height;
  }

  Future<String> get image async{
    this.imageData = new Completer<String>();
    this._rendereImageToDataURL = true;
    return this.imageData.future;
  }

  void animate(num time) {
    //HTML.window.requestAnimationFrame( animate );

    if(_rendereImageToDataURL == true){
      //var imageDataURLFuture = new Future<String>((){
        _rendereImageToDataURL = false;

        this._chronosGL.clearColor(1.0, 1.0, 1.0, 1.0);

        int newWidth = 3840, newHeight = 2160;
        this._changeRenderSize(newWidth, newHeight);

        this._phase.Draw();

        this._rendereImageToDataURL = false;
        var imgData = this._canvas.toDataUrl();

        this._changeRenderSize(this._canvas.offsetWidth, this._canvas.offsetHeight);
        Color backgroundColor = new Color(0xFBFAF4);
        this._chronosGL.clearColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, 1.0);

        if(imgData != null && imgData.isNotEmpty){
            //print("download result: ${imgData}");
          this.imageData.complete(imgData);
        }else{
          this.imageData.completeError("imgData was corrupt");
        }
      //});
      //imageDataURLFuture.then((imageDataURL)=>this.imageData.complete(imageDataURL));
    }else{
      List<DrawStats> stats = [];
      this._phase.Draw(stats);
      List<String> out = [];
      for (DrawStats d in stats) {
        out.add(d.toString());
      }

      this._fps.UpdateFrameCount(time.toDouble(), out.join("<br>"));
    }

    HTML.window.animationFrame.then((value){
      this.animate(value);
    });
  }

  void addToScene(Node object, String objectID){
    this._listOfSceneObjectID.add(objectID);
    this._scene.add(object);
  }

  void _removeFromScene(String objectID){
    this._scene.nodes.where((Node element){
      return element.name == objectID;
    }).toList().forEach((Node shape){
      this._scene.remove(shape);
    });

    this._listOfSceneObjectID.remove(objectID);
  }

  HTML.CanvasElement get canvasElement => this._canvas;

  //Canvas element offsetWidth and offsetHeight
  HomogeneousCoordinate getMousePosition(Point<num> mouseClickPos) {
    var mousePos = new Vector2(
        (mouseClickPos.x.toDouble() / (this._canvas.width)) * 2 - 1,
        -(mouseClickPos.y.toDouble() / (this._canvas.height)) * 2 + 1);

    var vector = new Vector3(mousePos.x, mousePos.y, 1.0);

    Vector3 unProjectedVector = this._perspective.unProjectVector(vector);

    Vector3 planeNormalVector = new Vector3.zero()..z = -1.0;

    Vector3 planePoint = new Vector3.zero();

    Vector3 rayStartPoint = this._flyingCamera.getPos();

    Vector3 rayDirection = (unProjectedVector - rayStartPoint)..normalize();

    double t = ((planePoint - rayStartPoint).dot(planeNormalVector))/(rayDirection.dot(planeNormalVector));

    Vector3 result = rayStartPoint + (rayDirection.scaled(t));
    //this.torusNode.setPosFromVec(result);
    //print(result);

    if(result != null){
      return new HomogeneousCoordinate<Vector3>(CoordinateType.twoDim, result.x, result.y);
    }else{
      throw new StateError("Can not determine 3D world coordinate");
    }

  }
}