part of dataProcessing;

/// Implementation of VisualObject
///
/// Class to build the logical hierarchy from the input data
///
/// With this we build a tree which will will represent the hierarchy of the segments
/// This class represent logically all the segments in the diagram
class ObjectVis extends VisualObject{

  /// The label of this segment
  Label _label;

  /// The value of this segment
  dynamic _value;

  /// The children of this segment
  Map<String, ObjectVis> _children;

  /// The parent of this segment
  /// Only one parent / segment
  VisualObject _parent;

  /// Element index in the children order
  @Deprecated("No usage")
  int _indexInParent;

  @Deprecated("No usage")
  bool _isHigherDim = false;

  /// The connection between segments
  VisConnection _connection;

  /// Value for modify objects height;
  double _scaling = 1.0;

  @override
  /// Value for modify objects height;
  double get scaling => _scaling;

  RangeMath<double> range;

  @override
  /// Set the value for modify objects height;
  set scaling(double value) {
    _scaling = value;
  }

  @override
  /// Gets the objects height with scaling
  double get heightValue {
    if(parent != null){
      if(parent.parent != null){
        return this.value * this._parent.parent.scaling * this.parent.scaling;
      }else{
        return this.value * this.parent.scaling;
      }
    }else{
      return this.value * this.scaling;
    }
  }

  VisualObject get parent{
    return this._parent;
  }

  /// Get the value of the segment
  dynamic get value => this._value;

  int get index => this._label.index;

  void set index(int newIndex){
    if(this._parent != null){
      this._parent.childrenIDsInOrder[newIndex] = this.id;
    }
    this._label.index = newIndex;
  }

  /// Get the list of the values of the children
  List<num> get getChildrenValues{
    var result = new List<num>(this._children.length);
    var index = 0;
    this._children.forEach((String key, VisualObject element){
      result[index++] = element.value;
    });
    return result;
  }

  /// Get the ID of the segment
  String get id => this._label.id;

  String get groupId{
    switch(this.role){
      case VisualObjectRole.GROUP:
        return this._label.id;
        break;
      case VisualObjectRole.BLOCK:
        return this.parent.id;
        break;
      case VisualObjectRole.BAR:
        return this.parent.parent.id;
        break;
      default:
        return "";
        break;
    }
  }

  String get segmentId{
    switch(this.role){
      case VisualObjectRole.GROUP:
        throw new StateError("Group element does not has a segment parent element");
        break;
      case VisualObjectRole.BLOCK:
        return this.label.id;
        break;
      case VisualObjectRole.BAR:
        return this.parent.id;
        break;
      default:
        return "";
        break;
    }
  }

  /// Get the Label information of the segment
  Label get label => this._label;

  @Deprecated("No usage")
  bool get isHigherDim => this._isHigherDim;

  @Deprecated("No usage")
  void set isHigherDim(bool value) {this._isHigherDim = value;}

  /// Get the connection between segments
  VisConnection get connection => this._connection;

  /// Set the connection between segments
  set connection(VisConnection value) {
    this._connection = value;
  }

  /// Set the value of the segment
  void set value(dynamic newValue) {this._value = newValue;}

  /// Set parent of the segment
  /// Only one parent / segment
  void set parent(VisualObject newParent) {
    this._parent = newParent;
  }

  /// Simple constructor
  ///
  /// Visual object with basic information: [label] and [value] and optional [id]
  /// if [id] is empty then we will generate an ID
  /// default the object do not have a parent
  ObjectVis(this._label, this._value, [String id = ""]){
    if(id.isEmpty){
      this._label.id = MathFunc.generateUniqueID(Label.listOfIDs);
    }else{
      this._label.id = id;
    }
    this.childrenIDsInOrder = new Map<int, String>();
    this._parent = null;
    this.role = VisualObjectRole.ROOT;
    this._children = new Map<String, ObjectVis>();
  }

  /// constructor with parent
  ///
  /// Basic information: [label], [value] and [parent], optionally [generateID]
  /// default it will generate a new id to the object
  ObjectVis.withParent(this._label, this._value, this._parent, {bool isHigherDim: false, bool generateID: true}){
    this._isHigherDim = isHigherDim;
    if(generateID)
      this._label.id = MathFunc.generateUniqueID(Label.listOfIDs);

    this._children = new Map<String, ObjectVis>();
    this.childrenIDsInOrder = new Map<int, String>();

    this._parent.addChild(this);

    if(this.value is num){
      _propagateValueToParent(this);
    }
  }

