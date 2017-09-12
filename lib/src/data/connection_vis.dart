part of dataProcessing;

enum DiagramColoring{
  circos,
  valueWithTwoColor
}

/// Abstract class for the represent the connections logically
class ConnectionVis implements VisConnection{

  /// List of the main segments' color
  static Map<String, Color> mainSegmentsColor = new Map<String, Color>();
  /// List of the main segments' random color
  static Map<String, Color> mainSegmentsColorRandom = new Map<String, Color>();

  /// Main segments color range
  static ColorRange mainSegmentsColorRange = new ColorRange.fromColors(
      new Color.fromArray([1.0,0.0,0.0]),
      new Color.fromArray([1.0,0.0,0.0])
  );

  /// Main segments random color range
  static ColorRange mainSegmentsColorRangeRandom = new ColorRange.fromColors(
      new Color.fromArray([0.0,0.0,0.0]),
      new Color.fromArray([1.0,1.0,1.0])
  );

  static Color maxColor = new Color(0xFF0000);
  static Color minColor = new Color(0x00FF00);
  static Color unifiedColor = new Color(0xAAAAAA);

  static void resetMainSegmentColorRange(){
    mainSegmentsColorRange = new ColorRange.fromColors(
        new Color.fromArray([1.0,0.0,0.0]),
        new Color.fromArray([1.0,0.0,0.0])
    );
  }

  static void updateMainSegmentColorRangeDefaultIncreaseValue(int numberOfSegments){
    mainSegmentsColorRange.defaultChangeValue = new Color.fromArray([1.0 / numberOfSegments,0.0,0.0]);
  }

  /// Initialize the colors of the main segments from the object hierarchy [root]
  static void initializeMainSegmentsColors(VisualObject root){
    root.getChildren.forEach((VisualObject child){
      mainSegmentsColor[child.id] = mainSegmentsColorRange.getRangeNextElement();
    });
  }

  /// Do we use random color
  static bool diagramColoringWithRandom = false;

  /// Update the colors of the main segments form the hierarchy [root]
  static void updateMainSegmentsColors(VisualObject root){
    ConnectionVis.resetMainSegmentColorRange();

    int sumOfNumberOfSegments = 0;
    for(VisualObject group in root.getChildren){
      sumOfNumberOfSegments += group.numberOfChildren;
    }

    /*if(sumOfNumberOfSegments >= 10) {
      ConnectionVis.updateMainSegmentColorRangeDefaultIncreaseValue(
          sumOfNumberOfSegments);
    }*/

    ConnectionVis.updateMainSegmentColorRangeDefaultIncreaseValue(
          sumOfNumberOfSegments);

    var segmentsWithColors = mainSegmentsColor.keys.toList();

    for(var i = 1; i <= root.getChildren.length; i++){
      var nextGroupID = root.getElementByIndex(i);
      var nextGroup = root.getChildByID(nextGroupID);
      for(var j = 1; j <= nextGroup.getChildren.length; j++) {
        var nextSegmentId = nextGroup.getElementByIndex(j);
        //var nextSegment = root.getChildByID(nextSegmentId);

        if (!mainSegmentsColor.containsKey(nextSegmentId)) {
          mainSegmentsColor[nextSegmentId] =
              mainSegmentsColorRange.getRangeNextElement();
          mainSegmentsColorRandom[nextSegmentId] =
              mainSegmentsColorRangeRandom.getRandomValueFromRange();
        }
        segmentsWithColors.remove(nextSegmentId);
      }
    }
    segmentsWithColors.forEach((String key) => mainSegmentsColor.remove(key));
    segmentsWithColors.forEach((String key) => mainSegmentsColorRandom.remove(key));
  }

