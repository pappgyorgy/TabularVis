import 'dart:html';
import 'dart:js';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:angular/core.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import 'package:bezier_simple_connect_viewer/bezier_simple_connect_viewer.dart';
import 'interaction_button.dart';
import 'handsontable_wrapper.dart';
import 'app_component.dart';
import '../data/data_processing.dart';
import 'input_slider.dart';
import 'component_with_drawer_inside.dart';
import 'color-input.dart';

//Angular-components
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_dialog/material_dialog.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_number_accessor.dart';

import 'package:js/js.dart';

class Selection{
  int rowMin = 1;
  int rowMax = 1;
  int colMin = 1;
  int colMax = 1;

  Selection();

  Selection.fromValue(this.rowMin, this.rowMax, this.colMin, this.colMax);

  Selection.fromArray(List<int> array){
    this.changeFromArray(array);
  }

  void changeFromArray(List<int> array){
    this.rowMin = min(array[0], array[1]);
    this.rowMax = max(array[0], array[1]);
    this.colMin = min(array[2], array[3]);
    this.colMax = max(array[2], array[3]);
  }

}

@Component(
    selector: 'data-grid',
    templateUrl: 'template/data_grid.html',
    directives: const <dynamic>[InteractionButton, materialDirectives, coreDirectives, InputSlider, materialNumberInputDirectives, ColorInput],
    providers: const <dynamic>[InteractionHandler, DataTable, materialProviders],
    styleUrls: const ['template/scss/common.css', 'template/scss/data_grid.css', 'package:angular_components/app_layout/layout.scss.css',],
)
class DataGrid extends ComponentWithDrawerInside implements AfterViewInit, OnDestroy{
  final Application _application;
  final DataTable _dataTable;

  StreamController<int> _requestToChangeContent = new StreamController<int>();

  @Output()
  Stream<int> get requestToChangeDiagram => _requestToChangeContent.stream;

  @ViewChild('tableMainDrawer') MaterialPersistentDrawerDirective tableMainDrawer;
  @ViewChild('dropZoneDiv') HtmlElement dropZoneDiv;

  static List<String> listOfTablesID = <String>[];

  bool showHandleTableDialog = false;

  Element tableEditor;
  AppComponent _appComponent;
  List<List> _defaultMatrix;
  DataMatrix matrixData;
  String actualMatrixID;
  Selection selection;
  String controlsType = "edit-table";
  InputElement uploadFile;

  int tableRow = 2;
  int tableCol = 2;
  String minRandomValue = "100";
  String maxRandomValue = "1000";
  bool randomValuesEnabled = false;
  bool useRandomZeroesValue = true;

  num minValue = 100.0;
  num maxValue = 1000.0;
  bool randomZeroesEnabled = false;
  int selectedGroupNumber = 0;
  String selectedGroupName = "";
  bool uniqueScale = false;
  bool mergeBlockInGroup = false;

  DivElement dropZone;

  bool showBlockSettings = false;

  bool setShowBlockSettings(){
    if(((selection.rowMin == 0 && selection.rowMax == 0) || (selection.colMin == 0 && selection.colMax == 0))
        && (!(selection.rowMin == 0 && selection.rowMax == 0 && selection.colMin == 0 && selection.colMax == 0))){
      var isRow = (selection.colMin == 0 && selection.colMax == 0);
      int tablePos = isRow ? selection.rowMin : selection.colMin;
      var prevSetGroupNumber = this.matrixData.getLabelGroupNumber(isRow, tablePos);
      selectedGroupNumber = prevSetGroupNumber;
      this.selectedGroupName = this.matrixData.getLabelGroupName(isRow, tablePos);
      this.uniqueScale = this.matrixData.getLabelUniqueScale(isRow, tablePos);
      return true;
    }else{
      return false;
    }
  }

  DataGrid(this._application, this._dataTable){
    Map<String, InputData> result;
    if(DataGrid.listOfTablesID.isEmpty){
      result = this._application.getInputData();
      DataGrid.listOfTablesID.add(result.keys.first);
    }else{
      result = this._application.getInputData(DataGrid.listOfTablesID.last);
    }

    actualMatrixID = result.keys.first;
    this.matrixData = result[actualMatrixID] as DataMatrix;
    this._dataTable.matrixData = this.matrixData.getDataForUI();
    ////print(this.matrixData.getLabels());
    selection = new Selection();

    this.drawerVisibility = true;
  }

