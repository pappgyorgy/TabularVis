part of sortConnection;

class CrossEntropy implements SortAlgorithm{

  List<List<double>> probabilityMatrix;
  Map<String, List<int>> probabilityMatrixMap;
  Map<String, Map<String, List<int>>> groupsProbabilityMatrixMap;
  Map<String, List<int>> generatedNumbers;

  State bestState;

  List<State> elites;
  List<int> orderInNumbers;

  final double probabilityConstant = 0.3;

  int numberOfGeneration = 10;
  int numberOfElite = 2;
  double marginOfError = 0.3;
  double epsilon = 0.25;
  int numberOfElement;
  State startState;
  int numberOfIteration = 10;
  Map<String, int> columns = new Map<String, int>();
  List<State> generatedStates;
  int numberOfGeneratedGroups = 0;
  Map<String, int> numberOfGeneratedSegments;
  Random randomGen = new Random();
  List<String> allSegmentsKeys;
  Map<String, List<String>> segmentsKeyPerGroup;
  List<String> groupKeys;
  String rootElementID;
  int numberOfInitialRound = 5;

  void processState(State x){
    this.startState = x;
    rootElementID = startState.diagramElements.rootElement.id;
    for(var i = 1; i <= this.startState.order.length; i++){
      columns[this.startState.getElementByPlace(i).id] = i-1;
    }

    numberOfElement = startState.order.length;
    numberOfElite = max(2, (numberOfGeneration * 0.3).floor());
    probabilityMatrix = new List<List<double>>(numberOfElement);

    double value = 1.0/(numberOfElement-1);

    probabilityMatrix[0] = (new List<double>.filled(numberOfElement, 0.0));
    probabilityMatrix[0][0] = 1.0;

    for(int i = 1; i < numberOfElement; i++){
      probabilityMatrix[i] = (new List<double>.filled(numberOfElement, value));
      probabilityMatrix[i][i] = 0.0;
    }

    probabilityMatrixMap = new Map<String, List<int>>();
    generatedNumbers = new Map<String, List<int>>();
    numberOfGeneratedSegments = new Map<String, int>();
    segmentsKeyPerGroup = new Map<String, List<String>>();
    generatedNumbers[rootElementID] = new List<int>();

    for(VisualObject group in  startState.diagramElements.rootElement.getChildren){
      probabilityMatrixMap[group.id] = (new List<int>.filled(numberOfElement, numberOfInitialRound));
      generatedNumbers[group.id] = new List<int>();
    }

    groupsProbabilityMatrixMap = new Map<String, Map<String, List<int>>>();

    for(VisualObject group in  startState.diagramElements.rootElement.getChildren){
      var size = group.numberOfChildren;
      groupsProbabilityMatrixMap[group.id] = new Map<String, List<int>>();
      segmentsKeyPerGroup[group.id] = group.getChildrenIDs();

      for(VisualObject segment in group.getChildren){
        numberOfGeneratedSegments[segment.id] = size * numberOfInitialRound;
        groupsProbabilityMatrixMap[group.id][segment.id] = (new List<int>.filled(size, numberOfInitialRound));
      }
    }

    groupKeys = startState.diagramElements.rootElement.getChildrenIDs();
    allSegmentsKeys = this.numberOfGeneratedSegments.keys.toList();


    generatedStates = new List<State>(numberOfGeneration);
    for(int i = 0; i < numberOfGeneration; i++){
      generatedStates[i] = startState.clone();
    }

    /*for(int i = 0; i < (numberOfGeneration * 5); i++){
      generatedStates[i] = startState.clone().chooseRandomState();
    }*/

    numberOfGeneratedGroups = numberOfInitialRound * numberOfElement;
    //numberOfGeneratedGroups = (numberOfInitialRound * numberOfElement) + (numberOfGeneration * 5);

    /*for(int i = 0; i < this.numberOfElement; i++){
      var element = (startState as DiagramStateFullWithoutCopy).getElementAtIndex(i+1);
      probabilityMatrixMap[element.id][i]++;
      for(VisualObject segment in element.getChildren){
        int indexOfSegment = (startState as DiagramStateFullWithoutCopy).getElementIndexByID(element.id, segment.id);
        groupsProbabilityMatrixMap[element.id][segment.id][indexOfSegment-1]++;
      }
    }*/

    /*for(State state in generatedStates){
      for(int i = 0; i < this.numberOfElement; i++){
        var element = state.getElementAtIndex(i+1);
        probabilityMatrixMap[element.id][i]++;
        for(VisualObject segment in element.getChildren){
          int indexOfSegment = state.getElementIndexByID(element.id, segment.id);
          groupsProbabilityMatrixMap[element.id][segment.id][indexOfSegment-1]++;
        }
      }
    }*/

    elites = new List<State>();
    orderInNumbers = new List<int>();
  }

