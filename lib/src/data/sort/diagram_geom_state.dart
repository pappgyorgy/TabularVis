part of dataProcessing;

class DiagramGeomState extends State{

  String get status{
    /*var printList = new List<String>();
    var sb = new StringBuffer();
    for(var i = 1; i <= orderTemp.length; i++){
      var element = getElementAtIndex(i);
      sb.write("{${element.label.name}: ");
      var firstOne = true;
      for(var j = 1; j <= orderSegmentTemp[element.id].length; j++){
        if(firstOne){
          sb.write("${getElementAtIndex(i, j).label.name}");
          firstOne = false;
        }else{
          sb.write(",${getElementAtIndex(i, j).label.name}");
        }

      }
      sb.write("}");
      printList.add(sb.toString());
    }
    print("${printList} :::: ${this.numberOfIntersection}");
    return "${printList} :::: ${this.numberOfIntersection}";*/
  }

  int getElementIndexByID(String groupID, [String segmentID = ""]){
    throw new UnimplementedError("unimplemented");
  }

  @override
  void calculate() {
    // TODO: implement calculate
  }

  @override
  void changeStateByOrder(dynamic order) {
    // TODO: implement changeStateByOrder
  }

  @override
  void chooseNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = false, int startRange = 1, int endRange = -1}) {
    // TODO: implement chooseNeighbour
  }

  @override
  void clean() {
    // TODO: implement clean
  }

  @override
  int compareTo(State o) {
    // TODO: implement compareTo
  }

  @override
  State copy() {
    // TODO: implement copy
  }

  @override
  int diffNeighbour(int neighbour, {bool isPermanent = false, bool enablePreCalculate = false, int startRange = 1, int endRange = -1}) {
    // TODO: implement diffNeighbour
  }

  @override
  int diffNeighbourByOrder(dynamic order) {
    // TODO: implement diffNeighbourByOrder
  }

  @override
  int getStatePossNeighbour([VisualObject object]) {
    // TODO: implement getStatePossNeighbour
  }

  @override
  int getValue() {
    // TODO: implement getValue
  }


  @override
  State clone() {

  }

  @override
  List<int> maxConflictNeighbour() {
    // TODO: implement maxConflictNeighbour
  }

  @override
  int numberOfNeighbours([VisualObject object]) {
    // TODO: implement numberOfNeighbours
  }

  @override
  Map<int, String> get orderID {
    // TODO: implement numberOfNeighbours
  }

  @override
  State chooseRandomState({bool setFinalOrder = true, bool enablePreCalculation = false, bool enableHelper = false}) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  State updateFromFinalOrder() {
    throw new UnimplementedError("unimplemented");
  }

  @override
  State finalize() {
    throw new UnimplementedError("unimplemented");
  }

  @override
  State save() {
    throw new UnimplementedError("unimplemented");
  }

  @override
  List<String> get orderPos {
    throw new UnimplementedError("unimplemented");
  }

  @override
  void setNewPositionForID(String groupID, int newValue,
      [String segmentID = ""]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  void setNewPositionForIndex(int index, int newValue,
      [int segmentIndex = -1]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  VisualObject getElementByPosition(int position, [int segmentPosition = -1]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  int getElementPositionByIndex(int index, [int segmentIndex = -1]) {
    throw new UnimplementedError("unimplemented");
  }

  @override
  VisualObject getElementAtIndex(int index, [int segmentIndex = -1]) {
    throw new UnimplementedError("unimplemented");
  }


}