part of dataProcessing;

class DiagramStateMatrix extends State{

  static List<String> listOfAllClonedOrdersIDs = new List<String>();

  final double roundToZero = pow(10, -10);
  final double roundToOne = (1 - pow(10, -10));

  List<int> numbersForOrders;

  double posDoubleConvertValue;

  double maxBlockNumberInGroup;

  @Deprecated("Replaced by ConnectionManager.listOfConnection")
  List<SortConnection> listOfConnections;

  Map<String, List<double>> groupsMatrix;

  Map<String, Map<String, List<double>>> blockMatrix;

  VisualObject groupsContainer;

  List<String> orderGroupTemp = new List<String>();
  Map<String, List<String>> orderBlockTemp = new Map<String, List<String>>();

  Map<String, int> groupsOrderById;
  Map<int, String> groupsOrderIndexHelper;

  Map<String, int> blocksOrderById;
  Map<String, Map<int, String>> blocksOrderIndexHelper;

  Map<String, int> finalOrderGroupsBlocks;

  Map<String, Map<String, int>> orderIndexHelperFinal = new Map<String, Map<String, int>>();

  List<VisConnection> listOfConnectionsGroupBlockIDs;

  int numberOfGroups;

  int finalOrderValue = double.maxFinite.toInt();

  DiagramStateMatrix(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
    listOfConnections = new List<SortConnection>();
    orderGroupTemp = this.diagramElements.rootElement.childrenIDsIterable;
    groupsContainer = this.diagramElements.rootElement;

    //orderIndexHelper = new Map<int, int>();

    this.groupsOrderById = new Map<String, int>();
    this.groupsOrderIndexHelper = new Map<int, String>();

    this.blocksOrderById = new Map<String, int>();
    this.blocksOrderIndexHelper = new Map<String, Map<int, String>>();

    this.finalOrderGroupsBlocks = new Map<String, int>();

    this.numberOfGroups = this.orderGroupTemp.length;
    //this.orderBlockTemp = new Map<String, List<String>>();

    int i = 0;
    maxBlockNumberInGroup = 0.0;
    double sum = 0.0;
    groupsContainer.childrenIterable.forEach((VisualObject actGroup){
      groupsOrderById[orderGroupTemp[i]] = actGroup.label.index;
      groupsOrderIndexHelper[actGroup.label.index] = orderGroupTemp[i];
      finalOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

      //orderBlockTemp[orderGroupTemp[i]] = actGroup.getChildrenIDs();

      sum = 0.0;
      actGroup.childrenIterable.forEach((VisualObject actBlock){
        blocksOrderIndexHelper[actGroup.id] = new Map<int, String>();
        blocksOrderById[actBlock.id] = actBlock.label.index;
        blocksOrderIndexHelper[actGroup.id][actBlock.label.index] = actBlock.id;
        finalOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
        sum+=1.0;
      });
      if(sum > maxBlockNumberInGroup){
        maxBlockNumberInGroup = sum;
      }
      i++;
    });

    this.posDoubleConvertValue = (2*pi) / ((this.numberOfGroups + 1) * (maxBlockNumberInGroup + 1));

    this.numbersForOrders = new List.generate(
        this.numberOfGroups > maxBlockNumberInGroup
            ? this.numberOfGroups
            : maxBlockNumberInGroup, (i)=>i+1);

    this.listOfConnectionsGroupBlockIDs = ConnectionManager.listOfConnection[groupsContainer.id].values.toList(growable: false);

    this.listOfConnectionsGroupBlockIDs.forEach((VisConnection conn){
      conn.sortPositionSegMin = (this.blocksOrderById[conn.segmentOne.segmentId] +
          this.groupsOrderById[conn.segmentOne.groupId] * maxBlockNumberInGroup) * posDoubleConvertValue;
      conn.sortPositionSegMax = (this.blocksOrderById[conn.segmentTwo.segmentId] +
          this.groupsOrderById[conn.segmentTwo.groupId] * maxBlockNumberInGroup) * posDoubleConvertValue;
    });

    this.calculate();
  }