  void initGeneratedNumbers(){
    for(VisualObject group in  startState.diagramElements.rootElement.getChildren){
      generatedNumbers[group.id].clear();
    }
  }

  int getGeneratedNumber2(int index, Random rnd){
    List<double> values = new List.from(probabilityMatrix[index]);
    double sum = 0.0;
    for(int usedIndex in orderInNumbers){
      sum += values[usedIndex];
    }

    //sum /= (numberOfElement - orderInNumbers.length);

    double probability = rnd.nextDouble();
    double probabilitySum = 0.0;

    probability = (1-sum) * probability;

    //probability = doubleRandomGenerator(rnd, (1-sum));

    for(int i = 0; i < values.length; i++){
      if(!orderInNumbers.contains(i)){
        probabilitySum += (values[i]);
        if(probabilitySum > probability){ //0,1 0,2 0,5 0, 0,1 ,0 0,1 -- 0,8
          return i;
        }
      }
    }
    //print("Exception: $values - - $probability - - $sum _ _ $orderInNumbers");

    for(int i = 0; i < values.length; i++) {
      if (!orderInNumbers.contains(i)) {
        return i;
      }
    }

    return -1;
  }

  List<State> doStateGeneration2(){
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    for(int i = 0; i < numberOfGeneration; i++){
      orderInNumbers = new List<int>();
      for(int j = 0; j < numberOfElement; j++){
        orderInNumbers.add(getGeneratedNumber2(j, rnd));
        //test.order[j].label.index = orderInNumbers.last;
        generatedStates[i].setPositionDirectly(j+1, orderInNumbers.last);
      }
      generatedStates[i].updateState();
    }
    return generatedStates;
  }

  int getGeneratedNumber(String groupID, [String segmentID = ""]){

    if(segmentID.isNotEmpty){
      int index = 0;
      do{
        int randomNum = randomGen.nextInt(this.numberOfGeneratedSegments[segmentID]) + 1;
        int sum = 0;
        index = 0;

        for(int nextPositionOccurrences in groupsProbabilityMatrixMap[groupID][segmentID]){
          sum += nextPositionOccurrences;
          if(randomNum <= sum){
            break;
          }
          index++;
        }
      }while(generatedNumbers[groupID].contains(index));
      generatedNumbers[groupID].add(index);

      return index;
    }else{
      int index = 0;
      do {
        int randomNum = randomGen.nextInt(this.numberOfGeneratedGroups) + 1;
        int sum = 0;
        index = 0;

        for(int nextPositionOccurrences in probabilityMatrixMap[groupID]){
          sum += nextPositionOccurrences;
          if (randomNum <= sum) {
            break;
          }
          index++;
        }
      }while(generatedNumbers[rootElementID].contains(index));
      generatedNumbers[rootElementID].add(index);
      return index;
    }
  }

  List<State> doStateGeneration(){
    //initGeneratedNumbers();

    for(State state in generatedStates){
      for(String groupID in groupKeys){
        for(String segmentID in segmentsKeyPerGroup[groupID]){
          state.setNewPositionForID(groupID, getGeneratedNumber(groupID));
          state.setNewPositionForID(groupID, getGeneratedNumber(groupID, segmentID), segmentID);
        }
        state.updateState();
        generatedNumbers[groupID].clear();
      }
      generatedNumbers[rootElementID].clear();
    }
    return generatedStates;
  }

  void increaseGeneratedStatesNumbers(int increaseValue){
    this.numberOfGeneratedGroups += increaseValue;
    for(String key in allSegmentsKeys){
      this.numberOfGeneratedSegments[key] += increaseValue;
    }
  }

  void updateMatrices(List<State> eliteStates){

    for(State elite in eliteStates){
      for(int i = 0; i < this.numberOfElement; i++){
        var element = elite.getElementAtIndex(i+1);
        probabilityMatrixMap[element.id][i]++;
        for(VisualObject segment in element.getChildren){
          int indexOfSegment = elite.getElementIndexByID(element.id, segment.id);
          groupsProbabilityMatrixMap[element.id][segment.id][indexOfSegment-1]++;
        }
      }
    }

    increaseGeneratedStatesNumbers(eliteStates.length);
  }

