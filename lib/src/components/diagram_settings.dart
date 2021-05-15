import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:bezier_simple_connect_viewer/bezier_simple_connect_viewer.dart';

import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:color_picker/color_picker.dart';

import 'input_slider.dart';
import 'bezier_curve_settings.dart';
import 'color-input.dart';

class SortingAlgorithm{

  final String label;
  bool selected;
  int value;

  SortingAlgorithm(this.label, this.selected, this.value);
}

@Component(
  selector: "diagram-settings",
  templateUrl: "template/diagram_settings.html",
  directives: const <dynamic>[BezierCurveSettings, materialDirectives, InputSlider, ColorInput, coreDirectives,],
  providers: const <dynamic>[materialProviders],
  styleUrls: const ['template/scss/common.css', 'template/scss/diagram_settings.css'],
)
class DiagramSettings implements AfterViewInit, OnDestroy{
  final Application _application;
  dynamic selectedSettingPage = 0;
  dynamic selectedAlgorithm = "0";
  bool isSortEnabled = false;
  bool _elementInitialized = false;
  bool _elementInTemplateInit = false;
  bool avoidDefault = true;
  bool showDialog = false;
  bool enableScaling = false;
  bool enableHeatmap = false;
  bool enableGroupLabeling = false;
  bool enableEdgeBundling = false;

  StreamController<bool> _lockSidebar = new StreamController<bool>();

  bool lockSidebar = false;

  VisualObject groupsContainer;

  @Input()
  String selectedSettings = "diagram";

  @Output()
  Stream<bool> get lockSideBar => _lockSidebar.stream;

  @ViewChild("connectionDirRadioGroup") MaterialRadioGroupComponent connectionDirRadioGroup;

  double crest;
  double bezier_radius;
  double bezier_radius_purity;

  int segmentOneSlider = 0;
  void segmentOneSliderChange(num value){
    this.segmentOneSlider = value.toInt();
    //selectedConnection.segmentOne.parent.label.index = this.segmentOneSlider;
    this.changeElementIndex(1,value);
  }
  int barInSegmentOneSlider = 0;
  void barInSegmentOneSliderChange(num value){
    this.barInSegmentOneSlider = value.toInt();
    //selectedConnection.segmentOne.label.index = this.barInSegmentOneSlider;
    this.changeElementIndex(3,value);
  }
  int groupOneSlider = 0;
  void groupOneSliderChange(num value){
    this.groupOneSlider = value.toInt();
    //selectedConnection.segmentOne.parent.label.groupLabel.index = groupOneSlider;
    this.changeElementIndex(5,value);
  }

  int segmentTwoSlider = 0;
  void segmentTwoSliderChange(num value){
    this.segmentTwoSlider = value.toInt();
    //selectedConnection.segmentTwo.parent.label.index = this.segmentTwoSlider;
    this.changeElementIndex(2,value);
  }
  int barInSegmentTwoSlider = 0;
  void barInSegmentTwoSliderChange(num value){
    this.barInSegmentTwoSlider = value.toInt();
    //selectedConnection.segmentTwo.label.index = this.barInSegmentTwoSlider;
    this.changeElementIndex(4,value);
  }
  int groupTwoSlider = 0;
  void groupTwoSliderChange(num value){
    this.groupTwoSlider = value.toInt();
    //selectedConnection.segmentTwo.parent.label.groupLabel.index = groupTwoSlider;
    this.changeElementIndex(6,value);
  }

  double spaceConnAndBlocks = 0.0;
  void spaceConnAndBlocksChange(num value){
    this.spaceConnAndBlocks = value.toDouble();
    this._application.changeDiagramLooks(1,this.spaceConnAndBlocks);
  }
  double blockDistance = 2.0;
  void blockDistanceChange(num value){
    this.blockDistance = value.toDouble();
    this._application.changeDiagramLooks(2, this.blockDistance);
  }
  double lineWidth = 0.3;
  void lineWidthChange(num value){
    this.lineWidth = value.toDouble();
    this._application.changeDiagramLooks(3,this.lineWidth);
  }

  int segmentOneSliderMax = 1;
  int barInSegmentOneSliderMax = 1;
  int groupOneSliderMax = 1;

  int segmentTwoSliderMax = 1;
  int barInSegmentTwoSliderMax = 1;
  int groupTwoSliderMax = 1;

  double ticksMinValue = 0.0;
  double ticksMaxValue = 100.0;
  int ticksDivideNumberOfParts = 4;
  double ticksSteps = 25.0;
  List<double> listOfTicksValue = [];

  bool colorPickerContainerVisibility;
  ColorPicker largeColorPicker = new ColorPicker(256);

  HtmlElement colorPickerActualTarget;