  double _getValueOfChildren(Function typeOfValue, [int recursiveLevel = 0]){
    if(this._children.isEmpty){
      return 0.0;
    }else{
      if(recursiveLevel > 0){
        List<double> maxValue = new List(this._children.length);
        int i = 0;
        this._children.forEach((String key, ObjectVis child){
          maxValue[i] = child._getValueOfChildren(typeOfValue, recursiveLevel - 1);
        });
        return maxValue.reduce(max);
      }else{
        return this.getChildrenValues.reduce(max);
      }
    }
  }

  double getMaxValueOfChildren({int recursiveLevel = 0}){
    return this._getValueOfChildren(max, recursiveLevel);
  }

  double getMinValueOfChildren({int recursiveLevel = 0}){
    return this._getValueOfChildren(min, recursiveLevel);
  }

  int get containsUniqueBlock{
    int sum = 0;
    this._children.forEach((String key, ObjectVis child){
      if(child.label.uniqueScale){
        sum++;
      }
    });
    return sum;
  }

  int getRangeBetweenLine(double maxValue, int numberOfLine){
    if(this.label.uniqueScale){
      return (this.getMaxValueOfChildren() ~/ numberOfLine);
    }else if(this.tickValueWasModified){
      return this.tickIncValue.toInt();
    }else{
      return maxValue ~/ numberOfLine;
    }
  }

  void performFunctionOnChildren(Function func){
    this._children.forEach((String key, VisualObject child){
      func(key, child);
    });
  }

  /// Updates the value and propagates the change through the parents
  void updateValue(dynamic value){
    if(this.isNumericValue()){
      if(this.value != value){
        this.value = value - this.value;
        this._propagateValueToParent(this);
      }
    }
    this.value = value;
  }

  /// Add value recursively (up) to the tree
  void _propagateValueToParent(VisualObject obj){
    if(obj.parent != null) {
      obj.parent.value += this.value;
      _propagateValueToParent(obj.parent);
    }
  }

  /// Get the list of the children
  List<VisualObject> get getChildren{
    return new List.from(this._children.values);
  }

  /// Get the map iterable of the children
  Iterable<VisualObject> get childrenIterable => this._children.values;

  /// Get the list of the children
  Map<String, int> get getChildrenWithIndex{
    var retVal = new Map<String, int>();

    List<ObjectVis> helperList = this._children.values.toList()..sort((ObjectVis a, ObjectVis b){
      return a.label.index - b.label.index;
    });

    for(VisualObject child in helperList){
      retVal[child.label.name] = child.label.index;
    }
    return retVal;
  }

  /// Gives the object's number of the children
  int get numberOfChildren => this._children.length;

  /// Returns child obj with [id]s
  VisualObject getChildByIDs(String firstID, [ int num = 0, String secondID = "", String thirdID = "" ]){
    switch(num){
      case 0: return this._children[firstID];
        break;
      case 1: return this._children[firstID]._children[secondID];
        break;
      case 2: return this._children[firstID]._children[secondID]._children[thirdID];
        break;
      default:
        throw new StateError("Wrong number of IDs given");
        break;
    }
    /*if (this._children.containsKey(firstID)) {
      if(secondID.isNotEmpty && this._children[firstID]._children.containsKey(secondID)){
          if(thirdID.isNotEmpty && this._children[firstID]._children[secondID]._children.containsKey(thirdID)){
            return this._children[firstID]._children[secondID]._children[thirdID];
          }else
            return this._children[firstID]._children[secondID];
      }else
        return this._children[firstID];
    }*/
  }

