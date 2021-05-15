part of dataProcessing;

enum SortAlgorithmType{
  hillClimb,
  minConf,
  crossEntropy,
  crossEntropyMinConf,
  crossEntropyMod,
  simulatedAnnealing,
  beesAlgorithm
}

abstract class State{

  SortDataSearchAlgorithm diagramElements;
  List<SortConnection> listOfConnections;
  var numberOfIntersection = 0;
  List<VisualObject> order;
  Map<int, int> orderIndexHelper;

  List<int> groupChildrenNumber;
  int get bestNeighbourIndex => 1;

  State();

  factory State.getState(SortAlgorithmType type, VisualObject order){
    SortDataSearchAlgorithm sortData = new SortDataSearchAlgorithm(order);
    return new StateVisObjConnectionMod(sortData);
    /*switch(type){
      case SortAlgorithmType.hillClimb:
        return new StateVisObjConnection(sortData);
        //return new DiagramStateMatrix.simple(sortData);
        //return new DiagramStateFullWithoutCopy.simple(sortData);
        break;
      case SortAlgorithmType.minConf:
        return new StateVisObjConnection(sortData);
        //return new DiagramStateMatrix.simple(sortData);
          //return new DiagramStateFullWithoutCopy.simple(sortData);
        break;
      case SortAlgorithmType.crossEntropy:
        return new StateVisObjConnection(sortData);
        //return new DiagramStateMatrix.simple(sortData);
          //return new DiagramStateFullWithoutCopy.simple(sortData);
        break;
      case SortAlgorithmType.crossEntropyMinConf:
        return new StateVisObjConnection(sortData);
        //return new DiagramStateMatrix.simple(sortData);
          //return new DiagramStateFullWithoutCopy.simple(sortData);
        break;
      case SortAlgorithmType.crossEntropyMod:
        return new StateVisObjConnection(sortData);
        //return new DiagramStateMatrix.simple(sortData);
        //return new DiagramStateFullWithoutCopy.simple(sortData);
        break;
      case SortAlgorithmType.simulatedAnnealing:
        return new StateVisObjConnection(sortData);
        //return new DiagramStateMatrix.simple(sortData);
        //return new DiagramStateFullWithoutCopy.simple(sortData);
        break;
      case SortAlgorithmType.beesAlgorithm:
        return new StateVisObjConnection(sortData);
        //return new DiagramStateMatrix.simple(sortData);
        //return new DiagramStateFullWithoutCopy.simple(sortData);
        break;
      default:
        throw new StateError("Wrong sort algorithm type");
    }
    return null;*/
  }

  factory State.copyState(SortAlgorithmType type, State stateToCopy){
    switch(type){
      case SortAlgorithmType.hillClimb:
        return new DiagramStateFull.simpleCopy(stateToCopy);
        break;
      case SortAlgorithmType.minConf:
        return new DiagramStateFull.simpleCopy(stateToCopy);
        break;
      case SortAlgorithmType.crossEntropy:
        return new DiagramStateFull.simpleCopy(stateToCopy);
        break;
      case SortAlgorithmType.crossEntropyMinConf:
        return new DiagramStateFull.simpleCopy(stateToCopy);
        break;
      default:
        throw new StateError("Wrong sort algorithm type");
    }
    return null;
  }

  State.fromData(List<List> matrix, List<String> rowLabel, List<String> colLabel);

  State._(this.diagramElements);

  Map<int, String> get orderID{
    var printList = new Map<int, String>();
    diagramElements.rootElement.getChildren.forEach((VisualObject value){
      printList[value.label.index] = value.id;
    });
    return printList;
  }

  int compareTo(State o);

  void calculate(){
    numberOfIntersection = 0;
    for (SortConnection conn in listOfConnections) {
      for (SortConnection helperConn in listOfConnections) {
        if(conn == helperConn){continue;}
        if(conn.isConnectionCollide(helperConn)){
          numberOfIntersection++;
        }
      }
    }
    numberOfIntersection = numberOfIntersection ~/ 2;
  }

  int getStatePossNeighbour([VisualObject object]);

  int getValue();

  int numberOfNeighbours([VisualObject object]);

  void chooseNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = false, int startRange = 1, int endRange = -1});

  void changeStateByOrder(dynamic order);

  void clean();

  State copy();

  State clone();

  VisualObject getElementByPlace(int place){
    return order[orderIndexHelper[place]-1];
  }

  void changePositions(int posA, int posB){
    if(posA == posB) return;
    //TODO error check
    //Change elements indices
    getElementByPlace(posA).label.index = posB;
    getElementByPlace(posB).label.index = posA;

    //change the position in indexHelper;
    int helper = orderIndexHelper[posA];
    orderIndexHelper[posA] = orderIndexHelper[posB];
    orderIndexHelper[posB] = helper;
  }

  void updateState(){
    for(SortConnection conn in listOfConnections){
      conn.updateIndex(this);
    }

    this.calculate();
  }

  void setPositionDirectly(int orderIndex, int newPost){
    order[orderIndex].label.index = newPost;
    orderIndexHelper[newPost] = orderIndex;
  }

  String get status;

  List<int> maxConflictNeighbour(){
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
    List<int> returnValue = new List<int>();

    for(SortConnection conn in listOfMaxConn){
      returnValue.add(conn.begin.index);
      returnValue.add(conn.end.index);
    }

    return returnValue;
  }

  int getElementIndexByID(String groupID, [String segmentID = ""]);

  int diffNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = true, int startRange = 1, int endRange = -1});

  int diffNeighbourByOrder(List<dynamic> order);

  String get groupsOrders{
    StringBuffer sb = new StringBuffer();

    for(var i = 1; i <= this.order.length; i++){
      for(VisualObject block in this.order[this.orderIndexHelper[i]].getChildren){
        sb.write("${block.label.name}");
      }
      if(i < this.order.length){
        sb.write(", ");
      }
    }
    return sb.toString();
  }

  @override
  String toString() {
    var sb = new StringBuffer();

    for(int i = 1; i <= order.length; i++){
      sb.write("${order[orderIndexHelper[i]].label.name}");
      if(i < order.length) {
        sb.write(",");
      }
    }
    return 'Order: ${sb.toString()} : ${this.getValue()}';
  }

  // New method

  VisualObject getElementAtIndex(int index, [int segmentIndex = -1]);

  int getElementPositionByIndex(int index, [int segmentIndex = -1]);

  VisualObject getElementByPosition(int position, [int segmentPosition = -1]);

  void setNewPositionForIndex(int index, int newValue, [int segmentIndex = -1]);

  void setNewPositionForID(String groupID, int newValue, [String segmentID = ""]);

  List<String> get orderPos;

  List<int> neighboursValues;

  int numberOfGroupsAndBlocks = 0;

  int numberOfBlocks = 0;

  bool allGroupsOneBlock = true;

  State save();

  State saveTemp(){}

  State finalize();

  State updateFromFinalOrder();

  State updateFromTempOrder(){}

  State finalizeFromTempOrder(){}

  void propagateTempToFinal(){}

  State chooseRandomState({bool setFinalOrder = true, bool enablePreCalculation = false, bool enableHelper = false});

  List<int> maxConflictConnection() => this.maxConflictNeighbour();

  bool chooseNeighbourAndDecideToKeepByFunc(int neighbour, {Function functionToDecide = null, bool enablePreCalculate = true, int startRange = 1, int endRange = -1}) {}

  int chooseNeighbourIntoTemp(int neighbour, {bool enablePreCalculate = false}){}

  void copySavedStateIntoAnother(State other, [bool finalState = false]){}

}