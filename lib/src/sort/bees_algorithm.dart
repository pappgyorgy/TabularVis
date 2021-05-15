part of sortConnection;

class BeesAlgorithm implements SortAlgorithm {

  int max_number_step = 10;
  int number_of_try = 10;

  int number_of_scout_bees = 10;
  int number_of_patches = 2;
  int number_of_elite_bees = 2;

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
      (x as DiagramStateFullWithoutCopy).chooseNeighbour(bestIndex, isPermanent: true);
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
        (x as DiagramStateFullWithoutCopy).chooseNeighbour(endBestIndex, isPermanent: true);
        //print("## ${x.order}: ${x.getValue()} ##");
      }
      bestIndex = endBestIndex;
      index++;
    }while(bestIndex > -1 && index < 20);
    return intersectionValue;
  }

  State sequenceAll(State currentState) {
    int iterationIndex = 0;

    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);

    List<int> eliteBees = new List<int>.generate(this.number_of_patches, (_)=>0);
    List<State> scoutBees = new List<State>();

    int bestValue = 999999999999999;

    //init the scout bees
    for (var i = 0; i < number_of_scout_bees; i++) {
      scoutBees.add(currentState.clone());

      scoutBees.last.chooseRandomState(enableHelper: false, enablePreCalculation: false, setFinalOrder: false);
      scoutBees.last.saveTemp();
    }

    scoutBees.sort((a, b) => a.compareTo(b));

    int previousBestValue = bestValue;
    int sameSince = 0;

    var numberOfEliteBeesPerPatch = this.number_of_elite_bees ~/ this.number_of_patches;

    int bestBeeInPatch = 0;

    List<List<State>> eliteBeesPatch = new List<List<State>>(this.number_of_patches);
    for (var i = 0; i < this.number_of_patches; i++) {
      eliteBeesPatch[i] = new List<State>(numberOfEliteBeesPerPatch);
      for (var j = 0; j < numberOfEliteBeesPerPatch; j++) {
        eliteBeesPatch[i][j] = scoutBees[i].clone();

        bestBeeInPatch = scoutBees[i].numberOfIntersection;

        eliteBeesPatch[i][j].chooseNeighbourAndDecideToKeepByFunc(
            rnd.nextInt(currentState.numberOfNeighbours()-1) + 1,
            functionToDecide: (int numberOfIntersection){
              int difference = numberOfIntersection - scoutBees[i].numberOfIntersection;
              return (difference < 0);
            },
            enablePreCalculate: false
        );

        if(bestBeeInPatch < eliteBeesPatch[i][j].numberOfIntersection){
          bestBeeInPatch = eliteBeesPatch[i][j].numberOfIntersection;
          eliteBees[i] = j;
        }
      }
    }

    List<int> patchesOrder = new List<int>.generate(this.number_of_patches, (i)=>i);
    patchesOrder.sort((int a, int b){
      return eliteBeesPatch[a][eliteBees[a]].compareTo(eliteBeesPatch[b][eliteBees[b]]);
    });

    var numberOfGroupsMinusOne = currentState.diagramElements.rootElement.numberOfChildren -1;
    var numberOfPossNeighbours = currentState.numberOfNeighbours();

    do {

      //init the scout bees
      for (var i = 0; i < scoutBees.length; i++) {
        scoutBees[i].chooseRandomState(enableHelper: false, enablePreCalculation: false, setFinalOrder: false);
        //print(scoutBees[i].numberOfIntersection);
        scoutBees[i].saveTemp();
      }


      //sort the scout to find the best ones
      scoutBees.sort((a, b) => a.compareTo(b));

      var previousIntersectionValue = 0;
      int bestBeeInPatch = 0;

      int indexOfLastlyUpdatedPatch = this.number_of_patches;
      int previousIndexOfLastlyUpdatedPatch = indexOfLastlyUpdatedPatch;
      for (var i = 0; i < number_of_patches; i++) {

        for (var k = indexOfLastlyUpdatedPatch - 1; k >= 0; k--) {
          if (scoutBees[i].numberOfIntersection <
              eliteBeesPatch[patchesOrder[k]][eliteBees[k]].numberOfIntersection) {

            eliteBeesPatch[patchesOrder[k]][eliteBees[k]].propagateTempToFinal();

            bestBeeInPatch =
                eliteBeesPatch[patchesOrder[k]][eliteBees[k]].numberOfIntersection;

            for (var j = 0; j < numberOfEliteBeesPerPatch; j++) {
              scoutBees[i].copySavedStateIntoAnother(eliteBeesPatch[patchesOrder[k]][j]);

              var minValueNeighbour = -1;
              eliteBeesPatch[patchesOrder[k]][j].maxConflictConnection().forEach((int maxIntersectionNeighbour){

                if(maxIntersectionNeighbour + numberOfGroupsMinusOne > numberOfPossNeighbours){
                  throw new StateError("Miscalculated neighbour for max conflict connection");
                }

                (eliteBeesPatch[patchesOrder[k]][j] as StateVisObjConnectionMod).preCalculateNeighboursValue(maxIntersectionNeighbour, maxIntersectionNeighbour + numberOfGroupsMinusOne);
                if(eliteBeesPatch[patchesOrder[k]][j].bestNeighbourIndex > -1){
                  if(eliteBeesPatch[patchesOrder[k]][j].neighboursValues[eliteBeesPatch[patchesOrder[k]][j].bestNeighbourIndex] < bestBeeInPatch){
                    bestBeeInPatch = eliteBeesPatch[patchesOrder[k]][j].neighboursValues[eliteBeesPatch[patchesOrder[k]][j].bestNeighbourIndex];
                    minValueNeighbour = eliteBeesPatch[patchesOrder[k]][j].bestNeighbourIndex;
                  }
                }

              });

              if(minValueNeighbour > -1) {
                eliteBeesPatch[patchesOrder[k]][j].chooseNeighbourIntoTemp(minValueNeighbour, enablePreCalculate: false);
              }

              /*(eliteBeesPatch[patchesOrder[k]][j] as StateVisObjConnectionMod).preCalculateNeighboursValue();

              if(eliteBeesPatch[patchesOrder[k]][j].bestNeighbourIndex < 0){
                continue;
              }

              if(eliteBeesPatch[patchesOrder[k]][j].neighboursValues[eliteBeesPatch[patchesOrder[k]][j].bestNeighbourIndex] < bestBeeInPatch){
                eliteBeesPatch[patchesOrder[k]][j].chooseNeighbourIntoTemp(
                    eliteBeesPatch[patchesOrder[k]][j].bestNeighbourIndex,
                    enablePreCalculate: false
                );
                bestBeeInPatch = eliteBeesPatch[patchesOrder[k]][j].numberOfIntersection;
                eliteBees[patchesOrder[k]] = j;
              }*/

              /*previousIntersectionValue =
                  eliteBeesPatch[patchesOrder[k]][j].numberOfIntersection;
              eliteBeesPatch[patchesOrder[k]][j].chooseNeighbourAndDecideToKeepByFunc(
                  rnd.nextInt(currentState.numberOfNeighbours() - 1) + 1,
                  functionToDecide: (int numberOfIntersection) {
                    int difference = numberOfIntersection -
                        previousIntersectionValue;
                    return (difference < 0);
                  },
                  enablePreCalculate: false
              );*/

              //Set the best bee in patch
              /*if (bestBeeInPatch > eliteBeesPatch[patchesOrder[k]][j].numberOfIntersection) {
                bestBeeInPatch = eliteBeesPatch[patchesOrder[k]][j].numberOfIntersection;
                eliteBees[patchesOrder[k]] = j;
              }*/
            }
            indexOfLastlyUpdatedPatch = k;
            break;
          }
        }

        if(indexOfLastlyUpdatedPatch <= 0 || previousIndexOfLastlyUpdatedPatch == indexOfLastlyUpdatedPatch){
          break;
        }
      }

      for(int i = indexOfLastlyUpdatedPatch - 1; i >= 0; i--){
        bestBeeInPatch =
            eliteBeesPatch[patchesOrder[i]][eliteBees[i]].numberOfIntersection;

        for (var j = 0; j < numberOfEliteBeesPerPatch; j++) {

          var minValueNeighbour = -1;
          eliteBeesPatch[patchesOrder[i]][j].maxConflictConnection().forEach((int maxIntersectionNeighbour){

            if(maxIntersectionNeighbour + numberOfGroupsMinusOne > numberOfPossNeighbours){
              throw new StateError("Miscalculated neighbour for max conflict connection");
            }

            (eliteBeesPatch[patchesOrder[i]][j] as StateVisObjConnectionMod).preCalculateNeighboursValue(maxIntersectionNeighbour, maxIntersectionNeighbour + numberOfGroupsMinusOne);
            if(eliteBeesPatch[patchesOrder[i]][j].bestNeighbourIndex > -1){
              if(eliteBeesPatch[patchesOrder[i]][j].neighboursValues[eliteBeesPatch[patchesOrder[i]][j].bestNeighbourIndex] < bestBeeInPatch){
                bestBeeInPatch = eliteBeesPatch[patchesOrder[i]][j].neighboursValues[eliteBeesPatch[patchesOrder[i]][j].bestNeighbourIndex];
                minValueNeighbour = eliteBeesPatch[patchesOrder[i]][j].bestNeighbourIndex;
              }
            }

          });

          if(minValueNeighbour > -1) {
            eliteBeesPatch[patchesOrder[i]][j].chooseNeighbourIntoTemp(minValueNeighbour, enablePreCalculate: false);
          }

          /*(eliteBeesPatch[patchesOrder[i]][j] as StateVisObjConnectionMod).preCalculateNeighboursValue();
          if(eliteBeesPatch[patchesOrder[i]][j].bestNeighbourIndex < 0){
            continue;
          }
          if(eliteBeesPatch[patchesOrder[i]][j].neighboursValues[eliteBeesPatch[patchesOrder[i]][j].bestNeighbourIndex] < bestBeeInPatch){
            eliteBeesPatch[patchesOrder[i]][j].chooseNeighbourIntoTemp(
                eliteBeesPatch[patchesOrder[i]][j].bestNeighbourIndex,
                enablePreCalculate: false
            );
            bestBeeInPatch = eliteBeesPatch[patchesOrder[i]][j].numberOfIntersection;
            eliteBees[patchesOrder[i]] = j;
          }*/

          /*previousIntersectionValue =
              eliteBeesPatch[patchesOrder[i]][j].numberOfIntersection;
          eliteBeesPatch[patchesOrder[i]][j].chooseNeighbourAndDecideToKeepByFunc(
              rnd.nextInt(currentState.numberOfNeighbours() - 1) + 1,
              functionToDecide: (int numberOfIntersection) {
                int difference = numberOfIntersection -
                    previousIntersectionValue;
                return (difference < 0);
              },
              enablePreCalculate: false
          );

          //Set the best bee in patch
          if (bestBeeInPatch > eliteBeesPatch[patchesOrder[i]][j].numberOfIntersection) {
            bestBeeInPatch = eliteBeesPatch[patchesOrder[i]][j].numberOfIntersection;
            eliteBees[patchesOrder[i]] = j;
          }*/
        }
      }

      patchesOrder.sort((int a, int b){
        return eliteBeesPatch[b][eliteBees[b]].compareTo(eliteBeesPatch[a][eliteBees[a]]);
      });


      /*StringBuffer sb = new StringBuffer("${iterationIndex}: ");
      for(var i = 0; i < eliteScoutBees.length; i++){
        sb.write("${eliteScoutBees[i].getValue()}, ");
      }
      sb.write(":::  Best ::: ${bestValue}");
      print(sb.toString());*/
      iterationIndex++;

      if(previousBestValue == eliteBeesPatch[patchesOrder[0]][eliteBees[patchesOrder[0]]].numberOfIntersection){
        sameSince++;
        if(sameSince > 1){
          break;
        }
      }else if(previousBestValue > eliteBeesPatch[patchesOrder[0]][eliteBees[patchesOrder[0]]].numberOfIntersection){
        eliteBeesPatch[0][eliteBees[0]].save();
        previousBestValue = bestValue;
        sameSince = 0;
      }

    } while (iterationIndex < max_number_step);

    //eliteBeesPatch[0][eliteBees[0]].updateFromFinalOrder();
    //return eliteBeesPatch[0][eliteBees[0]];
    eliteBeesPatch[0][eliteBees[0]].copySavedStateIntoAnother(currentState, true);
    return currentState;
  }


  State solve(State x) {
    return sequenceAll(x);
  }
}