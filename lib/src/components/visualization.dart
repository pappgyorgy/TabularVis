import 'dart:html';
import 'dart:core';
import 'dart:async';
import 'package:angular/core.dart';
import 'package:angular/angular.dart';

import 'package:angular_components/angular_components.dart';

import 'package:bezier_simple_connect_viewer/bezier_simple_connect_viewer.dart';
/*import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/paper_icon_button.dart';*/

import 'interaction_button.dart';
import 'diagram_settings.dart';
import 'component_with_drawer_inside.dart';

import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_input/material_number_accessor.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';

@Component(
    selector: 'vis-area',
    templateUrl: 'template/visualization.html',
    directives: const <dynamic>[
      InteractionButton,
      DiagramSettings,
      materialDirectives,
      materialNumberInputDirectives,
      coreDirectives,
    ],
    providers: const <dynamic>[InteractionHandler, materialProviders],
    styleUrls: const ['template/scss/common.css', 'template/scss/visualization.css', 'package:angular_components/app_layout/layout.scss.css',],
)
class VisualizationCanvas extends ComponentWithDrawerInside implements AfterViewInit{
  DivElement _canvasCont;
  final Application _application;
  Point<num> previousPoint = new Point(0.0,0.0);
  bool mouseButtonDown = false;
  int mousePosX = 0;
  int mousePosY = 0;
  bool _settingsSidebarStatus = false;
  String _previouslySelectedSettings = "";

  bool connectionEditEnabled = true;

  @ViewChild("visualizationSettings") DiagramSettings diagramSettings;
  @ViewChild("visualizationMainSidebar") MaterialPersistentDrawerDirective visualizationMainSidebar;
  @ViewChild("visSettings") MaterialPersistentDrawerDirective visSettingsSidebar;

  @Input()
  bool sidebarVisibility;

  StreamController<int> _requestToReDrawLatestDiagram = new StreamController<int>();

  @Output()
  Stream<int> get requestToReDrawLatestDiagram => _requestToReDrawLatestDiagram.stream;

  String _selectedButton = "";

  int mouseInteractionEffect = 0;
  bool settingsSidebarVisibility = false;

  bool _lockSettingsSideBar = false;
  bool _previousSecondSidebarVisibility = false;
  bool _secondSidebarVisibility = false;

  VisualizationCanvas(this._application){
    window.onResize.listen((Event e)=>
        this._application.resizeRenderer(
            _canvasCont.offsetWidth,
            _canvasCont.offsetHeight));
  }

  @override
  void ngAfterViewInit() {
    this._canvasCont = querySelector("#canvas_cont") as DivElement;
    //this._canvasCont.onContextMenu.listen(mouseRightClickOnCanvas);
    if(_canvasCont == null){
      throw new StateError("Canvas conatiner element is not found");
    }
    this._application.resizeRenderer (
        _canvasCont.offsetWidth,
        _canvasCont.offsetHeight);
    this._canvasCont.append(this._application.visualizationCanvasElement);
    if(!this._application.canvasMouseClickListen){
      //this._application.visualizationCanvasElement.onClick.listen(mouseClickOnCanvas);
      this._application.visualizationCanvasElement.onContextMenu.listen(mouseRightClickOnCanvas);
      this._application.canvasMouseClickListen = true;
    }
    
    this._requestToReDrawLatestDiagram.add(0);
  }

  @override
  void ngOnDestroy() {
    this._requestToReDrawLatestDiagram.close();
  }
  
  void clicked(String text){
    print(text);
  }

  void downloadImage(){
    this._application.visualizationUserInteraction(
        VisualizationAction.download
    );
  }

  String get selectedSidebarButtonID => this._selectedButton;

  bool selectedSidebarButton(String id){
    return _selectedButton == id;
  }

