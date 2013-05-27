part of math;


 Random mathRand = new Random(123);

 double randn({num mean: 0, num std: 1}) {
  if (std == 0) {
    return 0.0;
  }
  
  double u = 1.0, v = 1.0, s;
  s = u * u + v * v;
  while (s >= 1) {
    u = mathRand.nextDouble() * 2 - 1;
    v = mathRand.nextDouble() * 2 - 1;
    s = u * u + v * v;
  }
  var n = u * sqrt(-2 * log(s) / (s));
  return mean + n * std;
}

class Gaussian {

  static Random r = new Random(123);

  static double normal({num mean: 0, num std: 1}) {
    if (std == 0) {
      return 0.0;
    }
    
    double u = 1.0, v = 1.0, s;
    s = u * u + v * v;
    while (s >= 1) {
      u = r.nextDouble() * 2 - 1;
      v = r.nextDouble() * 2 - 1;
      s = u * u + v * v;
    }
    var n = u * sqrt(-2 * log(s) / (s));
    return mean + n * std;
  }

  static double gaussian(num x, {num mean: 0, num std: 1}) {
    return 1 / (std * sqrt(2 * PI)) * pow(E, pow(x - mean, 2) / (-2 * pow(std, 2)));
  }

}