  @Deprecated("The default constructor does the same")
  DiagramStateMatrix.simple(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){

    orderGroupTemp = this.diagramElements.rootElement.getChildrenIDs();
    groupsContainer = this.diagramElements.rootElement;

    //orderIndexHelper = new Map<int, int>();

    this.groupsOrderById = new Map<String, int>();
    this.groupsOrderIndexHelper = new Map<int, String>();

    this.blocksOrderById = new Map<String, int>();
    this.blocksOrderIndexHelper = new Map<String, Map<int, String>>();

    this.finalOrderGroupsBlocks = new Map<String, int>();

    this.numberOfGroups = this.orderGroupTemp.length;
    //this.orderBlockTemp = new Map<String, List<String>>();

    int i = 0;
    maxBlockNumberInGroup = 0.0;
    double sum = 0.0;
    groupsContainer.childrenIterable.forEach((VisualObject actGroup){
      groupsOrderById[orderGroupTemp[i]] = actGroup.label.index;
      groupsOrderIndexHelper[actGroup.label.index] = orderGroupTemp[i];
      finalOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

      //orderBlockTemp[orderGroupTemp[i]] = actGroup.getChildrenIDs();

      sum = 0.0;
      actGroup.childrenIterable.forEach((VisualObject actBlock){
        blocksOrderIndexHelper[actGroup.id] = new Map<int, String>();
        blocksOrderById[actBlock.id] = actBlock.label.index;
        blocksOrderIndexHelper[actGroup.id][actBlock.label.index] = actBlock.id;
        finalOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
        sum+=1.0;
      });
      if(sum > maxBlockNumberInGroup){
        maxBlockNumberInGroup = sum;
      }
      i++;
    });

    this.posDoubleConvertValue = (2*pi) / ((this.numberOfGroups + 1) * (maxBlockNumberInGroup + 1));

    this.numbersForOrders = new List.generate(
        this.numberOfGroups > maxBlockNumberInGroup
            ? this.numberOfGroups
            : maxBlockNumberInGroup, (i)=>i+1);

    this.listOfConnectionsGroupBlockIDs = ConnectionManager.listOfConnection[groupsContainer.id].values.toList(growable: false);

    this.listOfConnectionsGroupBlockIDs.forEach((VisConnection conn){
      conn.sortPositionSegMin = (this.blocksOrderById[conn.segmentOne.segmentId] +
          this.groupsOrderById[conn.segmentOne.groupId] * maxBlockNumberInGroup) * posDoubleConvertValue;
      conn.sortPositionSegMax = (this.blocksOrderById[conn.segmentTwo.segmentId] +
          this.groupsOrderById[conn.segmentTwo.groupId] * maxBlockNumberInGroup) * posDoubleConvertValue;
    });

    this.calculate();

    /*listOfConnections = new List<SortConnection>();
    orderGroupTemp = this.diagramElements.rootElement.getChildrenIDs();
    orderIndexHelper = new Map<int, int>();

    groupsContainer = this.diagramElements.rootElement;

    orderIndexHelperTemp[groupsContainer.id] = new Map<int, int>();
    orderIndexHelperFinal[groupsContainer.id] = new Map<int, int>();

    int i = 0, indexInOrder = 0;
    VisualObject actGroupForID;
    orderGroupTemp.forEach((String groupID){
      actGroupForID = groupsContainer.getChildByID(groupID);
      orderBlockTemp[groupID] = actGroupForID.getChildrenIDs();
      orderIndexHelperTemp[groupsContainer.id][actGroupForID.label.index] = indexInOrder;
      orderIndexHelperFinal[groupsContainer.id][actGroupForID.label.index] = indexInOrder;
      orderIndexHelper[actGroupForID.label.index] = indexInOrder++;

      orderIndexHelperTemp[groupID] = new Map<int, int>();
      orderIndexHelperFinal[groupID] = new Map<int, int>();

      i = 0;
      orderBlockTemp[groupID].forEach((String blockID){
        orderIndexHelperTemp[groupID][i+1] = i;
        orderIndexHelperFinal[groupID][i+1] = i;

        actGroupForID.getChildByID(blockID).label.index = i+1;
      });

    });


    VisualObject elementA, elementB;
    //create connections for the sort based on the segment not the groups
    for (int i = 0; i < orderGroupTemp.length; i++) {
      for (int j = 0; j < orderBlockTemp[orderGroupTemp[i]].length; j++) {

        for (int k = i; k < orderGroupTemp.length; k++) {
          for (int l = j; l < orderBlockTemp[orderGroupTemp[k]].length; l++) {

            elementA = groupsContainer.getChildByID(orderGroupTemp[i]).getChildByID(orderBlockTemp[orderGroupTemp[i]][j]);
            elementB = groupsContainer.getChildByID(orderGroupTemp[k]).getChildByID(orderBlockTemp[orderGroupTemp[k]][l]);
            if (diagramElements.isConnected(elementA, elementB)) {
              var possNewConn = new SortConnection(elementA.label, elementB.label, elementA.parent.label, elementB.parent.label);
              if(!listOfConnections.contains(possNewConn)){
                listOfConnections.add(possNewConn);
              }
            }

          }
        }
      }
    }

    this.calculate();*/


    /*listOfConnections = new List<SortConnection>();
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

    this.calculate();*/
  }