  /// Returns child obj with [id]
  /// Default only search within its children,
  /// but we can perform a recursive search with [recursive] option
  VisualObject getChildByID(String id, [bool recursive = false]) {
    if (this._children.containsKey(id)) {
      return this._children[id];
    } else {
      if(recursive){
        VisualObject result = null;
        //TODO this is not real recursive search
        for(ObjectVis child in this._children.values){
          if(child.isChildOfElement(id)){
            result = child._children[id];
            break;
          }else{
            for(ObjectVis child2 in child._children.values){
              if(child2.isChildOfElement(id)){
                result = child2._children[id];
                break;
              }else{
                for(ObjectVis child3 in child2._children.values){
                  if(child3.isChildOfElement(id)){
                    result = child3._children[id];
                    break;
                  }
                }
                if(result != null){
                  break;
                }
              }
              if(result != null){
                break;
              }
            }
          }
        }
        if(result == null){
          throw new StateError("No child with the given id($id)");
        }else{
          return result;
        }
      }else {
        throw new StateError("No child with the given id($id)");
      }
    }

  }

  @Deprecated("No usage")
  VisualObject getChildByPartialID(String id, [bool recursive = false]) {
    if (isChildOfElementPartialID(id)) {
      return this._children[id];
    } else {
      if(recursive){
        ObjectVis result = null;
        for(ObjectVis child in this._children.values){
          if(child.isChildOfElementPartialID(id)){
            result = child._children[id];
            break;
          }
        }
        if(result == null){
          throw new StateError("No child with the given id($id)");
        }else{
          return result;
        }
      }else {
        throw new StateError("No child with the given id($id)");
      }
    }

  }

  /// Add [element] as child
  VisualObject addChild(VisualObject element){
    if(this.childrenIDsInOrder.containsKey(element.index)){
      throw new StateError("You are trying to add a new element with an index which is alredy used by one of the child element");
    }else{
      this.childrenIDsInOrder[element.index] = element.id;
    }
    return this._children[element.id] = (element as ObjectVis);
  }

  /// Creates new child from [newChildLabel] and [value] if it not exists already and returns with it
  /// It it is already exists then this will be the return value
  VisualObject createChild(Label newChildLabel, dynamic value, [VisualObjectRole role = VisualObjectRole.BLOCK]){
    if(!this.isChildOfElement(newChildLabel.id)){
      var newElement = new ObjectVis.withParent(
          newChildLabel, value, this, generateID: false);
      newElement.role = role;
      //this.addChild(newElement);
    }
    return this._children[newChildLabel.id];
  }

  /// Remove element by [id]
  void removeChild(String id, [bool needIndexUpdate = true]){
    if(this._children.length > 1){

      //Update indices
      if(needIndexUpdate) {
        int index = this._children[id].label.index;
        while ((index + 1) <= this._children.length) {
          var idNextChild = _getNextChildByIndex(index + 1);
          this._children[idNextChild].label.index = index++;
        }
      }

      this.value -= this._children[id].value;

      if(this.parent != null) {
        var nextParent = this.parent;
        while (nextParent != null) {
          nextParent.value += this._children[id].value;
          if(nextParent.parent != null){
            nextParent = nextParent.parent;
          }else{
            nextParent = null;
          }

        }
      }
      if(this._parent != null){
        this._parent.value -= this._children[id].value;
      }

      //remove obj
      this._children.remove(id);
    }else if(this._children.length == 1){
      if(this._parent != null){
       this._parent.removeChild(this.id, false);
       //(this._parent.first as ObjectVis)._children.remove(this.id);

      }
    }
    /*if(this._children[id]._children != null &&
        this._children[id]._children.length > 0){
      var removeObj = this._children[id];

    }else{
      //Update indices
      if(this._children.length > 1) {
        int index = this._children[id].label.index + 1;
        while (index <= this._children.length) {
          var idNextChild = _getNextChildByIndex(index);
          this._children[idNextChild].label.index = index++;
        }
      }
      //remove obj
      this._children.remove(id);
    }*/
    /*if(!getChildByID(id).isHigherDim){
      value = value - getChildByID(id);
    }*/
  }

  void swapChildrenIndexValues(String idToMove, String idToReplace) {
    int indexToReplace = this._children[idToReplace].index;
    int indexToMove = this._children[idToMove].index;

    //this.childrenIDsInOrder[indexToReplace] = idToMove;
    //this.childrenIDsInOrder[indexToMove] = idToReplace;

    this._children[idToReplace].index = indexToMove;
    this._children[idToMove].index = indexToReplace;
  }

