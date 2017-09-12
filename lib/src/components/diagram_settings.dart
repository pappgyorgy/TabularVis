import 'dart:async';
import 'dart:html';
import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';

import 'package:bezier_simple_connect_viewer/tabular_vis.dart';

import 'paper_tab_selected_directive.dart';
import 'paper_radio_roup_selected_directive.dart';

import 'package:polymer_elements/paper_slider.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_tabs.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_toggle_button.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_radio_group.dart';
import 'package:polymer_elements/paper_radio_button.dart';
import 'package:polymer_elements/paper_scroll_header_panel.dart';
import 'package:polymer_elements/iron_flex_layout_classes.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:three/three.dart' show Color;
import 'package:color_picker/color_picker.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_drawer_panel.dart';

import 'slider_value.dart';
import 'bezier_curve_settings.dart';

@Component(
  selector: "diagram-settings",
  templateUrl: "template/diagram_settings.html",
  directives: const <dynamic>[PaperTabsSelectedDirective, PaperRadioGroupSelectedDirective, BezierCurveSettings, materialDirectives],
  providers: const <dynamic>[materialDirectives]
)
class DiagramSettings implements AfterViewInit, DoCheck, OnDestroy{
  final Application _application;
  dynamic selectedSettingPage = 0;
  dynamic selectedAlgorithm = "0";
  bool isSortEnabled = false;
  bool _elementInitialized = false;
  bool _elementInTemplateInit = false;

  StreamController<bool> _lockSidebar = new StreamController<bool>();

  @Output()
  Stream<bool> get lockSideBar => _lockSidebar.stream;

  PaperDrawerPanel drawer;

  PaperSlider segmentOneSliderElement;
  PaperSlider segmentTwoSliderElement;

  IronIcon segmentOneColor;
  IronIcon segmentTwoColor;
  IronIcon connectionColor;

  SliderValue crest;
  SliderValue bezier_radius;
  SliderValue bezier_radius_purity;

  SliderValue segmentOneSlider;
  SliderValue barInSegmentOneSlider;
  SliderValue groupOneSlider;

  SliderValue segmentTwoSlider;
  SliderValue barInSegmentTwoSlider;
  SliderValue groupTwoSlider;

  SliderValue spaceConnAndBlocks;
  SliderValue blockDistance;
  SliderValue lineWidth;

  PaperDialog colorPickerContainer;
  ColorPicker largeColorPicker = new ColorPicker(256);

  HtmlElement colorPickerActualTarget;

  Label segmentOne;
  Label segmentTwo;
  Label segmentOneParent;
  Label segmentTwoParent;
  Label groupOne;
  Label groupTwo;
  VisConnection _selectedConnection;

  String connectionsDirection = "none";
  PaperToggleButton enableConnectionsDirection;


  DiagramSettings(this._application){
    /*this.crest = new SliderValue(0.5,0.5,0.0,2.0,
            (num value){this._application.changeBezierParam(1,value);});
    this.bezier_radius = new SliderValue(0.0,0.0,0.0,2.0,
            (num value){this._application.changeBezierParam(2,value);});
    this.bezier_radius_purity = new SliderValue(0.75,0.75,-2.0,2.0,
            (num value){this._application.changeBezierParam(3,value);});*/

    this.segmentOneSlider = new SliderValue(1,1,1,10,
            (int value){this.changeElementIndex(1,value);});
    this.barInSegmentOneSlider = new SliderValue(1,1,1,10,
            (int value){this.changeElementIndex(3,value);});
    this.groupOneSlider = new SliderValue(1,1,1,10,
            (int value){this.changeElementIndex(5,value);});

    this.segmentTwoSlider = new SliderValue(1,1,1,10,
            (int value){this.changeElementIndex(2,value);});
    this.barInSegmentTwoSlider = new SliderValue(1,1,1,10,
            (int value){this.changeElementIndex(4,value);});
    this.groupTwoSlider = new SliderValue(1,1,1,10,
            (int value){this.changeElementIndex(6,value);});

    this.spaceConnAndBlocks = new SliderValue(0.0,0.0,0.0,150.0,
            (num value){this._application.changeDiagramLooks(1,value);});
    this.blockDistance = new SliderValue(1.5,1.5,0.0,1.0,
            (num value){this._application.changeDiagramLooks(2,value);});
    this.lineWidth = new SliderValue(0.3,0.3,0.01,1.0,
            (num value){this._application.changeDiagramLooks(3,value);});

    if(!this._application.isListenConnectionStream){
      //this._application.connectionData.listen(openSelectedConnectionSetting);
      //this._application.isListenConnectionStream = true;
    }

    openSelectedConnectionSetting(this._application.defaultConnection);

  }

