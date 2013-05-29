part of tests;

class SimpleTest {

  num time;
  num pNoise = 0;
  num mNoise = 1;
  num Ez;
  num Ex;
  num pCount;

  SimpleTest(this.time, this.mNoise, this.pNoise, this.Ex, this.Ez, this.pCount) {
    List measurements = new List();
    var x = 10;
    for (var i = 0; i < time; i++) {
      measurements.add({
        'real': x + Gaussian.normal(mean: 0, std: pNoise),
        'measured': x + Gaussian.normal(mean: 0, std: mNoise)
      });
    }
    measurements = particles(measurements, mNoise, pNoise, pCount);
    measurements = kalman(measurements, mNoise, pNoise);

    graph(measurements);
  }


  void graph(List m) {
    List data = new List();
    List data2 = new List();
    data.add(['t', 'real', 'measured', 'kalman', 'particles']);
    data2.add(['t', 'm', 'm total', 'k', 'k total', 'p', 'p total', 'p1 tot']);

    var met = 0, kt = 0, pt = 0, pt1 = 0;
    var me, k, p, p1;
    for (var i = 0; i < m.length; i++) {
      data.add([i, m[i]['real'], m[i]['measured'], m[i]['kalman'], m[i]['particles']]);
      me = (m[i]['real'] - m[i]['measured']).abs();
      met += me;
      k = (m[i]['real'] - m[i]['kalman']).abs();
      kt += k;
      p = (m[i]['real'] - m[i]['particles']).abs();
      pt += p;

      p1 = (m[i]['real'] - m[i]['particles1']).abs();
      pt1 += p1;
      data2.add([i, me, met, k, kt, p, pt, pt1]);
    }

    var options = {
                   'title': 'title'
    };

    new GoogleChats(data, options, '#simplec1');
    new GoogleChats(data2, options, '#simplec2');

  }



  List kalman(List measurements, num mNoise, num pNoise) {

    KalmanModel s = new KalmanModel();
    Kalman filter = new Kalman(s);

    var t = 1;

    s.x = new Matrix.fromList([[0]]);
    s.P = new Matrix.fromList([[1000000000]]);
    s.u = new Matrix.fromList([[0.0]]);
    s.B = new Matrix.fromList([[0]]);
    s.F = new Matrix.fromList([[1]]);
    s.H = new Matrix.fromList([[1]]);
    s.Ez = new Matrix.fromList([[mNoise]]);
    s.Ex = new Matrix.fromList([[Gaussian.normal(mean: 0, std: pNoise)]]);
    s.I = new Matrix.fromList([[1]]);

    for (var i = 0; i < measurements.length; i++) {
      s.Ex = new Matrix.fromList([[Gaussian.normal(mean: 0, std: pNoise)]]);
      filter.filter([[measurements[i]['measured']]]);
      measurements[i]['kalman'] = s.out.m[0][0];
    }

    return measurements;

  }


  List particles(List measurements, num meNoise, num peNoise, num pCount) {


    //define our model
    var aNoise = () {
      return Gaussian.normal(mean: 0, std: peNoise);
    };
    var mNoise = () {
      return Gaussian.normal(mean: 0, std: meNoise);
    };

    //define particles filter model
    var move = (List p) {
      p[0] = 10 + mNoise();
    };
    var generate = (List m, List o) {
      return [m[0] + mNoise()];
    };
    var weight = (List m, List p) {
      return Gaussian.gaussian(m[0], mean: p[0], std: meNoise);
    };
    var mean = (List p, List w) {
      num sum = 0;
      for (var i = 0; i < p.length; i++) {
        sum += p[i][0] * w[i];
       // sum += p[i][0];
      }
      return sum;
    };
    var clone = (List p) {
      return [p[0]];
    };
    ParticlesModel s = new ParticlesModel(pCount, move, generate, mean, aNoise, mNoise, weight, clone);
    Particles filter = new Particles(s);


    measurements[0]['particles'] = measurements[0]['measured'];

    filter.generate([measurements[0]['measured']], [measurements[0]['measured']]);

    //run experiment
    var filtered;
    for (var i = 1; i < measurements.length; i++) {

      filter.move();
      filter.weight([measurements[i]['measured']]);
      filter.resample();
      filtered = filter.mean();

      measurements[i]['particles'] = filtered;
    }

    return measurements;

  }

}