  void changeSelectedSidebarButton(String id){
    this._previouslySelectedSettings = this._selectedButton;

    if(!_secondSidebarVisibility || this._previouslySelectedSettings == id){
      this._secondSidebarVisibility = !this._secondSidebarVisibility;
    }

    if(this._previousSecondSidebarVisibility != this._secondSidebarVisibility){
      resizeCanvas(_secondSidebarVisibility);
    }

    if(!this._secondSidebarVisibility){
      cancelSidebarIconButtonSelection();
    }else{
      this._selectedButton = id;
    }
  }

  void cancelSidebarIconButtonSelection(){
    this._previouslySelectedSettings = this._selectedButton = "";
  }

  bool isDrawerOpened(){
    return drawerVisibility;
  }

  bool isSettingOpened(){
    return handleSecondSidebarVisibility();
  }

  bool handleSecondSidebarVisibility(){
    if(!this.drawerVisibility){
      _secondSidebarVisibility = false;
      return false;
    }
    return this._secondSidebarVisibility;
  }

  void lockSidebar(bool lockStatus) => this._lockSettingsSideBar = lockStatus;

  void handleCanvasMouseClick(Event event){
    if(isSettingOpened()){
      if(!this._lockSettingsSideBar){
        this._secondSidebarVisibility = false;
        cancelSidebarIconButtonSelection();
        resizeCanvas(this._secondSidebarVisibility);
      }
    }else if(isDrawerOpened()){

    }else{

    }
  }

  void settingsVisibilityChange(bool status){
    this._previousSecondSidebarVisibility = this._secondSidebarVisibility;
    this._secondSidebarVisibility = status;
  }

  void resizeCanvas(bool staus){
    if(_canvasCont == null) return;
    var newWidth = _canvasCont.offsetWidth + (staus ? -300 : 300);
    this._application.resizeRenderer (
        newWidth,
        _canvasCont.offsetHeight);
    this._canvasCont
        .querySelector("canvas")
        .style
        .width = newWidth.toString();
  }

  void mouseRightClickOnCanvas(MouseEvent e){
    e.preventDefault();
    if(isSettingOpened()){
      if(!this._lockSettingsSideBar){
        this._secondSidebarVisibility = false;
        cancelSidebarIconButtonSelection();
        resizeCanvas(this._secondSidebarVisibility);
        return;
      }
    }
    VisConnection connection;
    if(this.mouseInteractionEffect == 2) {
      try {
        connection = this._application.handleCanvasMouseClick(
            e.offset.x as int, e.offset.y as int);
      } catch (e) {
        this._application.addNotification(
            NotificationType.error, "${(e as StateError).message}");
        return;
      }
      this._previousSecondSidebarVisibility = this._secondSidebarVisibility;
      this._secondSidebarVisibility = true;
      if(this._previousSecondSidebarVisibility != this._secondSidebarVisibility){
        resizeCanvas(_secondSidebarVisibility);
      }
      this._previouslySelectedSettings = this._selectedButton;
      this._selectedButton = "style";
      this.diagramSettings.openSelectedConnectionSetting(connection);
    }
  }

  void mouseOver(MouseEvent event){
    Point mouseCoord = event.offset;
    if(mouseButtonDown) {
      if(this.mouseInteractionEffect == 0) {
        this._application.diagramInteraction(
            mouseCoord, previousPoint, event.buttons);
      }
      //print("${event.buttons}");
    }
    this.previousPoint = mouseCoord;
  }

  void mouseWheel(WheelEvent event){
    Point mouseCoord = event.offset;
    this._application.diagramZoom(event.deltaY.toDouble() / 10.0);

    this.previousPoint = mouseCoord;
  }

  Future mouseDown(MouseEvent event) async{
    this.previousPoint = event.offset;
    this.mouseInteractionEffect = event.button;
    print(this.mouseInteractionEffect);
    this.mouseButtonDown = true;
  }

  Future mouseUp(MouseEvent event) async{
    this.previousPoint = event.offset;
    this.mouseButtonDown = false;
  }

}