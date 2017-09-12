part of dataProcessing;

class DiagramStateFull extends State{

  int _maxChildNumber = 1;

  DiagramStateFull(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
    listOfConnections = new List<SortConnection>();
    order = new List<VisualObject>();
    orderIndexHelper = new Map<int, int>();

    List<VisualObject> mainSegments = this.diagramElements.rootElement.getChildren;

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

    int nextRowIndex = 2, nextColIndex = 1;
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

    //create connections for the sort
    for (int i = 0; i < mainSegments.length; i++) {
      for (int j = i; j < mainSegments.length; j++) {
        if (diagramElements.isConnected(mainSegments[i], mainSegments[j])) {
          var possNewConn = new SortConnection(mainSegments[i].label, mainSegments[j].label);
          if(!listOfConnections.contains(possNewConn)){
            listOfConnections.add(possNewConn);
          }
        }
      }
    }

    this.calculate();
  }

  DiagramStateFull.simple(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
    listOfConnections = new List<SortConnection>();
    order = new List<VisualObject>();
    orderIndexHelper = new Map<int, int>();

    List<VisualObject> mainSegments = new List<VisualObject>();

    order.addAll(this.diagramElements.rootElement.getChildren);
    int index = 1;
    int indexInOrder = 0;
    order.forEach((VisualObject groupElement){
      //groupElement.label.index = index++; Already done in the Data Matrix class
      int subSegmentOder = 1;

      groupElement.getChildren.forEach((VisualObject SegmentElement) {
        SegmentElement.label.index = subSegmentOder++;
      });

      mainSegments.addAll(groupElement.getChildren);

      if(groupElement.numberOfChildren > _maxChildNumber){
        _maxChildNumber = groupElement.numberOfChildren;
      }

      orderIndexHelper[groupElement.label.index] = indexInOrder++;
    });

    //create connections for the sort based on the segment not the groups
    for (int i = 0; i < mainSegments.length; i++) {
      for (int j = i; j < mainSegments.length; j++) {
        if (diagramElements.isConnected(mainSegments[i], mainSegments[j])) {
          var possNewConn = new SortConnection(mainSegments[i].label, mainSegments[j].label, mainSegments[i].parent.label, mainSegments[j].parent.label);
          if(!listOfConnections.contains(possNewConn)){
            listOfConnections.add(possNewConn);
          }
        }
      }
    }

    this.calculate();
  }

  DiagramStateFull.simpleCopy(State object){
    diagramElements = object.diagramElements.copy();
    listOfConnections = new List<SortConnection>();
    this.order = this.diagramElements.rootElement.getChildren;
    this.orderIndexHelper = new Map<int, int>();

    List<VisualObject> mainSegments = new List<VisualObject>();

    int index = 0;
    this.order.forEach((VisualObject groupElement){
      groupElement.label.index = object.diagramElements.rootElement.getChildByID(groupElement.id, true).label.index;
      groupElement.getChildren.forEach((VisualObject segmentElement) {
        segmentElement.label.index = object.diagramElements.rootElement.getChildByID(segmentElement.id, true).label.index;
      });

      mainSegments.addAll(groupElement.getChildren);

      if(groupElement.numberOfChildren > _maxChildNumber){
        _maxChildNumber = groupElement.numberOfChildren;
      }

      this.orderIndexHelper[groupElement.label.index] = index++;
    });

    //create connections for the sort
    for (int i = 0; i < mainSegments.length; i++) {
      for (int j = i; j < mainSegments.length; j++) {
        if (diagramElements.isConnected(mainSegments[i], mainSegments[j])) {
          var possNewConn = new SortConnection(mainSegments[i].label, mainSegments[j].label, mainSegments[i].parent.label, mainSegments[j].parent.label);
          if(!listOfConnections.contains(possNewConn)){
            listOfConnections.add(possNewConn);
          }
        }
      }
    }

    this.numberOfIntersection = object.getValue();
    //this.calculate();
  }


  VisualObject getElementByPlace(int place){
    return order[orderIndexHelper[place]];
  }

  int compareTo(State o) {
    return this.getValue() - o.getValue();
  }


  void calculate() {
    numberOfIntersection = 0;
    for (int i = 0; i < listOfConnections.length; i++) {
      for (int j = i; j < listOfConnections.length; j++) {
        if(listOfConnections[i] == listOfConnections[j]){continue;}
        if(listOfConnections[i].isConnectionCollide(listOfConnections[j])){
          numberOfIntersection++;
        }
      }
    }
    //numberOfIntersection = numberOfIntersection / 2;
  }

  int getValue() {
    return numberOfIntersection;
  }

  int numberOfNeighbours([VisualObject object]) {
    var sumOfNeighbours = 0;
    this.order.forEach((VisualObject group){
      var m = group.numberOfChildren;
      var partialValue = 0;
      if(m == 1){
        partialValue = (this.order.length-1);
      }else{
        partialValue = (this.order.length-1) * group.numberOfChildren * (group.numberOfChildren - 1);
      }

      sumOfNeighbours += partialValue;
    });
    return sumOfNeighbours;
  }


