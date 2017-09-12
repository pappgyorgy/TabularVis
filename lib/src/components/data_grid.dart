import 'dart:html';
import 'dart:js';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:angular2/core.dart';
import 'package:angular_components/angular_components.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import 'package:polymer_elements/iron_icons.dart';
import 'package:polymer_elements/editor_icons.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_item_body.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/iron_flex_layout.dart';
import 'package:polymer_elements/paper_fab.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/iron_pages.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_toggle_button.dart';

import 'package:bezier_simple_connect_viewer/tabular_vis.dart';
import 'interaction_button.dart';
import 'handsontable_wrapper.dart';
import 'app_component.dart';
import '../data/data_processing.dart';
import 'paper_input_value_changed_directive.dart';

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
    directives: const <dynamic>[InteractionButton, materialDirectives, PaperInputValueChangedDirective],
    providers: const <dynamic>[InteractionHandler, DataTable, materialDirectives]
)
class DataGrid implements AfterViewInit, OnDestroy{
  final Application _application;
  final DataTable _dataTable;

  StreamController<int> _requestToChangeContent = new StreamController<int>();

  @Output()
  Stream<int> get requestToChangeDiagram => _requestToChangeContent.stream;


  static List<String> listOfTablesID = <String>[];

  PaperDialog handleTable;

  Element tableEditor;
  AppComponent _appComponent;
  List<List> _defaultMatrix;
  DataMatrix matrixData;
  String actualMatrixID;
  Selection selection;
  String controlsType = "edit-table";
  PaperInput groupNumberSetter;
  InputElement uploadFile;
  int groupNumber = 0;

  String tableRow = "2";
  String tableCol = "2";
  String minRandomValue = "100";
  String maxRandomValue = "1000";
  bool randomValuesEnabled = false;
  bool useRandomZeroesValue = true;

  PaperInput minValue, maxValue;
  PaperToggleButton randomZeroesToggleButton;
  DivElement dropZone;

  bool showBlockSettings = false;

  bool setShowBlockSettings(){
    if((selection.rowMin == 0 && selection.rowMax == 0) || (selection.colMin == 0 && selection.colMax == 0)){
      var isRow = (selection.colMin == 0 && selection.colMax == 0);
      int tablePos = isRow ? selection.rowMin : selection.colMin;
      var prevSetGroupNumber = this.matrixData.getLabelGroupNumber(isRow, tablePos);
      groupNumber = prevSetGroupNumber;
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
    Function valueChanged = allowInterop((dynamic changes, dynamic source) {
      //print("$changes ----  $source");
    });
    _dataTable.createTable("#table_container", allowInterop(tableValueChanged), allowInterop(tableSelectionChanged));
    //this._dataTable.changeMatrixData(this._defaultMatrix, this._defaultMatrix.length, this._defaultMatrix[0].length);
    //_dataTable.refreshTable();

    tableEditor = querySelector("#table-editor-placeholder");
    groupNumberSetter = querySelector("#group_number_setter") as PaperInput;
    handleTable = querySelector("#handle_table") as PaperDialog;
    uploadFile = querySelector("#file") as InputElement;
    uploadFile.onChange.listen((e) => _onFileInputChange());
    minValue = querySelector("#min_value_input").querySelector("paper-input") as PaperInput;
    maxValue = querySelector("#max_value_input").querySelector("paper-input") as PaperInput;
    dropZone = querySelector("#drop_zone") as DivElement;
    dropZone.onDrop.listen(readFile);
    dropZone.onDragOver.listen(allowDrop);
    randomZeroesToggleButton = querySelector("#random_zeroes") as PaperToggleButton;
    //tableEditor.style.display = "none";

    ////print(_dataTable.matrixData);
  }

  void handleTables(){
    handleTable.open();
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

  void tableSelectionChanged(List<int> tableSelection, String source){
    selection.changeFromArray(tableSelection);
    showBlockSettings = setShowBlockSettings();
  }

  void changeLabelGroup(Event event){
    var isRow = (selection.colMin == 0 && selection.colMax == 0);
    int tablePos = isRow ? selection.rowMin : selection.colMin;
    this.groupNumberSetter = event.target as PaperInput;
    this.matrixData.updateLabelInformation(isRow, tablePos, int.parse(this.groupNumberSetter.value as String));
    this._application.tableChanged = true;
    //print(this.matrixData.getLabels());
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

  String _crateCircosFileFormat() {

    if(this.matrixData.allLabel.length != Label.groupLabels[this.matrixData.diagramDataID].length){
      return "#Using group and download matrix is not supported at the same time";
      throw new StateError("Using group and download matrix is not supported at the same time");
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

    return sb.toString();
  }

  void downloadTable() {
    var fileToDownload = _crateCircosFileFormat();
    this._application.downloadFileToClient("table-${this.actualMatrixID}", fileToDownload);
  }

  void uploadJSONTable() {
    this.uploadFile.click();
    //throw new UnimplementedError("Implementation later");
  }

  void _onFileInputChange() {
    _onFilesSelected(uploadFile.files);
  }

  void _onFilesSelected(List<File> files) {
    handleTable.close();
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
    int alma = 0;

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
      file = file.replaceAll(new RegExp("[×]"), "%");

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

  void useRandomNumbers(Event event){
    PaperToggleButton randomToggleButton = event.target as PaperToggleButton;
    this.randomValuesEnabled = randomToggleButton.checked;
    if(randomToggleButton.checked){
      minValue.attributes.remove("disabled");
      maxValue.attributes.remove("disabled");
      randomZeroesToggleButton.attributes.remove("disabled");
    }else{
      minValue.setAttribute("disabled", "");
      maxValue.setAttribute("disabled", "");
      randomZeroesToggleButton.setAttribute("disabled", "");
    }
  }

  void useRandomZeroes(Event event){
    PaperToggleButton randomZeroesToggleButton = event.target as PaperToggleButton;
    this.useRandomZeroesValue = randomZeroesToggleButton.checked;
  }

  void allowDrop(Event event){
    event.preventDefault();
  }

  void readFile(MouseEvent event){
    event.preventDefault();
    this._onFilesSelected(event.dataTransfer.files);
  }

  void createNewTable(Event event){
    this.handleTable.close();
    Map<String, InputData> result;
    if(DataGrid.listOfTablesID.isEmpty){
      result = this._application.getInputData();
      DataGrid.listOfTablesID.add(result.keys.first);
    }else{
      result = this._application.getInputData(DataGrid.listOfTablesID.last,
          [int.parse(this.tableRow) + 1,1,int.parse(this.tableCol) + 1,1,1,
          this.useRandomZeroesValue ? 1 : 0, int.parse(this.minRandomValue), int.parse(this.maxRandomValue)], !this.randomValuesEnabled, true);
    }

    actualMatrixID = result.keys.first;
    this.matrixData = result[actualMatrixID] as DataMatrix;
    this._dataTable.matrixData = this.matrixData.getDataForUI();
    this._dataTable.refreshTable();
    selection = new Selection();
  }
}