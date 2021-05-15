part of poincareMath;

class ColorRange implements RangeMath<Color>{

  static int _randomNumberHelper = 0;
  static int get rndHelper => _randomNumberHelper++;

  Color _begin;
  Color _end;
  Color _rangeValue;

  List<double> _beginHSL;
  List<double> _endHSL;

  Color _defaultChangeValue;

  Color get defaultChangeValue => this._defaultChangeValue;
  set defaultChangeValue(Color value){
    var valueHSL = [value.r, value.g, value.b];
    var rangeLengthHSL = this.length;
    this._defaultChangeValue = value;
    /*if(valueHSL[0] < rangeLengthHSL[0] && valueHSL[1] < rangeLengthHSL[1] && valueHSL[2] < rangeLengthHSL[2]){
        this._defaultChangeValue = value;
    }else{
      throw new StateError("The given value($valueHSL) is bigger than the range length($rangeLengthHSL)");
    }*/
  }

  bool _nextValueReachEnd = false;

  Color _colorFromHSL(List<double> hsl){
    return new Color().setHSL(hsl[0], hsl[1], hsl[2]);
  }

  ColorRange()
    : this._beginHSL = [0.0,0.0,0.0],
      this._endHSL = [1.0,1.0,1.0]{

    this._begin = _colorFromHSL(this._beginHSL);
    this._end = _colorFromHSL(this._endHSL);
    this._rangeValue = this.begin.clone();
    this._defaultChangeValue = new Color.fromArray([0.1,0.0,0.0]);
  }

  ColorRange.fromColors(this._begin, this._end){
    this._beginHSL = this._begin.HSL;
    this._endHSL = this._end.HSL;
    this._rangeValue = this.begin.clone();
    this._defaultChangeValue = new Color.fromArray([0.1,0.0,0.0]);
  }

  ColorRange.randomColor({RangeMath<Color> rangeOfColorOne: null,  RangeMath<Color> rangeOfColorTwo: null}){
    if(rangeOfColorOne == null || rangeOfColorTwo == null){
      rangeOfColorOne = new ColorRange.fromColors(
          new Color()..setHSL(0.0, 0.0, 0.0),
          new Color()..setHSL(1.0, 1.0, 1.0));
      rangeOfColorTwo = new ColorRange.fromColors(
          new Color()..setHSL(0.0, 0.0, 0.0),
          new Color()..setHSL(1.0, 1.0, 1.0));
    }
    this._begin = rangeOfColorOne.getRandomValueFromRange();
    this._end = rangeOfColorTwo.getRandomValueFromRange();
    this._rangeValue = this.begin.clone();
    this._defaultChangeValue = new Color().setHSL(0.1,0.0,0.0);
  }

  Color get begin => this._begin;

  Color get end => this._end;

  Color get rangeValue => this._rangeValue;

  void swapRangeLength(RangeMath<Color> otherRange) {
    if(this.compareTo(otherRange) < 0){
      _swapRangesLength(this, otherRange);
    }else if(this.compareTo(otherRange) < 0){
      _swapRangesLength(otherRange, this);
    }else{
      throw new StateError("Can't decide wich range is smaller");
    }
  }

  void _swapRangesLength(RangeMath<Color> one, RangeMath<Color> two){
    (one as ColorRange).endFromHSL = _sumArrays(one.begin.HSL, two.length() as List<double>);
    (two as ColorRange).beginFromHSL = _diffArrays(two.end.HSL, one.length() as List<double>);
  }

  Color getDifferenceBetweenRanges(RangeMath<Color> otherRange) {
    if(otherRange.compareTo(this) < 0){
      var range = new ColorRange.fromColors(otherRange.getMinValue(), this.getMaxValue());
      var list =  range.length;
      return new Color()..setHSL(list[0], list[1], list[2]);
    }else{
      var range = new ColorRange.fromColors(this.getMinValue(), otherRange.getMaxValue());
      var list =  range.length;
      return new Color()..setHSL(list[0], list[1], list[2]);
    }
  }

  @override
  int compare(Comparable a, Comparable b) {
    return a.compareTo(b);
  }

  //TODO need a deep review
  @override
  int compareTo(Object obj) {
    ColorRange other = obj as ColorRange;
    var otherEndHSL = other.end.HSL;
    var otherBeginHSL = other.begin.HSL;
    if(this._endHSL[0] < otherBeginHSL[0] ){
      return -1;
    }else if(this._beginHSL[0] > otherEndHSL[0]){
      return 1;
    }else if(this._beginHSL[0] == otherBeginHSL[0]){
      if(this.length[0] < other.length[0]){
        return -1;
      }else if(this.length[0] > other.length[0]){
        return 1;
      }else{
        return 0;
      }
    }else if(this._endHSL[0] == otherEndHSL[0]){
      if(this.length[0] > other.length[0]){
        return -1;
      }else if(this.length[0] < other.length[0]){
        return 1;
      }else{
        return 0;
      }
    }else if(this.isValueInRange(other.begin)){
      return -1;
    }else if(this.isValueInRange(other.end)){
      if(this._beginHSL[0] < otherBeginHSL[0]){
        return -1;
      }else if(this._beginHSL[0] > otherBeginHSL[0]){
        return 1;
      }else{
        return 0;
      }
    }else{
      return 0;
    }
  }


