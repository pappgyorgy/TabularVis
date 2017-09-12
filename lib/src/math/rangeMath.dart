part of poincareMath;

enum RangeCloseType{
  opened,
  closed,
  beginOpened,
  endOpened,
  openedAndClosed
}

abstract class RangeMath<T> implements Comparable<T>{

  T get begin;
  set begin(T value);

  T get end;
  set end(T value);

  T get rangeValue;

  T get defaultChangeValue;
  set defaultChangeValue(T value);

  dynamic get length;

  int get direction;

  int get toggleDirection;

  T getRangeDifference();

  T getMinValue();

  T getMaxValue();

  void shiftRange(T shiftValue);

  List<RangeMath> divideEqualParts(int numberOfParts,
    {List<T> spaceBetweenParts, bool differentSpaces, T defaultSpaceBetweenParts});

  RangeMath mergeRanges(List<RangeMath<T>> listOfRanges);

  List<RangeMath<T>> dividePartsByValue(List<T> values,
    {List<T> spaceBetweenParts, bool differentSpaces, T defaultSpaceBetweenParts});

  static bool isRangesDisjoint(RangeMath one, RangeMath Two){
    if((one.isValueInRange(Two.begin) || one.isValueInRange(Two.end))
    || (Two.isValueInRange(one.begin) || Two.isValueInRange(one.end)))
      return true;

    return false;
  }

  @deprecated
  T getRangeNextElement();

  Iterable<T> rangeNextElement(T step);

  List<T> getRangeAllElement(T step, Function doStuff(T value));

  dynamic loopOverRangeElement(T step, dynamic doStuff(T value));

  static void swapRanges(List<RangeMath> ranges, int firstIndex, int secondIndex){
    if(firstIndex < 0) throw new RangeError("FirstIndex($firstIndex) is negative");
    if(firstIndex >= ranges.length - 1) throw new RangeError(
        "FirstIndex($firstIndex) is equal or bigger than the list length - 1 (${ranges.length-1})");
    if(secondIndex >= ranges.length) throw new RangeError(
        "SecondIndex($secondIndex) is equal or bigger than the list length(${ranges.length})");
    if(firstIndex > secondIndex) throw new RangeError(
        "SecondIndex($secondIndex) is bigger than firstIndex($firstIndex)");

    dynamic lastSpaceBetweenParts = ranges[firstIndex].getDifferenceBetweenRanges(ranges[firstIndex+1]);

    ranges[firstIndex].swapRangeLength(ranges[secondIndex]);

    dynamic lastRangeEnd = ranges[firstIndex].end;
    var rangeLength = 0.0;

    for(var i = firstIndex+1; i < secondIndex; i++){
      rangeLength = ranges[i].getRangeDifference() as double;
      ranges[i].begin = lastRangeEnd + lastSpaceBetweenParts;
      ranges[i].end = rangeLength;
      if(i+1 <= ranges.length) {
        lastSpaceBetweenParts = ranges[i].getDifferenceBetweenRanges(ranges[i + 1]);
      }
    }
  }

  bool isValueInRange(T value, [RangeCloseType rangeType = RangeCloseType.closed]);

  T getRandomValueFromRange();

  int compareTo(Object other);

  int compare(Comparable a, Comparable b);

  T getDifferenceBetweenRanges(RangeMath<T> otherRange);

  void swapRangeLength(RangeMath<T> otherRange);
}