part of dataProcessing;

/// This class provides letters in alphabetic order
class LetterProvider{

  /// The letters of the english alphabet
  static List<String> englishAlphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];

  /// Get [size] number of letter is order. Starts the order from [start]
  static List<String> getListOfLetters(int size, [int start = 0]){
    List<String> retVal = new List();

    if(start < englishAlphabet.length){
      retVal.addAll(englishAlphabet.sublist(start, min(start+size, englishAlphabet.length)));
    }else if(start == englishAlphabet.length){
      retVal.add(englishAlphabet.last);
    }
    var remainingSize = (start + size) - englishAlphabet.length;
    var nextLetterIndex = 0, firstLetterIndex = 0;
    for(var i = 0; i < remainingSize; i++){
      nextLetterIndex = i%englishAlphabet.length;
      retVal.add("${englishAlphabet[firstLetterIndex]}${englishAlphabet[nextLetterIndex]}");
      if( i > 0 && nextLetterIndex == 0){
        firstLetterIndex = i ~/ englishAlphabet.length;
      }
    }
    return retVal;
  }
}