part of dataProcessing;

class DiagramState extends State{

  DiagramState(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
    listOfConnections = new List<SortConnection>();
    order = new List<VisualObject>();

    List<VisualObject> mainSegments = this.diagramElements.rootElement.getChildrenValues as List<VisualObject>;

    //create connections for the sort
    for (VisualObject segmentA in mainSegments) {
      for (VisualObject segmentB in mainSegments) {
        if (diagramElements.isConnected(segmentA, segmentB)) {
          listOfConnections.add(new SortConnection(segmentA.label, segmentB.label));
        }
      }
    }
    order.addAll(mainSegments);
    int rowNum = 0, colNum = 0;
    order.forEach((VisualObject element){
      if(element.label.isRow){
        rowNum++;
      }else{
        colNum++;
      }
    });

    //find the latest place while we need to put elements by skipping 2
    int minNumber = (min(rowNum, colNum) * 2) - 1;

    int nextRowIndex = 1, nextColIndex = 0;
    int indexInOrder = 0;
    for(VisualObject element in order){
      if(element.label.isRow){
        element.label.index = nextRowIndex;
        if(nextRowIndex + 2 > (minNumber + 1)){
          nextRowIndex++;
        }else{
          nextRowIndex += 2;
        }
      }else{
        element.label.index = nextColIndex;
        if(nextColIndex + 2 > (minNumber + 1)){
          nextColIndex++;
        }else{
          nextColIndex += 2;
        }
      }
      orderIndexHelper[element.label.index] = indexInOrder++;
    }

    this.calculate();

  }


  DiagramState.simple(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
    listOfConnections = new List<SortConnection>();
    order = new List<VisualObject>();

    List<VisualObject> mainSegments = this.diagramElements.rootElement.getChildrenValues as List<VisualObject>;

    //create connections for the sort
    for (VisualObject segmentA in mainSegments) {
      for (VisualObject segmentB in mainSegments) {
        if (diagramElements.isConnected(segmentA, segmentB)) {
          listOfConnections.add(new SortConnection(segmentA.label, segmentB.label));
        }
      }
    }

    order.addAll(mainSegments);
    int index = 0;
    var indexInOrder = 0;
    order.forEach((VisualObject element){
      element.label.index = index++;
      orderIndexHelper[element.label.index] = indexInOrder++;
    });

    this.calculate();
  }

  DiagramState.copyObj(DiagramState obj){
    diagramElements = obj.diagramElements.copy();
    listOfConnections = new List.from(obj.listOfConnections);
    this.order = new List.from(obj.order);

    this.numberOfIntersection = obj.getValue();
  }

  DiagramState.crossEntropy(DiagramCrossState obj){
    diagramElements = obj.diagramElements.copy();
    listOfConnections = new List.from(obj.listOfConnections);
    order = new List.from(obj.order);

    this.numberOfIntersection = obj.getValue();
  }

  VisualObject getElementByPlace(num place){
    return order[orderIndexHelper[place]];
  }

  @override
  int compareTo(Object o) {
    return (this.getValue() - (o as DiagramState).getValue()).toInt();
  }

  int getValue() {
    return numberOfIntersection;
  }

  int numberOfNeighbours([VisualObject object]) {
    return listOfConnections.length * 2;
  }