  void lockDiagramSettingsSidebar(Event event){
    PaperToggleButton enableSegmentRandomColor = event.target as PaperToggleButton;
    this._lockSidebar.add(enableSegmentRandomColor.checked);
  }

  void applySelectedColor(Event event){
    var selectedColor = largeColorPicker.currentColor;
    var color = new Color.fromArray([selectedColor.r / 255, selectedColor.g / 255, selectedColor.b / 255]);
    if(colorPickerActualTarget.id == "segOne"){
      //this.segmentOneColor.style.color = color.getContextStyle();
      this.selectedConnection.config.segmentOneColor = color;
    }else if(colorPickerActualTarget.id == "segTwo"){
      //this.segmentTwoColor.style.color = color.getContextStyle();
      this.selectedConnection.config.segmentTwoColor = color;
    }else if(colorPickerActualTarget.id == "connectionColor"){
      //this.connectionColor.style.color = color.getContextStyle();
      this.selectedConnection.config.connectionColor = color;
    }else if(colorPickerActualTarget.id == "minColor"){
      ConnectionVis.minColor = color;
    }else if(colorPickerActualTarget.id == "maxColor"){
      ConnectionVis.maxColor = color;
    }else if(colorPickerActualTarget.id == "unifiedColor"){
      ConnectionVis.unifiedColor = color;
    }

    colorPickerActualTarget.querySelector("iron-icon").style.color = "rgba(${selectedColor.r}, ${selectedColor.g}, ${selectedColor.b}, 1.0)";
  }

  void setSelectedColor(Event event){
    applySelectedColor(event);
    colorPickerContainer.close();
    if(colorPickerActualTarget.id != "minColor"
      && colorPickerActualTarget.id != "maxColor"
      && colorPickerActualTarget.id != "unifiedColor") {
      this._application.redrawLatestDiagram();
    }
  }

  void applyGreyColor(Event event){
    largeColorPicker.infoBox.color = new ColorValue.fromRGB(75,75,75);
    largeColorPicker.infoBox.refresh();
    applySelectedColor(event);
    colorPickerContainer.close();
    this._application.redrawLatestDiagram();
  }

  void openBy(Event event) {
    HtmlElement target;
    if(event.target is PaperButton){
      target = event.target as HtmlElement;
    }else{
      target = ((event.target as HtmlElement).parent.parent) as HtmlElement;
    }
    List<double> colorList;
    colorPickerActualTarget = target;
    if(target.id == "segOne"){
      colorList = this.selectedConnection.getSegmentConfig(this.selectedConnection.segmentOneID);
    }else if(target.id == "segTwo"){
      colorList = this.selectedConnection.getSegmentConfig(this.selectedConnection.segmentTwoID);
    }else if(target.id == "connectionColor"){
      colorList = this.selectedConnection.getConnectionConfig();
    }else if(target.id == "minColor"){
      colorList = [ConnectionVis.minColor.r, ConnectionVis.minColor.g, ConnectionVis.minColor.b];
    }else if(target.id == "maxColor"){
      colorList = [ConnectionVis.maxColor.r, ConnectionVis.maxColor.g, ConnectionVis.maxColor.b];
    }else if(target.id == "unifiedColor"){
      colorList = [ConnectionVis.unifiedColor.r, ConnectionVis.unifiedColor.g, ConnectionVis.unifiedColor.b];
    }else{
      throw new StateError("Wrong button");
    }

    target.querySelector("iron-icon").style.color = "rgba(${(colorList[0] * 255).toInt()}, ${(colorList[1] * 255).toInt()}, ${(colorList[2] * 255).toInt()}, 1.0)";

    largeColorPicker.infoBox.color = new ColorValue.fromRGB((colorList[0] * 255).toInt(), (colorList[1] * 255).toInt(), (colorList[2] * 255).toInt());
    largeColorPicker.infoBox.refresh();

    colorPickerContainer.positionTarget = target;
    colorPickerContainer.open();
  }