  void processGeneratedElement(List<State> generatedStates) {
    int firstError = generatedStates.first.getValue();
    int index = 0;
    elites.clear();

    //print("Error: $firstError ------ ${firstError * (marginOfError + 1.0)}");
    while(generatedStates[index].getValue() <= firstError * (marginOfError + 1.0)){
      elites.add(generatedStates[index++]);
      if(index > (generatedStates.length-1)){
        break;
      }
    }

    updateMatrices(elites);
  }

  void processGeneratedElement2(List<State> generatedStates){

    int firstError = generatedStates.first.getValue();
    int index = 0;
    elites.clear();

    //print("Error: $firstError ------ ${firstError * (marginOfError + 1.0)}");
    while(generatedStates[index].getValue() <= firstError * (marginOfError + 1.0)){
      elites.add(generatedStates[index++]);
      if(index > (generatedStates.length-1)){
        break;
      }
    }

    //print("NumberOfElites: ${elites.length}");

    List<List<int>> numbersOfLettersOccurancesInPositions = new List<List<int>>(numberOfElement);

    for(int i = 0; i < numberOfElement; i++){
      numbersOfLettersOccurancesInPositions[i] = (new List<int>.filled(numberOfElement, 0));
    }

    for(State elite in elites){
      for(int i = 0; i < elite.order.length; i++){
        int colNumber = columns[elite.getElementByPlace(i+1).id];
        numbersOfLettersOccurancesInPositions[i][colNumber]++;
      }
    }

    /*for(int j = 0; j < numberOfElement; j++){
      print("${numbersOfLettersOccurancesInPositions[j]} : ${sumInt(numbersOfLettersOccurancesInPositions[j])}");
    }*/

    //print("new generation afterprocess\n----------------------------------------------------------------------");
    for(int i = 0; i < numberOfElement; i++){
      int sum = sumInt(numbersOfLettersOccurancesInPositions[i]); //always number of Elites
      double average = avg(sum,numberOfElement);

      int increaseDivider = 0;
      int decreaseDivider = 0;

      for(int j = 0; j < numberOfElement; j++){
        if(numbersOfLettersOccurancesInPositions[i][j] > average.floor()){
          increaseDivider += ((probabilityMatrix[i][j] < 1 ? 1 : 0) * numbersOfLettersOccurancesInPositions[i][j]);
        }else if(numbersOfLettersOccurancesInPositions[i][j] < average.floor()){
          decreaseDivider += ((probabilityMatrix[i][j] > 0 ? 1 : 0) * (average.floor() - numbersOfLettersOccurancesInPositions[i][j]));
        }
      }

      /*print("sum: $sum");
      print("avg: $average");*/

      double increaseValue = probabilityConstant / increaseDivider;
      double decreaseValue = probabilityConstant / decreaseDivider;

      /*print("increaseDivider: $increaseDivider");
      print("decreaseDivider: $decreaseDivider");

      print("increaseValue: $increaseValue");
      print("decreaseValue: $decreaseValue");*/

      if(increaseDivider == 0 || decreaseDivider == 0){
        continue;
      }

      /*StringBuffer sb2 = new StringBuffer();
      sb2.write("Before: [ ");
      for(int h = 0; h < probabilityMatrix[i].length; h++){
        sb2.write("${probabilityMatrix[i][h].toStringAsFixed(3)},");
      }
      sb2.write(" ] : ${sumDouble(probabilityMatrix[i])}");

      print(sb2.toString());*/

      //Set new value for porbability matrix
      for(int j = 0; j < numberOfElement; j++){
        if(numbersOfLettersOccurancesInPositions[i][j] > average.floor() && probabilityMatrix[i][j] > 0.0){
          probabilityMatrix[i][j] += ((probabilityMatrix[i][j] < 1 ? 1 : 0) * (increaseValue * numbersOfLettersOccurancesInPositions[i][j]));
        }else if(numbersOfLettersOccurancesInPositions[i][j] < average.floor()){
          probabilityMatrix[i][j] -= ((probabilityMatrix[i][j] > 0 ? 1 : 0) * (decreaseValue * (average.floor() - numbersOfLettersOccurancesInPositions[i][j])));
        }
      }

      double negativeDifference = 0.0;
      bool isBiggerThanOne = false;
      int numberOfZeros = 0;

      /*StringBuffer sb4 = new StringBuffer();
      sb4.write("Normal: [ ");
      for(int h = 0; h < probabilityMatrix[i].length; h++){
        sb4.write("${probabilityMatrix[i][h].toStringAsFixed(3)},");
      }
      sb4.write(" ] : ${sumDouble(probabilityMatrix[i])}");

      print(sb4.toString());*/

      for(int j = 0; j < numberOfElement; j++){
        if(probabilityMatrix[i][j] <= 0.0){
          negativeDifference += probabilityMatrix[i][j];
          probabilityMatrix[i][j] = 0.0;
          numberOfZeros++;
        }else if(probabilityMatrix[i][j] > 1){
          probabilityMatrix[i][j] = 1.0;
          isBiggerThanOne = true;
          break;
        }
      }

      /*StringBuffer sb3 = new StringBuffer();
      sb3.write("Middle: [ ");
      for(int h = 0; h < probabilityMatrix[i].length; h++){
        sb3.write("${probabilityMatrix[i][h].toStringAsFixed(3)},");
      }
      sb3.write(" ] : ${sumDouble(probabilityMatrix[i])}");

      print(sb3.toString());*/

      if(isBiggerThanOne){
        for(int j = 0; j < numberOfElement; j++){
          if(probabilityMatrix[i][j] < 1){
            probabilityMatrix[i][j] = 0.0;
          }
        }
      }

      if(negativeDifference < 0) {
        double decValue = negativeDifference / (numberOfElement - numberOfZeros);
        do{
          double newDecreaseValue = 0.0;
          for (int j = 0; j < numberOfElement; j++) {
            if (probabilityMatrix[i][j] > decValue.abs()) {
              probabilityMatrix[i][j] += decValue;
            }else if(probabilityMatrix[i][j] < decValue){
              newDecreaseValue += (probabilityMatrix[i][j] - decValue);
              probabilityMatrix[i][j] = 0.0;
            }
          }
          /*StringBuffer sb = new StringBuffer();
          sb.write("After: [ ");
          for(int h = 0; h < probabilityMatrix[i].length; h++){
            sb.write("${probabilityMatrix[i][h].toStringAsFixed(3)},");
          }
          sb.write(" ] : ${sumDouble(probabilityMatrix[i])} ---- ${decValue.toStringAsFixed(3)}");

          print(sb.toString());*/
          if(newDecreaseValue < 0.0){
            decValue = newDecreaseValue;
          }else{
            decValue = 0.0;
          }
        }while(decValue > 0);

      }

      /*StringBuffer sb = new StringBuffer();
      sb.write("[ ");
      for(int h = 0; h < probabilityMatrix[i].length; h++){
        sb.write("${probabilityMatrix[i][h].toStringAsFixed(3)},");
      }
      sb.write(" ] : ${sumDouble(probabilityMatrix[i])} ---- ${negativeDifference.toStringAsFixed(3)}");

      print(sb.toString());*/

    }

    //print("Sum ----------------------------------------------------------------------");

    /*for(int j = 0; j < numberOfElement; j++){
      StringBuffer sb = new StringBuffer();
      sb.write("[ ");
      for(int h = 0; h < probabilityMatrix[j].length; h++){
        sb.write("${probabilityMatrix[j][h].toStringAsFixed(3)},");
      }
      sb.write(" ] : ${sumDouble(probabilityMatrix[j])}");

      print(sb.toString());
    }*/

  }