  Color getRandomValueFromRange() {
    Random rnd = new Random(
        new DateTime.now().millisecondsSinceEpoch + ColorRange.rndHelper);
    var diff = this.length;
    var hue = rnd.nextDouble();
    //var hue = rnd.nextDouble() * diff[0] + this._beginHSL[0];
    var saturation = max(0.8,rnd.nextDouble() * diff[1] + this._beginHSL[1]);
    var lightness = 0.5;
    //var saturation = rnd.nextDouble() * diff[1] + this._beginHSL[1];
    //var lightness = rnd.nextDouble() * diff[2] + this._beginHSL[2];
    return new Color()..setHSL(hue, saturation, lightness);
  }


  bool isValueInRange(Color value, [RangeCloseType rangeType = RangeCloseType.closed]) {
    var colorHSL = value.HSL;

    if(colorHSL[0] < this._beginHSL[0] || colorHSL[1] > this._endHSL[0])
      return false;

    if(colorHSL[1] < this._beginHSL[1] || colorHSL[1] > this._endHSL[1])
      return false;

    if(colorHSL[2] < this._beginHSL[2] || colorHSL[2] > this._endHSL[2])
      return false;

    return true;
  }


  static void swapRanges(List<RangeMath> ranges, int firstIndex, int secondIndex) {
    if(firstIndex < 0) throw new RangeError("FirstIndex($firstIndex) is negative");
    if(firstIndex >= ranges.length - 1) throw new RangeError(
        "FirstIndex($firstIndex) is equal or bigger than the list length - 1 (${ranges.length-1})");
    if(secondIndex >= ranges.length) throw new RangeError(
        "SecondIndex($secondIndex) is equal or bigger than the list length(${ranges.length})");
    if(firstIndex > secondIndex) throw new RangeError(
        "SecondIndex($secondIndex) is bigger than firstIndex($firstIndex)");

    ranges[firstIndex].swapRangeLength(ranges[secondIndex]);

    List<double> lastRangeEnd = (ranges[firstIndex] as ColorRange).end.HSL;
    List<double> rangeLength;
    List<double> helperList;

    for(var i = firstIndex+1; i < secondIndex; i++){
      rangeLength = (ranges[i] as ColorRange).getRangeDifference().HSL;
      (ranges[i] as ColorRange).beginFromHSL = lastRangeEnd;
      helperList = (ranges[i] as ColorRange).begin.HSL;
      ranges[i].end = [rangeLength[0] + helperList[0], rangeLength[1] + helperList[1], rangeLength[2] + helperList[2]];
      lastRangeEnd = (ranges[i] as ColorRange).end.HSL;
    }
  }


  List<RangeMath<Color>> dividePartsByValue(
    List<Color> values,
      { List<Color> spaceBetweenParts,
      bool differentSpaces,
      Color defaultSpaceBetweenParts}) {

    var rangeLength = this.length;

    var valuesSum = values.reduce((Color a, Color b){
      var helperList = _sumArrays(a.HSL, b.HSL);
      return new Color()..setHSL(helperList[0], helperList[1], helperList[2]);
    }).HSL;

    var divideValues = [rangeLength[0] / valuesSum[0], rangeLength[1] / valuesSum[1], rangeLength[2] / valuesSum[2]];

    var beginHSLHelper = this._begin.HSL;
    var endHSLHelper = this._end.HSL;

    var returnList = new List<RangeMath<Color>>(values.length);
    for(var i = 0; i < values.length; i++){
      endHSLHelper = _sumArrays(beginHSLHelper, _multiplyArrays(divideValues, values[i].HSL));
      returnList[i] = new ColorRange.fromColors(
          new Color()..setHSL(beginHSLHelper[0], beginHSLHelper[1], beginHSLHelper[2]),
          new Color()..setHSL(endHSLHelper[0], endHSLHelper[1], endHSLHelper[2]));
      beginHSLHelper = new List.from(endHSLHelper);
    }
    return returnList;
  }