  @override
  void ngAfterViewInit() {
    this._elementInitialized = true;
    this.colorPickerContainer = querySelector("#color_picker_container") as PaperDialog;
    largeColorPicker = new ColorPicker(256);
    this.colorPickerContainer.nodes.insert(0, largeColorPicker.element);
    largeColorPicker.element.style.width = "340px";
    largeColorPicker.element.style.padding = "0px";

    (largeColorPicker.element.querySelectorAll("input") as List<InputElement>).forEach((InputElement input){
      input.style.width = "30px";
    });

    this.drawer = querySelector("#drawer3") as PaperDrawerPanel;
  }

  String getSegmentColor(String ID){
    var segmentColor = this.selectedConnection.getSegmentConfig(ID);
    var color = new Color.fromArray(segmentColor);
    return color.getContextStyle();
  }

  @override
  void ngDoCheck() {
    if(selectedSettingPage == "4" && !_elementInTemplateInit && this.selectedConnection != null){
      this.segmentOneSliderElement = querySelector("#segmentOnePosSlider") as PaperSlider;
      this.segmentTwoSliderElement = querySelector("#segmentTwoPosSlider") as PaperSlider;

      this.segmentOneColor = querySelector("#segmentOneColorIcon") as IronIcon;
      this.segmentTwoColor = querySelector("#segmentTwoColorIcon") as IronIcon;
      this.connectionColor = querySelector("#connectionColorIcon") as IronIcon;

      this.segmentOneColor.style.color = this.getSegmentColor(this.selectedConnection.segmentOneID);
      this.segmentTwoColor.style.color = this.getSegmentColor(this.selectedConnection.segmentTwoID);
      this.connectionColor.style.color = new Color.fromArray(this.selectedConnection.getConnectionConfig()).getContextStyle();


      if(this.segmentOneSlider.maxValue < 2){
        segmentOneSliderElement.disabled = true;
        this.segmentOneSlider.maxValue = 1;
      }

      if(this.segmentTwoSlider.maxValue < 2){
        segmentTwoSliderElement.disabled = true;
        this.segmentTwoSlider.maxValue = 1;
      }

      _elementInTemplateInit = true;
    }else if(selectedSettingPage == "1" && enableConnectionsDirection == null){
      this.enableConnectionsDirection = querySelector("#enable_connections_direction") as PaperToggleButton;
    } else if(selectedSettingPage != "4" || (selectedSettingPage == "4" && this.selectedConnection != null)){
      _elementInTemplateInit = false;
    }
  }

  @override
  void ngOnDestroy() {
    //this._application.selectedConnection = null;
    _lockSidebar.close();
  }

  void applySegmentOneColor(Event event){
    this._application.applySegmentsColor(this.selectedConnection, 1);
  }

  void applySegmentTwoColor(Event event){
    this._application.applySegmentsColor(this.selectedConnection, 2);
  }

  void setAllConnectionColor(Event event){
    PaperToggleButton enableSegmentRandomColor = event.target as PaperToggleButton;
    this._application.setAllConnectionsColor(enableSegmentRandomColor.checked);
  }

