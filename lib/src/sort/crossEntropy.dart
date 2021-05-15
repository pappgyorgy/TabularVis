part of sortConnection;

class CrossEntropy implements SortAlgorithm{

  Map<String, List<int>> probabilityMatrixMap;

  Map<String, List<int>> generatedNumbers;

  final double probabilityConstant = 0.3;

  int numberOfGeneration = 20;
  int numberOfElite = 5;
  double marginOfError = 0.3;
  double epsilon = 0.25;
  int numberOfElement;
  int numberOfGroups;
  List<int> numberOfBlockPerGroup;
  State startState;
  int numberOfIteration = 20;
  int numberOfGeneratedGroups = 0;

  List<String> groupColumns;
  Map<String, List<String>> blocksColumns;

  List<Map<String, int>> generatedStates;
  List<int> generatedStatesOrder;

  Random randomGen = new Random();

  String rootElementID;

  int numberOfInitialRound = 1;

  int numberOfProcessedElite = 0;

  List<String> allKeys;

  void processState(State x){
    this.startState = x;

    rootElementID = startState.diagramElements.rootElement.id;
    var groupsContainer = startState.diagramElements.rootElement;

    this.numberOfGroups = groupsContainer.numberOfChildren;
    this.numberOfBlockPerGroup = new List<int>(this.numberOfGroups);

    this.numberOfElement = startState.numberOfGroupsAndBlocks;
    this.groupColumns = new List<String>(this.numberOfGroups);
    this.blocksColumns = new Map<String, List<String>>();

    int index = 0;
    int blockIndex = 0;
    groupsContainer.performFunctionOnChildren((String groupKey, VisualObject actGroup) {
      this.groupColumns[index] = groupKey;
      this.numberOfBlockPerGroup[index++] = actGroup.numberOfChildren;

      this.blocksColumns[groupKey] = new List<String>(actGroup.numberOfChildren);
      blockIndex = 0;
      actGroup.performFunctionOnChildren((String blockKey, VisualObject actBlock) {
        this.blocksColumns[groupKey][blockIndex++] = blockKey;
      });
    });

    this.numberOfElite = max(2, (numberOfGeneration * 0.3).floor());

    this.probabilityMatrixMap = new Map<String, List<int>>();

    this.generatedNumbers = new Map<String, List<int>>();
    this.generatedNumbers["root"] = new List<int>();
    this.allKeys = new List<String>();

    for(String groupID in this.groupColumns){
      this.probabilityMatrixMap[groupID] = (new List<int>.filled(this.numberOfGroups, this.numberOfInitialRound));

      this.generatedNumbers[groupID] = new List<int>();

      for(String blockID in blocksColumns[groupID]){
        this.probabilityMatrixMap[blockID] =
        (new List<int>.filled(blocksColumns[groupID].length, this.numberOfInitialRound));
        this.allKeys.add(groupID);
        this.allKeys.add(blockID);
      }
    }

    this.generatedStates = new List<Map<String, int>>(this.numberOfGeneration);
    for(int i = 0; i < this.numberOfGeneration; i++){
      this.generatedStates[i] = new Map<String, int>();
    }
    this.generatedStatesOrder = new List<int>.generate(this.numberOfGeneration, (i)=>i);


  }

  void updateMatrices(List<Map<String, int>> eliteStates){

    for(Map<String, int> elite in eliteStates){
      this.allKeys.forEach((String key){
        probabilityMatrixMap[key][elite[key]-1]++;
      });
    }

    this.numberOfProcessedElite += eliteStates.length;
  }

  void processGeneratedElement() {
    int firstError = generatedStates[generatedStatesOrder.first]["value"];
    int index = 0;
    List<Map<String, int>> elites = new List<Map<String, int>>();

    //print("Error: $firstError ------ ${firstError * (marginOfError + 1.0)}");
    do{
      elites.add(generatedStates[generatedStatesOrder[index]]);
      index++;
      if(index >= this.numberOfElite){
        break;
      }
    }while(generatedStates[generatedStatesOrder[index]]["value"] <= firstError * (marginOfError + 1.0));

    updateMatrices(elites);
  }

  int getGeneratedIDForPosition(String elementID, String generatedNumbersID){

    int index = 1;

    double sum = 0.0;
    do {
      index = 1;
      var maxValue = generatedNumbersID == "root"
          ? this.numberOfGroups
          : this.numberOfBlockPerGroup[this.groupColumns.indexOf(generatedNumbersID)];
      maxValue += this.numberOfProcessedElite;

      var testValue = this.randomGen.nextInt(maxValue + 1);

      sum = 0.0;
      for (int i = 0; i < this.probabilityMatrixMap[elementID].length; i++) {
        sum += this.probabilityMatrixMap[elementID][i];
        if (sum < testValue) {
          index++;
        } else {
          break;
        }
      }
    }while(this.generatedNumbers[generatedNumbersID].contains(index));

    this.generatedNumbers[generatedNumbersID].add(index);

    return index;

  }

  List<State> doStateGeneration(State currentState) {
    int index = 0;
    for (int indexOfGenState = 0; indexOfGenState < this.numberOfGeneration; indexOfGenState++) {

      for(String groupID in this.groupColumns){

        index = getGeneratedIDForPosition(groupID, "root");
        this.generatedStates[indexOfGenState][groupID] = index;

        for(String blockID in this.blocksColumns[groupID]){
          index = getGeneratedIDForPosition(blockID, groupID);
          this.generatedStates[indexOfGenState][blockID] = index;
        }

        this.generatedNumbers[groupID].clear();
      }

      this.generatedNumbers["root"].clear();

      currentState.changeStateByOrder(generatedStates[indexOfGenState]);
      this.generatedStates[indexOfGenState]["value"] = currentState.numberOfIntersection;
    }
  }

  State solve(State currentState){

    //Do something with the given state
    processState(currentState);

    int lastChange = 0;

    for(int i = 0; i < numberOfIteration; i++){
      //print("${i+1} iteration ------------------------");
      //Generate new states based on the probability matrix
      doStateGeneration(currentState);

      //Sort the states
      generatedStatesOrder.sort((a,b) =>
          generatedStates[a]["value"].compareTo(generatedStates[b]["value"]));

      if(generatedStates[generatedStatesOrder.first]["value"] < currentState.getValue()){
        currentState.changeStateByOrder(generatedStates[generatedStatesOrder.first]);
        currentState.save();
        lastChange = i;
        if(currentState.getValue() == 0){
          break;
        }
      }

      //Update the matrix
      processGeneratedElement();

      if((i - lastChange)>5){
        break;
      }

    }

    currentState.updateFromFinalOrder();
    return currentState;
  }


}