  /// Update the corresponding min and max value for the min color and max color
  /// Example: min color green max color red
  /// update the min value which means pure green and max value which means pure red
  static void updateMinMaxColorValue(VisualObject root){
    root.getChildren.forEach((VisualObject group){
      group.getChildren.forEach((VisualObject block){
        block.getChildren.forEach((VisualObject bar) {
          double barValue = bar.value.toDouble() as double;
          if (barValue > maxValueForRed) {
            maxValueForRed = barValue;
          } else if (barValue < minValueForBlue) {
            minValueForBlue = barValue;
          }
        });
      });
    });
  }

  /// How we can set the color of the segments and connection [DiagramColoring]
  static DiagramColoring coloringScheme = DiagramColoring.circos;

  /// The max value for red
  static double maxValueForRed = 0.0;
  /// The min value for blue
  static double minValueForBlue = 0.0;

  int _direction = 0;

  /// Get the connection direction
  /// 0 no direction
  /// 1 segmentOne -> segmentTwo
  /// 2 segmentTwo -> segmentOne
  int get direction => this._direction;

  /// Set the connection direction
  /// 0 no direction
  /// 1 segmentOne -> segmentTwo
  /// 2 segmentTwo -> segmentOne
  set direction(int value){
    this._direction = value;
  }

  /// The first segment
  VisualObject _segmentOne;

  /// The second segment
  VisualObject _segmentTwo;

  /// The list of sub connection config
  Map<String, SubConnConfig> _listOfSubConnConfig;

  /// The configuration settings of the connection
  ConnConfig _config;

  /// Simple constructor
  ///
  /// The two segment which we want to connect [segmentOne] and [segmentTwo] and the name of the connection
  ConnectionVis(this._segmentOne, this._segmentTwo, String nameOfConn) {
    this._config = new ConfigConn(nameOfConn);
    this._config.segmentOneColor = mainSegmentsColor[this._segmentOne.parent.id];
    this._config.segmentTwoColor = mainSegmentsColor[this._segmentTwo.parent.id];
    this._config.connectionColor = mainSegmentsColor[this._segmentOne.parent.id];
    if(!this.isFullConn){
      this._listOfSubConnConfig = new Map<String, SubConnConfig>();
    }
  }

  /// Constructor with addition inform.
  ///
  /// The simple constructor with colors for the two segment and the connection
  ConnectionVis.withAdditionInform(this._segmentOne, this._segmentTwo,
      String nameOfConn, Color connectionColor,
      Color segmentOneColor, Color segmentTwoColor){
    this._config = new ConfigConn.withColor(nameOfConn, connectionColor, segmentOneColor, segmentTwoColor);
    if(!this.isFullConn){
      this._listOfSubConnConfig = new Map<String, SubConnConfig>();
    }
  }

  /// Update the colors of the segment and the connection based on the diagram coloring settings
  void updateColors(){
    modifyMainSegmentsColorFromList(ConnectionVis.diagramColoringWithRandom);
  }

  /// Modify the colors
  void modifyMainSegmentsColorFromList(bool isRandom){
    if(isRandom){
      for(var i = 0; i < mainSegmentsColorRandom.length; i++){
        mainSegmentsColorRandom[mainSegmentsColorRandom.keys.elementAt(i)] =
            mainSegmentsColorRangeRandom.getRandomValueFromRange();
      }

      this._config.segmentOneColor = mainSegmentsColorRandom[this._segmentOne.parent.id];
      this._config.segmentTwoColor = mainSegmentsColorRandom[this._segmentTwo.parent.id];
      this._config.connectionColor = mainSegmentsColorRandom[this._segmentOne.parent.id];
    }else{
      this._config.segmentOneColor = mainSegmentsColor[this._segmentOne.parent.id];
      this._config.segmentTwoColor = mainSegmentsColor[this._segmentTwo.parent.id];
      this._config.connectionColor = mainSegmentsColor[this._segmentOne.parent.id];
    }
    ConnectionVis.diagramColoringWithRandom = isRandom;
  }

  /// Get Configuration information for the connection
  ConnConfig get config => this._config;

