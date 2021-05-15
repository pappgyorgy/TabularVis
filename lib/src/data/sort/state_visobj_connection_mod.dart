part of dataProcessing;

// csak a connection-be kell beállítani az új értéket, és ha permanent akkor pedig magában a block és groupID map-ben is

// a szomszédok az egyes elemenk
// minden elemnél kiszámoljuk, az össze lehetséges helyet ahova kerülhet.
// ez egy listát ad, ami azt is megmondja, hogy mennyire jó helyeket tartalmaz a szomszéd

// marad minden a régiben és csak a blockok-hoz számolok pluszba
// tehát a blokkok elrendezése adja a plusz infót

class StateVisObjConnectionMod extends State{

  static List<String> listOfAllClonedOrdersIDs = new List<String>();

  @Deprecated("Replaced by shuffling IDs of groups and blocks")
  List<int> numbersForOrders;

  double posDoubleConvertValue;

  int maxBlockNumberInGroup;

  @Deprecated("Replaced by ConnectionManager.listOfConnection")
  List<SortConnection> listOfConnections;

  List<int> neighboursValues;

  VisualObject groupsContainer;

  //Used for generating random states
  List<String> groupsIDs = new List<String>();
  Map<String, List<String>> blockIDsOrderByGroup = new Map<String, List<String>>();

  Map<String, int> finalOrderGroupsBlocks;
  Map<String, int> tempOrderGroupsBlocks;

  Map<String, VisConnection> listOfVisConnectionsMap;
  List<VisConnection> listOfVisConnections;
  List<int> listOfConnectionsIntersection;

  int numberOfGroups;

  int finalOrderValue = double.maxFinite.toInt();
  int numberOfIntersection = double.maxFinite.toInt();

  int _numberOfNeighbour = 0;

  double _convertOrderToRadian = 0.0;

  List<int> groupChildrenNumber;
  List<List<int>> groupToMoveAndWhereToMove;
  List<List<int>> blockToMoveAndWhereToMove;

  int _bestNeighbourIndex = -1;

  List<String> nameOfConnections;