  SelectionModel sortingAlgorithmSelectionModel = new SelectionModel.single();
  List<SortingAlgorithm> sortingAlgorithmsOptions = new List();

  Label segmentOne;
  Label segmentTwo;
  Label segmentOneParent;
  Label segmentTwoParent;
  Label groupOne;
  Label groupTwo;
  VisConnection _selectedConnection;

  int selectedSortingAlgorithm = 0;
  String connectionsDirection = "none";
  bool enableConnectionsDirection;
  bool sidebarLockStatus = false;
  bool enableSegmentRandomColor = false;
  bool showDiagramTicksToggleStatus = false;
  bool enableValueColorRepresentationToggleStatus = false;
  bool isConnectionDirectionEnabled = false;
  bool unifiedConnectionThickness = false;
  bool setUnifiedConnectionColorStatus = false;
  bool poincareDiskModel = false;
  String selectedDialogOption = "default";
  String information = "";
  String selectedTicksSettingsTab = "general";
  VisualObject listOfVisualObject;

  SelectionModel<dynamic> itemSelection =
    new SelectionModel.single();


  Color get minColor => ConnectionVis.minColor;
  Color get maxColor => ConnectionVis.maxColor;
  Color get unifiedColor => ConnectionVis.unifiedColor;

  void changeUnifiedColor(Color color){
    ConnectionVis.unifiedColor = color;
    setAllConnectionColor(true);
  }

  void minColorChange(Color color){
    ConnectionVis.minColor = color;
    enableValueColorRepresentation(true);
  }

  void maxColorChange(Color color){
    ConnectionVis.maxColor = color;
    enableValueColorRepresentation(true);
  }

  void segOneColChange(Color color){
    this.selectedConnection.config.segmentOneColor = color;
    this._application.redrawLatestDiagram();
  }

  void segTwoColChange(Color color){
    this.selectedConnection.config.segmentTwoColor = color;
    this._application.redrawLatestDiagram();
  }

  void connColChange(Color color){
    this.selectedConnection.config.connectionColor = color;
    this._application.redrawLatestDiagram();
  }

  DiagramSettings(this._application){
    /*this.crest = new SliderValue(0.5,0.5,0.0,2.0,
            (num value){this._application.changeBezierParam(1,value);});
    this.bezier_radius = new SliderValue(0.0,0.0,0.0,2.0,
            (num value){this._application.changeBezierParam(2,value);});
    this.bezier_radius_purity = new SliderValue(0.75,0.75,-2.0,2.0,
            (num value){this._application.changeBezierParam(3,value);});*/

    /*this.segmentOneSlider = new SliderValue(1,1,1,10,
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
            (num value){this._application.changeDiagramLooks(3,value);});*/

    if(!this._application.isListenConnectionStream){
      this._application.connectionData.listen(openSelectedConnectionSetting);
      this._application.isListenConnectionStream = true;
    }

    /*var conn = this._application.defaultConnection;
    openSelectedConnectionSetting(conn);
    this.groupsContainer = this._application.getActualDiagramVisualObject();*/

    this.listOfTicksValue.add(10.0);
    this.listOfTicksValue.add(12.5);
    this.listOfTicksValue.add(75.0);

    this.listOfVisualObject = this._application.getActualDiagramVisualObject();

    this.sortingAlgorithmSelectionModel.selectionChanges.listen(this.changeSortAlgorithm);

    this.sortingAlgorithmsOptions.add(new SortingAlgorithm("Hill climbing", false, 0));
    this.sortingAlgorithmsOptions.add(new SortingAlgorithm("Min Conflict", false, 1));
    this.sortingAlgorithmsOptions.add(new SortingAlgorithm("Cross entropy", false, 2));
    this.sortingAlgorithmsOptions.add(new SortingAlgorithm("Cross entropy min conflict", false, 3));
    this.sortingAlgorithmsOptions.add(new SortingAlgorithm("Cross entropy mod", false, 4));
    this.sortingAlgorithmsOptions.add(new SortingAlgorithm("Simulated annealing", false, 5));
    this.sortingAlgorithmsOptions.add(new SortingAlgorithm("Bees algorithm", false, 6));

  }

  void lockDiagramSettingsSidebar(bool status){
    sidebarLockStatus = status;
    this._lockSidebar.add(sidebarLockStatus);
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
    colorPickerContainerVisibility = false;
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
    colorPickerContainerVisibility = false;
    this._application.redrawLatestDiagram();
  }

  @override
  void ngAfterViewInit() {
    avoidDefault = true;
  }