    void chooseNeighbour(int neighbour) {
      bool isfirst = neighbour % 2 == 0 ? true : false;
      SortConnection conn = listOfConnections[(neighbour / 2).floor()];

      List possTry = new List<int>.generate(this.order.length,(_) => 0);

      //Try to find were we can put the connections max or min index
      for (SortConnection conn in listOfConnections) {
        for (SortConnection helperConn in listOfConnections) {
          if(conn == helperConn){continue;}
          if(conn.isConnectionCollide(helperConn)){
            if(isfirst){
              possTry[max(helperConn.begin.index, helperConn.end.index)]++;
            }else{
              possTry[min(helperConn.begin.index, helperConn.end.index)]++;
            }
          }
        }
      }

      //try the new possible places to the connections end
      int minimum = this.getValue();
      List orderHelper = new List<VisualObject>.from(order);
      int indexToMove = 0;
      while(indexToMove < possTry.length){
        if(possTry[indexToMove] == 0){indexToMove++; continue;}
        for(int j = 0; j < 2; j++){
          int indexToSwap = 0;
          if(j == 0){
            indexToSwap = min(conn.begin.index, conn.end.index);
          }else{
            indexToSwap = max(conn.begin.index, conn.end.index);
          }

          NumberRange movingElement = new NumberRange.fromNumbers(indexToSwap, indexToMove);

          movingElement.loopOverRangeElement(1, (element){
            int indexA = orderIndexHelper[element];
            getElementByPlace(element).label.index = (element as int) + movingElement.direction;
            int indexB = orderIndexHelper[element + movingElement.direction];
            getElementByPlace(element + movingElement.direction).label.index = element as int;
            orderIndexHelper[element as int] = indexB;
            orderIndexHelper[(element as int) + movingElement.direction] = indexA;
          });

          this.calculate();
          if(minimum > this.getValue()){
            minimum = this.getValue();
            orderHelper = new List<VisualObject>.from(this.order);
          }
        }
      }

      this.order = new List.from(orderHelper);
    }


  int getStatePossNeighbour([VisualObject object]){
    return 2;
  }

  void clean() {
    diagramElements.clean();
    listOfConnections = new List<SortConnection>();
  }

  String get status{
    /*var printList = new List<String>();
    var sb = new StringBuffer();
    for(var i = 1; i <= orderTemp.length; i++){
      var element = getElementAtIndex(i);
      sb.write("{${element.label.name}: ");
      var firstOne = true;
      for(var j = 1; j <= orderSegmentTemp[element.id].length; j++){
        if(firstOne){
          sb.write("${getElementAtIndex(i, j).label.name}");
          firstOne = false;
        }else{
          sb.write(",${getElementAtIndex(i, j).label.name}");
        }

      }
      sb.write("}");
      printList.add(sb.toString());
    }
    print("${printList} :::: ${this.numberOfIntersection}");
    return "${printList} :::: ${this.numberOfIntersection}";*/
  }

  DiagramState copy() {
    return new DiagramState.copyObj(this);
  }

  State clone(){
    return new DiagramState.copyObj(this);
  }

  int getElementIndexByID(String groupID, [String segmentID = ""]){
    throw new UnimplementedError("unimplemented");
  }

  int diffNeighbour(int neighbour) {
    DiagramState newState = this.copy();
    newState.calculate();
    newState.chooseNeighbour(neighbour);
    return newState.getValue() - this.getValue();
  }

  List<int> diffNeighbourMinValue(int neighbour) {
    DiagramState newState = this.copy();
    newState.calculate();
    //TODO maybe I do not need to calcuate again
    newState.chooseNeighbour(neighbour);
    return [newState.getValue() - this.getValue(), this.getValue()];
  }

  @override
  void changeStateByOrder(List<VisualObject> order) {
    // TODO: implement changeStateByOrder
  }

  @override
  int diffNeighbourByOrder(List<VisualObject> order) {
    // TODO: implement diffNeighbourByOrder
  }

  @override
  State chooseRandomState() {
    throw new UnimplementedError("unimplemented");
  }

  @override
  State updateFromFinalOrder() {
    throw new UnimplementedError("unimplemented");
  }

  @override
  State finalize() {
    throw new UnimplementedError("unimplemented");
  }

  @override
  State save() {
    throw new UnimplementedError("unimplemented");
  }

  @override
  List<String> get orderPos {
    throw new UnimplementedError("unimplemented");
  }

  @override
  void setNewPositionForID(String groupID, int newValue,
      [String segmentID = ""]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  void setNewPositionForIndex(int index, int newValue,
      [int segmentIndex = -1]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  VisualObject getElementByPosition(int position, [int segmentPosition = -1]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  int getElementPositionByIndex(int index, [int segmentIndex = -1]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  VisualObject getElementAtIndex(int index, [int segmentIndex = -1]) {
    throw new UnimplementedError("unimplemented");
  }


}