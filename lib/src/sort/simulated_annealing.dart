part of sortConnection;

class SimulatedAnnealing implements SortAlgorithm{

  int max_number_step = 100;
  int number_of_try = 10;
  int number_of_step_per_temp = 10;
  double acceptance_ratio = 0.8;
  double preHeatTemperature = 0.0;
  double actualAcceptanceRatio = 0.0;

  State getRandomState(State x){

    State helper = x.copy();
    State helper2 = x.copy();

    var helperIndexList = new List.generate(helper.order.length, (int index){return index+1;});
    helperIndexList.shuffle(new Random(new DateTime.now().millisecondsSinceEpoch));
    int i = 0;
    for(int newIndex in helperIndexList){
      helper.order[i].label.index = newIndex;
      helper.orderIndexHelper[newIndex] = i;
      i++;
    }

    for(SortConnection conn in helper.listOfConnections){
      int alma = 0;
      //conn.updateIndex();
      alma = 0;
    }

    helper.calculate();

    return helper2..changeStateByOrder(helper.order);
  }

  State getNewElement(State x, double actualTemperature) {
    State currentState = x;
    int min = 0;
    if(x.getValue() == 0){
      return x;
    }
    currentState.chooseNeighbour(new Random().nextInt(x.numberOfNeighbours()));
    //currentState.chooseRandomState();
    //currentState = getRandomState(x);
    int difference = currentState.getValue() - x.getValue();

    if(difference < 0){
      return currentState;
    }else if(new Random().nextDouble() < exp(difference/actualTemperature)){
      return currentState;
    }else{
      return x;
    }

    return currentState;
  }

  double updateTemperature(double currentTemperature, double k){
    return currentTemperature * 0.85;
  }

  State preheatTest(State x){
    State currentState = x;
    State bestState = x.clone();
    int min = 0;
    if(x.getValue() == 0){
      return x;
    }

    int accepted = 0;

    for(var i = 0; i < this.number_of_step_per_temp; i++) {

      currentState.chooseRandomState();
      int difference = currentState.getValue() - bestState.getValue();

      if(difference < 0) {
        if (currentState.getValue() < bestState.getValue()) {
          bestState = currentState.save().clone();
        }
      }

      if(new Random().nextDouble() < exp(-difference.abs()/this.preHeatTemperature)) {
        accepted++;
        if (currentState.getValue() < bestState.getValue()) {
          bestState = currentState.save().clone();
        }
      }
    }

    this.actualAcceptanceRatio = accepted / this.number_of_step_per_temp;

    return bestState;
  }

  State sequenceAll(State x) {
    State currentState = x;
    int iterationIndex = 1;
    int bestValue = x.getValue();
    State bestState = x.clone();
    int numberOfRandomJump = 5;
    int randomJumpIndex = 0;
    double initTemp = 100.0;
    this.preHeatTemperature = initTemp;
    double currentTemperature = initTemp;

    int previousBestValue = bestState.getValue();
    int sameSince = 0;
    bool sameSinceFirst = true;

    int preHeatRuns = 0;
    do{

      this.preHeatTemperature *= 1.15;

      currentState = preheatTest(currentState);

      if (currentState.getValue() < bestState.getValue()) {
        bestState = currentState.save().clone();
      }

      preHeatRuns++;

    }while(this.actualAcceptanceRatio < this.acceptance_ratio && preHeatRuns < 100);

    currentTemperature = this.preHeatTemperature;

    do {

      for(var i = 0; i < this.number_of_step_per_temp; i++) {
        currentState = getNewElement(currentState, currentTemperature);


        if (currentState.getValue() < bestState.getValue()) {
          bestState = currentState.save().clone();
        }

      }

      currentTemperature = updateTemperature(currentTemperature, (1 - iterationIndex/max_number_step));

      iterationIndex++;

      if(previousBestValue == bestState.getValue()){
        sameSince++;
        if(sameSince > 6){
          if(sameSinceFirst){
            preHeatRuns = 0;
            sameSinceFirst = false;
            sameSince = 0;
            do{

              this.preHeatTemperature *= 1.15;

              currentState = preheatTest(currentState);

              if (currentState.getValue() < bestState.getValue()) {
                bestState = currentState.save().clone();
              }

              preHeatRuns++;

            }while(this.actualAcceptanceRatio < this.acceptance_ratio && preHeatRuns < 100);

            currentTemperature = this.preHeatTemperature;
          }else{
            break;
          }
        }
      }else{
        previousBestValue = bestState.getValue();
        sameSince = 0;
      }

      //print("${iterationIndex} - ${bestState.getValue()} - ${currentTemperature}");
    } while (bestState.getValue() > 0 && (iterationIndex < max_number_step));

    bestState.finalize();
    return bestState;
  }


  State solve(State x){
    return sequenceAll(x);
  }
}