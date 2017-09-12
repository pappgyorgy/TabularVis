part of dataProcessing;

enum VisualObjectRole{
  GROUP,
  SEGMENT,
  SUB_SEGMENT
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

  /// Get the Label information of the segment
  Label get label;

  /// Get the ID of the segment
  String get id;

  /// Get the value of the segment
  dynamic get value;

  /// Get the list of the values of the children
  List get getChildrenValues;

  /// Get the list of the children
  List<VisualObject> get getChildren;

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

  @Deprecated("No usage")
  int get indexInParent;
  @Deprecated("No usage")
  void set indexInParent(int newIndex);

  @Deprecated("Moved to connection")
  bool get isHigherDim;

  @Deprecated("Moved to connection")
  void set isHigherDim(bool value);

  /// Get the connection between segments
  VisConnection get connection;
  /// Set the connection between segments
  set connection(VisConnection value);

  /// Returns child obj with [id]
  /// Default only search within its children,
  /// but we can perform a recursive search with [recursive] option
  VisualObject getChildByID(String id, [bool recursive = false]);

  @Deprecated("No usage")
  VisualObject getChildByPartialID(String id, [bool recursive = false]);

  /// Get the list of IDs of the children
  List<String> getChildrenIDs();

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
  VisualObject createChild(Label newChildLabel, dynamic value, [VisualObjectRole role = VisualObjectRole.SEGMENT]);

  /// Remove element by [id]
  void removeChild(String id, [bool needIndexUpdate = true]);

  /// Set the child [indexInParent]
  void setChildIndex(String id, int newIndex);

  /// Swap the [idOne] and [idTwo] children [indexInParent] value
  void _swapChildrenIndexValues(String idOne, String idTwo);

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
  Map<String, RangeMath<double>> divideRangeBasedOnEqualSubSegments(RangeMath dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: 0.1,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true});

  /// Divides the visual object into multiple pieces based on object children values
  Map<String, RangeMath<double>> divideRangeBasedOnChildValue(RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: null,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true});

  /// Divides the visual object into multiple pieces based on object children
  /// The new pieces has the same length
  Map<String, RangeMath<double>> divideRangeEqualParts(RangeMath<double> dividingRange,
      {List<dynamic> spaceBetweenParts,
        bool differentSpaces: false,
        dynamic defaultSpaceBetweenParts: null,
        bool inOrder: false, double shiftValue: 0.0, bool isAscending: true});

  /// Compare to segments
  int compareTo(VisualObject other);

  /// Hard copy of the element
  VisualObject copy();
}