import 'dart:html';
import 'dart:core';
import 'dart:async';
import 'package:angular2/core.dart';

import 'package:bezier_simple_connect_viewer/tabular_vis.dart';
import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/paper_icon_button.dart';

import 'interaction_button.dart';
import 'diagram_settings.dart';
import 'paper_drawer_narrow_changed_directive.dart';

@Component(
    selector: 'vis-area',
    templateUrl: 'template/visualization.html',
    directives: const <dynamic>[InteractionButton, DiagramSettings, PaperDrawerPanelNarrowChangedDirective],
    providers: const <dynamic>[InteractionHandler]
)
class VisualizationCanvas implements AfterViewInit{
  DivElement _canvasCont;
  final Application _application;
  final InteractionHandler _interactionHandler;
  Point<num> previousPoint = new Point(0.0,0.0);
  bool mouseButtonDown = false;
  int mousePosX = 0;
  int mousePosY = 0;
  bool _settingsSidebarStatus = false;
  String _previouslySelectedSettings = "";

  bool connectionEditEnabled = true;

  @ViewChild(DiagramSettings)
  DiagramSettings diagramSettings;

  PaperDrawerPanel drawer;
  PaperDrawerPanel drawer2;

  int mouseInteractionEffect = 0;

  bool _resizeRequire = false;

  VisualizationCanvas(this._application, this._interactionHandler){
    window.onResize.listen((Event e)=>
        this._application.resizeRenderer(
            _canvasCont.offsetWidth.toDouble(),
            _canvasCont.offsetHeight.toDouble()));

    this._interactionHandler.addNewInteraction((dynamic _){
      //print("Edit diagram");
      this.drawer.togglePanel();
    }, "settings", "Edit diagram");
    this._interactionHandler.addNewInteraction((dynamic _){
      //print("Resort diagram");
      this._application.sortSettingsChanged = true;
      this._application.redrawLatestDiagram();
    }, "sort", "Resort diagram");
    this._interactionHandler.addNewInteraction((dynamic _){
      //print("Refresn diagram");
      this._application.redrawLatestDiagram();
    }, "refresh", "Refresn diagram");
    this._interactionHandler.addNewInteraction((dynamic event){
      //print("edit connections");
      this.mouseInteractionEffect = 1 - this.mouseInteractionEffect;
      var target = event.target as PaperFab;
      if(target.icon == "open-with"){
        target.icon = "create";
      }else{
        target.icon = "open-with";
      }

    }, "create", "Edit mode");
    this._interactionHandler.addNewInteraction((dynamic _){
      //print("my second button");
      this._application.visualizationUserInteraction(
          VisualizationAction.download
      );
    }, "file-download", "Download the diagram");
  }

  @override
  void ngAfterViewInit() {
    this._canvasCont = querySelector("#canvas_cont") as DivElement;
    //this._canvasCont.onContextMenu.listen(mouseRightClickOnCanvas);
    if(_canvasCont == null){
      throw new StateError("Canvas conatiner element is not found");
    }
    this._application.resizeRenderer (
        _canvasCont.offsetWidth.toDouble(),
        _canvasCont.offsetHeight.toDouble());
    this._canvasCont.append(this._application.visualizationCanvasElement);
    if(!this._application.canvasMouseClickListen){
      this._application.visualizationCanvasElement.onClick.listen(mouseClickOnCanvas);
      this._application.visualizationCanvasElement.onContextMenu.listen(mouseRightClickOnCanvas);
      this._application.canvasMouseClickListen = true;
    }

    this.drawer = querySelector("#sideDrawer") as PaperDrawerPanel;
    this.drawer2 = querySelector("#sideSideDrawer") as PaperDrawerPanel;
  }

  void clicked(String text){
    print(text);
  }

  void downloadImage(){
    this._application.visualizationUserInteraction(
        VisualizationAction.download
    );
  }