  void toggleTableEditorVisibility(){
    if(this.tableEditor.style.top.compareTo("0px") == 0){
      this.tableEditor.style.top = "-64px";
    }else{
      this.tableEditor.style.top = "0px";
    }
  }

  @override
  void ngOnDestroy() {
    _requestToChangeContent.close();
  }

  @override
  void ngAfterViewInit() {
    _dataTable.createTable("#table_container", allowInterop(tableValueChanged), allowInterop(tableSelectionChanged));

    dropZone = (dropZoneDiv as DivElement);
    dropZone.onDrop.listen(readFile);
    dropZone.onDragOver.listen(allowDrop);
  }

  /*void handleTables(){
    handleTable.open();
  }*/

  void toggleSidebar(){
    this.tableMainDrawer.toggle();
  }

  void tableValueChanged(List<List<num>> changes, String source){
    if(source != null && source.compareTo("edit") != 0){
      return;
    }

    changes.forEach((List<num> change){
      dynamic changeValue = 0.0;
      try{
        if(change[0] != 0 && change[1] != 0){
          changeValue = num.parse(change[3] as String);
        }else{
          changeValue = change[3];
        }
      }catch(error){
        changeValue = 0.0;
      }
      this.matrixData.setTableValue(change[0] as int, change[1] as int, changeValue);
    });

    ////print(this.matrixData.matrixData);
    this._application.tableChanged = true;
    //print(this.matrixData.getLabels());
  }

  void tableRowChange(num value) => this.tableRow = value.toInt();

  void tableColChange(num value) => this.tableCol = value.toInt();

  void minValueChange(num value) => this.minValue = value.toInt();

  void maxValueChange(num value) => this.maxValue = value.toInt();

  void changeBlockColours(Color color){

  }

  void tableSelectionChanged(List<int> tableSelection, String source){
    selection.changeFromArray(tableSelection);
    showBlockSettings = setShowBlockSettings();
  }

  void selectedGroupNumberChange(num newValue){
    var isRow = (selection.colMin == 0 && selection.colMax == 0);
    int tablePos = isRow ? selection.rowMin : selection.colMin;
    //this.groupNumberSetter = event.target as PaperInput;
    //this.matrixData.updateLabelInformation(isRow, tablePos, int.parse(this.groupNumberSetter.value as String));
    this.matrixData.updateLabelInformation(isRow, tablePos, newGroup: newValue.toInt());
    this._application.tableChanged = true;
    //print(this.matrixData.getLabels());
  }

  void selectedGroupNameChange(String newValue){
    var isRow = (selection.colMin == 0 && selection.colMax == 0);
    int tablePos = isRow ? selection.rowMin : selection.colMin;

    this.matrixData.updateLabelInformation(isRow, tablePos, newName: newValue);
    this._application.tableChanged = true;

  }

  void selectedBlockUniqueScaleChange(MouseEvent newValue){
    var isRow = (selection.colMin == 0 && selection.colMax == 0);
    int tablePos = isRow ? selection.rowMin : selection.colMin;

    this.matrixData.updateLabelInformation(isRow, tablePos, uniqueScale: this.uniqueScale);
    this._application.tableChanged = true;
  }

  void mergeBlocksInGroupSelectedChange(MouseEvent newValue){
    Label.mergeByGroup = this.mergeBlockInGroup;
    this._application.tableChanged = true;
  }

  Future visualizeTable() async{
    //this._application.urlNavigation("/visualization");
    this._application.createDiagram(actualMatrixID);
    this._requestToChangeContent.add(1);
  }

  void setRandomValues() {
    this.matrixData.fillWithRandomData(this.useRandomZeroesValue, int.parse(this.maxRandomValue), int.parse(this.minRandomValue));
    this._dataTable.matrixData = this.matrixData.getDataForUI();
    this._dataTable.refreshTable();
    this._application.tableChanged = true;
    //print(this.matrixData.getLabels());
  }

  void clearTableValues() {
    this.matrixData.clearData();
    this._dataTable.matrixData = this.matrixData.getDataForUI();
    this._dataTable.refreshTable();
    this._application.tableChanged = true;
  }

