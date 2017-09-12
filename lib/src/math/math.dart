library poincareMath;

import "package:vector_math/vector_math.dart";
import 'package:three/three.dart' show Color;
import "dart:math";

part "math_lib_homogen.dart";
part "simple_circle.dart";
part "h_circle_2d.dart";
part "line.dart";
part "line_2d.dart";
part "homogeneous_coordinate.dart";
part "h_cordinate_2d.dart";
part "h_coordinate_3d.dart";
part "polarCoordinate.dart";
part "coordinatePolar.dart";
part "rangeMath.dart";
part "color_range.dart";
part "number_range.dart";


class MathFunc{

  static double PITwice = 2*PI;

  static Vector3 vector2ToVector3(Vector2 vector, double zValue){
    return new Vector3(vector.x, vector.y, zValue);
  }

  static double getInverseLn(double num){
    return pow(E, -num).toDouble();
  }

  static Vector2 vector3ToVector2(Vector3 vector){
    return vector.xy;
  }

  static dynamic vectorBetweenTwoPoints(dynamic a, dynamic b){
    return b.clone().sub(a);
  }

  static dynamic vectorBetweenTwoPointsNormalized(dynamic a, dynamic b){
    return b.clone().sub(a).normalize();
  }

  static dynamic scaleVectorBetweenTwoPoints(dynamic a, dynamic b, num scaleValue){
    return vectorBetweenTwoPointsNormalized(a, b).scaled(scaleValue.toDouble());
  }

  static int numericalSortDouble (double a, double b ) => (a - b).toInt();
  static int numericalSortInt (int a, int b ) => (a - b).toInt();

  static Vector3 definePointInverse(double radius, Vector3 center, Vector3 point){
    var scale = new Matrix4(1.0/radius,0.0,0.0,0.0,
        0.0,1.0/radius,0.0,0.0,
        0.0,0.0,1.0,0.0,
        0.0,0.0,0.0,1.0);
    var push = new Matrix4.translation(new Vector3(-center.x, -center.y, 0.0));

    var p = new Vector3(point.x, point.y, 0.0);

    push.transform3(p);
    p.scale(1.0/radius);

    var divider = p.x*p.x + p.y * p.y;

    var pVeszzo = new Vector3(p.x/divider, p.y / divider, 0.0);

    var scaleBack = new Matrix4(radius,0.0,0.0,0.0,
        0.0,radius,0.0,0.0,
        0.0,0.0,1.0,0.0,
        0.0,0.0,0.0,1.0);
    var pushBack = new Matrix4.translation(new Vector3(center.x, center.y, 0.0));

    pushBack.transform3(pVeszzo);
    pVeszzo.scale(radius);

    var newPoint = new Vector3(pVeszzo.x, pVeszzo.y, 0.0);

    //addNewPoint(newPoint, pMaterialCircleCenter);

    return newPoint;

  }

  static double getTwoPointsDistance(Vector3 pointOne, Vector3 pointTwo){

    var a2 = pow(pointOne.x - pointTwo.x,2);
    var b2 = pow(pointOne.y - pointTwo.y,2);

    return sqrt(a2+b2);

  }

  static List<String> lettersForUniqueID = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
    'u', 'v', 'w', 'x', 'y', 'z', '<', '>', '=', '+'
  ];

  static Map<int, String> lettersForUniqueID2 = {
    0: '0', 1: '1', 2: '2', 3: '3', 4: '4', 5: '5', 6: '6', 7: '7', 8: '8', 9: '9',
    10: 'a', 11: 'b', 12: 'c', 13: 'd', 14: 'e', 15: 'f', 16: 'g', 17: 'h', 18: 'i', 19: 'j',
    20: 'k', 21: 'l', 22: 'm', 23: 'n', 24: 'o', 25: 'p', 26: 'q', 27: 'r', 28: 's', 29: 't',
    30: 'u', 31: 'v', 32: 'w', 33: 'x', 34: 'y', 35: 'z', 36: '<', 37: '>', 38: '=', 39: '+'
  };

  //still not use
  @deprecated
  static int signOfNumber(double n) { return (n / (n.abs())).round(); }

  static String generateUniqueID(List<String> listOfGeneratedId){
    var rng = new Random(new DateTime.now().millisecondsSinceEpoch);

    var id = new StringBuffer();

    for (var i = 0; i < 5; i++) {
      id.write(MathFunc.lettersForUniqueID[rng.nextInt(40)]);
    }

    while(listOfGeneratedId.contains(id.toString())){
      id.clear();
      for (var i = 0; i < 5; i++) {
        id.write(MathFunc.lettersForUniqueID[rng.nextInt(40)]);
      }
    }

    listOfGeneratedId.add(id.toString());

    return id.toString();

  }

  static Random normalRandGen = new Random();
  static Random normalRandGen2 = new Random();

  ///Box muller algorithm with m = mean and q scatter
  ///http://tomacstibor.uni-eger.hu/tananyagok/Matematikai_statisztika_gyakorlatok.pdf 13 - 14 page
  static double getNormalDistributedRandomNumber(double max, double min){
    var mean = (max + min) / 2.0;
    var scatter = max - mean;
    //=$D$1+$D$2*GYÖK(-2*LN(VÉL()))*COS(2*PI()*VÉL())
    var u = normalRandGen.nextDouble();
    var v = normalRandGen2.nextDouble();
    var first = sqrt(-2 * log(u));
    var secondOne = cos(2 * PI * v);
    var secondTwo = sin(2 * PI * v);
    var x = mean + scatter * first * secondOne;
    var y = mean + scatter * first * secondTwo;
    return x;
  }

  /// Inverse transform sampling
  /// https://en.wikipedia.org/wiki/Exponential_distribution
  static double getExponentialDistributedRandomNumber(double lambda, double max, double min){
    var maxValue = max-min;
    var u = normalRandGen.nextDouble();
    var expBase = ((-log(1.0 - u)) / lambda);
    do{
      expBase = ((-log(1.0 - u)) / lambda);
      u = normalRandGen.nextDouble();
    }while(expBase > 1.0);
    return expBase * maxValue + min;
  }

}