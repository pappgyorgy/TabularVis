import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:bezier_simple_connect_viewer/bezier_simple_connect_viewer.dart';

import '../geometry/geometry.dart';
import '../math/math.dart';
import 'package:vector_math/vector_math.dart';

import 'input_slider.dart';

@Component(
    selector: "bezier-curve-settings",
    templateUrl: "template/bezier_curve_settings.html",
    directives: const <dynamic>[materialDirectives, InputSlider],
    providers: const <dynamic>[materialProviders],
    styleUrls: const ['template/scss/common.css', 'template/scss/bezier_curve_settings.css'],
)
class BezierCurveSettings implements AfterViewInit{
  final Application _application;
  List<Point> controlPoints;

  @Input()
  double crest = LineBezier.crest;
  @Input()
  double bezier_radius = LineBezier.bezier_radius;
  @Input()
  double bezier_radius_purity;

  double curveStart;
  double curveEnd;

  /*void curveStartChange(num newValue){
    this.curveStart = newValue.toDouble();
  }
  void curveEndChange(num newValue){
    this.curveEnd = newValue.toDouble();
  }
  void crestChange(num newValue){
    this.crest = newValue.toDouble();
  }
  void bezier_radiusChange(num newValue){
    this.bezier_radius = newValue.toDouble();
  }
  void bezier_radius_purityChange(num newValue){
    this.bezier_radius_purity = newValue.toDouble();
  }*/

  CanvasElement bezierCanvas;
  CanvasRenderingContext2D ctx;

  NumberRange<double> curveEndPointsAngularPosition;
  Diagram2D myDiagram;

  BezierCurveSettings(this._application){
    LineBezier.crest = 0.5;
    LineBezier.bezier_radius = 0.0;
    LineBezier.bezier_radius_purity = 0.75;

    this.crest = LineBezier.crest;
    this.bezier_radius = LineBezier.bezier_radius;
    this.bezier_radius_purity = LineBezier.bezier_radius_purity;

    curveEndPointsAngularPosition = new NumberRange.fromNumbers((2*PI) - 0.0, (2*PI) - (PI/2.0));
    curveStart = 0.0;
    curveEnd = (PI/2.0);
    myDiagram = new Diagram2D.empty();
    myDiagram.baseCircle.radius = 115.0;

  }

  void crestChange(num value){
    this._application.changeBezierParam(1, value);
    updateBezierCurve();
  }
  void bezier_radiusChange(num value){
    this._application.changeBezierParam(2, value);
    updateBezierCurve();
  }
  void bezier_radius_purityChange(num value){
    this._application.changeBezierParam(3, value);
    updateBezierCurve();
  }

  void curveStartChange(num value){
    curveEndPointsAngularPosition.begin = (2*PI) - value.toDouble();
    updateBezierCurve();
  }
  void curveEndChange(num value){
    curveEndPointsAngularPosition.end = (2*PI) - value.toDouble();
    updateBezierCurve();
  }

  void _addLinesToList(List<Point> listToAdd, List<HomogeneousCoordinate> listFrom, [int begin = 0, int end = 0]){
    if(end == 0) end = listFrom.length;
    for(var i = begin; i < end; i++){
      var helper = listFrom[i].coordinate.storage as List<double>;
      listToAdd.add(new Point(helper[0], helper[1]));
    }
  }

  @override
  void ngAfterViewInit() {
    bezierCanvas = querySelector('#bezier_canvas') as CanvasElement;
    ctx = bezierCanvas.getContext("2d") as CanvasRenderingContext2D;
    ctx.translate(bezierCanvas.width/2,bezierCanvas.height/2);

    ctx.font = "15px Arial";
    ctx.lineWidth=2;

    updateBezierCurve();
  }

  void updateBezierParam(num value, int type){
    switch(type){
      case 1: //crest
        LineBezier.crest = value.toDouble();
        break;
      case 2: //bezier_radius
        LineBezier.bezier_radius = value.toDouble();
        break;
      case 3: //bezier_radius_purity
        LineBezier.bezier_radius_purity = value.toDouble();
        break;
      default:
        break;
    }
  }

  void updateBezierCurve(){

    ctx.clearRect(-bezierCanvas.width/2, -bezierCanvas.height/2, bezierCanvas.width, bezierCanvas.height);

    LineBezier line = new LineBezier.newLineFromPoint(
        new Arc2D(
            curveEndPointsAngularPosition,
            myDiagram.baseCircle.clone(),
            myDiagram),
        myDiagram);

    List<HomogeneousCoordinate> allControlPoints = line.allControlPoints;

    List<HomogeneousCoordinate> listOfPoints = line.getLinePoints();

    var retVal = new List<Point>();
    var retVal2 = new List<Point>();

    _addLinesToList(retVal, listOfPoints);
    _addLinesToList(retVal2, allControlPoints);

    drawPoints(retVal, retVal2);

  }

  void drawPoints(List<Point> listOfPoints, List<Point> allControlPoints){

    int pointSize = 6;

    ctx.strokeStyle = '#aaaaaa';
    ctx.beginPath();
    ctx.arc(0,0,115,0,2*PI);
    ctx.stroke();

    ctx.beginPath();

    ctx.moveTo(listOfPoints.first.x, listOfPoints.first.y);

    for(var i = 1; i < listOfPoints.length; i++){
      ctx.lineTo(listOfPoints[i].x, listOfPoints[i].y);
    }

    ctx.stroke();

    ctx.fillStyle="#00ff00";
    for(var i = 0; i < allControlPoints.length; i++){
      ctx.fillRect(allControlPoints[i].x - pointSize/2, allControlPoints[i].y - pointSize/2, pointSize, pointSize);
    }

    ctx.fillStyle="#03a9f4";
    ctx.fillRect(- pointSize/2,- pointSize/2, pointSize, pointSize);
    ctx.fillRect((allControlPoints.first.x + allControlPoints.last.x) / 2 - pointSize/2, (allControlPoints.first.y + allControlPoints.last.y) / 2 - pointSize/2, pointSize, pointSize);


    ctx.fillStyle="#ffff99";
    for(var i = 0; i < allControlPoints.length; i++) {
      ctx.fillText("P${i + 1}", allControlPoints[i].x - 22, allControlPoints[i].y + 14);
    }

    ctx.fillStyle="#c180ff";
    ctx.fillText("O", - 16, 14,);
    ctx.fillText("M", (allControlPoints.first.x + allControlPoints.last.x) / 2 - 16, (allControlPoints.first.y + allControlPoints.last.y) / 2 + 14);


  }
}