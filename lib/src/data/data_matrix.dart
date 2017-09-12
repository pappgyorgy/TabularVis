part of dataProcessing;

enum LabelModType{
  change,
  add,
  remove
}

enum MatrixParts{
  row,
  col,
  cell
}

/// This class implements input data
///
/// Process the tabular data and provides visual object logical hierarchy to
/// create the diagram. Also this class provide raw data to the UI and handle
/// the changes in the raw data
class DataMatrix implements InputData{

  /// Logs messages
  final Logger log = new Logger('DataMatrix');

  /// The list of the generated row and column IDs
  static List<String> listOfGeneratedRowColID = new List<String>();

  @Deprecated("This will be always true in the future")
  bool isSiblingRowColsEnabled = true;

  /// Did we changed the structure of the matrix
  bool _structureChangeHappened = true;

  /// The raw data of the matrix
  ///
  /// In case of 2D matrix the first value values is in the third list first value
  List<List<List<dynamic>>> _matrixData;


  /// The labels of the table's row
  List<Label> rowLabel = new List<Label>();

  /// The labels of the table's column
  List<Label> colLabel = new List<Label>();

  /// Get the row and the col labels
  List<Label> get allLabel{
    var retVal = this.rowLabel.toList();
    retVal.addAll(this.colLabel);
    return retVal;
  }

  /// The percentage of what is the possibility to generate 0 as a table value
  double percentOfRandomZeroes = 0.3;

  /// The logical visual object structure to create diagrams
  VisualObject objectHierarchy;

  /// The number of the table's column
  int col_num = 0;

  /// The number of the table's row
  int row_num = 0;

  /// The number of the table's depth
  int depth_num = 0;

  // The diagrams ID of the diagram which this matrix belongs
  String diagramDataID = "defaultID";

  // The number of how many time this matrix id copied
  int numberOfCopy = 0;

  /// Simple constructor
  ///
  /// Optional basic information about the matrix [col_num], [row_num],
  /// [depth_num] and [initialValue]
  /// Default values are: 10, 10, 1 and 0.0
  DataMatrix(this.diagramDataID, [this.col_num = 10, this.row_num = 10, this.depth_num = 1, double initialValue = 0.0]){
    Label.groupLabels[this.diagramDataID] = new Map<int, Label>();
    this._matrixData = new List<List<List>>.generate(this.row_num,
            (int index) => new List<List>.generate(this.col_num,
                (int index) => new List<dynamic>.generate(this.depth_num, (int index) => "", growable: true),
            growable: true),
        growable: true);
    this._fillMatrixWithValue(initialValue, false);
    this._createRowAndColLabel();
  }

  /// Create DataMatrix from row data
  ///
  /// You have to provide [matrixData] as a raw data
  DataMatrix.fromMatrix(this.diagramDataID, List<List<List<dynamic>>> matrixData){
    Label.groupLabels[this.diagramDataID] = new Map<int, Label>();
    this.row_num = matrixData.length;
    this.col_num = matrixData[0].length;
    this.depth_num = matrixData[0][0].length;

    this._matrixData = new List<List<List>>.generate(this.row_num,
            (int index) => new List<List>.generate(this.col_num,
                (int index) => new List<dynamic>.generate(this.depth_num, (int index) => "", growable: true),
            growable: true),
        growable: true);

    for(var row = 0; row < row_num; row++){
      for(var col = 0; col < col_num; col++){
        for(var depth = 0; depth < depth_num; depth++){
          this._matrixData[row][col][depth] = matrixData[row][col][depth];
        }
      }
    }

    this._createRowAndColLabel();
  }