  DiagramStateMatrix.simpleCopy(State object){
    diagramElements = object.diagramElements;
    listOfConnections = new List<SortConnection>();
    orderIndexHelper = new Map<int, int>.from(object.orderIndexHelper);

    orderGroupTemp = this.diagramElements.rootElement.getChildrenIDs();
    groupsContainer = this.diagramElements.rootElement;

    this.groupsOrderById = new Map<String, int>();
    this.groupsOrderIndexHelper = new Map<int, String>();

    this.blocksOrderById = new Map<String, int>();
    this.blocksOrderIndexHelper = new Map<String, Map<int, String>>();

    this.finalOrderGroupsBlocks = new Map<String, int>();

    (object as DiagramStateMatrix).groupsOrderById.forEach((String key, int value){
      this.groupsOrderById[key] = value;
    });

    (object as DiagramStateMatrix).groupsOrderIndexHelper.forEach((int key, String value){
      this.groupsOrderIndexHelper[key] = value;
    });

    (object as DiagramStateMatrix).blocksOrderById.forEach((String key, int value){
      this.blocksOrderById[key] = value;
    });

    (object as DiagramStateMatrix).blocksOrderIndexHelper.forEach((String key, Map<int, String> value){
      blocksOrderIndexHelper[key] = new Map<int, String>();
      value.forEach((int index, String id){
        this.blocksOrderIndexHelper[key][index] = id;
      });
    });

    (object as DiagramStateMatrix).finalOrderGroupsBlocks.forEach((String key, int value){
      this.finalOrderGroupsBlocks[key] = value;
    });


    this.orderBlockTemp = new Map<String, List<String>>();
    (object as DiagramStateMatrix).orderBlockTemp.forEach((String key, List<String> value){
      this.orderBlockTemp[key] = new List.from(value);
    });

    this.numberOfIntersection = object.getValue();
    //this.calculate();
  }

  String getGroupIdFromBlockID(String blockID){
    return blockID.split('_').first;
  }

  VisualObject getElementByPlace(int place){
    return groupsContainer.getChildByID(orderGroupTemp[orderIndexHelper[place]]);
  }

  int compareTo(State o) {
    return this.numberOfIntersection - o.numberOfIntersection;
  }


