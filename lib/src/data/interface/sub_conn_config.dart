part of dataProcessing;

/// Abstract class to store information about divided connection
abstract class SubConnConfig{

  /// Default line color (black)
  static Color defaultLineColor = new Color(0xFFFFFF);
  /// Default opacity value (0.8)
  static double defaultOpacity = 0.8;

  /// Do we will fill the segments or not
  bool get isFilled;

  /// Set do we will fill the segments or not
  set isFilled(bool value);

  /// Get is this shape drawable
  bool get isDrawable;

  /// Set is this shape drawable
  set isDrawable(bool value);

  /// Get the name of the connection
  String get nameOfConnection;

  /// Set the name of the connection
  set nameOfConnection(String value);

  /// Get the color of the connection
  Color get connectionColor;

  /// Get the color of the line
  Color get lineColor;

  /// Get the opacity value
  double get connOpacity;

  /// Set the opacity value
  set connOpacity(double value);

  /// Set the color of the line
  set lineColor(Color value);

  /// Set the color of the connection
  set connectionColor(Color value);

  /// Fill these information randomly based on the given values
  /// Options: randomize line color and opacity value
  void fillConfigWithRandomData({bool randLineCol: true, bool randOpacity: true});

}