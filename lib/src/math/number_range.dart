part of poincareMath;

class NumberRange<T extends num> implements RangeMath<T>{

  T _begin;
  T _end;
  T _rangeValue;

  T get begin => this._begin;

  T get end => this._end;

  T get rangeValue => this._rangeValue;

  T _defaultChangeValue;

  bool nextValueReachEnd = false;

  T get defaultChangeValue => this._defaultChangeValue;
  set defaultChangeValue(T value){
    if(value < this.length){
      this._defaultChangeValue = value;
    }else{
      throw new StateError("The given value($value) is bigger than the range length(${this.length})");
    }
  }

  bool _nextValueReachEnd = false;

  NumberRange(){
    this._begin = 0 as T;
    this._end = 100 as T;
    this._rangeValue = this.begin;
    this._defaultChangeValue = 1 as T;
  }

  NumberRange.fromNumbers(this._begin, this._end){
    this._rangeValue = this.begin;
    this._defaultChangeValue = (T is double) ? 1.0 as T : 1 as T;
  }


  void shiftRange(T shiftValue) {
    this._begin += shiftValue;
    this._end += shiftValue;
  }

  void swapRangeLength(RangeMath otherRange) {
    if(this.compareTo(otherRange) < 0){
      _swapRangesLength(this, otherRange);
    }else if(this.compareTo(otherRange) < 0){
      _swapRangesLength(otherRange, this);
    }else{
      throw new StateError("Can't decide wich range is smaller");
    }
  }

  void _swapRangesLength(RangeMath one, RangeMath two){
    one.end = one.begin +  two.length;
    two.begin = two.end - one.length;
  }

  T getDifferenceBetweenRanges(RangeMath otherRange) {
    if(otherRange.compareTo(this) < 0){
      var range = new NumberRange.fromNumbers(otherRange.getMinValue() as T, this.getMaxValue());
      return range.length;
    }else{
      var range = new NumberRange.fromNumbers(this.getMinValue(), otherRange.getMaxValue() as T);
      return range.length;
    }
  }


  @deprecated
  T getRangeNextElement() {
    if(this.nextValueReachEnd){
      this._rangeValue = this._begin;
      this.nextValueReachEnd = false;
      return this._rangeValue;
    }

    this._rangeValue += this._defaultChangeValue;

    if(!this.isValueInRange(this._rangeValue)){
      this._rangeValue = this._end;
      this.nextValueReachEnd = true;
    }

    return this._rangeValue;
  }

  int get direction{
    return this._end > this._begin
      ? 1
      : -1;
  }

  int get toggleDirection {
    var swapHelper = this._begin;
    this._begin = this._end;
    this._end = swapHelper;
    return direction;
  }

  Iterable<T> rangeNextElement(T step) sync* {
    var start = this._begin;
    yield this._begin;
    while(((this._end - start).abs() - step) > step){
      yield start += (step * direction);
    }
    yield this._end;
  }


  dynamic loopOverRangeElement(T step, dynamic doStuff(T value)) {
    var iterator = this.rangeNextElement(step).iterator;

    var doStuffResult = new List<dynamic>();

    while(iterator.moveNext()){
      doStuffResult.add(doStuff(iterator.current));
    }

    return doStuffResult;
  }


  List<T> getRangeAllElement(T step, dynamic doStuff(T value)) {
    var iterator = this.rangeNextElement(step).iterator;

    var doStuffResult = new List<dynamic>();

    while(iterator.moveNext()){
      doStuffResult.addAll(doStuff(iterator.current) as Iterable);
    }

    return doStuffResult as List<T>;
  }

  bool isRangesDisjoint(RangeMath one, RangeMath Two) {
    if((one.isValueInRange(Two.begin) || one.isValueInRange(Two.end))
    || (Two.isValueInRange(one.begin) || Two.isValueInRange(one.end)))
      return true;

    return false;
  }