  String getSegmentColor(String ID){
    var segmentColor = this.selectedConnection.getSegmentConfig(ID);
    var color = new Color.fromArray(segmentColor);
    return color.getContextStyle();
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

  void setAllConnectionColor(bool newStatus){
    this.setUnifiedConnectionColorStatus = newStatus;
    this._application.setAllConnectionsColor(this.setUnifiedConnectionColorStatus);
  }

  void showDiagramTicks(bool newStatus){
    this.showDiagramTicksToggleStatus = newStatus;
    this._application.showDiagramTicks(this.showDiagramTicksToggleStatus);
  }

  void showDiagramGroupLabel(bool newStatus){
    this.enableGroupLabeling = newStatus;
    this._application.showDiagramGroupLabel(newStatus);
  }

  void changeConnectionCurveType(bool newStatus){
    this.enableEdgeBundling = newStatus;
    DiagramManager.connectionType = this.enableEdgeBundling
        ? ShapeType.edgeBundle
        : ShapeType.bezier;
    this._application.changeDiagramsConnectionsCurveType();
  }

  void showHeatmap(bool newStatus){
    this.enableHeatmap = newStatus;
    //TODO add actual heatmap feature
  }

  void applyScaling(bool newStatus){
    this.enableScaling = newStatus;
    //TODO add actual scaling feature
  }

  void changeDiagramLineType(bool newStatus){
    //this.poincareDiskModel = newStatus;
    if(!newStatus){
      this._application.changeWayToDrawLinesInDiagram(0);
    }else{
      this._application.changeWayToDrawLinesInDiagram(1);
    }
  }

  void connectionThicknessChanged(bool newStatus){
    //this.unifiedConnectionThickness = newStatus;
    if(!newStatus){
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
    if(this.groupsContainer == null){
      this.groupsContainer = this._application.getActualDiagramVisualObject();
    }

    this.selectedConnection = connection;
    groupOne = this.groupsContainer.getChildByIDs(this.selectedConnection.segmentOneID.split('_').first).label;
    groupTwo = this.groupsContainer.getChildByIDs(this.selectedConnection.segmentTwoID.split('_').first).label;
    segmentOne = selectedConnection.segmentOne.label;
    segmentTwo = selectedConnection.segmentTwo.label;
    segmentOneParent = selectedConnection.segmentOne.parent.label;
    segmentTwoParent = selectedConnection.segmentTwo.parent.label;

    var groupMax = selectedConnection.segmentOne.parent.parent.parent.numberOfChildren;
    var segmentOneMax = selectedConnection.segmentOne.parent.parent.numberOfChildren;
    var segmentTwoMax = selectedConnection.segmentTwo.parent.parent.numberOfChildren;
    var segmentOneBarMax = selectedConnection.segmentOne.parent.numberOfChildren;
    var segmentTwoBarMax = selectedConnection.segmentTwo.parent.numberOfChildren;

    segmentOneSlider = segmentOneParent.index;
    barInSegmentOneSlider = segmentOne.index;
    groupOneSlider = groupOne.index;

    segmentTwoSlider = segmentTwoParent.index;
    barInSegmentTwoSlider = segmentTwo.index;
    groupTwoSlider = groupTwo.index;

    if(segmentOneMax < 2){
      //this.segmentOneSlider.disabled(true);
      segmentOneSliderMax = 1;
    }else{
      //this.segmentOneSlider.disabled(false);
      segmentOneSliderMax = segmentOneMax;
    }

    barInSegmentOneSliderMax = segmentOneBarMax;
    groupOneSliderMax = groupMax;

    if(segmentTwoMax < 2){
      //this.segmentTwoSlider.disabled(true);
      segmentTwoSliderMax = 1;
    }else{
      //this.segmentTwoSlider.disabled(false);
      segmentTwoSliderMax = segmentOneMax;
    }

    barInSegmentTwoSliderMax = segmentTwoBarMax;
    groupTwoSliderMax = groupMax;

    //this._application.addNotification(NotificationType.info, "The connection between ${segmentOneParent.name} and ${segmentTwoParent.name} succesfully selected");
  }

  void changeSegmentColorPool(bool newStatus){
    this.enableSegmentRandomColor = newStatus;
    this._application.enableSegmentRandomColor(this.enableSegmentRandomColor);
  }

  void changeSortAlgorithm(List<SelectionChangeRecord> items){
    try {
      int selected = items.first.added.first;
      selectedSortingAlgorithm = selected;

      if (!isSortEnabled) return;
      this._application.modifySortingSettings(true, selectedSortingAlgorithm);

    }catch(e){

    }

    this._application.redrawLatestDiagram();
  }

  void enableValueColorRepresentation(bool newValue){
    this.enableValueColorRepresentationToggleStatus = newValue;
    this._application.modifyValueRepresentation(this.enableValueColorRepresentationToggleStatus);
  }

  void enableSortConnection(bool newValue){
    this.isSortEnabled = newValue;
    if(!this.isSortEnabled){
      this.sortingAlgorithmSelectionModel.clear();
      this.sortingAlgorithmsOptions.forEach((SortingAlgorithm alg) => alg.selected = false);

      this._application.modifySortingSettings(this.isSortEnabled, selectedSortingAlgorithm);
      this._application.redrawLatestDiagram();
    }
  }

  void changeElementIndex(int elementIndex, num newIndex){
    switch(elementIndex){
      case 1:
          /*String otherElementWithThisIndex = this.selectedConnection.segmentOne.parent.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentOne.parent.parent.getChildByID(otherElementWithThisIndex).label.index = segmentOneParent.index;
          segmentOneParent.index = newIndex.toInt();*/
          this._application.changeElementsIndex(groupOne.id, "", newIndex.toInt(), segmentOneParent.index);
        break;
      case 2:
          /*String otherElementWithThisIndex = this.selectedConnection.segmentTwo.parent.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentTwo.parent.parent.getChildByID(otherElementWithThisIndex).label.index = segmentTwoParent.index;
          segmentTwoParent.index = newIndex.toInt();*/
          this._application.changeElementsIndex(groupTwo.id, "", newIndex.toInt(), segmentTwoParent.index);
        break;
      case 3:
          /*String otherElementWithThisIndex = this.selectedConnection.segmentOne.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentOne.parent.getChildByID(otherElementWithThisIndex).label.index = segmentOne.index;
          segmentOne.index = newIndex.toInt();*/
          this._application.changeElementsIndex(groupOne.id, segmentOneParent.id, newIndex.toInt(), segmentOne.index);
        break;
      case 4:
          /*String otherElementWithThisIndex = this.selectedConnection.segmentTwo.parent.getElementByIndex(newIndex.toInt());
          this.selectedConnection.segmentTwo.parent.getChildByID(otherElementWithThisIndex).label.index = segmentTwo.index;
          segmentTwo.index = newIndex.toInt();*/
          this._application.changeElementsIndex(groupTwo.id, segmentTwoParent.id, newIndex.toInt(), segmentTwo.index);
        break;
      case 5:
          this._application.changeElementsIndex("", "", newIndex.toInt(), groupOne.index);
        break;
      case 6:
        this._application.changeElementsIndex("", "", newIndex.toInt(), groupTwo.index);
        break;
      default:
        break;
    }
    this._application.redrawLatestDiagram();
  }

  @Deprecated("")
  void enableConnectionsDirections(Event event){
    if(this.isConnectionDirectionEnabled){
      if(this.connectionsDirection == "row"){
        this._application.connectionsDirectionChange(1);
      }else{
        this._application.connectionsDirectionChange(2);
      }
    }else{
      this._application.connectionsDirectionChange(0);
    }
  }

  void connectionsDirectionChange(String newValue){
    if(!avoidDefault && newValue != connectionsDirection) {
      connectionsDirection = newValue;
      if (connectionsDirection == "row") {
        this._application.connectionsDirectionChange(1);
      } else if (connectionsDirection == "col") {
        this._application.connectionsDirectionChange(2);
      } else {
        this._application.connectionsDirectionChange(0);
      }
    }else{
      avoidDefault = false;
    }
  }

  void showSettingsPage(int i) {
    this.selectedSettingPage = i;
  }

  //Dialog methods

  void changeDialogType(String newDialogOption){
    this.selectedDialogOption = newDialogOption;
  }

  void onTicksSettingsTabChange(TabChangeEvent event){
    this.selectedTicksSettingsTab = event.newIndex == 0 ? "general" : "specific";
  }

  void applyTickSettings(MouseEvent event){
    //TODO finish method
  }

  String get dialogHeader{
    return this.selectedDialogOption == "ticks" ? "Ticks settings" : this.selectedDialogOption == "scaling" ? "Scaling settings" : this.selectedDialogOption == "heatmap" ? "Heatmap settings" : "Information";
  }

  void toggleItem(key) {
    if (itemSelection.isSelected(key)) {
      itemSelection.deselect(key);
    } else {
      itemSelection.select(key);
    }
  }

  void changeScalingValue(String id, double newValue, bool group){
    this.listOfVisualObject.getChildByID(id, group).scaling = newValue/100.0;
  }

  void changeTickValue(String id, double newValue, bool group){
    this.listOfVisualObject.getChildByID(id, group).tickIncValue = newValue;
    this.listOfVisualObject.getChildByID(id, group).tickValueWasModified = true;
  }

  void requestRedraw(MouseEvent event){
    print("redraw");
    this._application.redrawLatestDiagram();
  }

  //-------------------------------------------------

  final maxHeightDialogLines = <String>[];

  void addMaxHeightDialogLine() {
    maxHeightDialogLines.add('This is some text!');
  }

  void removeMaxHeightDialogLine() {
    maxHeightDialogLines.removeLast();
  }
}