part of sortConnection;

class SimulatedAnnealing implements SortAlgorithm{

  int max_number_step = 100;
  int number_of_try = 10;
  int number_of_step_per_temp = 10;
  double acceptance_ratio = 0.8;
  double preHeatTemperature = 0.0;
  double actualAcceptanceRatio = 0.0;
  double onePerNumber_of_step_per_temp;

  State getNewElement(State currentState, double actualTemperature, Random rnd) {

    int actValue = currentState.numberOfIntersection;
    if(currentState.numberOfIntersection == 0){
      currentState.save();
      return currentState;
    }

    currentState.chooseNeighbourAndDecideToKeepByFunc(
        rnd.nextInt(currentState.numberOfNeighbours()-1) + 1,
        functionToDecide: (int numberOfIntersection){
          int difference = numberOfIntersection - actValue;
          return (difference < 0) || (rnd.nextDouble() < exp((-((difference).abs()))/actualTemperature));
        },
        enablePreCalculate: false
    );

    return currentState;
  }

  double updateTemperature(double currentTemperature, double k){
    return currentTemperature * 0.85;
  }

  int preheatTest2(State x){
    State currentState = x;
    int actualBestStateValue = x.getValue();
    if(x.getValue() == 0){
      return 0;
    }

    bool saveRandomGenValue = false;
    int accepted = 0;

    for(var i = 0; i < this.number_of_step_per_temp; i++) {

      currentState.chooseRandomState(setFinalOrder: false);
      int difference = currentState.numberOfIntersection - actualBestStateValue;
      int difference2 = currentState.bestNeighbourIndex > 1 ? currentState.neighboursValues[currentState.bestNeighbourIndex] - actualBestStateValue : 99999999999;

      var randomValue = new Random().nextDouble();
      var acceptance = exp((-(min(difference, difference2).abs()))/this.preHeatTemperature);

      saveRandomGenValue = (difference < 0 || difference2 < 0) || (randomValue < acceptance);

      accepted += (!(difference < 0 || difference2 < 0) && (randomValue < acceptance)) ? 1 : 0;

      if(saveRandomGenValue){
        if(difference2 < difference){

          currentState.chooseNeighbourIntoTemp(currentState.bestNeighbourIndex, enablePreCalculate: false);
          actualBestStateValue = currentState.numberOfIntersection;
          difference = difference2;

        } else {

          actualBestStateValue = currentState.numberOfIntersection;
          currentState.saveTemp();

        }
      }
    }

    this.actualAcceptanceRatio = accepted / this.number_of_step_per_temp;

    return actualBestStateValue;
  }

  int preheatTest(State currentState){
    int actualBestStateValue = currentState.numberOfIntersection;
    if(currentState.numberOfIntersection == 0){
      currentState.save();
      return 0;
    }

    int accepted = 0;
    double acceptance = 0.0, acceptanceTest = 0.0;
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    for(var i = 0; i < this.number_of_step_per_temp; i++) {

      currentState.chooseRandomState(setFinalOrder: false, enablePreCalculation: false);
      int difference = currentState.numberOfIntersection - actualBestStateValue;
      acceptance = exp((-(difference).abs())/this.preHeatTemperature);

      //Ez akkor lesz negatív ha a randomvalue kisebb mint az acceptance;
      acceptanceTest = rnd.nextDouble() - acceptance;

      // diff- és acc- => minus | diff- miatt elfogadjuk
      // diff+ és acc- => minus | acc- miatt elfogadjuk
      // diff+ és acc+ => plus  | nem fogadjuk el
      // diff- és acc+ => minus | diff- miatt elfogadjuk

      accepted += ((-acceptanceTest).sign + 1) ~/ 2;

      if(acceptance * difference < 0){
        actualBestStateValue = currentState.numberOfIntersection;
        currentState.saveTemp();
      }

      this.actualAcceptanceRatio = accepted * this.onePerNumber_of_step_per_temp;
    }

    return actualBestStateValue;
  }

  State sequenceAll(State currentState) {
    this.onePerNumber_of_step_per_temp = 1.0 / this.number_of_step_per_temp;
    int iterationIndex = 1;
    int bestValue = currentState.getValue();
    //State bestState = x.clone();
    int numberOfRandomJump = 5;
    int randomJumpIndex = 0;
    double initTemp = 100.0;
    this.preHeatTemperature = initTemp;
    double currentTemperature = initTemp;

    int previousBestValue = currentState.getValue();
    int actualBestValue = currentState.getValue();
    int sameSince = 0;
    bool thirdPreHeat = false;

    int preHeatRuns = 0, accepted = 0;
    int bestValueFromPreheatIteration = 0;
    double acceptance = 0.0;
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    do{

      this.preHeatTemperature *= 1.15;

      if(currentState.getValue() == 0){
        print("value was 0");
        return currentState;
      }

      bestValueFromPreheatIteration = preheatTest(currentState);

      //We decide this in the preheat test, when we will change neighbour or here when we permanently change neighbour
      if (bestValueFromPreheatIteration < actualBestValue) {
        currentState.save();
        actualBestValue = currentState.getValue();
      }

      preHeatRuns++;

    }while(this.actualAcceptanceRatio < this.acceptance_ratio && preHeatRuns < 100);

    currentTemperature = this.preHeatTemperature;

    //currentState.updateFromFinalOrder();

    do {

      for(var i = 0; i < this.number_of_step_per_temp; i++) {
        getNewElement(currentState, currentTemperature, rnd);

        if (currentState.numberOfIntersection < actualBestValue) {
          currentState.save();
          previousBestValue = actualBestValue;
          actualBestValue = currentState.getValue();
          sameSince = 0;
        }

      }

      currentTemperature *= 0.85;

      iterationIndex++;

      //Ha a kettő egynlő akkor a különbségük nulla, ezért azt az alábbiak szerint konvertálva pont akkor kapunk egyet ha egyenlőek
      sameSince += (1 - (previousBestValue - actualBestValue).abs().sign);

      if(sameSince == 6){

        if(thirdPreHeat) break;

        do{

          this.preHeatTemperature *= 1.15;

          if(currentState.getValue() == 0){
            print("value was 0");
            return currentState;
          }

          bestValueFromPreheatIteration = preheatTest(currentState);

          //We decide this in the preheat test, when we will change neighbour or here when we permanently change neighbour
          if (bestValueFromPreheatIteration < actualBestValue) {
            currentState.save();
            actualBestValue = currentState.getValue();
          }

          preHeatRuns++;

        }while(this.actualAcceptanceRatio < this.acceptance_ratio && preHeatRuns < 100);

        currentTemperature = this.preHeatTemperature;

        sameSince = 0;
        thirdPreHeat = true;
      }

    } while (actualBestValue > 0 && (iterationIndex < max_number_step));

    currentState.updateFromFinalOrder();
    return currentState;
  }


  State solve(State x){
    return sequenceAll(x);
  }
}