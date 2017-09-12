part of sortConnection;

class CrossEntropyBuiltInMinConflicts extends CrossEntropy{

  MinConflicts minConfSearch = new MinConflicts.setMaxStep(3);

  void processState2(State x){
    this.startState = x;
    for(var i = 1; i <= this.startState.order.length; i++){
      columns[this.startState.getElementByPlace(i).id] = i-1;
    }

    numberOfGeneration = 10;
    numberOfIteration = 5;

    numberOfElement = startState.order.length;
    numberOfElite = min(2, (numberOfGeneration * 0.3).floor());
    probabilityMatrix = new List<List<double>>(numberOfElement);

    double value = 1.0/(numberOfElement);

    probabilityMatrix[0] = (new List<double>.filled(numberOfElement, 0.0));
    probabilityMatrix[0][0] = 1.0;

    for(int i = 1; i < numberOfElement; i++){
      probabilityMatrix[i] = (new List<double>.filled(numberOfElement, value));
      //probabilityMatrix[i][i] = 0.0;
    }

    generatedStates = new List<State>(numberOfGeneration);
    for(int i = 0; i < numberOfGeneration; i++){
      generatedStates[i] = startState.clone();
    }

    elites = new List<State>();
    orderInNumbers = new List<int>();
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

    for(var i = 0; i < elites.length; i++){
      minConfSearch.solve(elites[i]);
    }

    /*elites.forEach((State x){
      //print("worst: ${x.getValue()}");
      var newState = minConfSearch.solve(x.copy());
      elites.add(newState.copy());
      //print("new: ${newState.getValue()}");
    });*/


    updateMatrices(elites);
  }

  void processGeneratedElement2(List<State> generatedStates){

    int firstError = generatedStates.first.getValue();
    int index = 0;
    elites.clear();

    /*var worstElementsError = generatedStates.last.getValue();
    List<State> worstElements = new List<State>();
    index = generatedStates.length-1;

    //Select the worst elements from the generated lists

    while(generatedStates[index].getValue() >= worstElementsError * (1.0 - marginOfError)){
      worstElements.add(generatedStates[index--]);
      if(worstElements.length > (generatedStates.length-1) || worstElements.length <= numberOfElite){
        break;
      }
    }

    //generate good elements from the bad ones with min conflicts algorithm
    worstElements.forEach((State x){
      //print("worst: ${x.getValue()}");
      var newState = minConfSearch.solve(x);
      elites.add(newState);
      //print("new: ${newState.getValue()}");
    });*/

    List<State> bestElements = new List<State>();

    //Select the worst elements from the generated lists

    while(generatedStates[index].getValue() <= firstError * (marginOfError + 1.0)){
      bestElements.add(generatedStates[index]);
      if(bestElements.length > (generatedStates.length-1) || bestElements.length >= numberOfElite){
        break;
      }
    }

    //generate good elements from the bad ones with min conflicts algorithm
    bestElements.forEach((State x){
      //print("worst: ${x.getValue()}");
      var newState = minConfSearch.solve(x.copy());
      elites.add(newState.copy());
      //print("new: ${newState.getValue()}");
    });

    //print("Error: $firstError ------ ${firstError * (marginOfError + 1.0)}");
    /*while(generatedStates[index].getValue() <= firstError * (marginOfError + 1.0)){
      elites.add(generatedStates[index++]);
      if(index > (generatedStates.length-1)){
        break;
      }
    }*/

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
      var notNullElement = 0;
      for(var k = 0; k  < numberOfElement; k++){
        if(numbersOfLettersOccurancesInPositions[i][k] > 0){
         notNullElement++;
        }
      }
      double average = avg(sum,notNullElement);

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

    /*StringBuffer sb5 = new StringBuffer();
    for(int i = 0; i < numberOfElement; i++) {
      sb5.write("[ ");
      for (int h = 0; h < probabilityMatrix[i].length; h++) {
        sb5.write("${probabilityMatrix[i][h].toStringAsFixed(3)},");
      }
      sb5.write(
          " ] : ${sumDouble(probabilityMatrix[i])} \n");

    }
    print(sb5.toString());
    var a = 0;*/

  }

  State solve(State st){
    bestState = st;
    processState(st);
    int lastChange = 0;
    for(int i = 0; i < numberOfIteration; i++){
      //print("${i+1} iteration ------------------------");
      doStateGeneration();
      /*for(var i = 0; i < generatedStates.length; i++){
        var test = minConfSearch.solve(generatedStates[i]);
        generatedStates[i] = test;
      }*/
      generatedStates.sort((a,b) => a.compareTo(b));

      processGeneratedElement(generatedStates);

      if(generatedStates.first.getValue() < bestState.getValue()){
        bestState = (generatedStates.first as DiagramStateFullWithoutCopy).save().clone();
        lastChange = i;
        if(bestState.getValue() == 0){
          break;
        }
      }

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