  /// Create DataMatrix from randomly generated data
  ///
  /// Optional arguments: [col_num], [col_max], [row_num], [row_max]
  /// [depth_num], [randomZeroes], [max_value] and [min_value]
  DataMatrix.randomGenerated(this.diagramDataID, [int col_num = 0, int col_max = 7,
    int row_num = 0, int row_max = 7,
    this.depth_num = 1, bool randomZeroes = false,
    int min_value = 1, int max_value  = 99]){
    Label.groupLabels[this.diagramDataID] = new Map<int, Label>();
    this.col_num = col_num > 0 ? col_num : new Random(new DateTime.now().millisecondsSinceEpoch).nextInt(col_max) + 3;
    this.row_num = row_num > 0 ? row_num : new Random(new DateTime.now().millisecondsSinceEpoch + 100).nextInt(row_max) + 3;
    this._matrixData = new List<List<List>>.generate(this.row_num,
            (int index) => new List<List>.generate(this.col_num,
                (int index) => new List<dynamic>.generate(this.depth_num, (int index) => "", growable: true),
            growable: true),
        growable: true);
    this._fillMatrixWithRandomValue(randomZeroes, max_value, min_value, false);
    this._createRowAndColLabel();

  }

  /// Get the value of the given cell: [row], [col] and optionally [depth]
  dynamic getTableVale(int row, int col, [int depth = 0]){
    try{
      return this._matrixData[row][col];
    }catch(exception, stackTrace){
      print(exception);
      print(stackTrace);
      throw new StateError("Error while trying to get the matrix value");
    }
  }

  /// Set the value of the given cell: [row], [col], [value] and optionally [depth]
  void setTableValue(int row, int col, dynamic value, [int depth = 0]){
    try{
      this._matrixData[row][col][depth] = value;
      if(row == 0) { //In this case wee need to update the row col labels
        updateLabel(col, false, LabelModType.change, true);
      }
      if(col == 0){
        updateLabel(row, true, LabelModType.change, true);
      }
      if(objectHierarchyGenerated){
        var rowLabel = this._getLabelByTablePos(true, row);
        var colLabel = this._getLabelByTablePos(false, col);

        var rowElement = this.objectHierarchy.getChildByID(rowLabel.id, true);
        var colElement = this.objectHierarchy.getChildByID(colLabel.id, true);

        var rowConnElement = rowElement.getChildByID(
            rowElement.getElementByTablePos(row));
        var colConnElement = colElement.getChildByID(
            colElement.getElementByTablePos(col));

        rowConnElement.updateValue(value);
        colConnElement.updateValue(value);
      }
    }catch(exception, stackTrace){
      print(exception);
      print(stackTrace);
    }
  }

  /// Get the label of the given row
  Label getRowLabel(int numberOfLabel){
    return this._getLabelByTablePos(true, numberOfLabel);
  }

  /// Get the label of the given column
  Label getColLabel(int numberOfLabel){
    return this._getLabelByTablePos(false, numberOfLabel);
  }

  /// Did we generate the object hierarchy of the matrix
  bool get objectHierarchyGenerated{
    return this.objectHierarchy != null;
  }

  /// Check for sibling labels. If two labels has the same name we create set them as sibling
  /// Use this to create only one segment for two label
  bool checkSiblings(){
    var retVal = false;

    var allLabels = this.allLabel;

    Map<int, List<Label>> labelsInGroups = new Map<int, List<Label>>();

    for(var i = 0; i < allLabels.length; i++){
      for(var j = (i + 1); j < allLabels.length; j++){
        if(Label.createLabelSibling(allLabels[i], allLabels[j])){
          retVal = true;
        }
      }
      if(!labelsInGroups.containsKey(allLabels[i].groupNumber)){
        labelsInGroups[allLabels[i].groupNumber] = new List<Label>();
      }
      labelsInGroups[allLabels[i].groupNumber].add(allLabels[i]);
    }

    // We have to correct the indices because of the possibility to siblings
    // Label with lower index is the main Label for vis object

    labelsInGroups.forEach((int key, List<Label> labelOfGroup){
      int index = 1;
      labelOfGroup.forEach((Label label) {
        if (label.isPartialLabel) {
          label.index = -1;
        } else if (!label.isPartialLabel) {
          label.index = index++;
        }
      });
    });

    // Old version before groups
    /*int index = 1;
    allLabels.forEach((Label label) {
      if (label.isPartialLabel) {
        label.index = -1;
      } else if (!label.isPartialLabel) {
        label.index = index++;
      }
    });*/

    /*this.rowLabel.forEach((Label l){
      this.colLabel.forEach((Label l2){
        if(Label.createLabelSibling(l, l2)){
          retVal = true;
        }
      });
    });*/
    return retVal;
  }