  Future<String> _crateCircosFileFormat() async{
    Completer<String> completer = new Completer<String>();

    if(this.matrixData.allLabel.length != Label.groupLabels[this.matrixData.diagramDataID].length){
      completer.completeError("#Using group and download matrix is not supported at the same time");
      //return "#Using group and download matrix is not supported at the same time";
      //throw new StateError("Using group and download matrix is not supported at the same time");
    }

    StringBuffer sb = new StringBuffer();
    for(var i = 0; i <= this.matrixData.row_num; i++){
      for(var j = 0; j <= this.matrixData.col_num; j++){
        if(i == 0){
          if(j < 2){
            if(j == 0){
              sb.write("data");
            }else{
              sb.write("\tdata");
            }
            continue;
          }else{
            sb.write("\t${this.matrixData.getColLabel(j-1).groupLabel.index}");
          }
        }else if(i == 1){
          if(j < 2){
            if(j == 0){
              sb.write("data");
            }else{
              sb.write("\tdata");
            }
            continue;
          }else{
            sb.write("\t${this.matrixData.getTableVale(i-1, j-1)[0]}");
          }
        }else{
          if(j == 0){
            sb.write("${this.matrixData.getRowLabel(i-1).groupLabel.index}");
          }else{
            sb.write("\t${this.matrixData.getTableVale(i-1, j-1)[0]}");
          }
        }
      }
      sb.write("\n");
    }

    completer.complete(sb.toString());

    return completer.future;
  }

  void downloadTable() {
    _crateCircosFileFormat().then((String fileToDownload){
      this._application.downloadFileToClient("table-${this.actualMatrixID}", fileToDownload);
    });
  }

  void uploadJSONTable() {
    this.uploadFile.click();
    //throw new UnimplementedError("Implementation later");
  }

  void onFileInputChange(Event event) {
    _onFilesSelected((event.target as InputElement).files);
  }

  void _onFilesSelected(List<File> files) {
    //handleTable.close();
    showHandleTableDialog = false;
    for (var file in files) {
      FileReader fr = new FileReader();
      if(file.type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"){
        fr.readAsText(file);
        fr.onLoadEnd.listen((e) => processTableString(fr.result as String));
      }else{
        fr.readAsArrayBuffer(file);
        fr.onLoadEnd.listen((e) => processExcel(fr.result));
      }


    }
  }

  void processExcel(dynamic result){
    var decoder = new SpreadsheetDecoder.decodeBytes(result as List<int>);
    var table = decoder.tables['Munka1'];
    var maxCol = table.rows[0].length;
    var maxRow = table.rows.length;

    List columnOrder, rowOrder;
    if(table.rows.length > 2 && (table.rows[0][0] == "data" || table.rows[0][0] == null) && (table.rows[1][0] == "data" || table.rows[1][0] == null)){
      columnOrder = table.rows[0].sublist(2);
      rowOrder = <String>[];
      for(var i = 2; i < table.rows.length; i++){
        rowOrder.add(table.rows[i][0]);
      }
    }

    List rowLabels = <String>[];
    var rowLabelIndex = columnOrder == null ? 1 : 2;
    for(var i = rowLabelIndex; i < table.rows.length; i++){
      if(rowOrder == null) {
        rowLabels.add(table.rows[i][0]);
      }else{
        rowLabels.add(table.rows[i][1]);
      }
    }

    List columnLabels;
    int columnLabelIndex = rowOrder == null ? 1 : 2;
    if(columnOrder == null) {
      columnLabels = table.rows[0].sublist(columnLabelIndex);
    }else{
      columnLabels = table.rows[1].sublist(columnLabelIndex);
    }

    List<List<List<dynamic>>> tableData;

    tableData = new List<List<List>>.generate(maxRow,
            (int index) => new List<List>.generate(maxCol,
                (int index) => new List<dynamic>.generate(1, (int index) => "", growable: true),
            growable: true),
        growable: true);

    int rowIndex = 0;
    int colIndex = 0;

    int tableRowStartIndex = columnOrder == null ? 0 : 1;
    int tableColStartIndex = rowOrder == null ? 0 : 1;
    int previousLineLength = table.rows[tableRowStartIndex].sublist(tableColStartIndex).length;
    for(var i = tableRowStartIndex; i < table.rows.length; i++){
      List<dynamic> line = table.rows[i].sublist(tableColStartIndex);
      if(previousLineLength != line.length)
        throw new StateError("The row in the table has different length");
      colIndex = 0;
      for(var j = 0; j < line.length; j++){
        if(i == tableRowStartIndex){
          tableData[rowIndex][colIndex][0] = line[j];
        }else if(j == 0){
          tableData[rowIndex][colIndex][0] = line[j];
        }else{
          tableData[rowIndex][colIndex][0] = (line[j] is String) ? num.parse(line[j] as String) : line[j];
        }


        colIndex++;
      }
      rowIndex++;
      previousLineLength = line.length;
    }

    tableData[0][0][0] = "";

    var newMatrixID = this._application.setInputData(tableData);
    var newMatrixData = this._application.getInputData(newMatrixID);

    DataGrid.listOfTablesID.add(newMatrixData.keys.first);

    actualMatrixID = newMatrixData.keys.first;
    this.matrixData = newMatrixData[actualMatrixID] as DataMatrix;
    //this.matrixData = new DataMatrix.fromMatrix(tableData);

    if(rowOrder != null) {
      for (var i = 1; i <= rowLabels.length; i++) {
        this.matrixData
            .getRowLabel(i)
            .groupLabel
            .index = int.parse(rowOrder[i - 1] as String);
      }
    }

    if(columnOrder != null) {
      for (var i = 1; i <= columnLabels.length; i++) {
        this.matrixData
            .getColLabel(i)
            .groupLabel
            .index = int.parse(columnOrder[i - 1] as String);
      }
    }


    this._dataTable.matrixData = this.matrixData.getDataForUI();
    this._dataTable.refreshTable();
    this._application.updateDataMatrixFromUploadedFile(DataGrid.listOfTablesID.first, this.matrixData);
  }

