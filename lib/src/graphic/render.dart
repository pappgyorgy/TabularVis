library renderer;

import 'package:angular2/core.dart';

import 'package:three/three.dart';
import 'package:three/extras/shaders/shaders.dart';
import 'package:three/extras/core/shape_utils.dart' as ShapeUtils;
import 'package:three/extras/font_utils.dart' as FontUtils;
import 'package:three/extras/postprocessing/postprocessing.dart';
import 'package:vector_math/vector_math.dart' hide Ray;
import 'dart:core';
import 'dart:html';
import "dart:math";
import "dart:async";
import '../math/math.dart';
import '../diagram/diagram_manager.dart' show DiagramVisObject;
import '../geometry/geometry.dart' show Polygon, PolygonShape, PolygonText, ShapeForm, ShapeBezier, ShapeLine, ShapeSimple, ShapeText;

part 'visualization.dart';
part 'geometry_builder.dart';

const double DOT_SCALE = 2.0;
const double RGB_SHIFT_AMOUNT = 0.009;

@Injectable()
class Rendering{
  WebGLRenderer _renderer;
  Scene _scene;
  PerspectiveCamera _camera;
  List<String> _listOfSceneObjectID;
  bool _rendereImageToDataURL = false;
  Completer<String> imageData;
  var camAspect = 1;
  EffectComposer composer;

  PlaneGeometry _planeGeom = new PlaneGeometry(5000.0, 5000.0);
  Mesh _planeMesh;

  static const cameraZPosDef = 500;

  WebGLRenderer getRenderer() => _renderer;

  Rendering(double devicePixelRatio, double width, double height){
    //this._canvas = querySelector("#webGLContainer");

    //TODO put to another place
    //window.onResize.listen(this._onWindowResize);

    //TODO need to add void _onCanvasResize(e) event;

    this._planeMesh = new Mesh(_planeGeom, new MeshBasicMaterial());

    this._listOfSceneObjectID = new List();

    this._camera = new PerspectiveCamera( 45.0, width / height, 1.0, 1000.0 )
      ..position.setValues(0.0, 0.0, 500.0);
    this.camAspect = this._camera.aspect.toInt();


    //new colour: FBFAF4
    //old colour: E9FFE1
    this._renderer = new WebGLRenderer(devicePixelRatio: devicePixelRatio)
      ..autoClear = true
      ..setClearColorHex(0xFBFAF4, 1)
      ..setSize( width , height )
      ..antialias = true;
    this._renderer.sortObjects = true;

    this._scene = new Scene()
      ..add(this._camera)
      ..add(new AmbientLight(0xFFFFFF)
        ..position.setValues(.0, .0, 4500.0))
      ..add(new DirectionalLight( 0xFFFFFF, 0.125 )
        ..position.setValues( 0.0, 0.0, 1.0 ));

    var pointLight = new PointLight( 0xffffff, intensity: 1.0 )
      ..position.setValues( 0.0, 0.0, 4500.0 )
      ..color.setHSL(new Random().nextDouble(), 1.0, 0.5 );
  }


  void _changeRenderSize(double width, double height){
    if(height < pow(10,-5) && height > -pow(10,-5)) return;
    this._camera.aspect = width / height;
    this.camAspect = this._camera.aspect.toInt();
    this._camera.updateProjectionMatrix();
    this._renderer.setSize( width , height );
    //TODO I need to set the canvas element width after I returned back with it.
    //this._renderer.domElement.width = width;
  }

  Future<String> get image async{
    this.imageData = new Completer<String>();
    this._rendereImageToDataURL = true;
    return this.imageData.future;
  }

  void animate(num time) {
    window.requestAnimationFrame( animate );

    if(_rendereImageToDataURL == true){
      var imageDataURLFuture = new Future<String>((){
        _rendereImageToDataURL = false;
        this._camera.aspect = 1.7;
        this._camera.updateProjectionMatrix();
        this._renderer..setSize(3840,2160)
          ..setClearColorHex(0xFFFFFF, 1)
          ..render( _scene, _camera);

        /*this._renderer
          ..setClearColorHex(0xFFFFFF, 1)
          ..render( _scene, _camera);*/

        this._rendereImageToDataURL = false;
        var imgData = _renderer.canvas.toDataUrl();
        this._renderer.setClearColorHex(0xFBFAF4, 1);
        this._renderer.setSize( this._renderer.domElement.offsetWidth , this._renderer.domElement.offsetHeight );
        this._camera.aspect = (this._renderer.domElement.offsetWidth ) / (this._renderer.domElement.offsetHeight);
        this._camera.updateProjectionMatrix();
        if(imgData != null && imgData.isNotEmpty){
            //print("download result: ${imgData}");
            return imgData;
        }
      });
      // ignore: strong_mode_implicit_dynamic_method, strong_mode_implicit_dynamic_method
      imageDataURLFuture.then((imageDataURL)=>this.imageData.complete(imageDataURL));
    }else{
      //this.composer.render(time.toDouble());
      this._renderer.render(_scene, _camera);
      //print(this._renderer.info.render.calls);
    }
  }

  void addToScene(Object3D object, String objectID){
    this._listOfSceneObjectID.add(objectID);
    this._scene.add(
        object..name = objectID
    );
  }

  void _removeFromScene(String objectID){
    this._scene.objects.where((Object3D element){
      return element.name == objectID;
    }).toList().forEach((Object3D shape){
      this._scene.removeObject(shape);
    });

    this._listOfSceneObjectID.remove(objectID);
  }

  CanvasElement get canvasElement{
    return this._renderer.domElement as CanvasElement;
  }

  //Canvas element offsetWidth and offsetHeight
  HomogeneousCoordinate getMousePosition(Point<num> mouseClickPos) {
    var mousePos = new Vector2(
        (mouseClickPos.x.toDouble() / (this._renderer.domElement.offsetWidth)) * 2 - 1,
        -(mouseClickPos.y.toDouble() / (this._renderer.domElement.offsetHeight)) * 2 + 1);

    var vector = new Vector3(mousePos.x, mousePos.y, 1.0);
    Projector projector = new Projector();
    projector.unprojectVector(vector, this._camera);

    Ray ray = new Ray(this._camera.position, vector.sub(this._camera.position).normalize());

    var res = ray.intersectObject(this._planeMesh);

    if(res != null && res.length > 0){
      var coord = res.first.point;
      return new HomogeneousCoordinate<Vector3>(CoordinateType.twoDim, coord.x, coord.y);
    }else{
      throw new StateError("Can not determine 3D world coordinate");
    }

  }
}