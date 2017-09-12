part of dataProcessing;

class ConfigConn implements ConnConfig{

  static int defaultHeight = 50;

  /// The name of the connection
  String _nameOfConnection;
  /// The color of the connection
  Color _connectionColor;
  /// The color of the first segment
  Color _segmentOneColor;
  /// The color of the second segment
  Color _segmentTwoColor;

  /// The color of the line
  Color _lineColor;

  /// The height of the first segment
  double _segmentOneHeight;
  /// The height of the second segment
  double _segmentTwoHeight;

  /// The opacity value of the connection
  double _connOpacity;

  /// The opacity value of the first segment
  double _segmentOneOpacity;

  /// The opacity value of the second segment
  double _segmentTwoOpacity;

  /// The color range to get random colors
  ColorRange _rangeOfColors;

  /// The opacity range to get random opacity
  RangeMath<double> _rangeOfOpacity;

  /// The height range to get random height
  RangeMath<double> _rangeOfHeights;

  /// Is it filled
  bool _isFilled;
  /// Is it drawn on the screen
  bool _isDrawable;

  // Is the conn filled
  bool _isFullConn;

  /// Simple constructor
  ///
  /// Args: [nameOfConnection], optional: [isFilled], [isDrawable], [isFullConn] all true default
  /// Fill the other variable with random value
  ConfigConn(this._nameOfConnection, {bool isFilled: true, bool isDrawable: true, bool isFullConn: true}){
    this.fillConfigWithRandomData(randLineCol: false, randOpacity: false);
    this._isFilled = isFilled;
    this._isDrawable = isDrawable;
    this._isFullConn = isFullConn;
  }

  /// Create new conn config with colors
  ///
  /// Almost same as the simple constructor but with colors to the segments and the connection
  ConfigConn.withColor(this._nameOfConnection, this._connectionColor, this._segmentOneColor, this._segmentTwoColor,
                       {bool isFilled: true, bool isDrawable: true, bool isFullConn: true}){
    _setDefaultRanges();
    this.lineColor = ConnConfig.defaultLineColor;
    this.segmentOneHeight = ConnConfig.defaultHeight;
    this.segmentTwoHeight = ConnConfig.defaultHeight;
    this.connOpacity = ConnConfig.defaultOpacity;
    this.segmentOneOpacity = ConnConfig.defaultOpacity;
    this.segmentTwoOpacity = ConnConfig.defaultOpacity;
    this._isFilled = isFilled;
    this._isDrawable = isDrawable;
    this._isFullConn = isFullConn;
  }

  /// Set the ranges with the default values
  void _setDefaultRanges(){
    this._rangeOfColors = new ColorRange();
    this._rangeOfOpacity = new NumberRange.fromNumbers(ConnConfig.defaultOpacity, 1.0);
    this._rangeOfHeights = new NumberRange.fromNumbers(0.0, ConnConfig.defaultHeight);
  }

  /// Set the color of the connection
  set connectionColor(Color value) {
    this._connectionColor = value;
  }

  /// Set the color of the first segment
  set segmentOneColor(Color value) {
    this._segmentOneColor = value;
  }

  /// Set the color of the second segment
  set segmentTwoColor(Color value) {
    this._segmentTwoColor = value;
  }

  /// Set the color of the line
  set lineColor(Color value) {
    this._lineColor = value;
  }

  /// Set the height of the first segment
  set segmentOneHeight(double value) {
    this._segmentOneHeight = value;
  }

  /// Set the height of the second segment
  set segmentTwoHeight(double value) {
    this._segmentTwoHeight = value;
  }

  /// Set the opacity value of the connection
  set connOpacity(double value) {
    this.connOpacity = value;
  }

  /// Set the opacity value of the first segment
  set segmentOneOpacity(double value) {
    this._segmentOneOpacity = value;
  }

  /// Set the opacity value of the second segment
  set segmentTwoOpacity(double value) {
    this._segmentTwoOpacity = value;
  }

  ///Get the opacity of the second segment
  double get segmentTwoOpacity => this._segmentTwoOpacity;

  ///Get the opacity of the first segment
  double get segmentOneOpacity => this._segmentOneOpacity;

  /// Get the opacity value
  double get connOpacity => this._connOpacity;

  ///Get the height of the second segment
  double get segmentTwoHeight => this._segmentTwoHeight;

  ///Get the height of the first segment
  double get segmentOneHeight => this._segmentOneHeight;

  /// Get the color of the line
  Color get lineColor => this._lineColor;

  ///Get the color of the second segment
  Color get segmentTwoColor => this._segmentTwoColor;

  ///Get the color of first segment
  Color get segmentOneColor => this._segmentOneColor;

  /// Get the color of the connection
  Color get connectionColor => this._connectionColor;

  /// Set the name of the connection
  set nameOfConnection(String value) {
    this._nameOfConnection = value;
  }

  /// Get the name of the connection
  String get nameOfConnection => this._nameOfConnection;

  /// Do we will fill the segments or not
  bool get isFilled => this._isFilled;

  /// Set do we will fill the segments or not
  set isFilled(bool value) {
    this._isFilled = value;
  }

  /// Get is this shape drawable
  bool get isDrawable => this._isDrawable;

  /// Set is this shape drawable
  set isDrawable(bool value) {
    this._isDrawable = value;
  }

  /// Do we will fill the segments or not
  bool get isFullConn => this._isFullConn;

  /// Set do we will fill the connection or not
  set isFullConn(bool value) {
    this._isFullConn = value;
  }

  /// This will fill the values with random data based on the optional values
  ///
  /// Optional values, what we want to randomize: line color, segment height, opacity, conn color
  void fillConfigWithRandomData({bool randLineCol: true, bool randHeight: true,
                                bool randOpacity: true, bool randConnColor: true}){
    this._setDefaultRanges();

    this._segmentOneColor = this._rangeOfColors.getRandomValueFromRange();
    this._segmentTwoColor = this._rangeOfColors.getRandomValueFromRange();

    if(randLineCol){
      this._lineColor = this._rangeOfColors.getRandomValueFromRange();
    }else{
      this._lineColor = ConnConfig.defaultLineColor;
    }

    if(randHeight){
      this._segmentOneHeight = this._rangeOfHeights.getRandomValueFromRange();
      this._segmentTwoHeight = this._rangeOfHeights.getRandomValueFromRange();
    }else{
      this._segmentOneHeight = this._segmentTwoHeight = ConnConfig.defaultHeight;
    }

    if(randOpacity){
      this._connOpacity = this._rangeOfOpacity.getRandomValueFromRange();
      this._segmentOneOpacity = this._rangeOfOpacity.getRandomValueFromRange();
      this._segmentTwoOpacity = this._rangeOfOpacity.getRandomValueFromRange();
    }else{
      this._connOpacity = this._segmentOneOpacity = this._segmentTwoOpacity = ConnConfig.defaultOpacity;
    }

    if(randConnColor){
      this._connectionColor = this._rangeOfColors.getRandomValueFromRange();
    }else{
      this._connectionColor = new Color(0x153050);
    }
  }

}