  /// Get the visual object children by [tablePos]
  String getElementByTablePos(int tablePos) {
    for(String key in this._children.keys){
      if(this._children[key].label.tablePos == tablePos){
        return key;
      }
    }
    print("Return with null for ${tablePos}");
    return "";
  }

  /// Get the visual object children by [index]
  String getElementByIndex(int index) {
    for(ObjectVis child in this._children.values){
      if(child.label.index == index){
        return child.id;
      }
    }
    throw new StateError(
        "Child with index: ${index} not found in: ${this._children}");
  }

  @Deprecated("No usage")
  void setChildIndex(String id, int newIndex) {
    if(newIndex > this._children.length) throw new StateError(
        "NewIndex($newIndex) is higher than the number of the element children(${this._children.length})");
    if(isChildOfElement(id)){
      if(getChildByID(id).indexInParent != newIndex){
        String key = this.getElementByIndex(newIndex);
        this.swapChildrenIndexValues(id, key);
      }
    }else{
      throw new StateError("No child with the given id($id)");
    }
  }

  /// Is there a child element with the given [id]
  bool isChildOfElement(String id) => this._children.containsKey(id);

  @Deprecated("No usage")
  bool isChildOfElementPartialID(String id){
    for(String childID in this._children.keys){
      if(childID.contains(id)){
        return true;
      }
    }
    return false;
  }

  /// Get the list of IDs of the children
  List<String> getChildrenIDs() {
    return new List.from(this._children.keys);
  }

  /// Get the map iterable of IDs of the children
  Iterable<String> get childrenIDsIterable => this._children.keys;


  void RemoveElementBasedOnRange(List<List<double>> ranges, List<int> actions){

    RangeMath<double> finalRange;
    finalRange = new NumberRange<double>.fromNumbers(ranges[0][0], ranges[0][1]);

    for(var i = 1; i < actions.length; i++){
      switch(actions[i]){
        case 1:

          break;
        case 2:
          break;
        default:
          break;
      }
    }
  }


  @Deprecated("duplacation")
  String _getNextChildByIndex(int index){
    for(ObjectVis child in this._children.values){
      if(child.label.index == index){
        return child.id;
      }
    }
    throw new StateError(
        "Child with index: ${index} not found in: ${this._children}");
  }

  List<String> _getChildrenIDInOrder() {
    List<String> retVal = new List<String>();

    String nextElementID = "";
    for (var i = 1; i <= this._children.length; i++) {
      retVal.add(getElementByIndex(i));
    }
    return retVal;
  }

