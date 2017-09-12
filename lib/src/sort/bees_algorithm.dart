part of sortConnection;

class BeesAlgorithm implements SortAlgorithm {

  int max_number_step = 10;
  int number_of_try = 10;

  int number_of_scout_bees = 20;
  int number_of_patches = 2;
  int number_of_elite_bees = 4;

  State getRandomState(State x) {
    State helper = x.copy();
    State helper2 = x.copy();

    var helperIndexList = new List.generate(
        helper.order.length, (int index) {
      return index + 1;
    });
    helperIndexList.shuffle(
        new Random(new DateTime.now().millisecondsSinceEpoch));
    int i = 0;
    for (int newIndex in helperIndexList) {
      helper.order[i].label.index = newIndex;
      helper.orderIndexHelper[newIndex] = i;
      i++;
    }

    for (SortConnection conn in helper.listOfConnections) {
      int alma = 0;
      //conn.updateIndex();
      alma = 0;
    }

    helper.calculate();

    return helper2..changeStateByOrder(helper.order);
  }

  int replaceTheMinEliteScout(List<State> eliteScout, State replacement) {
    int minIndex = eliteScout.length - 1;
    if (minIndex < 0) {
      eliteScout.add(replacement);
      return eliteScout.length - 1;
    }

    int minValue = eliteScout[minIndex].getValue();
    for (var i = minIndex - 1; i >= 0; i--) {
      if (eliteScout[i].getValue() < minValue) {
        minIndex = i;
        minValue = eliteScout[i].getValue();
      }
    }

    if (eliteScout.length < number_of_patches) {
      eliteScout.add(replacement);
      minIndex = eliteScout.length - 1;
    } else {
      if(eliteScout[minIndex].getValue() >= replacement.getValue()){
        eliteScout[minIndex] = replacement.clone();
      }
    }
    return minIndex;
  }

  int getTheNextMinState(List<State> states, List<int> foundOnes) {

    int min = 999999999999999;
    for(var i = 0; i < states.length; i++){
      if(states[i].getValue() < min && !foundOnes.contains(i)){
        return i;
      }
    }
    return -1;
  }

  int takeOneStep(State x) {
    int bestIndex = -1;
    int min = 0;
    int intersectionValue = 0;
    if(x.getValue() == 0){
      return intersectionValue;
    }
    for (int index = 1; index < x.numberOfNeighbours(); index++) {
      int difference = x.diffNeighbour(index);
      if (difference < min) {
        bestIndex = index;
        min = difference;
        intersectionValue = x.getValue() + difference;
      }
    }
    if(bestIndex > -1){
      (x as DiagramStateFullWithoutCopy).chooseNeighbour(bestIndex, true);
    }
    return intersectionValue;
  }

  List<int> searchMinThreeUpdated(State x, int notMoveIndex) {
    int bestIndex = -1;
    int min = 0;
    if(x.getValue() == 0){
      return [bestIndex, 0];
    }
    int strict = notMoveIndex * x.getStatePossNeighbour();
    for (int index = strict; index <= strict + (x.getStatePossNeighbour()-1); index++) {
      int difference = x.diffNeighbour(index);
      if (difference < min) {
        bestIndex = index;
        min = difference;
      }
    }
    return [bestIndex, min];
  }

  int performMinConflict(State x){

    int intersectionValue = 0;
    int bestIndex = -1;
    int index = 0;
    do{
      List<int> maxConflictNeighbours = x.maxConflictNeighbour();
      List<int> elementToMove = new List();
      for(int index in maxConflictNeighbours){
        elementToMove.add((x as DiagramStateFullWithoutCopy).orderIndexHelperTemp[x.diagramElements.rootElement.id][index ~/ 1000]);
      }
      int min = 0;
      int endBestIndex = -1;
      for(int index in elementToMove) {
        List<int> res = searchMinThreeUpdated(x, index);
        if (res[0] > -1) {
          if(min > res[1]) {
            min = res[1];
            endBestIndex = res[0];
          }
        }


      }
      if(endBestIndex > -1) {
        (x as DiagramStateFullWithoutCopy).chooseNeighbour(endBestIndex, true);
        //print("## ${x.order}: ${x.getValue()} ##");
      }
      bestIndex = endBestIndex;
      index++;
    }while(bestIndex > -1 && index < 20);
    return intersectionValue;
  }