  RangeMath mergeRanges(List<RangeMath> listOfRanges) {
    listOfRanges.sort();
    return new ColorRange.fromColors(
        new Color((listOfRanges.first.getMinValue()..getHex()) as num),
        new Color((listOfRanges.last.getMaxValue()..getHex()) as num)
    );
  }

  List<double> _multiplyArrays(List<double> arrayOne, List<double> arrayTwo){
    return [arrayOne[0] * arrayTwo[0], arrayOne[1] * arrayTwo[1], arrayOne[2] * arrayTwo[2]];
  }

  List<double> _sumArrays(List<double> arrayOne, List<double> arrayTwo){
    return [arrayOne[0].toDouble() + arrayTwo[0], arrayOne[1].toDouble().toDouble() + arrayTwo[1], arrayOne[2] + arrayTwo[2]];
  }

  List<double> _diffArrays(List<double> arrayOne, List<double> arrayTwo){
    return [arrayOne[0] - arrayTwo[0], arrayOne[1] - arrayTwo[1], arrayOne[2] - arrayTwo[2]];
  }

  List<RangeMath> divideEqualParts(int numberOfParts, {List<Color> spaceBetweenParts,
                                    bool differentSpaces: false,
                                    Color defaultSpaceBetweenParts: null}) {
    var colorDifference = this.length;
    var increaseValues = [
      colorDifference[0] / numberOfParts,
      colorDifference[1] / numberOfParts,
      colorDifference[2] / numberOfParts ];

    var beginHSLHelper = this._begin.HSL;
    var endHSLHelper = this._end.HSL;

    var returnList = new List<RangeMath>(numberOfParts);
    for(var i = 0; i < numberOfParts; i++){
      endHSLHelper = _sumArrays(beginHSLHelper, increaseValues);
      returnList[i] = new ColorRange.fromColors(
          new Color()..setHSL(beginHSLHelper[0], beginHSLHelper[1], beginHSLHelper[2]),
          new Color()..setHSL(endHSLHelper[0], endHSLHelper[1], endHSLHelper[2]));
      beginHSLHelper = new List.from(endHSLHelper);
    }
    return returnList;
  }


  Color getMaxValue() {
    if(this._beginHSL[0] < this._endHSL[0]){
      return this._end;
    }else{
      return this._begin;
    }
  }


  Color getMinValue() {
    if(this._beginHSL[0] < this._endHSL[0]){
      return this._begin;
    }else{
      return this._end;
    }
  }


  Color getRangeDifference() {
    return new Color().setHSL(this.length[0], this.length[1], this.length[2]);
  }


  List<double> get length {
    return [(this._endHSL[0] - this._beginHSL[0]).abs(), (this._endHSL[1] - this._beginHSL[1]).abs(), (this._endHSL[2] - this._beginHSL[2]).abs()];

  }


  set end(Color value) {
    this._end = value;
    this._endHSL = this._end.HSL;
  }


  set begin(Color value) {
    this._begin = value;
    this._beginHSL = this._begin.HSL;
  }

  set endFromHSL(List<double> value) {
    this._end = new Color()
      ..setHSL(value[0], value[1], value[2]);
    this._endHSL = value;
  }


  set beginFromHSL(List<double> value) {
    this._begin = new Color()
      ..setHSL(value[0], value[1], value[2]);
    this._beginHSL = value;
  }

  bool _nextNeverWasCalled = true;

  Color getRangeNextElement() {
    if(_nextNeverWasCalled){
      this._nextNeverWasCalled = false;
      return this.rangeValue;
    }

    //defaultChangeValue variable store the HSL values in the R,G,B variables
    var defaultValueHSL = <double>[
      this.defaultChangeValue.r,
      this.defaultChangeValue.g,
      this.defaultChangeValue.b
    ];
    var listHSL = _sumArrays(this._rangeValue.HSL, defaultValueHSL);
    this._rangeValue = new Color().setHSL(listHSL[0], listHSL[1], listHSL[2]);

    return _rangeValue;
  }
  // TODO: implement direction
  @override
  int get direction => null;

  @override
  List<Color> getRangeAllElement(Color step, Function doStuff(Color value)) {
    // TODO: implement getRangeAllElement
  }

  @override
  dynamic loopOverRangeElement(Color step, dynamic doStuff(Color value)) {
    // TODO: implement loopOverRangeElement
  }

  @override
  Iterable<Color> rangeNextElement(Color step) {
    // TODO: implement rangeNextElement
  }

  @override
  void shiftRange(Color shiftValue) {
    // TODO: implement shiftRange
  }

  // TODO: implement toggleDirection
  @override
  int get toggleDirection => null;

  List<RangeMath<Color>> dividePartsByValueInside(List<Color> values,
      {List<Color> spaceBetweenParts,
        bool differentSpaces: false,
        Color defaultSpaceBetweenParts: null}){}
}