  void chooseNeighbour(int neighbour) {
    //Find out which connections you need to move and where
    // N = Number of groups = order.length
    // M = groups elements = order[i].length
    // N * (N-1) * (M * (M-1))
    // N = 4 és M = 2 esetén
    // E = neighbours = 24
    // P = poss state = 6
    // S = selected neighbour = 13
    // W = select who to move = (S / P).toInt() => 2
    // V = movement based on its position = S - (W * P); => 1, possible values 0 - 5
    // G = group movement = (V / (M * (M - 1))).toInt() => 0, possible values 0 - 2, need plus 1 when moving
    // T = segment remaining movement = (V - (G * (M * (M - 1)))) => 1, possible values 0 - 1
    // F = segment to move = (T / (M - 1)) = 0;
    // h = segment move value = (T - (f * (M - 1)));

    int index = 1;
    int remainder = neighbour;
    int m = this.order[orderIndexHelper[index]].numberOfChildren;
    var possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    while(remainder > (this.order.length-1) * possibleSegmentsVariations){
      remainder -= (this.order.length-1) * possibleSegmentsVariations;
      index++;
      m = this.order[orderIndexHelper[index]].numberOfChildren;
      possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    }

    int indexToMove = index;
    int groupToMove = orderIndexHelper[indexToMove];
    int possibleNeighboursOfTheGroup = this.getStatePossNeighbour(this.order[groupToMove]);
    int groupInsideNeighbours = (possibleNeighboursOfTheGroup ~/ (this.order.length - 1));
    int oneSegmentPossPositionsNumber = (groupInsideNeighbours ~/ (this.order[groupToMove].numberOfChildren));
    int remainingMovement = remainder;
    int groupMovement = (remainingMovement / groupInsideNeighbours).ceil();
    int segmentRemainingMovement = remainingMovement % groupInsideNeighbours;
    int segmentToMove = segmentRemainingMovement == 0 ? 1 : (segmentRemainingMovement /  oneSegmentPossPositionsNumber).ceil();
    int segmentMovement = segmentRemainingMovement == 0 ? 0 : segmentRemainingMovement %  segmentToMove;

    int groupNewPosition = indexToMove + groupMovement;
    int segmentNewPosition = segmentToMove + segmentMovement;

    if(groupNewPosition > this.order.length){
      groupNewPosition -= (this.order.length);
    }

    if(segmentNewPosition > this.order[groupToMove].numberOfChildren){
      segmentNewPosition -= (this.order[groupToMove].numberOfChildren);
    }

    int positionMoveValue = (neighbour - 1)%(this.order.length-1)+1;
    int newPosition = indexToMove + positionMoveValue;

    int indexGroupA = orderIndexHelper[indexToMove];
    int indexGroupB = orderIndexHelper[groupNewPosition];
    getElementByPlace(indexToMove).label.index = getElementByPlace(groupNewPosition).label.index;
    getElementByPlace(groupNewPosition).label.index = indexToMove;
    orderIndexHelper[indexToMove] = indexGroupB;
    orderIndexHelper[groupNewPosition] = indexGroupA;

    var movedGroup = getElementByPlace(groupNewPosition);
    var segmentA = movedGroup.getChildByID(movedGroup.getElementByIndex(segmentToMove));
    var segmentB = movedGroup.getChildByID(movedGroup.getElementByIndex(segmentNewPosition));

    segmentA.label.index = segmentNewPosition;
    segmentB.label.index = segmentToMove;


    //orderPos;
    //visualObjectIndices;
    //TODO make it better
    /*int indexA = orderIndexHelper[indexToMove];
    int indexB = orderIndexHelper[newPosition];
    getElementByPlace(indexToMove).label.index = getElementByPlace(newPosition).label.index;
    getElementByPlace(newPosition).label.index = indexToMove;
    orderIndexHelper[indexToMove] = indexB;
    orderIndexHelper[newPosition] = indexA;*/

    //orderPos;
    //visualObjectIndices;

    //update connections
    for(SortConnection conn in listOfConnections){
      /*if((conn.getIndex(ConnectionPart.begin) == indexToMove || conn.getIndex(ConnectionPart.end) == indexToMove) ||
          (conn.getIndex(ConnectionPart.begin) == newPosition || conn.getIndex(ConnectionPart.end) == newPosition)){
        conn.updateIndex();
      }*/
      conn.updateIndex(this);
    }

    this.calculate();
    //status;
    //visualObjectIndices;
  }