  void _createNewConnection(Label row, Label col, dynamic value) {
    var rowLabelGroup = row.groupLabel;
    var colLabelGroup = col.groupLabel;

    //First try to get the group for the two label
    //If there is no group for the label then create one
    var rowVisObjGroup = objectHierarchy.createChild(rowLabelGroup, 0.0, VisualObjectRole.GROUP);
    var colVisObjGroup = objectHierarchy.createChild(colLabelGroup, 0.0, VisualObjectRole.GROUP);

    objectHierarchy.getElementByIndex(rowLabelGroup.index);
    objectHierarchy.getElementByIndex(colLabelGroup.index);

    //First try to get the elements for the two label
    //If there is no element for the label then create one
    var rowVisObj = rowVisObjGroup.createChild(row, 0.0, VisualObjectRole.SEGMENT);
    var colVisObj = colVisObjGroup.createChild(col, 0.0, VisualObjectRole.SEGMENT);

    //create the sub elements for the connection
    var rowChild = rowVisObj.createChild(row.generateNewLabel, value, VisualObjectRole.SUB_SEGMENT);
    rowChild.label.index = rowVisObj.numberOfChildren;
    var colChild = colVisObj.createChild(col.generateNewLabel, value, VisualObjectRole.SUB_SEGMENT);
    colChild.label.index = colVisObj.numberOfChildren;

    // create the connection
    ConnectionManager.createNewConnection(rowChild, colChild, objectHierarchy.id);
  }

  /// Get all labels ID
  /// First rowLabel and then colLabel
  List<String> get allLabelsID{
    var retVal = new List<String>();
    this.allLabel.forEach((Label l){
      if(!l.isPartialLabel){
        retVal.add(l.id);
      }
    });
    return retVal;
  }

  void updateLabelInformation(bool isRow, int tablePos, int newGroup){
    this._getLabelByTablePos(isRow, tablePos).groupNumber = newGroup;
  }

  int getLabelGroupNumber(bool isRow, int tablePos){
    return this._getLabelByTablePos(isRow, tablePos).groupNumber;
  }

  /// Get a hierarchy data structure from the input data
  ///
  /// The given [ID] will be the unique identification of the diagram
  @override
  VisualObject getVisualizationObjectHierarchy([bool newlyGenerated = false]) {

    //ConnectionVis.updateMainSegmentsColors(this.allLabelsID);

    this.checkSiblings();

    // If we did not generate the object hierarchy then we do it
    // otherwise we will return with it
    if(newlyGenerated || (!this.objectHierarchyGenerated || this._structureChangeHappened)) {
      objectHierarchy = new ObjectVis(new LabelObj("root", 0, true, this.diagramDataID), 0.0, this.diagramDataID);

      ConnectionManager.listOfConnection[objectHierarchy.id] =
      new Map<String, ConnectionVis>();
    }else{
      return this.objectHierarchy;
    }

    ConnectionManager.removeDeletedConnections(
        this.objectHierarchy, this.rowLabel, this.colLabel);

    this.rowLabel.forEach((Label row){
      var rowLabelGroup = row.groupLabel;
      row.id = rowLabelGroup.id + row.id;
    });

    this.colLabel.forEach((Label col){
      var colLabelGroup = col.groupLabel;
      col.id = colLabelGroup.id + col.id;
    });


    /*this.allLabel.forEach((Label label){
      print("row: ${label.isRow} - name: ${label.name} - group: ${label.groupNumber}");
    });*/

    bool possibleIndexHole = false;

    //We go through both the rowLabels and the colLabels
    // if these two are connected
    //   (the matrix value at the row and col intersect is higher than zero)
    // then we a creating two VisObject. One for the rowLabel and one for the colLabel
    // if these are sibling then we are creating only one VisObject with the rowLabel
    int addedRowLabels = 0;
    int addedColLabels = 0;
    /*this.rowLabel.forEach((Label row){
      addedRowLabels++;
      this.colLabel.forEach((Label col){ // go trough the labels

        // Check the value of the cell
        // if 0 then we skip the cell
        // TODO possibility of mathematical error
        if(this._matrixData[row.tablePos][col.tablePos][0] != 0.0) {

          _createNewConnection(row.mainLabel, col.mainLabel,
              this._matrixData[row.tablePos][col.tablePos][0]);

        }else{
          if(!(row.id.isEmpty || col.id.isEmpty)){
            ConnectionManager.removeConnectionIfExists(
                this.objectHierarchy, row, col
            );
          }
        }

      });
    });*/

    for(var i = 1; i <= this.rowLabel.length; i++){
      for(var j = 1; j <= this.colLabel.length; j++){
        var row = this._getLabelByTablePos(true, i);
        var col = this._getLabelByTablePos(false, j);

        if(this._matrixData[row.tablePos][col.tablePos][0] != 0.0) {

          _createNewConnection(row.mainLabel, col.mainLabel,
              this._matrixData[row.tablePos][col.tablePos][0]);

        }else{
          if(!(row.id.isEmpty || col.id.isEmpty)){
            ConnectionManager.removeConnectionIfExists(
                this.objectHierarchy, row, col
            );
          }
        }
      }
    }


    fillGapsInIndex(objectHierarchy);

    ConnectionVis.updateMainSegmentsColors(objectHierarchy);
    ConnectionVis.updateMinMaxColorValue(objectHierarchy);
    ConnectionManager.updateConnectionsColors(objectHierarchy);

    //Reverse subSegments order to get a better result

    objectHierarchy.getChildren.forEach((VisualObject group) {
      group.getChildren.forEach((VisualObject segment) {
        segment.label.resetLabelGenerationCounter();
        var segmentChildNum = segment.getChildren.length;
        segment.getChildren.forEach((VisualObject subSegment) {
          subSegment.label.index = (segmentChildNum + 1) - subSegment.label.index;
        });
      });
    });

    //print("${objectHierarchy.getChildren}");
    return objectHierarchy;
  }

