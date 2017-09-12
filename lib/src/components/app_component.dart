import 'package:angular2/core.dart';
import 'package:angular_components/angular_components.dart';

//Polymer Dart elements
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/app_layout/app_header_layout/app_header_layout.dart';
import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/image_icons.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_tabs.dart';
import 'package:polymer_elements/app_layout/app_drawer_layout/app_drawer_layout.dart';
import 'package:polymer_elements/iron_resizable_behavior.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_toast.dart';

import 'package:polymer_elements/editor_icons.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_item_body.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/iron_pages.dart';

import 'package:polymer_elements/paper_slider.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_toggle_button.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_radio_group.dart';
import 'package:polymer_elements/paper_radio_button.dart';
import 'package:polymer_elements/paper_scroll_header_panel.dart';

import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/av_icons.dart';
import 'package:polymer_elements/paper_dialog.dart';

import 'package:polymer_elements/paper_tooltip.dart';

//dart imports
import 'dart:async';
import 'dart:html';

//Injectables
import 'package:bezier_simple_connect_viewer/src/application.dart';

//Custom elements
import 'interaction_button.dart';
import 'visualization.dart';
import 'data_grid.dart';
import 'information.dart';
import 'diagram_settings.dart';



@Component(
    selector: 'my-app',
    templateUrl: 'template/app_component.html',
    directives: const <dynamic>[Information, DataGrid, VisualizationCanvas, materialDirectives],
    providers: const <dynamic>[DiagramManager, AppLogger, SortHandler, Visualization, DataProcessing, Application, materialProviders])
class AppComponent implements AfterViewInit, AfterContentChecked{
  final Application _application;
  DivElement _drawArea;
  PaperDrawerPanel drawerVis;
  PaperDrawerPanel drawerTable;
  PaperHeaderPanel header;
  PaperIconButton menu;
  PaperToast notification;
  PaperToast notificationError;
  PaperIconButton switchContentButton;
  String notificationMessage = "Default notification message";
  int _selectedContent = 0;
  int sideBarPosition = 1;

  String get selectedContent => this._selectedContent % 2 == 0 ? "table" : "visualization";

  Element get myApp{
    return querySelector("my-app");
  }

  @override
  void ngAfterViewInit() {
    this.drawerVis = querySelector("#sideDrawer") as PaperDrawerPanel;
    this.drawerTable = querySelector("#sideDrawer2") as PaperDrawerPanel;
    this.header = querySelector("#header") as PaperHeaderPanel;
    this.notification = querySelector("#notification") as PaperToast;
    this.notificationError = querySelector("#notificationError") as PaperToast;
    this._application.notificationMessages.listen(showNotification);
    this.switchContentButton = querySelector("#switchContentSelector") as PaperIconButton;
    //this._application.testSortAlgorithm();
  }

  ///Initialize render
  AppComponent(this._application){

  }

  void showHideSideBar(Event event){
    var sideBarToToggle = drawerTable;
    if(this._selectedContent % 2 == 1){
      sideBarToToggle = drawerVis;
    }
    if(sideBarPosition == 1){
      sideBarToToggle.setAttribute("responsive-width", "999999px");
      sideBarPosition = 0;
    }else{
      sideBarToToggle.setAttribute("responsive-width", "768px");
      sideBarPosition = 1;
    }
  }

  void ngAfterContentChecked() {
    this.drawerVis = querySelector("#sideDrawer") as PaperDrawerPanel;
    this.drawerTable = querySelector("#sideDrawer2") as PaperDrawerPanel;
  }

  void changeContent(int contentIndex){
    //this._selectedContent = contentIndex;
    //this._selectedContent++;
    this.switchContent(null);
  }

  void showNotification(String newMessage){
    List<String> messages = newMessage.split("~");
    if(messages[0].compareTo("error") == 0){
      this.notificationError.text = messages.length == 1 ? messages.first : messages[1];
      this.notificationError.open();
    }else{
      this.notification.text = messages.length == 1 ? messages.first : messages[1];
      this.notification.open();
    }

  }

  void switchContent(Event event){
    if(!this._application.isDiagramAlreadyGenerated){
      this.notificationError.text = "First, a diagram has to be generated to switch the visualization tab.";
      this.notificationError.open();
      return;
    }
    this._selectedContent++;
    this.switchContentButton.icon = this._selectedContent % 2 == 0 ? "editor:insert-chart" : "image:grid-on";
    sideBarPosition = 1;
  }
}