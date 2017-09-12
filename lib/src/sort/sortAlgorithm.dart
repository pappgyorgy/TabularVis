part of sortConnection;

abstract class SortAlgorithm{

  factory SortAlgorithm(SortAlgorithmType type){
    switch(type){
      case SortAlgorithmType.hillClimb:
          return new HillClimbingTool();
        break;
      case SortAlgorithmType.minConf:
          return new MinConflicts();
        break;
      case SortAlgorithmType.crossEntropy:
          return new CrossEntropy();
        break;
      case SortAlgorithmType.crossEntropyMinConf:
          return new CrossEntropyMinConf();
        break;
      case SortAlgorithmType.crossEntropyMod:
        return new CrossEntropyBuiltInMinConflicts();
        break;
      case SortAlgorithmType.simulatedAnnealing:
        return new SimulatedAnnealing();
        break;
      case SortAlgorithmType.beesAlgorithm:
        return new BeesAlgorithm();
        break;
      default:
        throw new StateError("This kind of sorting algorithm is not exist in this software");
        break;
    }
  }

  State solve(State x);


}