  void cancelSidebarIconButtonSelection(){
    List<PaperIconButton> sidebarSelectorIcons = querySelectorAll(".sidebar-selector-icons") as List<PaperIconButton>;
    sidebarSelectorIcons.forEach((PaperIconButton iconButton) => iconButton.classes.remove("selected-sidebar-selector-icons"));
  }

  void openSettings(Event event){
    cancelSidebarIconButtonSelection();

    PaperIconButton iconButton = event.target as PaperIconButton;
    iconButton.toggleClass("selected-sidebar-selector-icons");
    switch(iconButton.id){
      case "basic":
        if(!isDrawerOpened(this.drawer2) || this._previouslySelectedSettings == "basic") {
          toggleDrawer(this.drawer2);
        }
        this.diagramSettings.showSettingsPage(0);
        this._previouslySelectedSettings = "basic";
        break;
      case "bezier":
        if(!isDrawerOpened(this.drawer2) || this._previouslySelectedSettings == "bezier") {
          toggleDrawer(this.drawer2);
        }
        this.diagramSettings.showSettingsPage(1);
        this._previouslySelectedSettings = "bezier";
        break;
      case "sorting":
        if(!isDrawerOpened(this.drawer2) || this._previouslySelectedSettings == "sorting") {
          toggleDrawer(this.drawer2);
        }
        this.diagramSettings.showSettingsPage(2);
        this._previouslySelectedSettings = "sorting";
        break;
      case "style":
        if(!isDrawerOpened(this.drawer2) || this._previouslySelectedSettings == "style") {
          toggleDrawer(this.drawer2);
        }
        this.diagramSettings.showSettingsPage(3);
        this._previouslySelectedSettings = "style";
        break;
      default:

    }
  }

  bool isDrawerOpened(PaperDrawerPanel drawer){
    return drawer.getAttribute("narrow") == null;
  }

  void toggleDrawer(PaperDrawerPanel drawer){
    if(drawer.getAttribute("narrow") != null){
      drawer.setAttribute("responsive-width", "468px");
    }else{
      drawer.setAttribute("responsive-width", "999999px");
      cancelSidebarIconButtonSelection();
    }
  }

  void lockSidebar(bool lockStatus){
    this._settingsSidebarStatus = lockStatus;
  }

  void resizeCanvas(Event event){
    DivElement main = ((event.target as PaperDrawerPanel).$["main"] as DivElement);
    int increaseDirection = (event.target as PaperDrawerPanel).getAttribute("narrow") == null ? -1 : 1;
    print("${_canvasCont.offsetWidth} - ${((event.target as PaperDrawerPanel).$["main"] as DivElement).offsetWidth}");
    this._application.resizeRenderer(
        main.offsetWidth.toDouble() + (300.0 * increaseDirection),
        _canvasCont.offsetHeight.toDouble());
    this._canvasCont
        .querySelector("canvas")
        .style
        .width = (main.offsetWidth.toDouble() + (300.0 * increaseDirection)).toString();
    this._resizeRequire = false;
  }

  void mouseClickOnCanvas(MouseEvent e){
    if(drawer2.getAttribute("narrow") == null && !this._settingsSidebarStatus){
      drawer2.setAttribute("responsive-width", "999999px");
      cancelSidebarIconButtonSelection();
      return;
    }
    //VisConnection connection;
    /*if(this.mouseInteractionEffect == 0) {
      try {
        connection = this._application.handleCanvasMouseClick(
            e.offset.x as int, e.offset.y as int);
      } catch (e) {
        this._application.addNotification(
            NotificationType.error, "${(e as StateError).message}");
        return;
      }

      this.diagramSettings.openSelectedConnectionSetting(connection);
    }*/
  }

  void mouseRightClickOnCanvas(MouseEvent e){
    e.preventDefault();
    if(drawer2.getAttribute("narrow") == null && !this._settingsSidebarStatus){
      drawer2.setAttribute("responsive-width", "999999px");
      cancelSidebarIconButtonSelection();
      return;
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