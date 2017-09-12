part of dataProcessing;

class DiagramStateFullWithoutCopy extends State{

  List<String> orderTemp = new List<String>();
  Map<String, List<String>> orderSegmentTemp = new Map<String, List<String>>();
  Map<String, Map<int, int>> orderIndexHelperTemp = new Map<String, Map<int, int>>();
  Map<String, Map<int, int>> orderIndexHelperFinal = new Map<String, Map<int, int>>();

  int finalOrderValue = 99999999999999999;

  DiagramStateFullWithoutCopy(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
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

  DiagramStateFullWithoutCopy.simple(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
    listOfConnections = new List<SortConnection>();
    order = this.diagramElements.rootElement.getChildren; // only groups
    orderIndexHelper = new Map<int, int>();

    List<VisualObject> mainSegments = new List<VisualObject>();

    orderTemp = this.diagramElements.rootElement.getChildrenIDs();

    orderIndexHelperTemp[this.diagramElements.rootElement.id] = new Map<int, int>();
    orderIndexHelperFinal[this.diagramElements.rootElement.id] = new Map<int, int>();

    int index = 1;
    int indexInOrder = 0;
    order.forEach((VisualObject groupElement){
      orderSegmentTemp[groupElement.id] = groupElement.getChildrenIDs();

      mainSegments.addAll(groupElement.getChildren);

      orderIndexHelperTemp[this.diagramElements.rootElement.id][groupElement.label.index] = indexInOrder;
      orderIndexHelperFinal[this.diagramElements.rootElement.id][groupElement.label.index] = indexInOrder;
      orderIndexHelper[groupElement.label.index] = indexInOrder++;
    });

    orderSegmentTemp.forEach((String groupElementID, List<String> children){

      orderIndexHelperTemp[groupElementID] = new Map<int, int>();
      orderIndexHelperFinal[groupElementID] = new Map<int, int>();

      VisualObject groupElement = this.diagramElements.rootElement.getChildByID(groupElementID);

      for(var i = 0; i < children.length; i++){
        orderIndexHelperTemp[groupElementID][i+1] = i;
        orderIndexHelperFinal[groupElementID][i+1] = i;

        // Set basic indexing
        groupElement.getChildByID(children[i]).label.index = i+1;
      }

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

  DiagramStateFullWithoutCopy.simpleCopy(State object){
    diagramElements = object.diagramElements;
    listOfConnections = new List<SortConnection>();
    order = this.diagramElements.rootElement.getChildren; // only groups
    orderIndexHelper = new Map<int, int>.from(object.orderIndexHelper);

    List<VisualObject> mainSegments = new List<VisualObject>();

    orderTemp = this.diagramElements.rootElement.getChildrenIDs();

    orderIndexHelperTemp = new Map<String, Map<int, int>>();
    (object as DiagramStateFullWithoutCopy).orderIndexHelperTemp.forEach((String key, Map<int, int> value){
      orderIndexHelperTemp[key] = new Map<int, int>.from(value);
    });

    orderIndexHelperFinal = new Map<String, Map<int, int>>();
    (object as DiagramStateFullWithoutCopy).orderIndexHelperFinal.forEach((String key, Map<int, int> value){
      orderIndexHelperFinal[key] = new Map<int, int>.from(value);
    });

    this.order.forEach((VisualObject groupElement){
      orderSegmentTemp[groupElement.id] = groupElement.getChildrenIDs();
      mainSegments.addAll(groupElement.getChildren);
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

  VisualObject getElementAtIndex(int index, [int segmentIndex = -1]){
    if(segmentIndex > 0){
      String groupId = this.orderTemp[orderIndexHelperTemp[this.diagramElements.rootElement.id][index]];
      String segmentId = this.orderSegmentTemp[groupId][orderIndexHelperTemp[groupId][segmentIndex]];
      return this.diagramElements.rootElement.getChildByID(groupId).getChildByID(segmentId);
    }else{
      String groupId = this.orderTemp[orderIndexHelperTemp[this.diagramElements.rootElement.id][index]];
      return this.diagramElements.rootElement.getChildByID(groupId);
    }
  }

  int getElementPositionByIndex(int index, [int segmentIndex = -1]){
    if(segmentIndex > 0){
      String groupId = this.orderTemp[orderIndexHelperTemp[this.diagramElements.rootElement.id][index]];
      return orderIndexHelperTemp[groupId][segmentIndex];
    }else{
      return orderIndexHelperTemp[this.diagramElements.rootElement.id][index];
    }
  }

  VisualObject getElementByPosition(int position, [int segmentPosition = -1]){
    if(segmentPosition >= 0){
      return this.diagramElements.rootElement.getChildByID(this.orderTemp[position]).getChildByID(this.orderSegmentTemp[this.orderTemp[position]][segmentPosition]);
    }else{
      return this.diagramElements.rootElement.getChildByID(this.orderTemp[position]);
    }
  }

  void setNewPositionForIndex(int index, int newValue, [int segmentIndex = -1]){
    if(segmentIndex > 0){
      String groupId = this.orderTemp[orderIndexHelperTemp[this.diagramElements.rootElement.id][index]];
      orderIndexHelperTemp[groupId][segmentIndex] = newValue;
    }else{
      orderIndexHelperTemp[this.diagramElements.rootElement.id][index] = newValue;
    }
  }

  void setNewPositionForID(String groupID, int newValue, [String segmentID = ""]){
    if(segmentID.isNotEmpty){
      int segmentIndex = getElementIndexByID(groupID, segmentID);
      orderIndexHelperTemp[groupID][segmentIndex] = newValue;
    }else{
      int groupIndex = getElementIndexByID(groupID);
      orderIndexHelperTemp[this.diagramElements.rootElement.id][groupIndex] = newValue;
    }
  }

  void chooseNeighbour(int neighbour, [bool isPermanent = false]) {
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


    this.copy();

    int index = 1;
    int remainder = neighbour;
    int m = getElementAtIndex(index).numberOfChildren;
    var possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    while(remainder > (this.orderTemp.length-1) * possibleSegmentsVariations){
      remainder -= (this.orderTemp.length-1) * possibleSegmentsVariations;
      index++;
      m = getElementAtIndex(index).numberOfChildren;
      possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    }

    int indexToMove = index;
    int groupToMove = getElementPositionByIndex(indexToMove);
    VisualObject groupObjToMove = getElementAtIndex(indexToMove);
    int possibleNeighboursOfTheGroup = this.getStatePossNeighbour(groupObjToMove);
    int groupInsideNeighbours = (possibleNeighboursOfTheGroup ~/ (this.orderTemp.length - 1));
    int oneSegmentPossPositionsNumber = (groupInsideNeighbours ~/ (groupObjToMove.numberOfChildren));
    int remainingMovement = remainder;
    int groupMovement = (remainingMovement / groupInsideNeighbours).ceil();
    int segmentRemainingMovement = remainingMovement % groupInsideNeighbours;
    int segmentToMove = segmentRemainingMovement == 0 ? 1 : (segmentRemainingMovement /  oneSegmentPossPositionsNumber).ceil();
    int segmentMovement = segmentRemainingMovement == 0 ? 0 : segmentRemainingMovement %  segmentToMove;

    int groupNewPosition = indexToMove + groupMovement;
    int segmentNewPosition = segmentToMove + segmentMovement;

    if(groupNewPosition > this.orderTemp.length){
      groupNewPosition -= (this.orderTemp.length);
    }

    if(segmentNewPosition > groupObjToMove.numberOfChildren){
      segmentNewPosition -= (groupObjToMove.numberOfChildren);
    }

    int positionMoveValue = (neighbour - 1)%(this.orderTemp.length-1)+1;
    int newPosition = indexToMove + positionMoveValue;

    int indexGroupA = getElementPositionByIndex(indexToMove);
    int indexGroupB = getElementPositionByIndex(groupNewPosition);

    //getElementByPlace(indexToMove).label.index = getElementByPlace(groupNewPosition).label.index;
    //getElementByPlace(groupNewPosition).label.index = indexToMove;
    setNewPositionForIndex(indexToMove, indexGroupB);
    setNewPositionForIndex(groupNewPosition, indexGroupA);

    int indexSegmentA = getElementPositionByIndex(groupNewPosition, segmentToMove);
    int indexSegmentB = getElementPositionByIndex(groupNewPosition, segmentNewPosition);

    setNewPositionForIndex(groupNewPosition, indexSegmentA, segmentNewPosition);
    setNewPositionForIndex(groupNewPosition, indexSegmentB, segmentToMove);

    /*var movedGroup = getElementByPlace(groupNewPosition);
    var segmentA = movedGroup.getChildByID(movedGroup.getElementByIndex(segmentToMove));
    var segmentB = movedGroup.getChildByID(movedGroup.getElementByIndex(segmentNewPosition));

    segmentA.label.index = segmentNewPosition;
    segmentB.label.index = segmentToMove;*/


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

    if(isPermanent){
      this.orderIndexHelperTemp.forEach((String key, Map<int, int> indexList){
        indexList.forEach((int index, int position){
          this.orderIndexHelperFinal[key][index] = position;
        });
      });
      this.finalOrderValue = this.getValue();
    }


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
    }
    print("${sb.toString()} :::: ${this.numberOfIntersection}");
    return "${sb.toString()} :::: ${this.numberOfIntersection}";
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


  State save(){
    this.orderIndexHelperTemp.forEach((String key, Map<int, int> indexList){
      indexList.forEach((int index, int position){
        this.orderIndexHelperFinal[key][index] = position;
      });
    });
    this.finalOrderValue = this.getValue();
    return this;
  }

  State copy() {
    this.orderIndexHelperFinal.forEach((String key, Map<int, int> indexList){
      indexList.forEach((int index, int position){
        this.orderIndexHelperTemp[key][index] = position;
      });
    });

    return this;
  }

  State clone(){
    return new DiagramStateFullWithoutCopy.simpleCopy(this);
  }

  State finalize(){

    this.orderIndexHelperFinal.forEach((String key, Map<int, int> indexList){
        for (var index = 1; index <= indexList.length; index++) {
          VisualObject visObject;
          if(this.diagramElements.rootElement.id == key){
            visObject = this.diagramElements.rootElement.getChildByID(this.orderTemp[this
                .orderIndexHelperFinal[key][index]]);
          }else {
            visObject = this.diagramElements.rootElement.getChildByID(key)
                .getChildByID(this.orderSegmentTemp[key][this
                .orderIndexHelperFinal[key][index]]);
          }
          visObject.label.index = index;
        }

    });

    return this;
  }

  int diffNeighbour(int neighbour) {
    this.chooseNeighbour(neighbour);
    return this.getValue() - this.finalOrderValue;
  }

  State updateFromFinalOrder(){
    this.copy();

    for(SortConnection conn in listOfConnections){
      conn.updateIndex(this);
    }

    this.calculate();

    return this;
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


  State chooseRandomState(){

    this.orderIndexHelperFinal.forEach((String key, Map<int, int> indexList){

      if(this.diagramElements.rootElement.id == key){
        var helperIndexList = new List.generate(
            this.orderTemp.length, (int index) {
          return index + 1;
        });

        helperIndexList.shuffle(
            new Random(new DateTime.now().millisecondsSinceEpoch));

        int i = 0;
        for (int newIndex in helperIndexList) {
          this.orderIndexHelperTemp[key][newIndex] = i++;
        }
      }else {
        var helperIndexList = new List.generate(
            this.orderSegmentTemp[key].length, (int index) {
          return index + 1;
        });

        helperIndexList.shuffle(
            new Random(new DateTime.now().millisecondsSinceEpoch));

        int i = 0;
        for (int newIndex in helperIndexList) {
          this.orderIndexHelperTemp[key][newIndex] = i++;
        }
      }

    });

    for(SortConnection conn in listOfConnections){
      conn.updateIndex(this);
    }

    this.calculate();

    /*this.orderIndexHelperTemp.forEach((String key, Map<int, int> indexList){
      indexList.forEach((int index, int position){
        this.orderIndexHelperFinal[key][index] = position;
      });
    });

    this.finalOrderValue = this.getValue();*/

    return this;
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

  @override
  void setPositionDirectly(int orderIndex, int newPost) {
    setNewPositionForIndex(orderIndex, newPost);
  }

  void changeStateWithNewOrderList(List<Map<int, int>> newOrder) {
    newOrder[0].forEach((int key, int value){
      setNewPositionForIndex(key, value);
    });

    for(var i = 1; i <= order.length; i++){
      newOrder[i].forEach((int key, int value){
        setNewPositionForIndex(i, value, key);
      });
    }
  }

  void changeStateWithNewOrder(Map<String, Map<int, int>> newOrder) {
    newOrder.forEach((String id, Map<int, int> order){
      order.forEach((int key, int value){
        setNewPositionForIndex(getElementIndexByID(id), value, key);
      });
    });
  }

  int getElementIndexByID(String groupID, [String segmentID = ""]){

    if(segmentID.isNotEmpty){
      int segmentPosition = this.orderSegmentTemp[groupID].indexOf(segmentID);
      for(var i = 1; i <= this.orderIndexHelperTemp[groupID].length; i++){
        if(this.orderIndexHelperTemp[groupID][i] == segmentPosition){
          return i;
        }
      }
    }else{
      int groupPosition = this.orderTemp.indexOf(groupID);
      for(var i = 1; i <= this.orderIndexHelperTemp[this.diagramElements.rootElement.id].length; i++){
        if(this.orderIndexHelperTemp[this.diagramElements.rootElement.id][i] == groupPosition){
          return i;
        }
      }
    }

    return -1;
  }

  @override
  int diffNeighbourByOrder(List<VisualObject> order) {
    // TODO: implement diffNeighbourByOrder
  }

  @override
  String toString() {
    var sb = new StringBuffer();

    for(int i = 1; i <= order.length; i++){
      sb.write("${getElementAtIndex(i).label.name}");
      if(i < order.length) {
        sb.write(",");
      }
    }
    return 'Order: ${sb.toString()} : ${this.getValue()}';
  }
}