  void processTableString(String file){

    try {
      file = file.replaceAll(new RegExp("[\r]"), "");
      file = file.replaceAll(new RegExp("[\n]"), "~");
      file = file.replaceAll(new RegExp("[\t]"), "%");
      file = file.replaceAll(new RegExp("[ ]"), "×");
      do {
        file = file.replaceAllMapped(new RegExp("××"), (Match m) =>"×");
      }while(file.contains(new RegExp("××")));
      file = file.replaceAll(new RegExp("[×]"), " ");

      file = file.replaceAllMapped(new RegExp("~%*[A-Z|a-z]"), (Match m) {
        return "~${m[0].substring(m[0].indexOf('%')+1)}";
      });

      var lines = file.split("~");
      lines.removeWhere((item) => item.length < 1);
      List columnOrder, rowOrder;
      if(lines.length > 2 && lines[0].startsWith("data") && lines[1].startsWith("data")){
        columnOrder = lines[0].split("%").sublist(2);
        rowOrder = <String>[];
        for(var i = 2; i < lines.length; i++){
          rowOrder.add(lines[i].split("%")[0]);
        }
      }

      List rowLabels = <String>[];
      var rowLabelIndex = columnOrder == null ? 1 : 2;
      for(var i = rowLabelIndex; i < lines.length; i++){
        if(rowOrder == null) {
          rowLabels.add(lines[i].split("%")[0]);
        }else{
          rowLabels.add(lines[i].split("%")[1]);
        }
      }

      List columnLabels;
      int columnLabelIndex = rowOrder == null ? 1 : 2;
      if(columnOrder == null) {
        columnLabels = lines[0].split("%").sublist(columnLabelIndex);
      }else{
        columnLabels = lines[1].split("%").sublist(columnLabelIndex);
      }

      List<List<List<dynamic>>> tableData;

      tableData = new List<List<List>>.generate(rowLabels.length + 1,
        (int index) => new List<List>.generate(columnLabels.length + 1,
        (int index) => new List<dynamic>.generate(1, (int index) => "", growable: true),
        growable: true),
        growable: true);

      int rowIndex = 0;
      int colIndex = 0;

      int tableRowStartIndex = columnOrder == null ? 0 : 1;
      int tableColStartIndex = rowOrder == null ? 0 : 1;
      int previousLineLength = lines[tableRowStartIndex].split("%").sublist(tableColStartIndex).length;
      for(var i = tableRowStartIndex; i < lines.length; i++){
        var line = lines[i].split("%").sublist(tableColStartIndex);
        if(previousLineLength != line.length)
          throw new StateError("The row in the table has different length");
        colIndex = 0;
        for(var j = 0; j < line.length; j++){
          if(i == tableRowStartIndex){
            tableData[rowIndex][colIndex][0] = line[j];
          }else if(j == 0){
            tableData[rowIndex][colIndex][0] = line[j];
          }else{
            tableData[rowIndex][colIndex][0] = num.parse(line[j]);
          }


          colIndex++;
        }
        rowIndex++;
        previousLineLength = line.length;
      }

      tableData[0][0][0] = "";

      var newMatrixID = this._application.setInputData(tableData);
      var result = this._application.getInputData(newMatrixID);

      DataGrid.listOfTablesID.add(result.keys.first);

      actualMatrixID = result.keys.first;
      this.matrixData = result[actualMatrixID] as DataMatrix;
      //this.matrixData = new DataMatrix.fromMatrix(tableData);

      if(rowOrder != null) {
        for (var i = 1; i <= rowLabels.length; i++) {
          this.matrixData
              .getRowLabel(i)
              .groupLabel
              .index = int.parse(rowOrder[i - 1] as String);
        }
      }

      if(columnOrder != null) {
        for (var i = 1; i <= columnLabels.length; i++) {
          this.matrixData
              .getColLabel(i)
              .groupLabel
              .index = int.parse(columnOrder[i - 1] as String);
        }
      }


      this._dataTable.matrixData = this.matrixData.getDataForUI();
      this._dataTable.refreshTable();
      this._application.updateDataMatrixFromUploadedFile(DataGrid.listOfTablesID.first, this.matrixData);

    }catch(exception, stackTrace) {
      print(exception);
      print(stackTrace);
    }

  }

