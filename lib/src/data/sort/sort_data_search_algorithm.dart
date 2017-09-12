part of dataProcessing;

class SortDataSearchAlgorithm implements SortInfoData{
  VisualObject rootElement;

  SortDataSearchAlgorithm(this.rootElement);

  SortDataSearchAlgorithm.fromObj(SortDataSearchAlgorithm obj) {
    throw new UnimplementedError("No need for this");
  }

  void clean(){
    (rootElement as ObjectVis)._children.clear();
  }

  bool isConnected(VisualObject A, VisualObject B){
    var retVal = false;
    List<VisualObject> childrenOfA = rootElement.getChildByID(A.id, true).getChildren;
    VisualObject segmentsOfB = rootElement.getChildByID(B.id, true);

    /*for(VisualObject segmentsOfA in childrenOfA){
      for(VisualObject subSegmentsOfA in segmentsOfA.getChildren){
        if(subSegmentsOfA.connection.containsBothElement(segmentsOfB, subSegmentsOfA)){
          retVal = true;
          return retVal;
        }
      }
    };*/


    for(VisualObject child in childrenOfA){
      if(child.connection.containsBothElement(segmentsOfB, child)){
        retVal = true;
        return retVal;
      }
    };
    return retVal;
  }

  SortDataSearchAlgorithm copy() {
    return new SortDataSearchAlgorithm(this.rootElement.copy());
  }
}