  /// Get the segment config information based on the given [ID] as a list of doubles
  List<double> getSegmentConfig(String ID){
    switch(ConnectionVis.coloringScheme){
      case DiagramColoring.circos:
          if(segmentOne.id == ID){
            return [this._config.segmentOneColor.r, this._config.segmentOneColor.g, this._config.segmentOneColor.b,
            this._config.segmentOneOpacity];
          }else{
            return [this._config.segmentTwoColor.r, this._config.segmentTwoColor.g, this._config.segmentTwoColor.b,
            this._config.segmentTwoOpacity];
          }
        break;
      case DiagramColoring.valueWithTwoColor:
          var connColor = getColorBasedOnValue((this._segmentOne.value as num).toDouble());
          connColor.add(this._config.segmentOneOpacity);
          return connColor;
        break;
      default:
        throw new StateError("This kind of coloring scheme is not exists");
        break;
    }
  }

  /// Get the sub connection config information based on the given [ID] and [ShapeType] as a list of doubles
  List<double> getSubConnectionConfig(String ID, ShapeType type){
    if(this._listOfSubConnConfig == null)
      throw new StateError("No subConfig exists");

    switch(type){
      case ShapeType.line :
        return [this._listOfSubConnConfig[ID].lineColor.r,
                this._listOfSubConnConfig[ID].lineColor.g,
                this._listOfSubConnConfig[ID].lineColor.b];
      case ShapeType.mesh :
          return [this._listOfSubConnConfig[ID].connectionColor.r,
                  this._listOfSubConnConfig[ID].connectionColor.g,
                  this._listOfSubConnConfig[ID].connectionColor.b,
                  this._listOfSubConnConfig[ID].connOpacity];
      default:
        throw new StateError("Bad config type: $type");
    }

  }

  /// Get the line config information based on the given [ID] as a list of doubles
  List<double> getLineConfig(){
    return [this._config.lineColor.r, this._config.lineColor.g, this._config.lineColor.b];
  }

  /// Get the connection config information
  List<double> getConnectionConfig(){
    switch(ConnectionVis.coloringScheme){
      case DiagramColoring.circos:
        return [this._config.connectionColor.r, this._config.connectionColor.g, this._config.connectionColor.b,
        this._config.connOpacity];
        break;
      case DiagramColoring.valueWithTwoColor:
        var connColor = getColorBasedOnValue((this._segmentOne.value as num).toDouble());
        connColor.add(this._config.connOpacity);
        return connColor;
        break;
      default:
        throw new StateError("This kind of coloring scheme is not exists");
        break;
    }
  }


  /// Get a color from the given [value] as described below
  ///
  /// HSL color
  /// blue: 0.5,1.0,0.5
  /// red: 1.0,1.0,0.5
  /// max - min value will be the length
  /// we need to map length to 0.0 - 0.5
  /// this will be our color value
  /// then we add this value to the blue color and we will get the actual color
  List<double> getColorBasedOnValue(double value){
    List<double> baseValue = <double>[0.5,1.0,0.5];
    var minMaxValueRange = maxValueForRed - minValueForBlue;

    var percent = value / minMaxValueRange;

    Color newColor = new Color();
    newColor.r = maxColor.r * percent + minColor.r * (1-percent);
    newColor.g = maxColor.g * percent + minColor.g * (1-percent);
    newColor.b = maxColor.b * percent + minColor.b * (1-percent);

    return [newColor.r, newColor.g, newColor.b];

    /*baseValue[0] += valueColorLength;

    var finalColor = new Color().setHSL(baseValue[0], baseValue[1], baseValue[2]);

    return [finalColor.r, finalColor.g, finalColor.b];*/
  }

  /// Set connection information
  set config(dynamic value) => _config = value as ConnConfig;