 int calculate(){
    this.numberOfIntersection = 0;

    // csak a connection-be kell beállítani az új értéket, és ha permanent akkor pedig magában a block és groupID map-ben is

    // a szomszédok az egyes elemenk
    // minden elemnél kiszámoljuk, az össze lehetséges helyet ahova kerülhet.
    // ez egy listát ad, ami azt is megmondja, hogy mennyire jó helyeket tartalmaz a szomszéd

    // marad minden a régiben és csak a blockok-hoz számolok pluszba
    // tehát a blokkok elrendezése adja a plusz infót

    var segmentOne, segmentTwo;
    this.listOfConnectionsGroupBlockIDs.forEach((VisConnection conn){
      segmentOne = (this.blocksOrderById[conn.segmentOne.segmentId] +
          this.groupsOrderById[conn.segmentOne.groupId] * maxBlockNumberInGroup) * posDoubleConvertValue;
      segmentTwo = (this.blocksOrderById[conn.segmentTwo.segmentId] +
          this.groupsOrderById[conn.segmentTwo.groupId] * maxBlockNumberInGroup) * posDoubleConvertValue;
      conn.sortPositionSegMin = min(segmentOne, segmentTwo);
      conn.sortPositionSegMax = max(segmentOne, segmentTwo);
    });

    for (int i = 0; i < listOfConnectionsGroupBlockIDs.length-1; i++) {
      for (int j = i + 1; j < listOfConnectionsGroupBlockIDs.length; j++) {
        this.numberOfIntersection += this.intersectionTest(
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMax,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMax
        );
        /*var test1 = this.intersectionTest(
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMax,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMax
        );

        var test2 = this.intersectionTestOld(
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[i].sortPositionSegMax,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMin,
            listOfConnectionsGroupBlockIDs[j].sortPositionSegMax
        );

        if(test1 != test2){
          this.intersectionTest(
              listOfConnectionsGroupBlockIDs[i].sortPositionSegMin,
              listOfConnectionsGroupBlockIDs[i].sortPositionSegMax,
              listOfConnectionsGroupBlockIDs[j].sortPositionSegMin,
              listOfConnectionsGroupBlockIDs[j].sortPositionSegMax
          );
        }

        this.numberOfIntersection += test2;*/
      }
    }

    return this.numberOfIntersection;
  }

  int getValue() {
    return numberOfIntersection;
  }

  int numberOfNeighbours([VisualObject object]) {
    var sumOfNeighbours = 0;
    this.orderGroupTemp.forEach((String groupID){
      var m = groupsContainer.getChildByID(groupID).numberOfChildren;
      var partialValue = 0;
      if(m == 1){
        partialValue = (this.numberOfGroups-1);
      }else{
        partialValue = (this.numberOfGroups-1) * m * (m - 1);
      }

      sumOfNeighbours += partialValue;
    });
    return sumOfNeighbours;
  }

  @override
  VisualObject getElementAtIndex(int groupIndex, [int blockIndex = -1]) {
    if(blockIndex < 0){
      return groupsContainer.getChildByIDs(groupsOrderIndexHelper[groupIndex]);
    }else{
      return groupsContainer.getChildByIDs(
          groupsOrderIndexHelper[groupIndex],
          1,
          blocksOrderIndexHelper[groupsOrderIndexHelper[groupIndex]][blockIndex]);
      /*String blockID = blocksOrderById.keys
          .where((String key)=>key.contains(groupsOrderIndexHelper[groupIndex]))
            .firstWhere((String element)=>blocksOrderIndexHelper[blockIndex] == element);
      return groupsContainer.getChildByIDs(
          groupsOrderIndexHelper[groupIndex],
          1, blockID);*/
    }
  }

  VisualObject getGroupAtIndex(int index){
    return groupsContainer.getChildByIDs(groupsOrderIndexHelper[index]);
  }

  VisualObject getBlockAtIndex(int groupIndex, int blockIndex){
    return groupsContainer.getChildByIDs(
        groupsOrderIndexHelper[groupIndex],
        1,
        blocksOrderIndexHelper[groupsOrderIndexHelper[groupIndex]][blockIndex]);
      /*String groupId = this.orderGroupTemp[orderIndexHelperTemp[groupsContainer.id][groupIndex]];
      String segmentId = this.orderBlockTemp[groupId][orderIndexHelperTemp[groupId][blockIndex]];
      return groupsContainer.getChildByIDs(groupId, 1, segmentId);*/
  }

  int getElementPositionByIndex(int groupIndex, [int blockIndex = -1]){
    if(blockIndex < 0){
      return this.orderGroupTemp.indexOf(this.groupsOrderIndexHelper[groupIndex]);
    }else{
      return this.orderBlockTemp[this.groupsOrderIndexHelper[groupIndex]].indexOf(
          this.blocksOrderIndexHelper[this.groupsOrderIndexHelper[groupIndex]][blockIndex]
      );
    }
  }

