part of sortConnection;

class MinConflicts implements SortAlgorithm{

  int maxStep = 10;
  MinConflicts(){}
  MinConflicts.setMaxStep(this.maxStep);

  int searchMinOne(State x, int notMoveIndex) {
    int bestIndex = -1;
    int min = 0;
    if(x.getValue() == 0){
      return bestIndex;
    }
    int strict = notMoveIndex * x.getStatePossNeighbour();
    for (int index = 1; index <= x.numberOfNeighbours(); index++) {
      if(index < strict || index > (strict + x.order.length-1)){
        if (x.diffNeighbour(index) < min) {
          bestIndex = index;
          min = x.diffNeighbour(index);
        }
        var z = x.copy();
        z.chooseNeighbour(index);
        //print("${z.order}: ${z.getValue()}");
        if(z.getValue() == 0){
          break;
        }
      }
    }
    return bestIndex;
  }

  int searchMinTwo(State x, int notMoveIndex) {
    int bestIndex = -1;
    int min = 0;
    if(x.getValue() == 0){
      return bestIndex;
    }
    int strict = notMoveIndex * x.getStatePossNeighbour();
    for (int index = 1; index <= x.numberOfNeighbours(); index++) {
      if(index < strict || index > (strict + x.listOfConnections.length-1)){
        if (x.diffNeighbour(index) < min) {
          bestIndex = index;
          min = x.diffNeighbour(index);
        }
        var z = x.copy();
        z.chooseNeighbour(index);
        //print("${z.order}: ${z.getValue()}");
        if(z.getValue() == 0){
          break;
        }
      }
    }
    return bestIndex;
  }

  int searchMinThree(State x, int notMoveIndex) {
    int bestIndex = -1;
    int min = 0;
    if(x.getValue() == 0){
      return bestIndex;
    }
    int strict = notMoveIndex * x.getStatePossNeighbour();
    for (int index = strict; index <= strict + (x.getStatePossNeighbour()-1); index++) {
        int difference = x.diffNeighbour(index);
        if (difference < min) {
          bestIndex = index;
          min = difference;
        }
        /*var z = x.copy();
        z.chooseNeighbour(index);
        print("${z.order}: ${z.getValue()}");
        if(z.getValue() == 0){
          break;
        }*/
    }
    return bestIndex;
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
      /*var z = x.copy();
        z.chooseNeighbour(index);
        print("${z.order}: ${z.getValue()}");
        if(z.getValue() == 0){
          break;
        }*/
    }
    return [bestIndex, min];
  }

  State executeMinConflictSearchOne(State x) {
    State minState = x.copy();
    for(int i = 0; i < this.maxStep; i++){
      Random rnd = new Random();
      int nextNeighbour = rnd.nextInt(x.numberOfNeighbours())+1;
      State helper = x.copy();
      helper.chooseNeighbour(nextNeighbour);
      //print("${x.order}: ${x.getValue()}");
      int indexOf = helper.order.indexOf(x.order[(nextNeighbour/(x.order.length)).floor()]);

      int bestIndex = searchMinTwo(helper, indexOf);
      if(bestIndex > -1) {
        helper.chooseNeighbour(bestIndex);
      }
      x = helper.copy();
      //print("## ${x.order}: ${x.getValue()} ##");

      if(minState.getValue() > x.getValue()){
        minState = x.copy();
      }
      if(x.getValue() == 0){
        break;
      }
    }
    return minState;
  }

  State executeMinConflictSearchTwo(State x) {
    State minState = x.copy();
    for(int i = 0; i < this.maxStep; i++){
      Random rnd = new Random();
      int nextNeighbour = rnd.nextInt(x.numberOfNeighbours())+1;
      State helper = x.copy();
      helper.chooseNeighbour(nextNeighbour);
      //print("${x.order}: ${x.getValue()}");
      int indexOf = helper.order.indexOf(x.order[(nextNeighbour/(x.listOfConnections.length)).floor()]);

      int bestIndex = searchMinOne(helper, indexOf);
      if(bestIndex > -1) {
        helper.chooseNeighbour(bestIndex);
      }
      x = helper.copy();
      //print("## ${x.order}: ${x.getValue()} ##");

      if(minState.getValue() > x.getValue()){
        minState = x.copy();
      }
      if(x.getValue() == 0){
        break;
      }
    }
    return minState;
  }

  State executeMinConflictSearchThree(State x) {
    int bestIndex = -1;
    for(int i = 0; i < this.maxStep; i++) {
      Random rnd = new Random();
      int elementToMove = (rnd.nextInt((x.numberOfNeighbours() / x.getStatePossNeighbour()).floor() - 1) + 1);

      bestIndex = searchMinThree(x, elementToMove);
      if (bestIndex > -1) {
        x.chooseNeighbour(bestIndex);
      }

      //print("## ${x.order}: ${x.getValue()} ##");

    }
    return x;
  }

  State executeMinConflictSearchThreeUpdated(State x) {
    int bestIndex = -1;
    for(int i = 0; i < this.maxStep; i++) {
      Random rnd = new Random();
      int elementToMove = (rnd.nextInt(x.numberOfNeighbours())+1 / x.getStatePossNeighbour()).floor();

      bestIndex = searchMinThree(x, elementToMove);
      if (bestIndex > -1) {
        x.chooseNeighbour(bestIndex);
      }

      //print("## ${x.order}: ${x.getValue()} ##");

    }
    return x;
  }

  State executeMinConflictSearchFour(State x) {
    int bestIndex = -1;
    int index = 0;
    do {
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
    (x as DiagramStateFullWithoutCopy).finalize();
    return x;
  }

  State solveOne(State x){
    State alma = this.executeMinConflictSearchOne(x);
    return alma;
  }

  State solveTwo(State x){
    State alma = this.executeMinConflictSearchTwo(x);
    return alma;
  }

  State solveFour(State x){
    State alma = this.executeMinConflictSearchFour(x);
    return alma;
  }

  State solveMaxMinSearch(State x){
    State alma = this.executeMinConflictSearchThree(x);
    return alma;
  }

  @override
  State solve(State x) {
    return solveFour(x);
  }
}