  void fillGapsInIndex(VisualObject root){
    var actualIndex = 1;
    bool holeFound = false;
    for(var i = 1; i <= Label.getGroupLabelsIndices(root.id).length; i++){
      try {
        var nextGroupID = root.getElementByIndex(i);
        var nextGroup = root.getChildByID(nextGroupID);
        nextGroup.label.index = actualIndex++;
      }catch(error){

      }
    }
  }

  /// Fills the matrix with zeroes
  void _fillMatrixWithZero(){
    this._fillMatrixWithValue(0.0);
  }

  /// Get the label of given row or column [rowOrCol] and [index]
  Label _getLabelByTablePos(bool rowOrCol, int index){
    var listOfInterest = rowOrCol ? this.rowLabel : this.colLabel;
    for(int i = 0; i < listOfInterest.length; i++){
      if(listOfInterest[i].tablePos == index){
        return listOfInterest[i];
      }
    }
    print("Return with null for: ${index} - ${rowOrCol ? "row" : "col"}");
    return null;
  }

  /// Updates all labels based on any changes in [matrixData]
  void updateAllLabel(){
    for(var i = 1; i < row_num; i++){
      updateLabel(i, true, LabelModType.change, false);
    }

    for(var i = 1; i < col_num; i++){
      updateLabel(i, false, LabelModType.change, false);
    }
    this.checkSiblings();
  }