  void insertRow(){
    //print("insertRow");
    if(this.selection.rowMin < 1){
      //print("You could not add row before the first row");
      return;
    }
    this.matrixData.addRowToMatrix(this.selection.rowMin);
    ////print("rowNumber: ${this.matrixData.row_num}");
    this._dataTable.matrixData = matrixData.getDataForUI();
    this._dataTable.refreshTable();
    this._application.tableChanged = true;
    //print(this.matrixData.getLabels());
  }

  void insertCol(){
    //print("insertCol");
    if(this.selection.colMin < 1){
      //print("You could not add col before the first col");
      return;
    }
    this.matrixData.addColToMatrix(this.selection.colMin);
    ////print("colNumber: ${this.matrixData.col_num}");
    this._dataTable.matrixData = matrixData.getDataForUI();
    this._dataTable.refreshTable();
    this._application.tableChanged = true;
    //print(this.matrixData.getLabels());
  }

  void removeRow(){
    //print("removeRow");
    if(this.selection.rowMin < 1){
      //print("You could not delete the first row");
      return;
    }
    if(this.matrixData.matrixData.length < 3){
      //print("You could not delete the first two row");
      return;
    }
    if(this.matrixData.matrixData.length <= this.selection.rowMin){
      this.selection.rowMin = this.matrixData.matrixData.length-1;
    }
    this.matrixData.removeRowFromMatrix(this.selection.rowMin);
    ////print("rowNumber: ${this.matrixData.row_num}");
    this._dataTable.matrixData = matrixData.getDataForUI();
    this._dataTable.refreshTable();
    this._application.tableChanged = true;
    ////print(this.matrixData.getLabels());
  }

  void removeCol(){
    //print("removeCol");
    if(this.selection.colMin < 1){
      //print("You could not delete first col");
      return;
    }
    if(this.matrixData.matrixData[0].length < 3){
      //print("You could not delete the first two col");
      return;
    }
    if(this.matrixData.matrixData[0].length <= this.selection.colMin){
      this.selection.colMin = this.matrixData.matrixData[0].length-1;
    }
    this.matrixData.removeColFromMatrix(this.selection.colMin);
    ////print("colNumber: ${this.matrixData.col_num}");
    this._dataTable.matrixData = matrixData.getDataForUI();
    this._dataTable.refreshTable();
    this._application.tableChanged = true;
    ////print(this.matrixData.getLabels());
  }

  void allowDrop(Event event){
    event.preventDefault();
  }

  void readFile(MouseEvent event){
    event.preventDefault();
    this._onFilesSelected(event.dataTransfer.files);
  }

  void createNewTable(Event event){
    //this.handleTable.close();
    this.showHandleTableDialog = false;
    Map<String, InputData> result;
    if(DataGrid.listOfTablesID.isEmpty){
      result = this._application.getInputData();
      DataGrid.listOfTablesID.add(result.keys.first);
    }else{
      result = this._application.getInputData(DataGrid.listOfTablesID.last,
          <int>[this.tableRow + 1,1,this.tableCol + 1,1,1,
          this.useRandomZeroesValue ? 1 : 0, this.minValue, this.maxValue], !this.randomValuesEnabled, true);
    }

    actualMatrixID = result.keys.first;
    this.matrixData = result[actualMatrixID] as DataMatrix;
    this._dataTable.matrixData = this.matrixData.getDataForUI();
    this._dataTable.refreshTable();
    selection = new Selection();
  }
}