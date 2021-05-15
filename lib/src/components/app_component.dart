import 'package:angular/core.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/app_layout/material_temporary_drawer.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/material_toggle/material_toggle.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_number_accessor.dart';



//platform detects
import 'package:platform_detect/platform_detect.dart';

//dart imports
import 'dart:html';

//Injectables
import '../application.dart';

//Custom elements
//import 'interaction_button.dart';
import 'visualization.dart';
import 'data_grid.dart';
import 'component_with_drawer_inside.dart';
//import 'information.dart';
//import 'diagram_settings.dart';

@Component(
    selector: 'my-app',
    styleUrls: const ['template/scss/common.css', 'template/scss/app_component.css', 'package:angular_components/app_layout/layout.scss.css',],
    templateUrl: 'template/app_component.html',
    directives: const <dynamic>[
      DataGrid,
      VisualizationCanvas,
      materialDirectives,
      DeferredContentDirective,
      MaterialButtonComponent,
      MaterialIconComponent,
      MaterialPersistentDrawerDirective,
      MaterialTemporaryDrawerComponent,
      coreDirectives,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialToggleComponent,
      materialNumberInputDirectives
    ],
    providers: const <dynamic>[
      DiagramManager,
      AppLogger,
      SortHandler,
      Visualization,
      DataProcessing,
      Application,
      materialProviders],
)
class AppComponent implements AfterViewInit, AfterContentChecked{
  final Application _application;
  DivElement _drawArea;
  MaterialDialogComponent showBrowserCompatibility;
  MaterialPersistentDrawerDirective drawerVis;
  MaterialPersistentDrawerDirective drawerTable;
  MaterialIconComponent menu;
  //PaperToast notification;
  //PaperToast notificationError;

  @ViewChild("switchContentButton") MaterialIconComponent switchContentButton;

  String notificationMessage = "Default notification message";
  int _selectedContent = 0;

  bool showBrowserWarningDialog = false;

  String get selectedContent => this._selectedContent % 2 == 0 ? "table" : "visualization";

  String selectedContentIcon = "insert_chart";

  @ViewChild('tableMainDrawer') ComponentWithDrawerInside tableMainDrawer;
  @ViewChild('visualizationMainDrawer') ComponentWithDrawerInside visualizationMainDrawer;

  ComponentWithDrawerInside get mainSideBar{
    if(this._selectedContent % 2 == 0){
      return tableMainDrawer;
    }else{
      return visualizationMainDrawer;
    }
  }

  Element get myApp{
    return querySelector("my-app");
  }

  @override
  void ngAfterViewInit() {
    //this.drawerVis = querySelector("#sideDrawer") as MaterialPersistentDrawerDirective;
    //this.drawerTable = querySelector("#sideDrawer2") as MaterialPersistentDrawerDirective;

    //this.notification = querySelector("#notification") as PaperToast;
    //this.notificationError = querySelector("#notificationError") as PaperToast;
    this._application.notificationMessages.listen(showNotification);
    //this.switchContentButton = querySelector("#switchContentSelector") as MaterialIconComponent;
    //showBrowserCompatibility = querySelector("#show_browser_compatibility") as MaterialDialogComponent;
    //this._application.testSortAlgorithm();

    if (!browser.isChrome) {
      //showBrowserCompatibility.open();
    }
  }

  ///Initialize render
  AppComponent(this._application){

  }

  void showHideSideBar(Event event){
    var sideBarToToggle = drawerTable;
    if(this._selectedContent % 2 == 1){
      sideBarToToggle = drawerVis;
    }
    /*if(sideBarPosition == 1){
      sideBarToToggle.setAttribute("responsive-width", "999999px");
      sideBarPosition = 0;
    }else{
      sideBarToToggle.setAttribute("responsive-width", "768px");
      sideBarPosition = 1;
    }*/
  }

  void ngAfterContentChecked() {
    this.drawerVis = querySelector("#sideDrawer") as MaterialPersistentDrawerDirective;
    this.drawerTable = querySelector("#sideDrawer2") as MaterialPersistentDrawerDirective;
  }

  void changeContent(int contentIndex){
    this._selectedContent = contentIndex;
    this._selectedContent++;
    this.switchContent(null);
  }

  void showNotification(String newMessage){
    List<String> messages = newMessage.split("~");
    if(messages[0].compareTo("error") == 0){
      //this.notificationError.text = messages.length == 1 ? messages.first : messages[1];
      //this.notificationError.open();
    }else{
      //this.notification.text = messages.length == 1 ? messages.first : messages[1];
      //this.notification.open();
    }

  }

  void initiateDiagramRedraw(int value){
    this._application.redrawLatestDiagram();
    this._application.initConnection();
  }

  void switchContent(Event event){
    if(!this._application.isDiagramAlreadyGenerated){
      //this.notificationError.text = "First, a diagram has to be generated to switch the visualization tab.";
      //this.notificationError.open();
      return;
    }
    this._selectedContent++;
    this.selectedContentIcon  = this._selectedContent % 2 == 0 ? "insert_chart" : "grid_on";
    //this.switchContentButton.icon = this._selectedContent % 2 == 0 ? "editor:insert-chart" : "image:grid-on";
  }
}