  VisualObject getElementByPosition(int position, [int segmentPosition = -1]){
    if(segmentPosition < 0){
      return this.diagramElements.rootElement.getChildByID(this.orderGroupTemp[position]);
    }else{
      return groupsContainer.getChildByIDs(this.orderGroupTemp[position], 1, this.orderBlockTemp[this.orderGroupTemp[position]][segmentPosition]);
    }
  }

  void setNewPositionForIndex(int index, int newValue, [int segmentIndex = -1]){
    if(segmentIndex < 0){
      String groupId = this.groupsOrderIndexHelper[index];

      this.blocksOrderById[this.blocksOrderIndexHelper[groupId][segmentIndex]] = newValue;
      this.blocksOrderIndexHelper[groupId][newValue] = this.blocksOrderIndexHelper[groupId][segmentIndex];
    }else{
      this.groupsOrderById[this.groupsOrderIndexHelper[index]] = newValue;
      this.groupsOrderIndexHelper[newValue] = this.groupsOrderIndexHelper[index];
    }
  }

  void setNewPositionForID(String groupID, int newValue, [String segmentID = ""]){
    if(segmentID.isEmpty){
      this.groupsOrderById[groupID] = newValue;
      this.groupsOrderIndexHelper[newValue] = groupID;
    }else{
      this.blocksOrderById[segmentID] = newValue;
      this.blocksOrderIndexHelper[groupID][newValue] = segmentID;
    }
  }

  int getElementIndexByID(String groupID, [String segmentID = ""]){

    if(segmentID.isEmpty){
      return this.groupsOrderById[groupID];
    }else{
      return this.blocksOrderById[segmentID];
    }

  }

