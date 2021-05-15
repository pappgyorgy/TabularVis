part of sortConnection;

class CrossEntropyMinConf implements SortAlgorithm{

  CrossEntropy crossEntropy;
  MinConflicts minConflicts;

  CrossEntropyMinConf(){
    this.crossEntropy = new CrossEntropy();
    this.minConflicts = new MinConflicts();
  }

  @override
  State solve(State x) {
    var sortStateOne = crossEntropy.solve(x);
    //print("Cross entropy min conflict - after state one: ${sortStateOne.getValue()}");

    var sortStateFinal = minConflicts.solve(x);
    if(sortStateOne.getValue() < sortStateFinal.getValue()){
      return sortStateOne;
    }else{
      return sortStateFinal;
    }

  }
}