  /// Updates the given label [index], [isRow] based on [matrixData] and [action]
  /// Action can be: change, add, remove
  void updateLabel(int index, bool isRow, LabelModType action, bool checksiblings){
    int rowIndex = isRow ? index : 0;
    int colIndex = isRow ? 0 : index;
    switch(action){
      case LabelModType.change:
        Label changedLabel = this._getLabelByTablePos(isRow, index);
        changedLabel.name = this.matrixData[rowIndex][colIndex][0] as String;
        changedLabel.mainLabel = null;
        if(checksiblings){
          this.checkSiblings();
        }
        break;
      case LabelModType.add:
        var listOfInterest = isRow ? this.rowLabel : this.colLabel;

        // update the labels indices
        int maxIndex = isRow ? this.row_num - 2 : this.col_num - 2;
        var affectedLabel = this._getLabelByTablePos(isRow, index);
        int sortIndexMin = affectedLabel.groupLabel.index;
        int sortIndexMax = Label.groupLabels[this.diagramDataID].length;
        Label.reindexLabels(this.allLabel, sortIndexMin, sortIndexMax, index, maxIndex, 1, isRow);

        listOfInterest.add(
            new LabelObj(_matrixData[rowIndex][colIndex][0] as String, index, isRow, this.diagramDataID)
        );
        listOfInterest.last.tablePos = index;
        listOfInterest.last.groupNumber = nextAvailableGroup();
        listOfInterest.last.groupLabel.index = sortIndexMin;


        if(checksiblings){
          this.checkSiblings();
        }

        break;
      case LabelModType.remove:
        var listOfInterest = isRow ? this.rowLabel : this.colLabel;

        int maxIndex = isRow ? this.row_num : this.col_num;
        var affectedLabel = this._getLabelByTablePos(isRow, index);
        if(_getNumberOfLabelWithSameGroupNumber(affectedLabel.groupNumber) < 2){
          int sortIndexMin = affectedLabel.groupLabel.index;
          int sortIndexMax = Label.groupLabels[this.diagramDataID].length;
          Label.reindexLabels(this.allLabel, sortIndexMin, sortIndexMax, index, maxIndex, -1, isRow);


          listOfInterest.remove(
              affectedLabel
          );
          Label.groupLabels[this.diagramDataID].remove(affectedLabel.groupNumber);

        }else{
          listOfInterest.remove(
              affectedLabel
          );
        }

        break;
      default:
        break;
    }
  }

  int _getNumberOfLabelWithSameGroupNumber(int groupNumber){
    int sum = 0;
    for(Label label in this.allLabel){
      if(label.groupNumber == groupNumber){
        sum++;
      }
    }
    return sum;
  }

  /// Get the data in a 2D matrix representation
  List<List> get rawData{
    List<List<dynamic>> retVal = new List<List<dynamic>>();

    retVal = new List(this.row_num-1);
    for(int i = 0; i < this.row_num-1; i++){
      retVal[i] = new List<List>(this.col_num);
      for(int j = 0; j < this.col_num-1; j++){
        retVal[i][j] = new List<dynamic>(this.depth_num);
      }
    }

    for(var row = 1; row < row_num; row++){
      for(var col = 1; col < col_num; col++){
        retVal[row - 1][col-1][0] = this._matrixData[row][col][0];
      }
    }
    return retVal;
  }

  /// Get the matrix data
  List<List<List<dynamic>>> get matrixData{
    return _matrixData;
  }

  /// Get the matrix data
  set matrixData(List<List<List<dynamic>>> value){
    this._matrixData = value;
  }

  /// Creates the labels based on the matrix first row and column
  void _createRowAndColLabel(){
    int groupNumber = 1;
    for(var rowIndex = 1; rowIndex < row_num; rowIndex++){
      this.rowLabel.add(
          new LabelObj(_matrixData[rowIndex][0][0] as String, 1, true, this.diagramDataID)
      );
      this.rowLabel.last.tablePos = rowIndex;
      this.rowLabel.last.groupNumber = groupNumber++;
      this.rowLabel.last.groupLabel;
    }
    for(var colIndex = 1; colIndex < col_num; colIndex++){
      this.colLabel.add(
          new LabelObj(_matrixData[0][colIndex][0] as String, 1, false, this.diagramDataID)
      );
      this.colLabel.last.tablePos = colIndex;
      this.colLabel.last.groupNumber = groupNumber++;
      this.colLabel.last.groupLabel;
    }

    // Check is there any siblings
    this.checkSiblings();

    var a = 0;
  }

  /// Fill the matrix with the given value [newValue]
  /// You can update [needUpdate] the matrix with the new values (optional)
  void _fillMatrixWithValue(dynamic newValue, [bool needUpdate = true]){
    var rowLabel = LetterProvider.getListOfLetters(this.row_num-1);
    var colLabel = LetterProvider.getListOfLetters(this.col_num-1,this.row_num-1);
    for(var row = 0; row < row_num; row++){
      for(var col = 0; col < col_num; col++){
        if(row == 0){
          if(col < col_num-1) {
            this._matrixData[0][col + 1][0] = colLabel[col];
          }
        }else
        if(col == 0 && row != 0){
          this._matrixData[row][0][0] = rowLabel[row-1];
        }else{
          for(var depth = 0; depth < depth_num; depth++){
            this._matrixData[row][col][depth] = newValue;
          }
        }
      }
    }
    if(needUpdate){
      this.updateAllLabel();
    }
  }

