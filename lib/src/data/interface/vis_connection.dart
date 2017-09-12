part of dataProcessing;

/// Abstract class for the represent the connections logically
abstract class VisConnection{

  /// Get Configuration information for the connection
  ConnConfig get config;

  /// Get the segment config information based on the given [ID] as a list of doubles
  List<double> getSegmentConfig(String ID);

  /// Get the line config information based on the given [ID] as a list of doubles
  List<double> getLineConfig();

  /// Get the sub connection config information based on the given [ID] and [ShapeType] as a list of doubles
  List<double> getSubConnectionConfig(String ID, ShapeType type);

  /// Get the connection config information
  List<double> getConnectionConfig();

  /// Set connection information
  set config(dynamic value);

  /// Set the configuration with some basic value
  /// Like: [nameOfConn], [connectionColor], [segmentOneColor],  [segmentTwoColor]
  void setConfigWithColor(String nameOfConn, Color connectionColor, Color segmentOneColor, Color segmentTwoColor);

  /// Get the connection direction
  /// 0 no direction
  /// 1 segmentOne -> segmentTwo
  /// 2 segmentTwo -> segmentOne
  int get direction;

  /// Set the connection direction
  /// 0 no direction
  /// 1 segmentOne -> segmentTwo
  /// 2 segmentTwo -> segmentOne
  set direction(int value);

  /// Get the ID of the second segment
  String get segmentTwoID;

  /// Get the ID of the first segment
  String get segmentOneID;

  /// Get the name of the connection
  String get nameOfConn;

  /// Get the second segment
  VisualObject get segmentTwo;

  /// Set the second segment
  set segmentTwo(VisualObject value);

  /// Get the first segment
  VisualObject get segmentOne;

  /// Set the first segment
  set segmentOne(VisualObject value);

  /// Do we will fill the connection
  bool get isFullConn;

  /// Set do we will fill the connection
  set isFullConn(bool value);

  /// Modify the colors of the main segments
  /// You can set random colors with [isRandom]
  void modifyMainSegmentsColorFromList(bool isRandom);

  /// Decide does both side of the connection is in the root?
  bool isConnectionNeeded(VisualObject root, List<String> allLabelID);

  /// Get the other segment then this [segment]
  VisualObject getOtherSegment(VisualObject segment);

  /// Get the list of the sub connection configs
  List<SubConnConfig> get listOfSubConnConfig;

  /// Get the sub connection config based on the given [ID]
  SubConnConfig getSubConnConfigByID(String ID);

  /// Add new sub connection config with [ID]
  void addSubConnConfigByID(String ID);

  /// Does this connection contains element
  bool containsElement(VisualObject childByID);

  /// Does this connection contains booth element
  bool containsBothElement(VisualObject A, VisualObject B);

  /// Update the colors of the segment and the connection based on the diagram coloring settings
  void updateColors();
}