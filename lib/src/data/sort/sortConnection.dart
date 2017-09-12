part of dataProcessing;

enum ConnectionPart{
  begin,
  end
}

class SortConnection{

  static int groupChildrenNum = 1000;

  RangeMath<int> connectionRange;
  Label beginGroup;
  Label begin;
  Label endGroup;
  Label end;

  int beginGroupIndex;
  int beginIndex;
  int endGroupIndex;
  int endIndex;


  SortConnection(Label begin, Label end, [Label beginGroup, Label endGroup]){
    if(begin.compareTo(end) < 0){
      this.beginGroup = beginGroup;
      this.endGroup = endGroup;
      this.begin = begin;
      this.end = end;
    }else{
      this.beginGroup = endGroup;
      this.endGroup = beginGroup;
      this.begin = end;
      this.end = begin;
    }

    connectionRange = new NumberRange<int>.fromNumbers(0, 1);
    this.beginGroupIndex = this.beginGroup.index;
    this.beginIndex = this.begin.index;
    this.endGroupIndex = this.endGroup.index;
    this.endIndex = this.end.index;

    this.connectionRange.begin = this.beginIndex + this.beginGroupIndex * groupChildrenNum;
    this.connectionRange.end = this.endIndex + this.endGroupIndex * groupChildrenNum;
  }

  int compareTo(SortConnection o) {
    int a = this.begin.index + this.beginGroup.index * groupChildrenNum;
    int b = o.begin.index + o.beginGroup.index * groupChildrenNum;
    return a.compareTo(b);
  }

  @override
  bool operator ==(Object obj){
    if(!(obj is SortConnection)) return false;
    SortConnection sortConObj = obj as SortConnection;
    return begin.id == sortConObj.begin.id && end.id == sortConObj.end.id;
  }

  int getIndex(ConnectionPart connPart){
    switch(connPart){
      case ConnectionPart.begin:
        return this.beginIndex + this.beginGroupIndex * groupChildrenNum;
      case ConnectionPart.end:
        return this.endIndex + this.endGroupIndex * groupChildrenNum;
      default:
        throw new StateError("Not valid value for swith variable (Good value = ConnectionPart) ");
        break;
    }
  }

  void setIndex(int newValue, ConnectionPart connPart){
    switch(connPart){
      case ConnectionPart.begin:
        this.beginIndex = newValue;
        this.connectionRange.begin = this.beginIndex + this.beginGroupIndex * groupChildrenNum;
        break;
      case ConnectionPart.end:
        this.endIndex = newValue;
        this.connectionRange.end = this.endIndex + this.endGroupIndex * groupChildrenNum;
        break;
      default:
        throw new StateError("Not valid value for swith variable (Good value = ConnectionPart) ");
        break;
    }
  }

  void updateIndex(State state){

    this.beginGroupIndex = state.getElementIndexByID(this.beginGroup.id);
    this.endGroupIndex = state.getElementIndexByID(this.endGroup.id);

    this.beginIndex = state.getElementIndexByID(this.beginGroup.id, this.begin.id);
    this.endIndex = state.getElementIndexByID(this.endGroup.id, this.end.id);

    this.connectionRange.begin = this.beginIndex + this.beginGroupIndex * groupChildrenNum;
    this.connectionRange.end = this.endIndex + this.endGroupIndex * groupChildrenNum;
  }

  bool equals(Object obj) {
    if(obj == null){
      return false;
    }
    if (!(obj is SortConnection)) {
      return false;
    }

    SortConnection anotherConn = obj as SortConnection;

    int a = this.beginIndex + this.beginGroupIndex * groupChildrenNum;
    int b = anotherConn.beginIndex + anotherConn.beginGroupIndex * groupChildrenNum;
    if(a.compareTo(b) != 0){
      return false;
    }

    a = this.endIndex + this.endGroupIndex * groupChildrenNum;
    b = anotherConn.endIndex + anotherConn.endGroupIndex * groupChildrenNum;
    if(a.compareTo(b) != 0){
      return false;
    }

    return true;
  }


  // 1: inside
  // 2: outside
  // 3: unclear
  int _valueInConnectionRange(int value){
    var retVal = 3;

    var firstTest = connectionRange.isValueInRange(value, RangeCloseType.endOpened);

    return retVal;
  }


  bool isConnectionCollide(SortConnection other){

    if((!connectionRange.isValueInRange(other.connectionRange.begin, RangeCloseType.openedAndClosed) &&
        connectionRange.isValueInRange(other.connectionRange.end, RangeCloseType.opened)) ||
        (!connectionRange.isValueInRange(other.connectionRange.end, RangeCloseType.openedAndClosed) &&
            connectionRange.isValueInRange(other.connectionRange.begin, RangeCloseType.opened))){
      return true;
    }

    if((connectionRange.isValueInRange(other.connectionRange.begin, RangeCloseType.opened) &&
        !connectionRange.isValueInRange(other.connectionRange.end, RangeCloseType.closed)) ||
        (connectionRange.isValueInRange(other.connectionRange.end, RangeCloseType.opened) &&
            !connectionRange.isValueInRange(other.connectionRange.begin, RangeCloseType.closed))){
      return true;
    }

    return false;

    /*bool firstTest = false;
    bool secondTest = false;

    if(connectionRange.isValueInRange(other.connectionRange.begin, RangeCloseType.endOpened)){
      if(connectionRange.isValueInRange(other.connectionRange.end, RangeCloseType.closed)){
        firstTest = false;
      }else{
        firstTest = true;
      }
    }else if(connectionRange.isValueInRange(other.connectionRange.end, RangeCloseType.opened)){
      firstTest = true;
    }else {
      firstTest = false;
    }

    return firstTest;*/

    //TODO maybe we need to test in the other way;


    /*return (!connectionRange.isValueInRange(other.connectionRange.begin, false) &&
            connectionRange.isValueInRange(other.connectionRange.end, false)) ||
            (!connectionRange.isValueInRange(other.connectionRange.end, false) &&
                connectionRange.isValueInRange(other.connectionRange.begin, false));*/
  }

  @override
  String toString(){
    return "[${begin.name} - ${beginIndex} <-> ${end.name} - ${endIndex}]";
  }

}