  /// Fill the matrix with random values
  /// You can generate zeroes [randomZeroes] or you can set the min and max value
  /// for the random generator [maxValue] and [minValue]
  /// You can update [needUpdate] the matrix with the new values (optional)
  void _fillMatrixWithRandomValue([bool randomZeroes = false, num maxValue = 99, num minValue = 1, bool needUpdate = true]){
    var rowLabel = LetterProvider.getListOfLetters(this.row_num-1);
    var colLabel = LetterProvider.getListOfLetters(this.col_num-1,this.row_num-1);
    int numberOfElementInTable = 1;
    int allElement = row_num * col_num;

    var listOfAllGeneratedNumber = new List<double>();
    double max = 0.0;
    for(var i = 0; i < (row_num - 1) * (col_num - 1); i++) {
      var helper = 0.0;
      do {
        helper = MathFunc.getExponentialDistributedRandomNumber(
            1.0, maxValue.toDouble(), minValue.toDouble());
      } while (helper < 1);
      if(helper > max){
        max = helper;
      }
      listOfAllGeneratedNumber.add(helper);
    }
    double convertToRange = 1.0/max;
    int generatedNumberIndex = 0;

    for(var row = 0; row < row_num; row++){
      for(var col = 0; col < col_num; col++){
        if(row == 0){
          if(col < col_num-1){
            this._matrixData[0][col+1][0] = colLabel[col];
          }
        }else
        if(col == 0 && row != 0){
          this._matrixData[row][0][0] = rowLabel[row-1];
        }else{
          for(var depth = 0; depth < depth_num; depth++){
            if(randomZeroes){
              var rnd = new Random(new DateTime.now().millisecondsSinceEpoch +
                  (allElement * numberOfElementInTable));
              if(rnd.nextDouble() < this.percentOfRandomZeroes){
                this._matrixData[row][col][depth] = 0;
              }else {
                /*this._matrixData[row][col][depth] =
                    rnd.nextInt(maxValue - minValue as int) + minValue;*/
                var helper = 0;
                do {
                  helper = MathFunc.getNormalDistributedRandomNumber(
                      maxValue.toDouble(), minValue.toDouble()).toInt();
                }while(helper < 1);

                this._matrixData[row][col][depth] = helper;

                /*var helper = 0;
                do {
                  helper = MathFunc.getExponentialDistributedRandomNumber(1.0, maxValue.toDouble(), minValue.toDouble()).toInt();
                }while(helper < 1);*/

                //var helper = ((listOfAllGeneratedNumber[generatedNumberIndex++] * convertToRange) * maxValue + minValue).toInt();

                this._matrixData[row][col][depth] = helper;

              }
            }else{
              /*this._matrixData[row][col][depth] =
                  new Random(new DateTime.now().millisecondsSinceEpoch + (allElement * numberOfElementInTable))
                      .nextInt(maxValue - minValue as int) + minValue;*/

              var helper = 0;
              do {
                helper = MathFunc.getNormalDistributedRandomNumber(
                    maxValue.toDouble(), minValue.toDouble()).toInt();
              }while(helper < 1);

              this._matrixData[row][col][depth] = helper;

              /*var helper = 0;
              do {
                helper = MathFunc.getExponentialDistributedRandomNumber(1.0, maxValue.toDouble(), minValue.toDouble()).toInt();
              }while(helper < 1);*/

              //var helper = ((listOfAllGeneratedNumber[generatedNumberIndex++] * convertToRange) * maxValue + minValue).toInt();

              this._matrixData[row][col][depth] = helper;
            }
          }
        }
        numberOfElementInTable++;
      }
    }
    if(needUpdate){
      this.updateAllLabel();
    }
  }