  void chooseNeighbour2(int neighbour) {
    int indexToMove = 1+((neighbour-1)/(this.order.length-1)).floor();
    int positionMoveValue = (neighbour - 1)%(this.order.length-1)+1;
    int newPosition = indexToMove + positionMoveValue;

    if(newPosition > this.order.length){
      newPosition -= (this.order.length);
    }

    //orderPos;
    //visualObjectIndices;
    //TODO make it better
    int indexA = orderIndexHelper[indexToMove];
    int indexB = orderIndexHelper[newPosition];
    getElementByPlace(indexToMove).label.index = getElementByPlace(newPosition).label.index;
    getElementByPlace(newPosition).label.index = indexToMove;
    orderIndexHelper[indexToMove] = indexB;
    orderIndexHelper[newPosition] = indexA;

    //orderPos;
    //visualObjectIndices;

    //update connections
    for(SortConnection conn in listOfConnections){
      if((conn.getIndex(ConnectionPart.begin) == indexToMove || conn.getIndex(ConnectionPart.end) == indexToMove) ||
          (conn.getIndex(ConnectionPart.begin) == newPosition || conn.getIndex(ConnectionPart.end) == newPosition)){
        conn.updateIndex(this);
      }
    }

    this.calculate();
    //status;
    //visualObjectIndices;
  }

  List<String> get visualObjectIndices{
    var printList = new List<String>();
    diagramElements.rootElement.getChildren.forEach((VisualObject value){
      printList.add("<< ${value.label.name} - ${value.label.index} >>");
    });
    print(printList);
    return printList;
  }

  Map<int, String> get orderID{
    var printList = new Map<int, String>();
    diagramElements.rootElement.getChildren.forEach((VisualObject value){
      printList[value.label.index] = value.id;
    });
    return printList;
  }

  List<String> get orderPos{
    var printList = new List<String>();
    for(var i = 1; i <= order.length; i++){
      printList.add(getElementByPlace(i).label.name);
    }
    print(printList);
    return printList;
  }

  String get status{
    var printList = new List<String>();
    var sb = new StringBuffer();
    for(var i = 1; i <= order.length; i++){
      var element = getElementByPlace(i);
      sb.write("{${element.label.name}: ");
      var firstOne = true;
      for(VisualObject child in element.getChildren){
        if(firstOne){
          sb.write("${child.label.name}");
          firstOne = false;
        }else{
          sb.write(",${child.label.name}");
        }

      }
      sb.write("}");
      printList.add(sb.toString());
    }
    print("${printList} :::: ${this.numberOfIntersection}");
    return "${printList} :::: ${this.numberOfIntersection}";
  }

  int getStatePossNeighbour([VisualObject object]) {
    if(object == null){
      return (this.order.length - 1);
    }else{
      var m = object.numberOfChildren;
      var possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
      return (this.order.length-1) * possibleSegmentsVariations;
    }
  }

  void clean() {
    diagramElements.clean();
    listOfConnections = new List<SortConnection>();
  }


  State copy() {
    return new State.copyState(SortAlgorithmType.hillClimb, this);
  }

  State clone(){
    return new State.copyState(SortAlgorithmType.hillClimb, this);
  }


  int diffNeighbour(int neighbour) {
    State newState = this.copy();
    //newState.calculate();

    newState.chooseNeighbour(neighbour);
    return newState.getValue() - this.getValue();
  }

  List<int> maxConflictNeighbour() {
    int maxIndex = -1;
    SortConnection maxConflictConn;
    List<SortConnection> listOfMaxConn = new List<SortConnection>();
    for (SortConnection conn in listOfConnections) {
      int actIntersection = 0;

      for (SortConnection helperConn in listOfConnections) {
        if(conn == helperConn){continue;}
        if(conn.isConnectionCollide(helperConn)){
          actIntersection++;
        }
      }

      if(maxIndex < actIntersection){
        maxIndex = actIntersection;
        maxConflictConn = conn;
        listOfMaxConn.clear();
        listOfMaxConn.add(maxConflictConn);
      }else if (maxIndex == actIntersection){
        listOfMaxConn.add(conn);
      }
    }
    var returnValue = new List<int>();

    for(SortConnection conn in listOfMaxConn){
      returnValue.add(conn.getIndex(ConnectionPart.begin));
      returnValue.add(conn.getIndex(ConnectionPart.end));
      //returnValue.add(conn.end.id);
    }

    return returnValue;
  }


  @override
  void changeStateByOrder(List<VisualObject> newOrder) {
    this.order;

    for(var i = 0; i < newOrder.length; i++) {
      var indexToMove = getElementIndexByID(newOrder[i].id);
      var newPosition = newOrder[i].label.index;

      if(indexToMove == newPosition) continue;

      if(newPosition > this.order.length){
        newPosition -= (this.order.length);
      }

      int indexA = orderIndexHelper[indexToMove];
      int indexB = orderIndexHelper[newPosition];
      getElementByPlace(indexToMove).label.index = getElementByPlace(newPosition).label.index;
      getElementByPlace(newPosition).label.index = indexToMove;
      orderIndexHelper[indexToMove] = indexB;
      orderIndexHelper[newPosition] = indexA;

      for (SortConnection conn in listOfConnections) {
        if ((conn.getIndex(ConnectionPart.begin) == indexToMove ||
            conn.getIndex(ConnectionPart.end) == indexToMove) ||
            (conn.getIndex(ConnectionPart.begin) == newPosition ||
                conn.getIndex(ConnectionPart.end) == newPosition)) {
          conn.updateIndex(this);
        }
      }
    }

    this.calculate();
  }

  int getElementIndexByID(String groupID, [String segmentID = ""]){
    throw new UnimplementedError("unimplemented");
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