import '../data_processing.dart' show LetterProvider;
import 'package:test/test.dart';

void main(){
  test("Test data_matrix letter provider", () {
    var leters = LetterProvider.getListOfLetters(3);
    expect(leters, equals(["a", "b", "c"]));
  });

  test("Test data_matrix letter provider 2", () {
    var leters = LetterProvider.getListOfLetters(3, 2);
    expect(leters, equals(["c", "d", "e"]));
  });

  test("Test data_matrix letter provider 3", () {
    var leters = LetterProvider.getListOfLetters(3, 25);
    expect(leters, equals(["z", "aa", "ab"]));
  });
}