  /// Add row(s) [numberOfAddedRow] to the matrix at the given [indexToAddRow] place
  void addRowToMatrix(int indexToAddRow, [int numberOfAddedRow = 1]) {
    indexToAddRow = indexToAddRow < 0 ? this.row_num : indexToAddRow;
    if(this._matrixData == null) throw new StateError("Matrix is not initialized");

    for(var i = 0; i < numberOfAddedRow; i++){
      var newRow = new List<List<dynamic>>.generate(this.col_num,
              (int index) => index < 1
              ? new List<dynamic>.generate(this.depth_num,
                  (int index) =>
                  MathFunc.generateUniqueID(
                      DataMatrix.listOfGeneratedRowColID
                  ), growable: true)
              : new List<dynamic>.generate(this.depth_num,
                  (int index) => 0.0, growable: true),
          growable: true);
      this._matrixData.insert(indexToAddRow, newRow);
    };
    this.row_num += numberOfAddedRow;
    updateLabel(indexToAddRow, true, LabelModType.add, true);
    this._structureChangeHappened = true;
  }

  /// Add column(s) [numberOfAddedCol] to the matrix at the given [indexToAddCol] place
  void addColToMatrix(int indexToAddCol, [int numberOfAddedCol = 1]) {
    indexToAddCol = indexToAddCol < 0 ? this.col_num : indexToAddCol;
    if(this._matrixData == null) throw new StateError("Matrix is not initialized");

    var index = 0;
    this._matrixData.forEach((e){
      if(e == null) throw new StateError("Matrix $index row is not initialized");
      for(var i = 0; i < numberOfAddedCol; i++) {
        if(index == 0){
          e.insert(indexToAddCol,new List<dynamic>.generate(this.depth_num,
                  (int index) => MathFunc.generateUniqueID(DataMatrix.listOfGeneratedRowColID),
              growable: true));
        }else{
          e.insert(indexToAddCol,new List<dynamic>.generate(this.depth_num,
                  (int index) => 0.0, growable: true));
        }

      }
      index++;
    });
    this.col_num += numberOfAddedCol;
    updateLabel(indexToAddCol, false, LabelModType.add, true);
    this._structureChangeHappened = true;
  }

  /// Add depth(s) [numberOfRemovedCol] from the matrix
  void addDepthToMatrix({int numberOfAddedDepth: 1}) {
    throw new UnimplementedError("Implementation later");
    /*if(this._dataFromUser == null) throw new StateError("Matrix is not initialized");

    var index = 0;
    this._dataFromUser.forEach((e){
      if(e == null) throw new StateError("Matrix $index row is not initialized");
      index++;
      var colIndex = 0;
      e.forEach((List<double> f) {
        if(f == null) throw new StateError("Matrix depth in $index row and $colIndex is not initialized");
        colIndex++;
        for (int i = 0; i < numberOfAddedDepth; i++) {
          f.add(0.0);
        }
      });
    });*/
  }

  /// Delete depth(s) [numberOfRemovedCol] from the matrix
  void removeDepthFromMatrix({int numberOfRemovedDepth: 1}) {
    throw new UnimplementedError("Implementation later");
    /*if(this._dataFromUser == null) throw new StateError("Matrix is not initialized");

    var index = 0;
    this._dataFromUser.forEach((e){
      if(e == null) throw new StateError("Matrix $index row is not initialized");
      index++;
      var colIndex = 0;
      e.forEach((List<double> f) {
        if(f == null) throw new StateError("Matrix depth in $index row and $colIndex is not initialized");
        if(f.length <= numberOfRemovedDepth) throw new StateError(
            "Matrix depth ${f.length} in $index row and $colIndex is less then or equals with $numberOfRemovedDepth");
        colIndex++;
        f.removeRange(f.length - numberOfRemovedDepth,f.length);
      });
    });*/
  }

  /// Delete the given [indexRemoveCol] column(s) [numberOfRemovedCol] from the matrix
  void removeColFromMatrix(int indexRemoveCol, [int numberOfRemovedCol = 1]) {
    indexRemoveCol = indexRemoveCol < 0 ? this.col_num - numberOfRemovedCol : indexRemoveCol;
    if(this._matrixData == null) throw new StateError("Matrix is not initialized");

    var index = 0;
    this._matrixData.forEach((e){
      if(e == null) throw new StateError("Matrix $index row is not initialized");
      index++;
      if(e.length <= numberOfRemovedCol)
        throw new StateError("Matrix col ${e.length} in $index row is less then or equals with $numberOfRemovedCol");
      e.removeRange(indexRemoveCol, indexRemoveCol + numberOfRemovedCol);
    });
    this.col_num -= numberOfRemovedCol;
    updateLabel(indexRemoveCol, false, LabelModType.remove, true);
    var groupLabelIndices = Label.getGroupLabelsIndices(this.diagramDataID);
    this._structureChangeHappened = true;
  }