  List<RangeMath<T>> dividePartsByValue(List<T> values,
                                 {List<T> spaceBetweenParts,
                                 bool differentSpaces: false,
                                 T defaultSpaceBetweenParts: null}) {

    var sumOfValues = values.reduce((a,b) => (a+b));

    defaultSpaceBetweenParts = defaultSpaceBetweenParts == null
        ? (sumOfValues * 0.1 / values.length) as T
        : (defaultSpaceBetweenParts * sumOfValues) / values.length as T ;

    T sumOfSpaces;
    if(differentSpaces){
      sumOfSpaces = spaceBetweenParts.reduce((a,b) => (a+b));
    }else{
      sumOfSpaces = defaultSpaceBetweenParts * values.length;
    }

    var divideLength = this.length / (sumOfValues + sumOfSpaces);

    var beginHelper = this._begin;
    var endHelper = this._end;

    var returnList = new List<RangeMath<T>>(values.length);
    for(var i = 0; i < values.length; i++){
      endHelper = beginHelper + ((divideLength * values[i]) * this.direction) as T;
      returnList[i] = new NumberRange.fromNumbers(beginHelper, endHelper);
      if(differentSpaces){
        beginHelper = endHelper + ((divideLength * spaceBetweenParts[i]) * this.direction) as T;
      }else {
        beginHelper = endHelper + ((divideLength * defaultSpaceBetweenParts) * this.direction) as T;
      }
    }
    return returnList;
  }

  List<RangeMath<T>> dividePartsByValueInside(List<T> values,
      {List<T> spaceBetweenParts,
        bool differentSpaces: false,
        T defaultSpaceBetweenParts: null}) {

    var sumOfValues = values.reduce((a,b) => (a+b));

    defaultSpaceBetweenParts = defaultSpaceBetweenParts == null
        ? (sumOfValues * 0.1 / (values.length-1)) as T
        : (defaultSpaceBetweenParts * sumOfValues) / (values.length-1) as T ;

    T sumOfSpaces;
    if(differentSpaces){
      sumOfSpaces = spaceBetweenParts.reduce((a,b) => (a+b));
    }else{
      sumOfSpaces = defaultSpaceBetweenParts * (values.length-1);
    }

    var divideLength = this.length / (sumOfValues + sumOfSpaces);

    var beginHelper = this._begin;
    var endHelper = this._end;

    var returnList = new List<RangeMath<T>>(values.length);
    for(var i = 0; i < values.length; i++){
      endHelper = beginHelper + ((divideLength * values[i]) * this.direction) as T;
      returnList[i] = new NumberRange.fromNumbers(beginHelper, endHelper);
      if(differentSpaces){
        beginHelper = endHelper + ((divideLength * spaceBetweenParts[i]) * this.direction) as T;
      }else {
        beginHelper = endHelper + ((divideLength * defaultSpaceBetweenParts) * this.direction) as T;
      }
    }
    return returnList;
  }

  NumberRange<T> mergeRanges(List<RangeMath<T>> listOfRanges) {
    listOfRanges.sort();
    return new NumberRange.fromNumbers(listOfRanges.first.begin, listOfRanges.last.end);
  }


  List<RangeMath<T>> divideEqualParts(int numberOfParts,
                                  {List<T> spaceBetweenParts,
                                  bool differentSpaces: false,
                                  T defaultSpaceBetweenParts: null}) {

    defaultSpaceBetweenParts = defaultSpaceBetweenParts == null
        ? this.length * 0.1 as T
        : defaultSpaceBetweenParts;

    T sumOfSpaces;
    if(differentSpaces){
      sumOfSpaces = spaceBetweenParts.reduce((a,b) => (a+b));
    }else{
      sumOfSpaces = defaultSpaceBetweenParts * numberOfParts;
    }

    var divideLength = (this.length - sumOfSpaces) / numberOfParts;

    var beginHelper = this._begin;
    var endHelper = this._end;

    var returnList = new List<RangeMath<T>>(numberOfParts);
    for(var i = 0; i < numberOfParts; i++){
      endHelper = beginHelper + (divideLength * this.direction) as T;
      returnList[i] = new NumberRange<T>.fromNumbers(beginHelper, endHelper);
      beginHelper = endHelper + (defaultSpaceBetweenParts * this.direction);
    }
    return returnList;
  }


