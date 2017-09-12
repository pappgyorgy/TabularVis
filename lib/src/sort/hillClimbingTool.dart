part of sortConnection;

class HillClimbingTool implements SortAlgorithm{

  int max_number_step = 100;
  int number_of_try = 10;

  int bestStepAll(State x) {
    //x.status;
    int bestIndex = -1;
    int min = 0;
    if(x.getValue() == 0){
      return bestIndex;
    }
    for (int index = 1; index < x.numberOfNeighbours(); index++) {
      int difference = x.diffNeighbour(index);
      //x.status;
      if (difference < min) {
        bestIndex = index;
        min = difference;
      }
      //var z = x.copy();
      //z.chooseNeighbour(index);
      //print("${z.order}: ${z.getValue()}");
      //if(z.getValue() == 0){
        //break;
      //}
    }
    return bestIndex;
  }

  State sequenceAll(State x) {
    int bestIndex;
    int iterationIndex = 0;
    int numberOfRandomJump = 5;
    int randomJumpIndex = 0;
    do {
      bestIndex = bestStepAll(x);
      if (bestIndex > -1) {
        (x as DiagramStateFullWithoutCopy).chooseNeighbour(bestIndex, true);
        //x.status;
        //print("##${x.order}: ${x.getValue()}##");
      }else{
        //x.status;
        (x as DiagramStateFullWithoutCopy).chooseRandomState();
        randomJumpIndex++;
        //x.status;

        /*if(x.getValue() <= bestState.getValue()){
          bestState = x.copy();
        }*/
      }
      //print(bestState.getValue());
      iterationIndex++;
      //print("${iterationIndex} - ${x.toString()}");
    } while ((-1 > bestIndex || randomJumpIndex < numberOfRandomJump) && (iterationIndex < max_number_step));

    (x as DiagramStateFullWithoutCopy).updateFromFinalOrder();
    (x as DiagramStateFullWithoutCopy).finalize();

    return x;
  }


  State solve(State x){
    return sequenceAll(x);
  }
}