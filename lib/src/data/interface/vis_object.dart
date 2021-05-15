part of dataProcessing;

enum VisualObjectRole{
  GROUP,
  BLOCK,
  BAR,
  ROOT
}

/// Abstract class to build the logical hierarchy from the input data
///
/// With this we build a tree which will will represent the hierarchy of the segments
/// This class represent logically all the segments in the diagram
abstract class VisualObject implements Comparable<VisualObject>{

  ///Tells what is the role of the visual object in the diagram
  VisualObjectRole role;

  /// Store all the ID of the generated Visualization object
  static List<String> listOfIDs = new List<String>();

  bool preserveOriginalOrder = false;

  /// Get the Label information of the segment
  Label get label;

  /// Get the ID of the segment
  String get id;

  String get segmentId;

  String get groupId;

  Map<String, ShapeForm> _shape = new Map<String, ShapeForm>();

  RangeMath<double> range;

  ShapeForm get elementShape => this._shape["default"];

  set elementShape(ShapeForm newShape){
    switch(this.role){
      case VisualObjectRole.GROUP:
        this._shape[this.label.id] = newShape;
        break;
      case VisualObjectRole.BLOCK:
        this._shape[this.label.id] = newShape;
        break;
      case VisualObjectRole.BAR:
        this._shape["${this.label.id}-${this.parent.id}"] = newShape;
        break;
      default:
        throw new StateError("This emlement can not have a default shape");
        break;
    }
  }

  ShapeForm setShapeByID(String ID, ShapeForm newShape){
    this._shape[ID] = newShape;
    return newShape;
  }

  ShapeForm getShapeByID(String ID){
    return this._shape[ID];
  }

  Map<String, ShapeForm> get shapeIterable => this._shape;

  /// Get the value of the segment
  dynamic get value;

  /// Get the list of the values of the children
  List<num> get getChildrenValues;

  /// Get the list of the children
  List<VisualObject> get getChildren;

  /// Get the map iterable of the children
  Iterable<VisualObject> get childrenIterable;

  /// Gives the object's number of the children
  int get numberOfChildren;

  /// Set the value of the segment
  void set value(dynamic newValue);

  /// Get the parent of the segment
  ///
  /// The top segment parent is null
  /// Only one parent / segment
  VisualObject get parent;

  /// Set parent of the segment
  /// Only one parent / segment
  void set parent(VisualObject newParent);


  int get indexInParent{
    return this.parent.label.index;
  }

  void set indexInParent(int newIndex){
    this.parent.label.index = newIndex;
  }

  int get index{
    return this.label.index;
  }

  void set index(int newIndex);

  Map<int, String> childrenIDsInOrder;

  @Deprecated("Moved to connection")
  bool get isHigherDim;

  @Deprecated("Moved to connection")
  void set isHigherDim(bool value);

  /// Get the connection between segments
  VisConnection get connection;
  /// Set the connection between segments
  set connection(VisConnection value);

  /// Value for modify objects height;
  double get scaling;
  /// Set the value for modify objects height;
  set scaling (double value);
  /// Gets the objects height with scaling
  double get heightValue;

  /// Returns child obj with [id]s
  VisualObject getChildByIDs(String firstID, [ int num = 0, String secondID, String thirdID ]);

  /// Returns child obj with [id]
  /// Default only search within its children,
  /// but we can perform a recursive search with [recursive] option
  VisualObject getChildByID(String id, [bool recursive = false]);

  @Deprecated("No usage")
  VisualObject getChildByPartialID(String id, [bool recursive = false]);

  /// Get the list of IDs of the children
  List<String> getChildrenIDs();

  /// Get the map iterable of IDs of the children
  Iterable<String> get childrenIDsIterable;

  /// Return true if the element has not parent and false otherwise
  bool isRootVisObject() => parent == null
    ? true
    : false;

  /// Returns true is value is int or double false otherwise
  bool isNumericValue()  => (value is int || value is double);

  /// Updates the value and propagates the change through the parents
  void updateValue(dynamic value);

  /// Add [element] as child
  VisualObject addChild(VisualObject element);

  /// Creates new child if it not exists already and returns with it
  /// It it is already exists then this will be the return value
  VisualObject createChild(Label newChildLabel, dynamic value, [VisualObjectRole role = VisualObjectRole.BLOCK]);

  /// Remove element by [id]
  void removeChild(String id, [bool needIndexUpdate = true]);

  /// Set the child [indexInParent]
  void setChildIndex(String id, int newIndex);

  /// Swap the [idOne] and [idTwo] children [indexInParent] value
  void swapChildrenIndexValues(String idOne, String idTwo);

  /// Get the visual object children by [tablePos]
  String getElementByTablePos(int tablePos);

  /// Get child with the given [index]
  String getElementByIndex(int index);

  /// Is there a child element with the given [id]
  bool isChildOfElement(String VisualObject);

  /// Get the connected elements
  Map<String, VisualObject> get connectedElements;

  /// Divides the visual object into multiple pieces based on object children
  /// The new pieces has the same length
  Map<String, RangeMath<double>> divideRangeBasedOnEqualSubSegmentsInside(RangeMath dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange});

  /// Divides the visual object into multiple pieces based on object children values
  Map<String, RangeMath<double>> divideRangeBasedOnChildValueInside(RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: null,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange});

  /// Divides the visual object into multiple pieces based on object children
  /// The new pieces has the same length
  Map<String, RangeMath<double>> divideRangeBasedOnEqualSubSegments(RangeMath dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange});

  /// Divides the visual object into multiple pieces based on object children values
  Map<String, RangeMath<double>> divideRangeBasedOnChildValue(RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: null,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange});

  /// Divides the visual object into multiple pieces based on object children
  /// The new pieces has the same length
  Map<String, RangeMath<double>> divideRangeEqualParts(RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: null,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true, List<RangeMath<double>> valueRange});

  int get numberOfChildWithRowLabel;

  /// Compare to segments
  int compareTo(VisualObject other);

  /// Hard copy of the element
  VisualObject copy();

  void performFunctionOnChildren(Function func);

  double getMaxValueOfChildren({int recursiveLevel = 0});

  double getMinValueOfChildren({int recursiveLevel = 0});

  int get containsUniqueBlock;

  double getScaling({VisualObjectRole typeOfScale}){}

  bool tickValueWasModified = false;

  double tickIncValue = 25.0;

  int getRangeBetweenLine(double maxValue, int numberOfLine);
}