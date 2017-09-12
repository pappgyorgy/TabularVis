part of dataProcessing;

/// Abstract class to store configuration information about the connection
///
/// It stores the color, height, fill, information for the two segments
/// and for the connection.
abstract class ConnConfig extends SubConnConfig{

  /// Default height for the segments
  static double defaultHeight = 50.0;

  /// Default line color (black) for the segments and the connection
  static Color defaultLineColor = new Color(0x000000);

  /// Default opacity value (0.8) for the segments
  static double defaultOpacity = 0.8;

  ///Get the color of first segment
  Color get segmentOneColor;

  ///Get the color of the second segment
  Color get segmentTwoColor;

  /// Do we will fill the segments or not
  bool get isFullConn;

  ///Get the height of the first segment
  double get segmentOneHeight;

  ///Get the height of the second segment
  double get segmentTwoHeight;

  ///Get the opacity of the first segment
  double get segmentOneOpacity;

  ///Get the opacity of the second segment
  double get segmentTwoOpacity;

  /// Set do we will fill the connection or not
  set isFullConn(bool value);

  ///Set the opacity of the first segment
  set segmentOneOpacity(double value);

  ///Set the opacity of the second segment
  set segmentTwoOpacity(double value);

  ///Set the height of the first segment
  set segmentOneHeight(double value);

  ///Set the height of the second segment
  set segmentTwoHeight(double value);

  ///Set the color of first segment
  set segmentOneColor(Color value);

  ///Set the color of second segment
  set segmentTwoColor(Color value);

  /// This will fill the values with random data based on the optional values
  ///
  /// Optional values, what we want to randomize: line color, segment height, opacity, conn color
  void fillConfigWithRandomData({bool randLineCol: true, bool randHeight: true,
                                bool randOpacity: true, bool randConnColor: true});

}