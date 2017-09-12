part of poincareCore;

/*@Depreceted("No usage")
class DataTransformer implements TransformData{

  Map<String, VisualObject> _dataForVis;
  Map<String, VisMatrix> _dataForSave;


  DataTransformer(){
    this._dataForVis = new Map<String, VisualObject>();
    this._dataForSave = new Map<String, VisMatrix>();
  }

  VisualObject modifyOneElement(String id, int row, int col, dynamic value){
    this._dataForSave[id].setElement(row, col, value);
    this._checkMatrixElement(this._dataForSave[id], row, col, this._dataForVis[id]);
    return this._dataForVis[id];
  }

  VisualObject modifyVisData(String id, VisMatrix dataMatrix) {
    var diagramRoot = this._dataForVis[id];

    for(var i=0; i < dataMatrix.rowLabels.length; i++){
      try{
        diagramRoot.getChildByID(dataMatrix.getRowLabel(i).id);
      }catch(error){
        diagramRoot.addChild(new ObjectVis.withParent(dataMatrix.getRowLabel(i), 0.0, diagramRoot));
      }

    }

    for(var i=0; i < dataMatrix.colLabels.length; i++){
      try{
        diagramRoot.getChildByID(dataMatrix.getColLabel(i).id);
      }catch(error, stackTrace){
        diagramRoot.addChild(new ObjectVis.withParent(dataMatrix.getColLabel(i), 0.0, diagramRoot));
      }
    }

    for(var i = 0; i < dataMatrix.matrixNumberOfRows; i++){
      for(var j = 0; j < dataMatrix.matrixNumberOfCols; j++){
        _checkMatrixElement(dataMatrix, i, j, diagramRoot);
      }
    }
    return diagramRoot;
  }

  void _checkMatrixElement(VisMatrix dataMatrix, int i, int j, VisualObject diagramRoot){
    var rowLabel = dataMatrix.getRowLabel(i);
    var colLabel = dataMatrix.getColLabel(j);
    var firstParent = diagramRoot.getChildByID(rowLabel.id);
    var secondParent = diagramRoot.getChildByID(colLabel.id);

    if(dataMatrix.isThirdDimMatrix(rowIndex: i, colIndex: j)){
      var elementOne;
      try {
        elementOne = firstParent.getChildByID("${rowLabel.id}=$i:$j")
          ..label.name = "${rowLabel.name} <-> ${colLabel.name}"
          ..label.index = rowLabel.index
          ..label.isRow = rowLabel.isRow;
      }catch(_) {
        elementOne = firstParent.addChild(
            new ObjectVis.withParent(
                new LabelObj.ID("${rowLabel.name} <-> ${colLabel.name}", "${rowLabel.id}=$i:$j", rowLabel.index, rowLabel.isRow),
                0.0, firstParent, isHigherDim: true, generateID: false));
      }

      var elementTwo;

      try {
        elementTwo = secondParent.getChildByID("${rowLabel.id}=$i:$j")
          ..label.name = "${rowLabel.name} <-> ${colLabel.name}"
          ..label.index = rowLabel.index
          ..label.isRow = rowLabel.isRow;
      }catch(_) {
        elementTwo = secondParent.addChild(
            new ObjectVis.withParent(
                new LabelObj.ID("${colLabel.name} <-> ${rowLabel.name}", "${colLabel.id}=$i:$j", colLabel.index, colLabel.isRow),
                0.0, secondParent, isHigherDim: true, generateID: false));
      }

      if (ConnectionManager.listOfConnection[diagramRoot.id]["connection: $i/$j"] == null){
        elementOne.connection = new ConnectionVis(elementOne, elementTwo, "connection: $i/$j");
        elementTwo.connection = elementOne.connection;

        ConnectionManager.listOfConnection[diagramRoot.id]["connection: $i/$j"] = elementOne.connection;
      }

      var helper;
      for (var h = 0; h < (dataMatrix.getElement(i, j) as List).length; h++) {
        try{
          helper = (elementOne as VisualObject).getChildByID("$i:$j:$h")
            ..label.name = "${colLabel.name} <-> ${rowLabel.name}"
            ..label.index = colLabel.index
            ..label.isRow = colLabel.isRow
            ..value = dataMatrix.getElement(i, j, thirdDimNum: h);
        }catch(_){
          helper = elementOne.addChild(new ObjectVis.withParent(
              new LabelObj.ID("${colLabel.name} <-> ${rowLabel.name}", "$i:$j:$h", colLabel.index, colLabel.isRow),
              dataMatrix.getElement(i, j, thirdDimNum: h), secondParent, isHigherDim: true, generateID: false));
        }

        elementTwo.addChild(helper);
        elementOne.connection.addSubConnConfigByID("$i:$j:$h");
      }

    }else{
      var elementOne;
      try {
        elementOne = firstParent.getChildByID("${rowLabel.id}=$i:$j")
          ..label.name = "${rowLabel.name} <-> ${colLabel.name}"
          ..label.index = rowLabel.index
          ..label.isRow = rowLabel.isRow
          ..value = dataMatrix.getElement(i, j);
      }catch(_) {
        elementOne = firstParent.addChild(
            new ObjectVis.withParent(
                new LabelObj.ID("${rowLabel.name} <-> ${colLabel.name}", "${rowLabel.id}=$i:$j", rowLabel.index, rowLabel.isRow),
                dataMatrix.getElement(i, j), firstParent, generateID: false));
      }

      var elementTwo;

      try {
        elementTwo = secondParent.getChildByID("${colLabel.id}=$i:$j")
          ..label.name = "${colLabel.name} <-> ${rowLabel.name}"
          ..label.index = colLabel.index
          ..label.isRow = colLabel.isRow
          ..value = dataMatrix.getElement(i, j);
      }catch(_) {
        elementTwo = secondParent.addChild(
            new ObjectVis.withParent(
                new LabelObj.ID("${colLabel.name} <-> ${rowLabel.name}", "${colLabel.id}=$i:$j", colLabel.index, colLabel.isRow),
                dataMatrix.getElement(i, j), secondParent, generateID: false));
      }

      if (ConnectionManager.listOfConnection[diagramRoot.id]["connection: $i/$j"] == null){
        elementOne.connection = new ConnectionVis(elementOne, elementTwo, "connection: $i/$j");
        elementTwo.connection = elementOne.connection;

        ConnectionManager.listOfConnection[diagramRoot.id]["connection: $i/$j"] = elementOne.connection;
      }
    }
  }

  VisualObject getVisualData(String id) {
    if(this._isDataExist(id)){
      return this._dataForVis[id];
    }else{
      throw new StateError("Do not exist data for visualization with the given id($id)");
    }
  }

  VisMatrix getSaveData(String id){
    if(this._dataForSave.containsKey(id)){
      return this._dataForSave[id];
    }else{
      throw new StateError("Do not exist data for visualization with the given id($id)");
    }
  }

  void removeVisData(String id) {
    if(this._isDataExist(id)){
      this._dataForVis.remove(id);
    }else{
      throw new StateError("Do not exist data for visualization with the given id($id)");
    }
  }

  String createEmptyVisData(){
    var diagramRoot = new ObjectVis(new LabelObj("root",[0],true),0.0);

    this._dataForVis[diagramRoot.id] = diagramRoot;
    this._dataForSave[diagramRoot.id] = new MatrixVis.empty();
    return diagramRoot.id;
  }

  String createVisData(VisMatrix dataMatrix) {

    var diagramRoot = new ObjectVis(new LabelObj("root",[0],true),0.0);

    ConnectionManager.listOfConnection[diagramRoot.id] = new Map<String, ConnectionVis>();

    for(var i=0; i < dataMatrix.rowLabels.length; i++){
      diagramRoot.addChild(new ObjectVis.withParent(dataMatrix.getRowLabel(i), 0.0, diagramRoot));
    }

    for(var i=0; i < dataMatrix.colLabels.length; i++){
      diagramRoot.addChild(new ObjectVis.withParent(dataMatrix.getColLabel(i), 0.0, diagramRoot));
    }

    for(var i = 0; i < dataMatrix.matrixNumberOfRows; i++){
      for(var j = 0; j < dataMatrix.matrixNumberOfCols; j++){
        _processMatrixElement(dataMatrix, i, j, diagramRoot);
      }
    }

    this._dataForVis[diagramRoot.id] = diagramRoot;
    this._dataForSave[diagramRoot.id] = dataMatrix;
    return diagramRoot.id;
  }

  //TODO use the original rowLabel and colLabel and set them the new ID
  void _processMatrixElement(VisMatrix dataMatrix, int i, int j, VisualObject diagramRoot){

    var rowLabel = dataMatrix.getRowLabel(i);
    var colLabel = dataMatrix.getColLabel(j);
    var firstParent = diagramRoot.getChildByID(rowLabel.id);
    var secondParent = diagramRoot.getChildByID(colLabel.id);

    if(dataMatrix.isThirdDimMatrix(rowIndex: i, colIndex: j)){

      var elementOne = firstParent.addChild(
          new ObjectVis.withParent(
              new LabelObj.ID("${rowLabel.name} <-> ${colLabel.name}", "${rowLabel.id}=$i:$j", rowLabel.index, rowLabel.isRow),
              0.0, firstParent, isHigherDim: true, generateID: false));

      var elementTwo = secondParent.addChild(
          new ObjectVis.withParent(
              new LabelObj.ID("${colLabel.name} <-> ${rowLabel.name}", "${colLabel.id}=$i:$j", colLabel.index, colLabel.isRow),
              0.0, secondParent, isHigherDim: true, generateID: false));

      elementOne.connection = new ConnectionVis(elementOne, elementTwo, "connection: $i/$j")
        .._config.isFullConn = false
        .._listOfSubConnConfig = new Map<String, SubConnConfig>();
      elementTwo.connection = elementOne.connection;

      ConnectionManager.listOfConnection[diagramRoot.id]["connection: $i/$j"] = elementOne.connection;

      var helper;
      for(var h = 0; h < (dataMatrix.getElement(i,j) as List).length; h++){
        helper = elementOne.addChild(new ObjectVis.withParent(
          new LabelObj.ID("${colLabel.name} <-> ${rowLabel.name}", "$i:$j:$h", colLabel.index, colLabel.isRow),
          dataMatrix.getElement(i, j, thirdDimNum: h), [elementOne ,elementTwo], isHigherDim: true, generateID: false));
        elementTwo.addChild(helper);
        (elementOne.parent as VisualObject).value += helper.value;
        (elementTwo.parent as VisualObject).value += helper.value;
        elementOne.connection.addSubConnConfigByID("$i:$j:$h");
      }
    }else{
      var elementOne = firstParent.addChild(
          new ObjectVis.withParent(
              new LabelObj.ID("${rowLabel.name} <-> ${colLabel.name}", "${rowLabel.id}=$i:$j", rowLabel.index, rowLabel.isRow),
                dataMatrix.getElement(i, j), firstParent, generateID: false));

      var elementTwo = secondParent.addChild(
          new ObjectVis.withParent(
              new LabelObj.ID("${colLabel.name} <-> ${rowLabel.name}", "${colLabel.id}=$i:$j", colLabel.index, colLabel.isRow),
                dataMatrix.getElement(i, j), secondParent, generateID: false));

      elementOne.connection = new ConnectionVis(elementOne, elementTwo, "connection: $i/$j");
      elementTwo.connection = elementOne.connection;

      ConnectionManager.listOfConnection[diagramRoot.id]["connection: $i/$j"] = elementOne.connection;
    }
  }

  void sortConnection(int sortAlgorithm, String id) {
    throw new UnsupportedError("This function is not suported yet");
  }

  bool _isDataExist(String id) => this._dataForVis[id] != null
    ? true
    : false;


}*/