  int chooseNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = false, int startRange = 1, int endRange = -1}){
    int index = 1;
    int remainder = neighbour;
    int m = getElementAtIndex(index).numberOfChildren;
    var possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    while(remainder > (this.numberOfGroups-1) * possibleSegmentsVariations){
      remainder -= (this.numberOfGroups-1) * possibleSegmentsVariations;
      index++;
      m = getElementAtIndex(index).numberOfChildren;
      possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    }

    int groupToMove = index;
    int moveBy = remainder ~/ (m) + 1;
    int groupFinalPosition = groupToMove + moveBy;
    if(groupFinalPosition > this.numberOfGroups){
      groupFinalPosition -= (this.numberOfGroups);
    }

    String previousGroupIdAtNewPos = this.groupsOrderIndexHelper[groupFinalPosition];
    String groupToMoveID = this.groupsOrderIndexHelper[groupToMove];
    int movingGroupPreviousPos = this.groupsOrderById[groupToMoveID];

    setNewPositionForID(groupToMoveID, groupFinalPosition);
    setNewPositionForID(previousGroupIdAtNewPos, movingGroupPreviousPos);


    String previousBlockIdAtNewPos, blockToMoveID;
    int movingBlockPreviousPos, blockFinalPosition;
    if(m != 1){
      int insideGroup = moveBy % m;
      int blockToMove = insideGroup ~/ (m-1);
      int moveBlockBy = insideGroup % (m-1);

      blockFinalPosition = blockToMove + moveBlockBy;
      if(blockFinalPosition > m){
        blockFinalPosition -= m;
      }

      previousBlockIdAtNewPos = this.blocksOrderIndexHelper[groupToMoveID][blockFinalPosition];
      blockToMoveID = this.blocksOrderIndexHelper[groupToMoveID][blockToMove];
      movingBlockPreviousPos = this.groupsOrderById[blockToMoveID];

      setNewPositionForID(groupToMoveID, blockFinalPosition, blockToMoveID);
      setNewPositionForID(groupToMoveID, movingBlockPreviousPos, previousBlockIdAtNewPos);
    }

    var retVal;
    if(isPermanent){

      this.calculate();
      retVal = this.numberOfIntersection;
      this.finalOrderValue = this.numberOfIntersection;


    }else{
      var valueBefore = this.numberOfIntersection;
      this.calculate();
      retVal = this.numberOfIntersection;
      this.numberOfIntersection = valueBefore;

      setNewPositionForID(groupToMoveID, movingGroupPreviousPos);
      setNewPositionForID(previousGroupIdAtNewPos, groupFinalPosition);

      if(m != 1){
        setNewPositionForID(groupToMoveID, blockFinalPosition, previousBlockIdAtNewPos);
        setNewPositionForID(groupToMoveID, movingBlockPreviousPos, blockToMoveID);
      }

    }

    return retVal;
  }

  void chooseNeighbour3(int neighbour, [bool isPermanent = false]) {
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


    //this.copy();

    int index = 1;
    int remainder = neighbour;
    int m = getElementAtIndex(index).numberOfChildren;
    var possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    while(remainder > (this.orderGroupTemp.length-1) * possibleSegmentsVariations){
      remainder -= (this.orderGroupTemp.length-1) * possibleSegmentsVariations;
      index++;
      m = getElementAtIndex(index).numberOfChildren;
      possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
    }

    int indexToMove = index;
    int groupToMove = getElementPositionByIndex(indexToMove);
    VisualObject groupObjToMove = getElementAtIndex(indexToMove);
    int possibleNeighboursOfTheGroup = this.getStatePossNeighbour(groupObjToMove);
    int groupInsideNeighbours = (possibleNeighboursOfTheGroup ~/ (this.orderGroupTemp.length - 1));
    int oneSegmentPossPositionsNumber = (groupInsideNeighbours ~/ (groupObjToMove.numberOfChildren));
    int remainingMovement = remainder;
    int groupMovement = (remainingMovement / groupInsideNeighbours).ceil();
    int segmentRemainingMovement = remainingMovement % groupInsideNeighbours;
    int segmentToMove = segmentRemainingMovement == 0 ? 1 : (segmentRemainingMovement /  oneSegmentPossPositionsNumber).ceil();
    int segmentMovement = segmentRemainingMovement == 0 ? 0 : segmentRemainingMovement %  segmentToMove;

    int groupNewPosition = indexToMove + groupMovement;
    int segmentNewPosition = segmentToMove + segmentMovement;

    if(groupNewPosition > this.orderGroupTemp.length){
      groupNewPosition -= (this.orderGroupTemp.length);
    }

    if(segmentNewPosition > groupObjToMove.numberOfChildren){
      segmentNewPosition -= (groupObjToMove.numberOfChildren);
    }

    int positionMoveValue = (neighbour - 1)%(this.orderGroupTemp.length-1)+1;
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
      /*this.orderIndexHelperTemp.forEach((String key, Map<int, int> indexList){
        indexList.forEach((int index, int position){
          //this.orderIndexHelperFinal[key][index] = position;
        });
      });*/
      this.finalOrderValue = this.getValue();
    } else {

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
    for(var i = 1; i <= orderGroupTemp.length; i++){
      var element = getElementAtIndex(i);
      sb.write("{${element.label.name}: ");
      var firstOne = true;
      for(var j = 1; j <= orderBlockTemp[element.id].length; j++){
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
      return (this.numberOfGroups - 1);
    }else{
      var m = object.numberOfChildren;
      var possibleSegmentsVariations = m == 1 ? 1 : (m * (m-1));
      return (this.numberOfGroups-1) * possibleSegmentsVariations;
    }
  }

  void clean() {
    diagramElements.clean();
    listOfConnections = new List<SortConnection>();
  }


  State save(){

    this.groupsOrderById.forEach((String id, int index){
      this.finalOrderGroupsBlocks[id] = index;
    });

    this.blocksOrderById.forEach((String id, int index){
      this.finalOrderGroupsBlocks[id] = index;
    });

    this.finalOrderValue = this.getValue();
    return this;
  }

  State copy() {

    this.orderIndexHelperFinal[groupsContainer.label.id] = new Map<String, int>();
    this.groupsOrderById.forEach((String id, int index){
      this.orderIndexHelperFinal[groupsContainer.label.id][id] = index;
      this.orderIndexHelperFinal[id] = new Map<String, int>();
    });

    this.blocksOrderById.forEach((String id, int index){
      this.orderIndexHelperFinal[id.split('_').first][id] = index;
    });

    return this;
  }

  State copyBack(){

    this.orderIndexHelperFinal.forEach((String key, Map<String, int> value){
      if(key == groupsContainer.id){
        value.forEach((String groupID, int index){
          this.groupsOrderById[groupID] = index;
          this.groupsOrderIndexHelper[index] = groupID;
        });
      }else{
        value.forEach((String blockID, int index){
          this.blocksOrderById[blockID] = index;
          this.blocksOrderIndexHelper[key][index] = blockID;
        });
      }
    });

    this.calculate();

    return this;
  }

  State clone(){
    return new DiagramStateFullWithoutCopy.simpleCopy(this);
  }

  State finalize(){

    this.finalOrderGroupsBlocks.forEach((String id, int index){
      if(id.contains("_")){
        groupsContainer.getChildByIDs(id.split('_').first, 1, id).label.index = index;
      }else{
        groupsContainer.getChildByIDs(id).label.index = index;
      }
    });

    /*this.orderIndexHelperFinal.forEach((String key, Map<int, int> indexList){
        for (var index = 1; index <= indexList.length; index++) {
          if(this.diagramElements.rootElement.id == key){
            visObject = this.diagramElements.rootElement.getChildByID(this.orderGroupTemp[this
                .orderIndexHelperFinal[key][index]]);
          }else {
            visObject = this.diagramElements.rootElement.getChildByID(key)
                .getChildByID(this.orderBlockTemp[key][this
                .orderIndexHelperFinal[key][index]]);
          }
          visObject.label.index = index;
        }

    });*/

    return this;
  }

  int diffNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = false, int startRange = 1, int endRange = -1}){
    int newValue = this.chooseNeighbour(neighbour);
    return newValue - this.finalOrderValue;
  }

  State updateFromFinalOrder(){

    this.finalOrderGroupsBlocks.forEach((String key, int value){
      if(key.contains('_')){
        this.blocksOrderById[key] = value;
        this.blocksOrderIndexHelper[key.split('_').first][value] = key;
      }else{
        this.groupsOrderById[key] = value;
        this.groupsOrderIndexHelper[value] = key;
      }
    });

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


  State chooseRandomState({bool setFinalOrder = true, bool enablePreCalculation = false, bool enableHelper = false}){

    List<int> temporaryOrder = this.numbersForOrders.getRange(
        0, this.numberOfGroups).toList(growable: false)
          ..shuffle(new Random(new DateTime.now().millisecondsSinceEpoch));
    List<int> temporaryOrder2;

    int i = 0, j = 0;
    this.groupsContainer.childrenIterable.forEach((VisualObject group){

      this.groupsOrderById[group.label.id] = temporaryOrder[i];
      this.groupsOrderIndexHelper[temporaryOrder[i]] = group.label.id;

      temporaryOrder2 = numbersForOrders.getRange(
          0, group.numberOfChildren).toList(growable: false)
        ..shuffle(new Random(new DateTime.now().millisecondsSinceEpoch));

      j = 0;
      group.childrenIDsIterable.forEach((String blockID){
        this.blocksOrderById[blockID] = temporaryOrder2[j];
        this.blocksOrderIndexHelper[group.label.id][temporaryOrder2[j]] = blockID;
        j++;
      });

      i++;

    });

    this.calculate();

    this.finalOrderValue = this.getValue();

    /*this.orderIndexHelperFinal.forEach((String key, Map<int, int> indexList){

      if(this.diagramElements.rootElement.id == key){
        var helperIndexList = new List.generate(
            this.orderGroupTemp.length, (int index) {
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
            this.orderBlockTemp[key].length, (int index) {
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

    this.orderIndexHelperTemp.forEach((String key, Map<int, int> indexList){
      indexList.forEach((int index, int position){
        this.orderIndexHelperFinal[key][index] = position;
      });
    });

    this.finalOrderValue = this.getValue();*/

    return this;
  }

  @override
  void changeStateByOrder(dynamic newOrder) {

    Map<String, Map<String, int>> mapOfNewOrder = (newOrder as Map<String, Map<String, int>>);

    mapOfNewOrder.forEach((String key, Map<String, int> value){
      if(key == groupsContainer.id){
        value.forEach((String groupID, int index){
          this.groupsOrderById[groupID] = index;
          this.groupsOrderIndexHelper[index] = groupID;
        });
      }else{
        value.forEach((String blockID, int index){
          this.blocksOrderById[blockID] = index;
          this.blocksOrderIndexHelper[key][index] = blockID;
        });
      }
    });

    this.calculate();

    /*for(var i = 0; i < newOrder.length; i++) {
      var indexToMove = getElementIndexByID(newOrder[i].id);
      var newPosition = newOrder[i].label.index;

      if(indexToMove == newPosition) continue;

      if(newPosition > this.orderGroupTemp.length){
        newPosition -= (this.orderGroupTemp.length);
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

    this.calculate();*/
  }

  @override
  void setPositionDirectly(int orderIndex, int newPost) {
    setNewPositionForIndex(orderIndex, newPost);
  }

  void changeStateWithNewOrderList(List<Map<int, int>> newOrder) {
    newOrder[0].forEach((int key, int value){
      setNewPositionForIndex(key, value);
    });

    for(var i = 1; i <= orderGroupTemp.length; i++){
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

  double convertPosToRad(int a){
    return a * 0.0001;
  }

  double lengthAB, lengthCD;
  double distAB, distCD, halfDistAB, halfDistCD;
  double midAB, midCD, distOfMidPoints, diffOfConnLength;
  bool normAB, normCD;

  // b must be bigger than a
  // d must be bigger than c
  int intersectionTest(double a, double b, double c, double d){
    if(a == c || a == d || b == c || b == d){
      return 0;
    }
    this.lengthAB = (1 - (1 - ((b - a) / pi).abs()).abs()) * pi;
    this.halfDistAB = this.lengthAB / 2;
    this.midAB = b - (1 - (b-a) / pi).sign * this.halfDistAB;
    this.lengthCD = (1 - (1 - ((d - c) / pi).abs()).abs()) * pi;
    this.halfDistCD = this.lengthCD / 2;
    this.midCD = d - (1 - (d-c) / pi).sign * this.halfDistCD;

    this.diffOfConnLength = (this.halfDistAB - this.halfDistCD) * (this.halfDistAB - this.halfDistCD);
    this.distOfMidPoints = (1 - (1 - ((this.midAB - this.midCD) / pi).abs()).abs()) * pi;

    var finalValue = (((this.distOfMidPoints * this.distOfMidPoints) - this.diffOfConnLength)
          / ((this.halfDistAB + this.halfDistCD)*(this.halfDistAB + this.halfDistCD) - this.diffOfConnLength));
    return finalValue > roundToZero && finalValue < roundToOne ? 1 : 0;
  }

/*// b must be bigger than a
  double midPoint(double a, double b) {
    return b - (1 - (b-a) / pi).sign * lengthAB / 2;
  }
// b must be bigger than a
  double dist(double a, double b) {
    return (1 - (1 - ((b - a) / pi).abs()).abs()) * pi;
  }*/

  int intersectionTestOld(double a, double b, double c, double d){
    return 1 + (-1 - overlapOfTwoRange(a, b, c, d)/2
    ).sign.toInt();
  }

  double overlapOfTwoRange(double a, double b, double c, double d) {
    return  ( pointInsideGivenRange(a, b, c) *  pointInsideGivenRange(a, b, d)).sign
        + ( pointInsideGivenRange(c, d, a) *  pointInsideGivenRange(c, d, b)).sign;
  }

  double pointInsideGivenRange(double a, double b, double c)  {
    var value =  dist( midPoint(a, b), c) -  dist(a, b)/2;
    return value < roundToZero && value > -roundToZero ? 0.0 : value;
  }

  double midPoint(double a, double b) {
    return (a-b).abs() > pi ? normValue((a+b)/2 + pi) : normValue((a+b)/2);
  }

  double normValue(double a) {
    return a - (a / (2*pi)).floor() * (2*pi);
  }

  double dist(double a, double b) {
    return (a-b).abs() > pi ? (2*pi) - (a-b).abs() : (a-b).abs();
  }

  @override
  int diffNeighbourByOrder(dynamic order) {
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