  double sumDouble(List<double> array){
    double sum = 0.0;
    array.forEach((a){
      sum+=a;
    });
    return sum;
  }

  int sumInt(List<int> array){
    int sum = 0;
    array.forEach((a){
      sum+=a;
    });
    return sum;
  }

  double avg(int a, int b){
    return a/b.toDouble();
  }

  State solve(State st){
    bestState = st;
    processState(st);
    int lastChange = 0;
    for(int i = 0; i < numberOfIteration; i++){
      //print("${i+1} iteration ------------------------");
      doStateGeneration();
      generatedStates.sort((a,b) => a.compareTo(b));
      if(generatedStates.first.getValue() < bestState.getValue()){
        bestState = (generatedStates.first as DiagramStateFullWithoutCopy).save().clone();
        lastChange = i;
        if(bestState.getValue() == 0){
          break;
        }
      }
      processGeneratedElement(generatedStates);
      //print("${i} - ${bestState.getValue()}");
      if((i - lastChange)>1){
        break;
      }
      /*for(int j = 0; j < numberOfElement; j++){
        print("${probabilityMatrix[j]} : ${sumDouble(probabilityMatrix[j])}");
      }*/
    }
    (bestState as DiagramStateFullWithoutCopy).finalize();
    return bestState;
  }


}