  T getMaxValue() {
    return max(this._end, this._begin);
    /*if(this._end < this._begin){
      return this._begin;
    }else{
      return this._end;
    }*/
  }


  T getMinValue() {
    return min(this._end, this._begin);
    /*if(this._end > this._begin){
      return this._begin;
    }else{
      return this._end;
    }*/
  }


  T getRangeDifference() {
    return this._end - this._begin;
  }


  T get length {
    return this.getMaxValue() - this.getMinValue();
  }


  set end(T value) {
    this._end = value;
  }


  set begin(T value) {
    this._begin = value;
  }


  @override
  int compare(Comparable a, Comparable b) {
    return a.compareTo(b);
  }

  @override
  int compareTo(Object other) {
    NumberRange numbRange = other as NumberRange;
    if(this.begin < numbRange.begin){
      return 1;
    }else if(this.begin > numbRange.begin){
      return -1;
    }else if(this.begin == numbRange.begin){
      if(this.length < numbRange.length){
        return 1;
      }else if (this.length > numbRange.length){
        return -1;
      }else{
        return 0;
      }
    }else{
      return 0;
    }
  }

  T getRandomValueFromRange() {
    var length = this.length;
    var rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    return this._begin + rnd.nextDouble() * length as T;
  }


  bool isValueInRange(T value, [RangeCloseType rangeType = RangeCloseType.closed]) {
    var compareValue = (value - min(this._begin, this._end));
    switch(rangeType){
      case RangeCloseType.opened:
        return !(compareValue >= this.length || compareValue <= 0);

      case RangeCloseType.closed:
        return !(compareValue > this.length || compareValue < 0);

      case RangeCloseType.beginOpened:
        return !(compareValue > this.length || compareValue <= 0);

      case RangeCloseType.endOpened:
        return !(compareValue >= this.length || compareValue < 0);

      case RangeCloseType.openedAndClosed:
        var opened = !(compareValue >= this.length || compareValue <= 0);
        var closed = !(compareValue > this.length || compareValue < 0);
        if(opened && closed){
          return true;
        }else if(opened || closed){
          return true;
        }

        return false;
      default:
        throw new StateError("Value: ${value} range test is failed, default switch case returned");
    }

  }


  /*static void swapRanges(List<RangeMath> ranges, int firstIndex, int secondIndex){
    if(firstIndex < 0) throw new RangeError("FirstIndex($firstIndex) is negative");
    if(firstIndex >= ranges.length - 1) throw new RangeError(
        "FirstIndex($firstIndex) is equal or bigger than the list length - 1 (${ranges.length-1})");
    if(secondIndex >= ranges.length) throw new RangeError(
        "SecondIndex($secondIndex) is equal or bigger than the list length(${ranges.length})");
    if(firstIndex > secondIndex) throw new RangeError(
        "SecondIndex($secondIndex) is bigger than firstIndex($firstIndex)");

    var lastSpaceBetweenParts = ranges[firstIndex].getDifferenceBetweenRanges(ranges[firstIndex+1]);

    ranges[firstIndex].swapRangeLength(ranges[secondIndex]);

    var lastRangeEnd = ranges[firstIndex].end;
    var rangeLength = 0.0;

    for(var i = firstIndex+1; i < secondIndex; i++){
      rangeLength = ranges[i].getRangeDifference();
      ranges[i].begin = lastRangeEnd + lastSpaceBetweenParts;
      ranges[i].end = ranges[i].begin + rangeLength;
      if(i+1 <= ranges.length) {
        lastSpaceBetweenParts = ranges[i].getDifferenceBetweenRanges(ranges[i + 1]);
      }
    }
  }*/


}