  StateVisObjConnectionMod(SortDataSearchAlgorithm diagramElements) : super._(diagramElements){
    groupsIDs = this.diagramElements.rootElement.childrenIDsIterable.toList(growable: false);
    groupChildrenNumber = new List<int>(this.groupsIDs.length + 1);
    groupsContainer = this.diagramElements.rootElement;

    /*this.listOfVisConnections = new List<VisConnection>(ConnectionManager.listOfConnection[this.groupsContainer.id].length);
    var nameOfConnections = ConnectionManager.listOfConnection[this.groupsContainer.id].keys.toList(growable: false);
    for(var i = 0; i < listOfVisConnections.length; i++){
      this.listOfVisConnections[i] = ConnectionManager.listOfConnection[this.groupsContainer.id][nameOfConnections[i]];
    };*/

    //this.nameOfConnections = ConnectionManager.listOfConnection[this.groupsContainer.id].keys.toList(growable: false);
    //this.listOfVisConnectionsMap = ConnectionManager.listOfConnection[this.groupsContainer.id];
    this.listOfVisConnections = ConnectionManager.listOfConnection[this.groupsContainer.id].values.toList(growable: false);

    //Set the initial final id;
    //precalculate the number of neighbours

    this.finalOrderGroupsBlocks = new Map<String, int>();
    this.tempOrderGroupsBlocks = new Map<String, int>();
    this.numberOfGroups = this.groupsIDs.length;

    /*var mapTest = new Map<String, int>();
    this.listOfVisConnections = new Map<String, VisConnection>();*/

    int i = 0;
    maxBlockNumberInGroup = 0;
    int sum = 0;
    var numberOfBlockInGroup = 0;
    var numberOfGroupMinusOne = this.numberOfGroups-1;
    this.groupsContainer.performFunctionOnChildren((String groupKey, VisualObject actGroup){
      finalOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;
      tempOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

      groupChildrenNumber[i+1] = actGroup.numberOfChildren;

      if(actGroup.numberOfChildren > 1){
        this.allGroupsOneBlock = false;
      }

      this.blockIDsOrderByGroup[actGroup.id] = actGroup.getChildrenIDs();

      this.numberOfGroupsAndBlocks++;

      sum = 0;
      actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock){
        finalOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
        tempOrderGroupsBlocks[actBlock.id] = actBlock.label.index;

        /*actBlock.performFunctionOnChildren((String barKey, VisualObject actBar){
          if(!mapTest.containsKey(actBar.connection.nameOfConn)){
           this.listOfVisConnections.add(actBar.connection);
           mapTest[actBar.connection.nameOfConn] = 1;
          }
        });*/

        this.numberOfGroupsAndBlocks++;
        this.numberOfBlocks++;
        sum++;
      });
      if(sum > maxBlockNumberInGroup){
        maxBlockNumberInGroup = sum;
      }

      this.listOfConnectionsIntersection = new List<int>.generate(this.listOfVisConnections.length, (_)=>0);

      numberOfBlockInGroup = actGroup.numberOfChildren;
      i++;
    });

    this._numberOfNeighbour = this.numberOfGroups * (this.numberOfGroups - 1);

    this.neighboursValues = new List<int>(this._numberOfNeighbour + 1);

    this.posDoubleConvertValue = (MathFunc.PITwice) / ((this.numberOfGroups + 1) * (maxBlockNumberInGroup + 1));

    this._convertOrderToRadian = maxBlockNumberInGroup * posDoubleConvertValue;

    this.groupToMoveAndWhereToMove = new List<List<int>>.generate(this._numberOfNeighbour+1, (int i)=>new List<int>(3));
    this.blockToMoveAndWhereToMove = new List<List<int>>.generate(this._numberOfNeighbour+1, (int i)=>new List<int>(3));

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.setupNeighbourHelpers();

    this.preCalculateNeighboursValue();

    this.calculate();

    this.finalOrderValue = this.numberOfIntersection;
  }

  void setupNeighbourHelpers([int startRange = 1, int endRange = -1]){
    int i = 1;
    this.groupsContainer.performFunctionOnChildren((String groupKey, VisualObject actGroup){
      groupChildrenNumber[i++] = actGroup.numberOfChildren;
    });

    endRange = endRange < 2 ? this._numberOfNeighbour : endRange;
    int index = 1;
    var possibleSegmentsVariations = 0, helperValue = 0;
    int remainder = 0;
    for(int neighbour = startRange; neighbour < endRange; neighbour++){
      /*index = 1;
      int remainder = neighbour;
      int m = this.groupChildrenNumber[index];
      if(this.allGroupsOneBlock){
        index = remainder ~/ (this.numberOfGroups - 1) + 1;
        remainder = remainder % (this.numberOfGroups - 1);
      }else {
        possibleSegmentsVariations = max((m * (m - 1)), 1);
        helperValue = (this.numberOfGroups - 1) * possibleSegmentsVariations;
        while (remainder >= helperValue) {
          remainder -= helperValue;
          index++;
          m = this.groupChildrenNumber[index];
          possibleSegmentsVariations = max((m * (m - 1)), 1);
          helperValue = (this.numberOfGroups - 1) * possibleSegmentsVariations;
        }
      }*/


      index = neighbour ~/ (this.numberOfGroups - 1) + 1;
      remainder = neighbour % (this.numberOfGroups - 1);

      this.groupToMoveAndWhereToMove[neighbour][0] = index;
      this.groupToMoveAndWhereToMove[neighbour][2] = remainder + 1;
      this.groupToMoveAndWhereToMove[neighbour][1] = index + this.groupToMoveAndWhereToMove[neighbour][2];
      if(this.groupToMoveAndWhereToMove[neighbour][1] > this.numberOfGroups){
        this.groupToMoveAndWhereToMove[neighbour][1] -= (this.numberOfGroups);
      }
    }
  }

  StateVisObjConnectionMod.simpleCopy(State object){
    this.diagramElements = object.diagramElements.copy();

    groupsIDs = this.diagramElements.rootElement.childrenIDsIterable.toList(growable: false);
    //groupChildrenNumber = new List<int>(this.groupsIDs.length + 1);
    groupsContainer = this.diagramElements.rootElement;

    this.listOfVisConnections = ConnectionManager.listOfConnection[this.groupsContainer.id].values.toList(growable: false);

    this.finalOrderGroupsBlocks = new Map<String, int>();
    this.tempOrderGroupsBlocks = new Map<String, int>();
    this.numberOfGroups = this.groupsIDs.length;

    int i = 0;
    maxBlockNumberInGroup = 0;
    int sum = 0;
    this.groupsContainer.performFunctionOnChildren((String groupKey, VisualObject actGroup){
      finalOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;
      tempOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

      //groupChildrenNumber[i+1] = actGroup.numberOfChildren;

      this.blockIDsOrderByGroup[actGroup.id] = actGroup.getChildrenIDs();

      actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock){
        finalOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
        tempOrderGroupsBlocks[actBlock.id] = actBlock.label.index;

      });

      this.listOfConnectionsIntersection = new List<int>.generate(this.listOfVisConnections.length, (_)=>0);

      i++;
    });

    this.allGroupsOneBlock = (object as StateVisObjConnectionMod).allGroupsOneBlock;

    this.maxBlockNumberInGroup = (object as StateVisObjConnectionMod).maxBlockNumberInGroup;

    this._numberOfNeighbour = (object as StateVisObjConnectionMod)._numberOfNeighbour;

    //this.neighboursValues = new List<int>(this._numberOfNeighbour + 1);

    this.posDoubleConvertValue = (object as StateVisObjConnectionMod).posDoubleConvertValue;

    this._convertOrderToRadian = (object as StateVisObjConnectionMod)._convertOrderToRadian;

    this.groupToMoveAndWhereToMove = new List<List<int>>.generate(this._numberOfNeighbour+1, (int i)=>new List<int>(3));

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.groupChildrenNumber = (object as StateVisObjConnectionMod).groupChildrenNumber.toList(growable: false);

    for(int neighbour = 1; neighbour < this._numberOfNeighbour; neighbour++) {
      this.groupToMoveAndWhereToMove[neighbour][0] = (object as StateVisObjConnectionMod).groupToMoveAndWhereToMove[neighbour][0];
      this.groupToMoveAndWhereToMove[neighbour][1] = (object as StateVisObjConnectionMod).groupToMoveAndWhereToMove[neighbour][1];
      this.groupToMoveAndWhereToMove[neighbour][2] = (object as StateVisObjConnectionMod).groupToMoveAndWhereToMove[neighbour][2];
    }

    this.neighboursValues = (object as StateVisObjConnectionMod).neighboursValues.toList(growable: false);

    this.finalOrderValue = (object as StateVisObjConnectionMod).finalOrderValue;
    this.numberOfIntersection = (object as StateVisObjConnectionMod).numberOfIntersection;

    this.listOfConnectionsIntersection = (object as StateVisObjConnectionMod).listOfConnectionsIntersection.toList(growable: false);
  }

  String getGroupIdFromBlockID(String blockID){
    return blockID.split('_').first;
  }

  VisualObject getElementByPlace(int place){
    return groupsContainer.getChildByID(groupsIDs[orderIndexHelper[place]]);
  }

  int compareTo(State o) {
    return this.numberOfIntersection - o.numberOfIntersection;
  }

  void preCalculateNeighboursValue([int startRange = 1, int endRange = -1]){
    endRange = endRange < 2 ? this._numberOfNeighbour : endRange;
    this._bestNeighbourIndex = -1;
    int numberOfIntersectionHelper = this.numberOfIntersection;
    int min = this.numberOfIntersection;
    int groupToMoveIndex = 1, groupFinalPosition = 0, moveBy = 0, m = 0, blockFinalPosition = 0;
    VisualObject groupToMove, groupAtNewPos;
    String previousBlockIdAtNewPos, blockToMove;
    for(int neighbour = startRange; neighbour < endRange; neighbour++){
      groupToMoveIndex = this.groupToMoveAndWhereToMove[neighbour][0];
      groupFinalPosition = this.groupToMoveAndWhereToMove[neighbour][1];
      moveBy = this.groupToMoveAndWhereToMove[neighbour][2];

      groupAtNewPos = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupFinalPosition]);
      groupToMove = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupToMoveIndex]);

      this.groupsContainer.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

      m = groupToMove.numberOfChildren;

      if(m != 1){

        if(!groupToMove.preserveOriginalOrder){

          int bestLocalNeighbour = double.maxFinite.toInt();
          int bestLocalNeighbourIndex = -1;
          int actLocalValue = 0;
          int blockToMoveIndex, moveBlockBy;
          for(var i = 0; i < m * (m-1); i++){
            blockToMoveIndex = i ~/ (this.numberOfGroups - 1) + 1;
            moveBlockBy = i % (this.numberOfGroups - 1);

            blockFinalPosition = blockToMoveIndex + moveBlockBy;
            if(blockFinalPosition > m){
              blockFinalPosition -= m;
            }

            previousBlockIdAtNewPos = groupToMove.childrenIDsInOrder[blockFinalPosition];
            blockToMove = groupToMove.childrenIDsInOrder[blockToMoveIndex];

            groupToMove.swapChildrenIndexValues(previousBlockIdAtNewPos, blockToMove);

            groupToMove.getChildByIDs(previousBlockIdAtNewPos).performFunctionOnChildren((String key, VisualObject bars){
              bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
              //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
            });

            groupToMove.getChildByIDs(blockToMove).performFunctionOnChildren((String key, VisualObject bars){
              bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
              //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
            });

            actLocalValue = this.calculate();

            if(actLocalValue < bestLocalNeighbour){
              bestLocalNeighbour = actLocalValue;

              this.blockToMoveAndWhereToMove[neighbour][0] = blockToMoveIndex;
              this.blockToMoveAndWhereToMove[neighbour][1] = moveBlockBy;
              this.blockToMoveAndWhereToMove[neighbour][2] = blockFinalPosition;
            }

            groupToMove.swapChildrenIndexValues(previousBlockIdAtNewPos, blockToMove);

          }
        }
      }

      groupToMove.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
          //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });

      groupAtNewPos.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
          //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });

      this.neighboursValues[neighbour] = this.calculate();
      if(this.numberOfIntersection < min){
        this._bestNeighbourIndex = neighbour;
        min = this.numberOfIntersection;
      }

      this.groupsContainer.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

      if(m != 1){
        if(!groupToMove.preserveOriginalOrder) {
          groupToMove.swapChildrenIndexValues(
              previousBlockIdAtNewPos, blockToMove);
        }
      }

      groupToMove.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });

      groupAtNewPos.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });
    }
    this.numberOfIntersection = numberOfIntersectionHelper;
  }

  int calculate(){
    this.numberOfIntersection = 0;

    for(var i = 0; i < this.listOfVisConnections.length; i++){
      this.listOfVisConnections[i].numberOfIntersection = 0;
    }

    int intersection = 0;
    for (int i = 0; i < this.listOfVisConnections.length-1; i++) {
      for (int j = i + 1; j < this.listOfVisConnections.length; j++) {
        this.numberOfIntersection += this.intersectionTest(this.listOfVisConnections[i], this.listOfVisConnections[j]);

      }
    }

    return this.numberOfIntersection;
  }

  int calculateAndStoreSeparateConnIntersection(){
    this.numberOfIntersection = 0;

    int res = 0;
    for (int i = 0; i < this.listOfVisConnections.length-1; i++) {
      for (int j = i + 1; j < this.listOfVisConnections.length; j++) {
        res = this.intersectionTest(this.listOfVisConnections[i], this.listOfVisConnections[j]);
        this.listOfConnectionsIntersection[i] += res;
        this.listOfConnectionsIntersection[j] += res;
      }
    }

    return this.numberOfIntersection;
  }

  int getValue() {
    return this.finalOrderValue;
  }

  int _calculateNeighbours(){
    var numberOfBlockInGroup = 0;
    var numberOfGroupMinusOne = this.numberOfGroups-1;
    groupsContainer.childrenIterable.forEach((VisualObject group){
      numberOfBlockInGroup = group.numberOfChildren;
      var partialValue = 0;
      if(numberOfBlockInGroup == 1){
        partialValue = numberOfGroupMinusOne;
      }else{
        partialValue = numberOfGroupMinusOne * numberOfBlockInGroup * (numberOfBlockInGroup - 1);
      }

      this._numberOfNeighbour += partialValue;
    });
    return this._numberOfNeighbour;
  }

  int numberOfNeighbours([VisualObject object]) {
    return this._numberOfNeighbour;
  }

  @override
  VisualObject getElementAtIndex(int groupIndex, [int blockIndex = -1]) {
    if(blockIndex < 0){
      return groupsContainer.getChildByIDs(groupsContainer.getElementByIndex(groupIndex));
    }else{
      var group = groupsContainer.getChildByIDs(groupsContainer.getElementByIndex(groupIndex));
      return group.getChildByIDs(group.getElementByIndex(blockIndex));
    }
  }

  VisualObject getGroupAtIndex(int index){
    return groupsContainer.getChildByIDs(groupsContainer.getElementByIndex(index));
  }

  VisualObject getBlockAtIndex(int groupIndex, int blockIndex){
    var group = groupsContainer.getChildByIDs(groupsContainer.getElementByIndex(groupIndex));
    return group.getChildByIDs(group.getElementByIndex(blockIndex));
  }

  @Deprecated("Helper maps were removed from this state. There is not need for this function")
  int getElementPositionByIndex(int groupIndex, [int blockIndex = -1]){
    throw new StateError("Helper maps were removed from this state. There is not need for this function");
  }

  @Deprecated("Helper maps were removed from this state. There is not need for this function")
  VisualObject getElementByPosition(int position, [int segmentPosition = -1]){
    throw new StateError("Helper maps were removed from this state. There is not need for this function");
  }

  @Deprecated("Helper maps were removed from this state. There is not need for this function")
  void setNewPositionForIndex(int index, int newValue, [int segmentIndex = -1]){
    throw new StateError("Helper maps were removed from this state. There is not need for this function");
  }

  @Deprecated("Helper maps were removed from this state. There is not need for this function")
  void setNewPositionForID(String groupID, int newValue, [String segmentID = ""]){
    throw new StateError("Helper maps were removed from this state. There is not need for this function");
  }

  int getElementIndexByID(String groupID, [String segmentID = ""]){
    if(segmentID.isEmpty){
      return this.groupsContainer.getChildByIDs(groupID).index;
    }else{
      return this.groupsContainer.getChildByIDs(groupID, 1, segmentID).index;
    }

  }

  int get bestNeighbourIndex => this._bestNeighbourIndex;

  int chooseBestNeighbour([bool isPermanent = false]){
    return chooseNeighbour(this._bestNeighbourIndex, isPermanent: isPermanent);
  }

  int chooseNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = true, int startRange = 1, int endRange = -1}) {

    int groupToMoveIndex = 0, groupFinalPosition = 0, m = 0, blockFinalPosition = 0, blockToMoveIndex = 0;
    VisualObject groupToMove, groupAtNewPos;
    String previousBlockIdAtNewPos, blockToMove;

    groupToMoveIndex = this.groupToMoveAndWhereToMove[neighbour][0];
    groupFinalPosition = this.groupToMoveAndWhereToMove[neighbour][1];
    //moveBy = this.groupToMoveAndWhereToMove[neighbour][2];

    groupAtNewPos = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupFinalPosition]);
    groupToMove = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupToMoveIndex]);

    this.groupsContainer.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

    m = groupToMove.numberOfChildren;

    if(m != 1){
      blockToMoveIndex = this.blockToMoveAndWhereToMove[neighbour][0];
      blockFinalPosition = this.blockToMoveAndWhereToMove[neighbour][2];

      previousBlockIdAtNewPos = groupToMove.childrenIDsInOrder[blockFinalPosition];
      blockToMove = groupToMove.childrenIDsInOrder[blockToMoveIndex];

      groupToMove.swapChildrenIndexValues(previousBlockIdAtNewPos, blockToMove);
    }

    groupToMove.performFunctionOnChildren((String key, VisualObject block){
      block.performFunctionOnChildren((String key, VisualObject bars){
        bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      });
    });

    groupAtNewPos.performFunctionOnChildren((String key, VisualObject block){
      block.performFunctionOnChildren((String key, VisualObject bars){
        bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      });
    });

    var retVal;
    if(isPermanent){

      this.calculate();
      retVal = this.numberOfIntersection;
      this.finalOrderValue = this.numberOfIntersection;

      this.groupsContainer.childrenIterable.forEach((VisualObject actGroup){
        finalOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

        actGroup.childrenIterable.forEach((VisualObject actBlock){
          finalOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
        });
      });

      this.setupNeighbourHelpers(startRange, endRange);

      if(enablePreCalculate){
        this.preCalculateNeighboursValue(startRange, endRange);
      }

    }else{
      var valueBefore = this.numberOfIntersection;
      this.calculate();
      retVal = this.numberOfIntersection;
      this.numberOfIntersection = valueBefore;

      this.groupsContainer.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

      if(m != 1){
        groupToMove.swapChildrenIndexValues(previousBlockIdAtNewPos, blockToMove);
      }

      groupToMove.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });

      groupAtNewPos.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });

    }

    return retVal;
  }

  bool chooseNeighbourAndDecideToKeepByFunc(int neighbour, {Function functionToDecide = null, bool enablePreCalculate = true, int startRange = 1, int endRange = -1}) {

    int groupToMoveIndex = 0, groupFinalPosition = 0, moveBy = 0, m = 0, blockFinalPosition = 0;
    VisualObject groupToMove, groupAtNewPos;
    String previousBlockIdAtNewPos, blockToMove;

    groupToMoveIndex = neighbour ~/ (this.numberOfGroups - 1) + 1;
    moveBy = neighbour % (this.numberOfGroups - 1) + 1;
    groupFinalPosition = groupToMoveIndex + moveBy;
    if(groupFinalPosition > this.numberOfGroups){
      groupFinalPosition -= (this.numberOfGroups);
    }

    groupAtNewPos = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupFinalPosition]);
    groupToMove = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupToMoveIndex]);

    this.groupsContainer.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

    m = groupToMove.numberOfChildren;
    if(m != 1) {
      if (!groupToMove.preserveOriginalOrder) {
        int bestLocalNeighbour = double.maxFinite.toInt();
        int bestLocalNeighbourIndex = -1;
        int actLocalValue = 0;
        int blockToMoveIndex, moveBlockBy;
        for (var i = 0; i < m * (m - 1); i++) {
          blockToMoveIndex = i ~/ (this.numberOfGroups - 1) + 1;
          moveBlockBy = i % (this.numberOfGroups - 1);

          blockFinalPosition = blockToMoveIndex + moveBlockBy;
          if (blockFinalPosition > m) {
            blockFinalPosition -= m;
          }

          previousBlockIdAtNewPos =
          groupToMove.childrenIDsInOrder[blockFinalPosition];
          blockToMove = groupToMove.childrenIDsInOrder[blockToMoveIndex];

          groupToMove.swapChildrenIndexValues(
              previousBlockIdAtNewPos, blockToMove);

          groupToMove.getChildByIDs(previousBlockIdAtNewPos)
              .performFunctionOnChildren((String key, VisualObject bars) {
            bars.connection.updateSegmentsRadianPos(
                this.posDoubleConvertValue, this.maxBlockNumberInGroup);
            //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
          });

          groupToMove.getChildByIDs(blockToMove).performFunctionOnChildren((
              String key, VisualObject bars) {
            bars.connection.updateSegmentsRadianPos(
                this.posDoubleConvertValue, this.maxBlockNumberInGroup);
            //this.listOfVisConnections[bars.connection.nameOfConn].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
          });

          actLocalValue = this.calculate();

          if (actLocalValue < bestLocalNeighbour) {
            bestLocalNeighbour = actLocalValue;

            this.blockToMoveAndWhereToMove[neighbour][0] = blockToMoveIndex;
            this.blockToMoveAndWhereToMove[neighbour][1] = moveBlockBy;
            this.blockToMoveAndWhereToMove[neighbour][2] = blockFinalPosition;
          }

          groupToMove.swapChildrenIndexValues(
              previousBlockIdAtNewPos, blockToMove);
        }

        previousBlockIdAtNewPos = groupToMove.childrenIDsInOrder[this
            .blockToMoveAndWhereToMove[neighbour][2]];
        blockToMove = groupToMove.childrenIDsInOrder[this
            .blockToMoveAndWhereToMove[neighbour][0]];

        groupToMove.swapChildrenIndexValues(
            previousBlockIdAtNewPos, blockToMove);
      }
    }

    groupToMove.performFunctionOnChildren((String key, VisualObject block){
      block.performFunctionOnChildren((String key, VisualObject bars){
        bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      });
    });

    groupAtNewPos.performFunctionOnChildren((String key, VisualObject block){
      block.performFunctionOnChildren((String key, VisualObject bars){
        bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      });
    });

    var valueBefore = this.numberOfIntersection;

    this.calculate();

    var isPermanent = functionToDecide(this.numberOfIntersection);
    if(isPermanent){

      this.groupsContainer.childrenIterable.forEach((VisualObject actGroup){
        tempOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

        actGroup.childrenIterable.forEach((VisualObject actBlock){
          tempOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
        });
      });

      if(enablePreCalculate){
        this.setupNeighbourHelpers(startRange, endRange);
        this.preCalculateNeighboursValue(startRange, endRange);
      }

    }else{
      this.numberOfIntersection = valueBefore;

      this.groupsContainer.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

      if(m != 1){
        groupToMove.swapChildrenIndexValues(previousBlockIdAtNewPos, blockToMove);
      }

      groupToMove.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });

      groupAtNewPos.performFunctionOnChildren((String key, VisualObject block){
        block.performFunctionOnChildren((String key, VisualObject bars){
          bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
        });
      });

    }

    return isPermanent;
  }


  @override
  State saveTemp() {
    this.groupsContainer.childrenIterable.forEach((VisualObject actGroup){
      tempOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

      actGroup.childrenIterable.forEach((VisualObject actBlock){
        tempOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
      });
    });

    return this;
  }

  int chooseNeighbourIntoTemp(int neighbour, {bool enablePreCalculate = false}){

    int groupToMoveIndex = 0, groupFinalPosition = 0, m = 0, blockFinalPosition = 0, blockToMoveIndex = 0;
    VisualObject groupToMove, groupAtNewPos;
    String previousBlockIdAtNewPos, blockToMove;

    groupToMoveIndex = this.groupToMoveAndWhereToMove[neighbour][0];
    groupFinalPosition = this.groupToMoveAndWhereToMove[neighbour][1];

    groupAtNewPos = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupFinalPosition]);
    groupToMove = this.groupsContainer.getChildByIDs(this.groupsContainer.childrenIDsInOrder[groupToMoveIndex]);

    this.groupsContainer.swapChildrenIndexValues(groupAtNewPos.id, groupToMove.id);

    m = groupToMove.numberOfChildren;

    if(m != 1){
      blockToMoveIndex = this.blockToMoveAndWhereToMove[neighbour][0];
      blockFinalPosition = this.blockToMoveAndWhereToMove[neighbour][2];

      previousBlockIdAtNewPos = groupToMove.childrenIDsInOrder[blockFinalPosition];
      blockToMove = groupToMove.childrenIDsInOrder[blockToMoveIndex];

      groupToMove.swapChildrenIndexValues(previousBlockIdAtNewPos, blockToMove);
    }


    groupToMove.performFunctionOnChildren((String key, VisualObject block){
      block.performFunctionOnChildren((String key, VisualObject bars){
        bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      });
    });

    groupAtNewPos.performFunctionOnChildren((String key, VisualObject block){
      block.performFunctionOnChildren((String key, VisualObject bars){
        bars.connection.updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      });
    });


    this.calculate();

    this.groupsContainer.childrenIterable.forEach((VisualObject actGroup){
      tempOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

      actGroup.childrenIterable.forEach((VisualObject actBlock){
        tempOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
      });
    });

    this.setupNeighbourHelpers();

    if(enablePreCalculate){
      this.preCalculateNeighboursValue();
    }

    return this.numberOfIntersection;
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
    for(var i = 1; i <= groupsIDs.length; i++){
      var element = getElementAtIndex(i);
      sb.write("{${element.label.name}: ");
      var firstOne = true;
      for(var j = 1; j <= blockIDsOrderByGroup[element.id].length; j++){
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

    this.groupsContainer.childrenIterable.forEach((VisualObject actGroup){
      finalOrderGroupsBlocks[actGroup.label.id] = actGroup.label.index;

      actGroup.childrenIterable.forEach((VisualObject actBlock){
        finalOrderGroupsBlocks[actBlock.id] = actBlock.label.index;
      });
    });

    this.finalOrderValue = this.numberOfIntersection;
    return this;
  }

  State updateFromTempOrder(){
    this.tempOrderGroupsBlocks.forEach((String key, int value){
      if(key.contains('_')){
        this.groupsContainer.getChildByIDs(key.split('_').first, 1, key).index = value;
      }else{
        this.groupsContainer.getChildByIDs(key).index = value;
      }
    });

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.calculate();

    this.finalOrderValue = this.numberOfIntersection;

    return this;
  }

  void propagateTempToFinal(){
    this.tempOrderGroupsBlocks.forEach((String key, int value){
      if(key.contains('_')){
        this.groupsContainer.getChildByIDs(key.split('_').first, 1, key).index = value;
      }else{
        this.groupsContainer.getChildByIDs(key).index = value;
      }
    });

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.calculate();

    this.finalOrderValue = this.numberOfIntersection;

    this.tempOrderGroupsBlocks.forEach((String key, int value){
      finalOrderGroupsBlocks[key] = value;
    });

  }

  @Deprecated("We do not need to copy states anymore")
  State copy() {
    return this;
  }

  @Deprecated("We do not need to copy states anymore")
  State copyBack(){
    return this;
  }

  //@Deprecated("We do not need to copy states anymore")
  State clone(){
    //throw new StateError("We do not need to copy states anymore if you use the StateVisObjConnection state, rewrite the search function");
    return new StateVisObjConnectionMod.simpleCopy(this);
  }

  State finalize(){

    this.finalOrderGroupsBlocks.forEach((String id, int index){
      if(id.contains("_")){
        groupsContainer.getChildByIDs(id.split('_').first, 1, id).label.index = index;
      }else{
        groupsContainer.getChildByIDs(id).label.index = index;
      }
    });

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.calculate();

    this.finalOrderValue = this.numberOfIntersection;

    return this;
  }

  State finalizeFromTempOrder(){

    this.tempOrderGroupsBlocks.forEach((String id, int index){
      if(id.contains("_")){
        groupsContainer.getChildByIDs(id.split('_').first, 1, id).label.index = index;
      }else{
        groupsContainer.getChildByIDs(id).label.index = index;
      }
    });

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.calculate();

    this.finalOrderValue = this.numberOfIntersection;

    return this;
  }

  int diffNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = false, int startRange = 1, int endRange = -1}) {
    int newValue = this.chooseNeighbour(neighbour,
        isPermanent: isPermanent,
        enablePreCalculate: enablePreCalculate,
        startRange: startRange,
        endRange: endRange);
    return newValue - this.finalOrderValue;
  }

  State updateFromFinalOrder(){

    this.finalOrderGroupsBlocks.forEach((String key, int value){
      if(key.contains('_')){
        this.groupsContainer.getChildByIDs(key.split('_').first, 1, key).index = value;
      }else{
        this.groupsContainer.getChildByIDs(key).index = value;
      }
    });

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.calculate();

    this.finalOrderValue = this.numberOfIntersection;

    return this;
  }

  List<int> maxConflictNeighbour() {
    List<int> maxIndex = [0];

    // returns with the connections's begin and end order which has the most intersection

    /*for(int i = 1; i < this.listOfConnectionsIntersection.length; i++){
      if(this.listOfConnectionsIntersection[maxIndex[0]] < this.listOfConnectionsIntersection[i]){
        maxIndex.clear();
        maxIndex.add(i);
      }else if(this.listOfConnectionsIntersection[maxIndex[0]] == this.listOfConnectionsIntersection[i]){
        maxIndex.add(i);
      }
    }

    var returnValue = new List<int>();

    for(int i = 0; i < maxIndex.length; i++){
      returnValue.add(this.listOfVisConnections[maxIndex[i]].sortPositionOne);
      returnValue.add(this.listOfVisConnections[maxIndex[i]].sortPositionTwo);
    }

    return returnValue;*/

    // returns with the index of the neighbours that contains the most intersection

    for(int i = 1; i < this.neighboursValues.length; i++){
      if(this.neighboursValues[i] != null && this.neighboursValues[i] != null){
        if(this.neighboursValues[maxIndex[0]] < this.neighboursValues[i]){
          maxIndex.clear();
          maxIndex.add(i);
        }else if(this.neighboursValues[maxIndex[0]] == this.neighboursValues[i]){
          maxIndex.add(i);
        }
      }
    }

    return maxIndex;
  }

  List<int> maxConflictConnection() {
    List<int> maxIndex = [0];

    // returns with the connections's begin and end order which has the most intersection

    for(int i = 1; i < this.listOfVisConnections.length; i++){
      if(this.listOfVisConnections[maxIndex[0]].numberOfIntersection < this.listOfVisConnections[i].numberOfIntersection){
        maxIndex.clear();
        maxIndex.add(i);
      }else if(this.listOfVisConnections[maxIndex[0]].numberOfIntersection == this.listOfVisConnections[i].numberOfIntersection){
        maxIndex.add(i);
      }
    }

    var returnValue = new List<int>();
    if(this.allGroupsOneBlock){
      for(int i = 0; i < maxIndex.length; i++){
        var groupIndexA = this.listOfVisConnections[maxIndex[i]].segmentOne.parent.indexInParent - 1;
        var groupIndexB = this.listOfVisConnections[maxIndex[i]].segmentTwo.parent.indexInParent - 1;
        returnValue.add(groupIndexA == 0 ? 1 : groupIndexA * (this.numberOfGroups - 1));
        returnValue.add(groupIndexB == 0 ? 1 : groupIndexB * (this.numberOfGroups - 1));
      }
    }else{
      for(int i = 0; i < maxIndex.length; i++){
        var groupIndexA = this.listOfVisConnections[maxIndex[i]].segmentOne.parent.indexInParent-1;
        var groupIndexB = this.listOfVisConnections[maxIndex[i]].segmentTwo.parent.indexInParent-1;

        var sumOfAllGroupChild = this.groupChildrenNumber.reduce((int a, int b)=> a+b);


        var neighbourA = this.groupChildrenNumber.sublist(1, groupIndexA + 1).reduce((int a, int b)=>a+b) * (this.numberOfGroups - 1);
        var neighbourB = this.groupChildrenNumber.sublist(1, groupIndexB + 1).reduce((int a, int b)=>a+b) * (this.numberOfGroups - 1);
        returnValue.add(groupIndexA == 0 ? 1 : neighbourA);
        returnValue.add(groupIndexB == 0 ? 1 : neighbourB);
      }
    }


    return returnValue;

    // returns with the index of the neighbours that contains the most intersection

    /*for(int i = 1; i < this.neighboursValues.length; i++){
      if(this.neighboursValues[maxIndex[0]] < this.neighboursValues[i]){
        maxIndex.clear();
        maxIndex.add(i);
      }else if(this.neighboursValues[maxIndex[0]] == this.neighboursValues[i]){
        maxIndex.add(i);
      }
    }

    return maxIndex;*/
  }

  State chooseRandomState({bool setFinalOrder = true, bool enablePreCalculation = false, bool enableHelper = false}){

    var rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    this.groupsIDs.shuffle(rnd);

    int i = 0;
    var groupID;
    VisualObject group;
    for(int i = 0; i < this.groupsIDs.length; i++){
      groupID = this.groupsIDs[i];
      this.blockIDsOrderByGroup[groupID].shuffle(rnd);

      group = this.groupsContainer.getChildByIDs(groupID);
      group.index = i+1;

      for(int j = 0; j < this.blockIDsOrderByGroup[groupID].length; j++){
        group.getChildByIDs(this.blockIDsOrderByGroup[groupID][j]).index = j+1;
      }
    };

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    this.calculate();

    if(setFinalOrder){
      this.finalOrderValue = this.numberOfIntersection;
    }

    if(enableHelper) {
      this.setupNeighbourHelpers();
    }

    if(enablePreCalculation){
      this.preCalculateNeighboursValue();
    }

    return this;
  }

  void copySavedStateIntoAnother(State other, [bool finalState = false]){
    StateVisObjConnectionMod otherState = (other as StateVisObjConnectionMod);
    var copyFrom = finalState ? this.finalOrderGroupsBlocks : this.tempOrderGroupsBlocks;

    copyFrom.forEach((String key, int value){
      if(key.contains('_')){
        otherState.groupsContainer.getChildByIDs(key.split('_').first, 1, key).index = value;
      }else{
        otherState.groupsContainer.getChildByIDs(key).index = value;
      }
    });

    for (int i = 0; i < otherState.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      otherState.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
    }

    otherState.calculate();

    otherState.finalOrderValue = otherState.numberOfIntersection;
  }

  @override
  void changeStateByOrder(dynamic newOrder) {
    Map<String, int> order = (newOrder as Map<String, int>);
    order.forEach((String key, int value){
      if(key != "value") {
        if (key.contains('_')) {
          this.groupsContainer
              .getChildByIDs(key
              .split('_')
              .first, 1, key)
              .index = value;
        } else {
          this.groupsContainer
              .getChildByIDs(key)
              .index = value;
        }
      }
    });

    for (int i = 0; i < this.listOfVisConnections.length; i++) {
      //this.listOfVisConnections[this.nameOfConnections[i]].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
      this.listOfVisConnections[i].updateSegmentsRadianPos(this.posDoubleConvertValue, this.maxBlockNumberInGroup);
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

    for(var i = 1; i <= groupsIDs.length; i++){
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
  double intersectionFinalValue;
  int finalValueTest;

  // b must be bigger than a
  // d must be bigger than c
  int intersectionTest(VisConnection one, VisConnection two){

    double a = one.sortPositionSegMin,
        b = one.sortPositionSegMax,
        c = two.sortPositionSegMin,
        d = two.sortPositionSegMax;

    if(a == c || a == d || b == c || b == d){
      return 0;
    }

    this.lengthAB = pi - (pi - (a-b).abs()).abs();
    this.halfDistAB = this.lengthAB / 2;
    this.midAB = b - (a - b + pi).sign * this.halfDistAB;
    this.lengthCD = pi - (pi - (c-d).abs()).abs();;
    this.halfDistCD = this.lengthCD / 2;
    this.midCD = d - (c - d + pi).sign * this.halfDistCD;

    this.diffOfConnLength = (this.halfDistAB - this.halfDistCD) * (this.halfDistAB - this.halfDistCD);
    this.distOfMidPoints = pi - (pi - (this.midAB - this.midCD).abs()).abs();

    this.intersectionFinalValue = (((this.distOfMidPoints * this.distOfMidPoints) - this.diffOfConnLength)
        / ((this.halfDistAB + this.halfDistCD)*(this.halfDistAB + this.halfDistCD) - this.diffOfConnLength));
    this.finalValueTest = this.intersectionFinalValue > MathFunc.roundToZero && this.intersectionFinalValue < MathFunc.roundToOne ? 1 : 0;
    one.numberOfIntersection += finalValueTest;
    two.numberOfIntersection += finalValueTest;
    return finalValueTest;
  }

  // b must be bigger than a
  // d must be bigger than c
  int intersectionTest2(VisConnection one, VisConnection two){

    double a = one.sortPositionSegMin,
           b = one.sortPositionSegMax,
           c = two.sortPositionSegMin,
           d = two.sortPositionSegMax;

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

    this.intersectionFinalValue = (((this.distOfMidPoints * this.distOfMidPoints) - this.diffOfConnLength)
          / ((this.halfDistAB + this.halfDistCD)*(this.halfDistAB + this.halfDistCD) - this.diffOfConnLength));
    this.finalValueTest = this.intersectionFinalValue > MathFunc.roundToZero && this.intersectionFinalValue < MathFunc.roundToOne ? 1 : 0;
    one.numberOfIntersection += finalValueTest;
    two.numberOfIntersection += finalValueTest;
    return finalValueTest;
  }

/*// b must be bigger than a
  double midPoint(double a, double b) {
    return b - (1 - (b-a) / pi).sign * lengthAB / 2;
  }
// b must be bigger than a
  double dist(double a, double b) {
    return (1 - (1 - ((b - a) / pi).abs()).abs()) * pi;
  }*/

  int intersectionTestOld(VisConnection one, VisConnection two){

    double a = one.sortPositionSegMin,
        b = one.sortPositionSegMax,
        c = two.sortPositionSegMin,
        d = two.sortPositionSegMax;

    return 1 + (-1 - overlapOfTwoRange(a, b, c, d)/2
    ).sign.toInt();
  }

  double overlapOfTwoRange(double a, double b, double c, double d) {
    return  ( pointInsideGivenRange(a, b, c) *  pointInsideGivenRange(a, b, d)).sign
        + ( pointInsideGivenRange(c, d, a) *  pointInsideGivenRange(c, d, b)).sign;
  }

  double pointInsideGivenRange(double a, double b, double c)  {
    var value =  dist( midPoint(a, b), c) -  dist(a, b)/2;
    return value < MathFunc.roundToZero && value > -MathFunc.roundToZero ? 0.0 : value;
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