  /// Delete the given [indexRemoveRow] row(s) [numberOfRemovedRow] from the matrix
  void removeRowFromMatrix(int indexRemoveRow, [int numberOfRemovedRow = 1]) {
    indexRemoveRow = indexRemoveRow < 0 ? this.row_num - numberOfRemovedRow : indexRemoveRow;
    if(this._matrixData == null) throw new StateError("Matrix is not initialized");
    if(this.row_num <= numberOfRemovedRow)
      throw new StateError("Matrix row ${this._matrixData.length} is less then or equals with $numberOfRemovedRow");

    this._matrixData.removeRange(indexRemoveRow, indexRemoveRow + numberOfRemovedRow);
    this.row_num -= numberOfRemovedRow;
    updateLabel(indexRemoveRow, true, LabelModType.remove, true);
    this._structureChangeHappened = true;
  }

  ///Find the next available groupNumber
  int nextAvailableGroup(){
    var allLabels = this.allLabel;

    List<int> groupNumbers = new List<int>();

    for(var i = 0; i < allLabels.length; i++){
      groupNumbers.add(allLabels[i].groupNumber);
    }


    groupNumbers.sort(((int a, int b){return a-b;}));

    int retVal = groupNumbers.length;
    for(var i = 0; i < groupNumbers.length - 1; i++){
      if(groupNumbers[i] - groupNumbers[i+1] > 1){
        retVal = groupNumbers[i]+1;
        break;
      }
    }

    return retVal;
  }

  /// Get data structure for sorting the segments
  @override
  SortDataSearchAlgorithm getInformationForConnectionSort() {
    throw new UnsupportedError("Change, we do not use matrix for the sort anymore");
    var localRowLabel = this.rowLabel;
    var localColLabel = this.colLabel;
    var localRawData = this.rawData;

    //return new sortData(this.row_num-1, this.col_num-1, localRawData, localRowLabel, localColLabel);
  }

  /// Get a matrix to show the data on the UI
  @override
  List<List> getDataForUI() {
    var retVal = new List<List>();

    for(var i = 0; i < this._matrixData.length; i++){
      retVal.add(new List<dynamic>());
      for(var j = 0; j <this._matrixData[i].length; j++){
        retVal[i].add(this._matrixData[i][j][0]);
      }
    }

    return retVal;
  }

  /// clear the input value with the optionally given [clearValue] default = 0
  @override
  void clearData([dynamic clearValue = 0]) {
    this._fillMatrixWithValue(clearValue);
  }

  /// Fill the input data with random values
  ///
  /// Only optional settings [randomZeroes] : is zero a valid value
  /// [max] and [min] is the boundaries of the random value generation
  @override
  void fillWithRandomData([bool randomZeroes = false, dynamic max = 99, dynamic min = 1, bool needUpdate = true]) {
    this._fillMatrixWithRandomValue(randomZeroes, max as num, min as num, needUpdate);
  }

  /// Get string representation of the table's labels
  String getLabels(){
    StringBuffer sb = new StringBuffer();
    sb.writeln("rowLabels:");
    this.rowLabel.forEach((Label l){
      sb.writeln("${l.name} => ${l.tablePos} ::: ${l.index} ### ${l.groupNumber} ///:  ${l.id}");
    });
    sb.writeln("colLabels:");
    this.colLabel.forEach((Label l){
      sb.writeln("${l.name} => ${l.tablePos} ::: ${l.index} ### ${l.groupNumber} ///:  ${l.id}");
    });
    return sb.toString();
  }

  @override
  InputData copy() {
    return new DataMatrix.fromMatrix("${this.diagramDataID}_copy_${this.numberOfCopy++}", this._matrixData);
  }
}