  /// Set the configuration with some basic value
  /// Like: [nameOfConn], [connectionColor], [segmentOneColor],  [segmentTwoColor]
  void setConfigWithColor(String nameOfConn, Color connectionColor, Color segmentOneColor, Color segmentTwoColor){
    this._config.nameOfConnection = nameOfConn;
    this._config.connectionColor = connectionColor;
    this._config.segmentOneColor = segmentOneColor;
    this._config.segmentTwoColor = segmentTwoColor;
  }

  /// Get the ID of the second segment
  String get segmentTwoID => this._segmentTwo.id;

  /// Get the ID of the first segment
  String get segmentOneID => this._segmentOne.id;

  /// Get the name of the connection
  String get nameOfConn => this._config.nameOfConnection;

  /// Get the second segment
  VisualObject get segmentTwo => this._segmentTwo;

  /// Get the first segment
  VisualObject get segmentOne => this._segmentOne;

  /// Do we will fill the connection
  bool get isFullConn => this._config.isFullConn;

  /// Get the list of the sub connection configs
  List<SubConnConfig> get listOfSubConnConfig {
    if(this._listOfSubConnConfig == null)
      throw new StateError("The list of sub connection config is not initialized");

    return this._listOfSubConnConfig.values.toList(growable: false);
  }


  /// Get the sub connection config based on the given [ID]
  SubConnConfig getSubConnConfigByID(String ID) {
    if(this._listOfSubConnConfig == null)
      throw new StateError("The list of sub connection config is not initialized");

    if(!this._listOfSubConnConfig.containsKey(ID))
      throw new StateError("The list of sub connection config does not contains element with this id:$ID");

    return this._listOfSubConnConfig[ID];
  }

  /// Add new sub connection config with [ID]
  void addSubConnConfigByID(String ID){
    this._listOfSubConnConfig[ID] = new ConfigSubConnection(ID);
  }

  /// Set do we will fill the connection
  set isFullConn(bool value) {
    this._config.isFullConn = value;
  }

  /// Set the first segment
  set segmentOne(VisualObject value) {
    this._segmentOne = value;
  }

  /// Set the second segment
  set segmentTwo(VisualObject value) {
    this._segmentTwo = value;
  }

  /// Decide does both side of the connection is in the root?
  @override
  bool isConnectionNeeded(VisualObject root, List<String> allLabelID) {
    if(!allLabelID.contains(this._segmentOne.parent.id) || !allLabelID.contains(this._segmentTwo.parent.id)){
      this._segmentOne.parent.removeChild(this._segmentOne.id);
      this._segmentTwo.parent.removeChild(this._segmentTwo.id);
      return false;
    }
    /*try {
      root.getChildByID(this._segmentOne.id, true);
    }catch(error){
      this._segmentOne.parent.first.removeChild(this._segmentOne.id);
      retVal = false;
    }
    try {
      root.getChildByID(this._segmentTwo.id, true);
    }catch(error){
      this._segmentTwo.parent.first.removeChild(this._segmentTwo.id);
      retVal = false;
    }*/
    return true;
  }

  /// Does this connection contains element
  @override
  bool containsElement(VisualObject childByID) {
    return this.segmentOneID.startsWith(childByID.id) || this.segmentTwoID.startsWith(childByID.id);
  }

  /// Does this connection contains booth element
  @override
  bool containsBothElement(VisualObject A, VisualObject B){
    return (this.segmentOneID.startsWith(A.id) && this.segmentTwoID.startsWith(B.id)) ||
        (this.segmentOneID.startsWith(B.id) && this.segmentTwoID.startsWith(A.id));
  }


  /// Get the other segment then this [segment]
  @override
  VisualObject getOtherSegment(VisualObject segment){
    if(this.segmentOneID != segment.id && this.segmentTwoID != segment.id)
      throw new StateError("The given segment is not element of this connection");

    if(this.segmentOneID == segment.id){
      return segmentTwo;
    }else{
      return segmentOne;
    }
  }
}