  State sequenceAll(State x) {
    int bestIndex;
    int iterationIndex = 0;
    int bestStateValue = x.getValue();
    int numberOfRandomJump = 5;
    int randomJumpIndex = 0;

    List<State> eliteScoutBees = new List<State>();
    Map<int, List<State>> eliteBees = new Map<int, List<State>>();
    List<State> scoutBees = new List<State>();

    int bestValue = 999999999999999;

    //init the scout bees
    for (var i = 0; i < number_of_scout_bees; i++) {
      scoutBees.add((x.clone() as DiagramStateFullWithoutCopy).chooseRandomState());
    }

    int previousBestValue = bestValue;
    int sameSince = 0;

    do {

      List<int> changedPatchIndices = new List<int>();
      List<int> patchMinSearchHelper = new List<int>();

      if(iterationIndex != 0) {
        //init the scout bees
        for (var i = number_of_scout_bees - 1; i >= eliteScoutBees.length; i--) {
          scoutBees[i] = (scoutBees[i] as DiagramStateFullWithoutCopy).chooseRandomState();
        }
      }

      //sort the scout to find the best ones
      scoutBees.sort((a, b) => a.compareTo(b));

      //create the patches
      for (var i = 0; i < number_of_patches; i++) {
        var minIndex = replaceTheMinEliteScout(
            eliteScoutBees, scoutBees[i]);
        changedPatchIndices.add(minIndex);
      }

      //eliteScoutBees.sort((a,b) => a.compareTo(b));

      int averageEliteBeesPerPatch = number_of_elite_bees ~/ number_of_patches;

      //Fill the elements newly found patches with new elements
      for (var i = 0; i < changedPatchIndices.length; i++) {
        List<int> selectedNeighbours = new List<int>();
        eliteBees[changedPatchIndices[i]] = new List<State>();
        for (var j = 0; j < averageEliteBeesPerPatch; j++) {
          int newNeighbour;
          do {
            newNeighbour =
                new Random().nextInt(eliteScoutBees[i].numberOfNeighbours());
          } while (selectedNeighbours.contains(newNeighbour));

          eliteBees[changedPatchIndices[i]].add((eliteScoutBees[i] as DiagramStateFullWithoutCopy).clone()
            ..chooseNeighbour(newNeighbour));
        }
      }


      //Rearrange the patches bees between each other
      /*for(var i = 0; i < number_of_patches; i++){
        int nextBestPatch = getTheNextMinState(eliteScoutBees, patchMinSearchHelper);

        if(eliteBees[nextBestPatch].length < averageEliteBeesPerPatch + number_of_patches - 1){
          var difference = (averageEliteBeesPerPatch + number_of_patches - 1) - eliteBees[nextBestPatch].length;
          List<int> selectedNeighbours = new List<int>();
          for(var i = 0; i < difference; i++){
            int newNeighbour = new Random().nextInt(
                eliteScoutBees[nextBestPatch].numberOfNeighbours());

            do {
              newNeighbour =
                  new Random().nextInt(eliteScoutBees[nextBestPatch].numberOfNeighbours());
            } while (selectedNeighbours.contains(newNeighbour));

            eliteBees[nextBestPatch].add(eliteScoutBees[nextBestPatch].copy()
              ..chooseNeighbour(newNeighbour));
          }
        }else{
          var difference = eliteBees[nextBestPatch].length - (averageEliteBeesPerPatch + number_of_patches - 1);
          eliteBees[nextBestPatch].sort((a,b) => a.compareTo(b));
          for(var i = 0; i < difference; i++){
            eliteBees[nextBestPatch].removeLast();
          }
        }

        patchMinSearchHelper.add(nextBestPatch);
      }*/

      //Take one step with each elite search bee and update the best scout bees wit the best position

      for(var i = 0; i < eliteBees.length; i++){
        int minIndex = 0;
        int minValue = 999999999999999;
        for(var j = 0; j < eliteBees[i].length; j++){
          //int result = takeOneStep(eliteBees[i][j]);
          //int result = takeOneStep(eliteBees[i][j]);
          int result = performMinConflict(eliteBees[i][j]);
          if(result < minValue){
            minIndex = j;
            minValue = result;
          }
        }
        if(eliteScoutBees[i].getValue() >= eliteBees[i][minIndex].getValue()){
          eliteScoutBees[i] = eliteBees[i][minIndex];
        }
        if(eliteScoutBees[i].getValue() < bestValue){
          bestIndex = i;
          bestValue = eliteScoutBees[i].getValue();
        }
      }

      /*StringBuffer sb = new StringBuffer("${iterationIndex}: ");
      for(var i = 0; i < eliteScoutBees.length; i++){
        sb.write("${eliteScoutBees[i].getValue()}, ");
      }
      sb.write(":::  Best ::: ${bestValue}");
      print(sb.toString());*/
      iterationIndex++;

      if(previousBestValue == bestValue){
        sameSince++;
        if(sameSince > 1){
          break;
        }
      }else{
        previousBestValue = bestValue;
        sameSince = 0;
      }

    } while (iterationIndex < max_number_step);

    (eliteScoutBees[bestIndex] as DiagramStateFullWithoutCopy).save();
    (eliteScoutBees[bestIndex] as DiagramStateFullWithoutCopy).finalize();
    return eliteScoutBees[bestIndex];
  }


  State solve(State x) {
    return sequenceAll(x);
  }
}