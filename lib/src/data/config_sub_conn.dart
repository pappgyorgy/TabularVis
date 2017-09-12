part of dataProcessing;

class ConfigSubConnection implements SubConnConfig{

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
  ConfigSubConnection(this._nameOfConnection, {bool isFilled: true, bool isDrawable: true, bool isFullConn: true}){
    this.fillConfigWithRandomData(randLineCol: false);
    this._isFilled = isFilled;
    this._isDrawable = isDrawable;
    this._isFullConn = isFullConn;
  }

  /// Create new conn config with colors
  ///
  /// Almost same as the simple constructor but with color to the connection
  ConfigSubConnection.withColor(this._nameOfConnection, this._connectionColor,
                                {bool isFilled: true, bool isDrawable: true, bool isFullConn: true}){
    _setDefaultRanges();
    this.lineColor = ConnConfig.defaultLineColor;
    this.connOpacity = ConnConfig.defaultOpacity;
    this._isFilled = isFilled;
    this._isDrawable = isDrawable;
    this._isFullConn = isFullConn;
  }

  /// Set the ranges with the default values
  void _setDefaultRanges() {
    this._rangeOfColors = new ColorRange();
    this._rangeOfOpacity = new NumberRange.fromNumbers(ConnConfig.defaultOpacity, 1.0);
  }

  /// Fill these information randomly based on the given values
  /// Options: randomize line color and opacity value
  void fillConfigWithRandomData({bool randConnCol : true, bool randLineCol : true, bool randOpacity : true}) {
    this._setDefaultRanges();

    this._segmentOneColor = this._rangeOfColors.getRandomValueFromRange();
    this._segmentTwoColor = this._rangeOfColors.getRandomValueFromRange();

    if(randLineCol){
      this._lineColor = this._rangeOfColors.getRandomValueFromRange();
    }else{
      this._lineColor = ConnConfig.defaultLineColor;
    }

    if(randOpacity){
      this._connOpacity = this._rangeOfOpacity.getRandomValueFromRange();
      this._segmentOneOpacity = this._rangeOfOpacity.getRandomValueFromRange();
      this._segmentTwoOpacity = this._rangeOfOpacity.getRandomValueFromRange();
    }else{
      this._connOpacity = this._segmentOneOpacity = this._segmentTwoOpacity = ConnConfig.defaultOpacity;
    }

    if(randConnCol){
      this._connectionColor = this._rangeOfColors.getRandomValueFromRange();
    }else{
      this._connectionColor = new Color(0x153050);
    }
  }

  /// Set the color of the connection
  set connectionColor(Color value) {
    this._connectionColor = value;
  }

  /// Set the color of the line
  set lineColor(Color value) {
    this._lineColor = value;
  }

  /// Set the opacity value
  set connOpacity(double value) {
    this._connOpacity = value;
  }

  /// Get the opacity value
  double get connOpacity => this._connOpacity;

  /// Get the color of the line
  Color get lineColor => this._lineColor;

  /// Get the color of the connection
  Color get connectionColor => this._connectionColor;

  /// Set the name of the connection
  set nameOfConnection(String value) {
    this._nameOfConnection = value;
  }

  /// Get the name of the connection
  String get nameOfConnection => this._nameOfConnection;

  /// Set is this shape drawable
  set isDrawable(bool value) {
    this._isDrawable = value;
  }

  /// Get is this shape drawable
  bool get isDrawable => this._isDrawable;

  /// Set do we will fill the segments or not
  set isFilled(bool value) {
    this._isFilled = value;
  }

  /// Do we will fill the segments or not
  bool get isFilled => this._isFilled;


}