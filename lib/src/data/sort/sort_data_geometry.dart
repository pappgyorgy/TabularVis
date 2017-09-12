part of dataProcessing;

class sortDataGeometry {
  Random r;

  VisualObject rootElement;

  sortDataGeometry(this.rootElement);

  sortDataGeometry.fromObj(sortDataGeometry obj) {

  }

  bool isConnected(Label A, Label B){
    var retVal = false;
    List<VisualObject> childrenOfA = rootElement.getChildByID(A.id).getChildrenValues as List<VisualObject>;
    for(VisualObject child in childrenOfA){
      if(child.connection.containsElement(rootElement.getChildByID(B.id))){
        retVal = true;
        return retVal;
      }
    };
    return retVal;
  }

  void clean(){
    (rootElement as ObjectVis)._children.clear();
  }

}