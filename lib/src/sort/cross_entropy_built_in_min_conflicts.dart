part of sortConnection;

class CrossEntropyBuiltInMinConflicts extends CrossEntropy{

  MinConflicts minConfSearch = new MinConflicts.setMaxStep(3);

  List<State> doStateGeneration2(State currentState) {
    int index = 0;
    int bestValue = 0;
    for (int indexOfGenState = 0; indexOfGenState < this.numberOfGeneration; indexOfGenState++) {

      for(String groupID in this.groupColumns){

        index = getGeneratedIDForPosition(groupID, "root");
        this.generatedStates[indexOfGenState][groupID] = index;

        for(String blockID in this.blocksColumns[groupID]){
          index = getGeneratedIDForPosition(blockID, groupID);
          this.generatedStates[indexOfGenState][blockID] = index;
        }
      }

      currentState.changeStateByOrder(generatedStates[indexOfGenState]);
      this.generatedStates[indexOfGenState]["value"] = currentState.numberOfIntersection;

      if(bestValue > currentState.numberOfIntersection){
        minConfSearch.solve(currentState);
        if(currentState.getValue() < bestValue){
          (minConfSearch as StateVisObjConnectionMod).finalOrderGroupsBlocks.forEach((String key, int value){
            this.generatedStates[indexOfGenState][key] = value;
          });
          this.generatedStates[indexOfGenState]["value"] = currentState.numberOfIntersection;
        }
      }

    }
  }

  List<State> doStateGeneration(State currentState) {
    int index = 0;
    int bestValue = currentState.getValue();
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

      if(bestValue > currentState.numberOfIntersection){
        minConfSearch.solve(currentState);
        if(currentState.getValue() < bestValue){
          (currentState as StateVisObjConnectionMod).finalOrderGroupsBlocks.forEach((String key, int value){
            this.generatedStates[indexOfGenState][key] = value;
          });
          this.generatedStates[indexOfGenState]["value"] = currentState.numberOfIntersection;
        }
      }
    }
  }

}