  /// Get the IDs of the visual object children in order, only the ones' which values are in the given range
  /// valueType => 0: data value, 1: number of connections in block
  Map<String, double> _getChildrenIDInOrderWithValue([List<RangeMath<double>> ranges, int valueType = 0]){
    Map<String, double> retVal = new Map<String, double>();

    String nextElementID = "";
    if(!(ranges != null && ranges.length > 0)){
      for (var i = 1; i <= this._children.length; i++) {
        nextElementID = getElementByIndex(i);
        if(valueType == 0){
          retVal[nextElementID] = this._children[nextElementID]._value;
        }else{
          if(this._children[nextElementID].role == VisualObjectRole.GROUP){
            retVal[nextElementID] = 0.0;
            this._children[nextElementID].childrenIterable.forEach((VisualObject block){
              retVal[nextElementID] += block.numberOfChildren.toDouble();
            });
          }else if(this._children[nextElementID].role == VisualObjectRole.BLOCK){
            retVal[nextElementID] = 0.0;
            retVal[nextElementID] += this._children[nextElementID].numberOfChildren.toDouble();
          }
        }
      }
    }else {
      for (var i = 1; i <= this._children.length; i++) {
        nextElementID = getElementByIndex(i);
        if(this._children[nextElementID].role == VisualObjectRole.GROUP){
          var validGroup = false;
          var sumOfBlockInRanges = 0.0;
          for(var j = 0; j < this._children[nextElementID].numberOfChildren; j++){

            var listOfBlockIDsInGroup = this._children[nextElementID].getChildrenIDs();

            for(var k = 0; k < listOfBlockIDsInGroup.length; k++ ){

              var validBlock = false;
              var listOfBarsValuesInBlock = this._children[nextElementID]._children[listOfBlockIDsInGroup[k]].getChildrenValues;
              var sumOfBarsInRanges = 0.0;

              for(var l = 0; l < listOfBarsValuesInBlock.length; l++){

                for (var m = 0; m < ranges.length; m++) {
                  if (ranges[m].isValueInRange(listOfBarsValuesInBlock[l])) {
                    validBlock = true;
                    sumOfBarsInRanges += valueType == 0 ? listOfBarsValuesInBlock[l] : 1;
                    break;
                  }
                }
              }
              if(validBlock){
                validGroup = true;
                sumOfBlockInRanges += sumOfBarsInRanges;
              }
            }
            if(validGroup){
              retVal[nextElementID] = sumOfBlockInRanges;
            }
          }

        } else if(this._children[nextElementID].role == VisualObjectRole.BLOCK){


            var validBlock = false;
            var listOfBarsValuesInBlock = this._children[nextElementID].getChildrenValues;
            var sumOfBarsInRanges = 0.0;

            for(var l = 0; l < listOfBarsValuesInBlock.length; l++){

              for (var m = 0; m < ranges.length; m++) {
                if (ranges[m].isValueInRange(listOfBarsValuesInBlock[l])) {
                  validBlock = true;
                  sumOfBarsInRanges += listOfBarsValuesInBlock[l];
                  break;
                }
              }
            }
            if(validBlock){
              retVal[nextElementID] = sumOfBarsInRanges;
            }


        }else{
          for (var j = 0; j < ranges.length; j++) {
            if (ranges[j].isValueInRange(this._children[nextElementID].value)) {
              nextElementID = getElementByIndex(i);
              retVal[nextElementID] = this._children[nextElementID]._value;
              break;
            }
          }
        }
      }
    }

    return retVal;
  }


  double _getNumbersOfConnections(){
    if(this.role == VisualObjectRole.GROUP){
      var sum = 0.0;
      this._children.forEach((String key, VisualObject child){
         sum += child.getChildren.length.toDouble();
      });
      return sum;
    }else if(this.role == VisualObjectRole.BLOCK){
      return this._children.length.toDouble();
    }else{
      return 1.0;
    }
  }