  void showDiagramTicks(Event event){
    PaperToggleButton showDiagramTicksButton = event.target as PaperToggleButton;
    this._application.showDiagramTicks(showDiagramTicksButton.checked);
  }


  void radioButtonChanged(Event event){
    PaperRadioButton radioGroup = event.target as PaperRadioButton;
    //print("${radioGroup.name}");
    if(radioGroup.name == "a"){
      this._application.changeWayToDrawDiagram(0);
    }else{
      this._application.changeWayToDrawDiagram(1);
    }
  }

  void connectionThicknessChanged(Event event){
    PaperToggleButton connectionThicknessButton = event.target as PaperToggleButton;
    if(!connectionThicknessButton.checked){
      this._application.changeWayToDrawDiagram(0);
    }else{
      this._application.changeWayToDrawDiagram(1);
    }
  }

  String get isSelectedVis => this.selectedConnection == null ? "fallBack" : "connSettings";

  VisConnection get selectedConnection{
    return this._selectedConnection;
  }

  set selectedConnection(VisConnection value) {
    this._selectedConnection = value;
  }

  void openSelectedConnectionSetting(VisConnection connection){
    this.selectedConnection = connection;
    groupOne = selectedConnection.segmentOne.parent.label.groupLabel;
    groupTwo = selectedConnection.segmentTwo.parent.label.groupLabel;
    segmentOne = selectedConnection.segmentOne.label;
    segmentTwo = selectedConnection.segmentTwo.label;
    segmentOneParent = selectedConnection.segmentOne.parent.label;
    segmentTwoParent = selectedConnection.segmentTwo.parent.label;

    var groupMax = selectedConnection.segmentOne.parent.parent.parent.numberOfChildren;
    var segmentOneMax = selectedConnection.segmentOne.parent.parent.numberOfChildren;
    var segmentTwoMax = selectedConnection.segmentTwo.parent.parent.numberOfChildren;
    var segmentOneBarMax = selectedConnection.segmentOne.parent.numberOfChildren;
    var segmentTwoBarMax = selectedConnection.segmentTwo.parent.numberOfChildren;

    this.segmentOneSlider.value = segmentOneParent.index;
    this.barInSegmentOneSlider.value = segmentOne.index;
    this.groupOneSlider.value = groupOne.index;

    this.segmentTwoSlider.value = segmentTwoParent.index;
    this.barInSegmentTwoSlider.value = segmentTwo.index;
    this.groupTwoSlider.value = groupTwo.index;

    if(segmentOneMax < 2){
      //this.segmentOneSlider.disabled(true);
      this.segmentOneSlider.maxValue = 1;
    }else{
      //this.segmentOneSlider.disabled(false);
      this.segmentOneSlider.maxValue = segmentOneMax;
    }

    this.barInSegmentOneSlider.maxValue = segmentOneBarMax;
    this.groupOneSlider.maxValue = groupMax;

    if(segmentTwoMax < 2){
      //this.segmentTwoSlider.disabled(true);
      this.segmentTwoSlider.maxValue = 1;
    }else{
      //this.segmentTwoSlider.disabled(false);
      this.segmentTwoSlider.maxValue = segmentOneMax;
    }

    this.barInSegmentTwoSlider.maxValue = segmentTwoBarMax;
    this.groupTwoSlider.maxValue = groupMax;

    //this._application.addNotification(NotificationType.info, "The connection between ${segmentOneParent.name} and ${segmentTwoParent.name} succesfully selected");
  }

  void changeSegmentColorPool(Event event){
    if(!this._elementInitialized) return;
    PaperToggleButton enableSegmentRandomColor = event.target as PaperToggleButton;
    this._application.enableSegmentRandomColor(enableSegmentRandomColor.checked);
  }