  /// Divides the visual object into multiple pieces based on object children
  /// The new pieces has the same length
  Map<String, RangeMath<double>> divideRangeBasedOnEqualSubSegmentsInside(RangeMath dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange}){

    var result = new Map<String, RangeMath<double>>();

    var numberOfElements = new List<double>();
    List<String> blocksIDsInOrder;
    Map<String, double> blocksIDsInOrderWithValues, barsIDsInOrderWithValues;

    if(inOrder){

      blocksIDsInOrder = isAscending ? _getChildrenIDInOrder().reversed.toList() : _getChildrenIDInOrder();
      //blocksIDsInOrder = _getChildrenIDInOrder().reversed.toList();
      blocksIDsInOrderWithValues = _getChildrenIDInOrderWithValue(valueRange, 1);

      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)) {
          numberOfElements.add(blocksIDsInOrderWithValues[ID]);
        }
      });
      /*blocksIDsInOrderWithValues.forEach((String ID, double value){
        sizesOfBlocks.add(blocksIDsInOrderWithValues[ID]);
      });*/

    }else {
      //TODO add rangeValue here
      this._children.forEach((String key, VisualObject child) => numberOfElements.add(child.getChildren.length.toDouble()));
    }

    //var sumOfValues = segmentsLength.reduce((a,b) => (a+b));

    /*if((defaultSpaceBetweenParts as double) > 0.0){
      defaultSpaceBetweenParts -= (sumOfValues / 360.0) * 0.5;
    }*/


    var list = dividingRange.dividePartsByValueInside(numberOfElements,
        spaceBetweenParts: spaceBetweenParts,
        differentSpaces: differentSpaces,
        defaultSpaceBetweenParts: defaultSpaceBetweenParts) as List<RangeMath<double>>;

    if(inOrder){
      var i = 0;
      var increase = 1;
      if(!isAscending){
        i = list.length - 1;
        increase = -1;
      }

      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
        }
      });
      /*blocksIDsInOrderWithValues.forEach((String ID, double value){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
      });*/
    }else {
      var i = 0;
      this._children.forEach((String key, VisualObject element) {
        result[key] = list[i++];
        result[key].begin += shiftValue;
        result[key].end += shiftValue;
      });
    }

    this._children.forEach((String key, VisualObject child){
      child.range = result[key];
    });

    return result;

  }

  /// Divides the visual object into multiple pieces based on object children values
  Map<String, RangeMath<double>> divideRangeBasedOnChildValueInside(RangeMath dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange}) {

    var result = new Map<String, RangeMath<double>>();

    List<double> values = new List<double>();
    var sizesOfBlocks = new List<double>();
    List<String> blocksIDsInOrder;
    Map<String, double> blocksIDsInOrderWithValues;

    if(inOrder){
      blocksIDsInOrder = isAscending ? _getChildrenIDInOrder().reversed.toList() : _getChildrenIDInOrder();
      blocksIDsInOrderWithValues = _getChildrenIDInOrderWithValue(valueRange, 0);

      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)){
          values.add(blocksIDsInOrderWithValues[ID]);
        }
      });
    }else {
      values = this.getChildrenValues;
    }

    var list = dividingRange.dividePartsByValueInside(values,
        spaceBetweenParts: spaceBetweenParts,
        differentSpaces: differentSpaces,
        defaultSpaceBetweenParts: defaultSpaceBetweenParts) as List<RangeMath<double>>;


    if(inOrder){
      /*var helperMap = new Map<String, RangeMath<double>>();
      int rangeIndex = 0;
      this._children.forEach((String key, VisualObject child) => helperMap[key]= list[rangeIndex++]);*/


      var i = 0;
      var increase = 1;
      if(!isAscending){
        i = list.length - 1;
        increase = -1;
      }
      /*blocksIDsInOrderWithValues.forEach((String ID, double value){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
      });*/
      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
        }
      });
    }else {
      var i = 0;
      this._children.forEach((String key, VisualObject element) {
        result[key] = list[i++];
        result[key].begin += shiftValue;
        result[key].end += shiftValue;
      });
    }

    this._children.forEach((String key, VisualObject child){
      child.range = result[key];
    });

    return result;
  }

  /// Divides the visual object into multiple pieces based on object children
  /// The new pieces has the same length
  Map<String, RangeMath<double>> divideRangeBasedOnEqualSubSegments(RangeMath dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange}){

    var result = new Map<String, RangeMath<double>>();

    var numberOfElements = new List<double>();
    List<String> blocksIDsInOrder;
    Map<String, double> blocksIDsInOrderWithValues, barsIDsInOrderWithValues;

    if(inOrder){

      blocksIDsInOrder = isAscending ? _getChildrenIDInOrder().reversed.toList() : _getChildrenIDInOrder();
      //blocksIDsInOrder = _getChildrenIDInOrder().reversed.toList();
      blocksIDsInOrderWithValues = _getChildrenIDInOrderWithValue(valueRange, 1);

      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)) {
          numberOfElements.add(blocksIDsInOrderWithValues[ID]);
        }
      });
      /*blocksIDsInOrderWithValues.forEach((String ID, double value){
        sizesOfBlocks.add(blocksIDsInOrderWithValues[ID]);
      });*/

    }else {
      //TODO add rangeValue here
      this._children.forEach((String key, VisualObject child) => numberOfElements.add(child.getChildren.length.toDouble()));
    }

    //var sumOfValues = segmentsLength.reduce((a,b) => (a+b));

    /*if((defaultSpaceBetweenParts as double) > 0.0){
      defaultSpaceBetweenParts -= (sumOfValues / 360.0) * 0.5;
    }*/


    var list = dividingRange.dividePartsByValue(numberOfElements,
        spaceBetweenParts: spaceBetweenParts,
        differentSpaces: differentSpaces,
        defaultSpaceBetweenParts: defaultSpaceBetweenParts) as List<RangeMath<double>>;

    if(inOrder){
      var i = 0;
      var increase = 1;
      if(!isAscending){
        i = list.length - 1;
        increase = -1;
      }

      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
        }
      });
      /*blocksIDsInOrderWithValues.forEach((String ID, double value){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
      });*/
    }else {
      var i = 0;
      this._children.forEach((String key, VisualObject element) {
        result[key] = list[i++];
        result[key].begin += shiftValue;
        result[key].end += shiftValue;
      });
    }

    this._children.forEach((String key, VisualObject child){
      child.range = result[key];
    });

    return result;

  }

  /// Divides the visual object into multiple pieces based on object children values
  Map<String, RangeMath<double>> divideRangeBasedOnChildValue(RangeMath dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange}) {

    var result = new Map<String, RangeMath<double>>();

    List<double> values = new List<double>();
    var sizesOfBlocks = new List<double>();
    List<String> blocksIDsInOrder;
    Map<String, double> blocksIDsInOrderWithValues;

    if(inOrder){
      blocksIDsInOrder = isAscending ? _getChildrenIDInOrder().reversed.toList() : _getChildrenIDInOrder();
      blocksIDsInOrderWithValues = _getChildrenIDInOrderWithValue(valueRange, 0);

      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)){
          values.add(blocksIDsInOrderWithValues[ID]);
        }
      });
    }else {
      values = this.getChildrenValues;
    }

    var list = dividingRange.dividePartsByValue(values,
        spaceBetweenParts: spaceBetweenParts,
        differentSpaces: differentSpaces,
        defaultSpaceBetweenParts: defaultSpaceBetweenParts) as List<RangeMath<double>>;


    if(inOrder){
      /*var helperMap = new Map<String, RangeMath<double>>();
      int rangeIndex = 0;
      this._children.forEach((String key, VisualObject child) => helperMap[key]= list[rangeIndex++]);*/


      var i = 0;
      var increase = 1;
      if(!isAscending){
        i = list.length - 1;
        increase = -1;
      }
      /*blocksIDsInOrderWithValues.forEach((String ID, double value){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
      });*/
      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
        }
      });
    }else {
      var i = 0;
      this._children.forEach((String key, VisualObject element) {
        result[key] = list[i++];
        result[key].begin += shiftValue;
        result[key].end += shiftValue;
      });
    }

    this._children.forEach((String key, VisualObject child){
      child.range = result[key];
    });

    return result;
  }

  /// Divides the visual object into multiple pieces based on object children
  /// The new pieces has the same length
  @override
  Map<String, RangeMath<double>> divideRangeEqualParts(RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: null,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange}) {
    var result = new Map<String, RangeMath<double>>();

    int values;
    List<String> blocksIDsInOrder;
    Map<String, double> blocksIDsInOrderWithValues;

    if(inOrder){
      blocksIDsInOrder = isAscending ? _getChildrenIDInOrder().reversed.toList() : _getChildrenIDInOrder();
      blocksIDsInOrderWithValues = _getChildrenIDInOrderWithValue(valueRange, 0);

      values = blocksIDsInOrderWithValues.length;
    }else {
      values = this.getChildrenValues.length;
    }

    var list = dividingRange.divideEqualParts(values,
        spaceBetweenParts: spaceBetweenParts,
        differentSpaces: differentSpaces,
        defaultSpaceBetweenParts: defaultSpaceBetweenParts) as List<RangeMath<double>>;

    if(inOrder){
      /*var helperMap = new Map<String, dynamic>();
      int rangeIndex = 0;
      this._children.forEach((String key, VisualObject child) => helperMap[key]= list[rangeIndex++]);*/

      //List<String> childrenIDInOrder = _getChildrenIDInOrderWithValue(valueRange).reversed.toList();
      var i = list.length-1;
      var increase = -1;
      if(isAscending){
        i = 0;
        increase = 1;
      }

      /*blocksIDsInOrderWithValues.forEach((String ID, double value){
        result[ID] = list[i];
        result[ID].begin += shiftValue;
        result[ID].end += shiftValue;
        i += increase;
      });*/
      blocksIDsInOrder.forEach((String ID){
        if(blocksIDsInOrderWithValues.containsKey(ID)){
          result[ID] = list[i];
          result[ID].begin += shiftValue;
          result[ID].end += shiftValue;
          i += increase;
        }
      });

    }else {
      var i = 0;
      this._children.forEach((String key, VisualObject element) {
        result[key] = list[i++];
        result[key].begin += shiftValue;
        result[key].end += shiftValue;
      });
    }

    this._children.forEach((String key, VisualObject child){
      child.range = result[key];
    });

    return result;
  }

  /// Hard copy of the element
  @override
  VisualObject copy(){
    //find root element
    VisualObject possibleRootElement = this;
    while(possibleRootElement.parent != null){
      possibleRootElement = possibleRootElement.parent;
    }

    var newRootElement = new ObjectVis(this.label.copy(), this.value);
    ConnectionManager.listOfConnection[newRootElement.id] =
        new Map<String, ConnectionVis>();
    _addChildrenToElement(newRootElement, possibleRootElement);
    _addConnectionToElement(newRootElement, possibleRootElement);

    return newRootElement;
  }

  /// This will recursively add the element to the new root from the other one
  void _addChildrenToElement(ObjectVis to, ObjectVis from){
    from._children.forEach((String id, ObjectVis element){
      var elementCopy = new ObjectVis.withParent(element.label.copy(), element.value, to, generateID: false);
      elementCopy.role = element.role;
      if(element.getChildrenValues.length > 0){
        _addChildrenToElement(elementCopy, element);
      }
    });
  }

  /// This will recursively add the connection to the new element from the other one
  void _addConnectionToElement(ObjectVis newRootElement, ObjectVis from){
    if(ConnectionManager.listOfConnection[from.id] == null) return;

    ConnectionManager.listOfConnection[from.id].forEach((String key, VisConnection conn){
      var segmentA = newRootElement.getChildByID(conn.segmentOneID, true);
      var segmentB = newRootElement.getChildByID(conn.segmentTwoID, true);

      ConnectionManager.createNewConnection(segmentA, segmentB, newRootElement.id);
    });

    /*from._children.forEach((String id, ObjectVis element){
      if(element.connection != null){
        var segmentA = newRootElement.getChildByID(element.connection.segmentOneID, true);
        var segmentB = newRootElement.getChildByID(element.connection.segmentTwoID, true);
        newRootElement.getChildByID(element.id, true).connection =
        new ConnectionVis(segmentA, segmentB, element.connection.nameOfConn).._config =
            (element.connection as ConnectionVis)._config;

      }
      if(element.getChildrenValues.length > 0){
        _addConnectionToElement(newRootElement, element);
      }
    });*/
  }

  /// The string representation of the visual object
  @override
  String toString() {
    return "${this.label} ||\n Value: ${this._value} ||\n child length: ${this._children.length} ||--||\n";
  }

  int get numberOfChildWithRowLabel{
    int rowNum = 0;
    this._children.forEach((String key, VisualObject element){
      if(element.label.isRow){
        rowNum++;
      }
    });
  }

  /// Compare to segments
  @override
  int compareTo(VisualObject other) {
    // TODO: implement compareTo
    throw new UnimplementedError("I have no idea how I will need to compare these ones");
  }

  // Get the connected elements
  Map<String, VisualObject> get connectedElements{
    var retVal = new Map<String, VisualObject>();
    if(this.role != VisualObjectRole.GROUP){
      this._children.forEach((String id, VisualObject element){
        if(element.connection != null){
          retVal[id] = element.connection.getOtherSegment(element);
        }
      });
    }else{
      this._getChildrenIDInOrder().forEach((String id){
        ObjectVis element = this._children[id];

        /*element._getChildrenIDInOrder().forEach((String subId){
          VisualObject subElement = element._children[subId];
        });*/
        element._children.forEach((String subId, VisualObject subElement){
          if(subElement.connection != null){
            retVal[subId] = subElement.connection.getOtherSegment(subElement).parent;
          }
        });

        if(element.connection != null){
          retVal[id] = element.connection.getOtherSegment(element);
        }
      });
    }

    /*this._children.forEach((String id, VisualObject element){
      if(element.connection != null){
        retVal[id] = element.connection.getOtherSegment(element);
      }
    });

    if(this.connection != null){
      retVal[this.id] = this.connection.getOtherSegment(this);
    }*/

    return retVal;
  }
}