  void changeSortAlgorithm(Event event){
    if(!this._elementInitialized) return;
    PaperRadioButton radioGroup = event.target as PaperRadioButton;
    this._application.modifySortingSettings(true, int.parse(radioGroup.name));
    this._application.sortSettingsChanged = true;
    this._application.redrawLatestDiagram();
  }

  void enableValueColorRepresentation(Event event){
    if(!this._elementInitialized) return;
    PaperToggleButton enableValueColorRepresentation = event.target as PaperToggleButton;
    this._application.modifyValueRepresentation(enableValueColorRepresentation.checked);
  }

  void enableSortConnection(Event event){
    if(!this._elementInitialized) return;
    PaperToggleButton enableSort = event.target as PaperToggleButton;
    isSortEnabled = enableSort.checked;
    this._application.modifySortingSettings(isSortEnabled);
  }

  void changeElementIndex(int elementIndex, num newIndex){
    if(!this._elementInitialized) return;
    switch(elementIndex){
      case 1:
          String otherElementWithThisIndex = this.selectedConnection.segmentOne.parent.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentOne.parent.parent.getChildByID(otherElementWithThisIndex).label.index = segmentOneParent.index;
          segmentOneParent.index = newIndex.toInt();
        break;
      case 2:
          String otherElementWithThisIndex = this.selectedConnection.segmentTwo.parent.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentTwo.parent.parent.getChildByID(otherElementWithThisIndex).label.index = segmentTwoParent.index;
          segmentTwoParent.index = newIndex.toInt();
        break;
      case 3:
          String otherElementWithThisIndex = this.selectedConnection.segmentOne.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentOne.parent.getChildByID(otherElementWithThisIndex).label.index = segmentOne.index;
          segmentOne.index = newIndex.toInt();
        break;
      case 4:
          String otherElementWithThisIndex = this.selectedConnection.segmentTwo.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentTwo.parent.getChildByID(otherElementWithThisIndex).label.index = segmentTwo.index;
          segmentTwo.index = newIndex.toInt();
        break;
      case 5:
          String otherElementWithThisIndex = this.selectedConnection.segmentOne.parent.parent.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentOne.parent.parent.parent.getChildByID(otherElementWithThisIndex).label.index = groupOne.index;
          groupOne.index = newIndex.toInt();
        break;
      case 6:
          String otherElementWithThisIndex = this.selectedConnection.segmentTwo.parent.parent.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentTwo.parent.parent.parent.getChildByID(otherElementWithThisIndex).label.index = groupTwo.index;
          groupTwo.index = newIndex.toInt();
        break;
      default:
        break;
    }
    //this._application.changeShapePosition(1, newIndex);
    this._application.redrawLatestDiagram();
  }

  void enableConnectionsDirections(Event event){
    PaperToggleButton enableDirection = event.target as PaperToggleButton;
    if(enableDirection.checked){
      if(this.connectionsDirection == "row"){
        this._application.connectionsDirectionChange(1);
      }else{
        this._application.connectionsDirectionChange(2);
      }
    }else{
      this._application.connectionsDirectionChange(0);
    }
    this._isConnectionDirectionEnabled = enableDirection.checked;
  }

  void connectionsDirectionChange(Event event){
    PaperRadioButton radioGroup = event.target as PaperRadioButton;
    if(radioGroup.name == "row"){
      this._application.connectionsDirectionChange(1);
    }else if(radioGroup.name == "col"){
      this._application.connectionsDirectionChange(2);
    }else{
      this._application.connectionsDirectionChange(0);
    }
  }


  bool _isConnectionDirectionEnabled = false;
  bool get isConnectionDirectionEnabled{
    return _isConnectionDirectionEnabled;
    /*if(this.enableConnectionsDirection != null){
      return this.enableConnectionsDirection.checked;
    }else{
      return false;
    }*/
  }

  void showSettingsPage(int i) {
    this.selectedSettingPage = i;
  }
}