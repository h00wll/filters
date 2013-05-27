part of tests;

class MoveTest {
  
  num pNoise = 0.05;
  num mNoise = 1;
  num pCount;
  
  MoveTest(this.mNoise, this.pNoise, this.pCount) {
    pNoise = 0.05;
    mNoise = 5;
    List measurements = new List();
    var x = 0;
    var v = 5;
    var a = 1;
    for (var i = 0; i < 50; i++) {
      measurements.add({
        'real': x,
        'measured': x + randn(std: mNoise)
      });
      x += v;
      v += a + randn(std: pNoise);
    }
    measurements = particles(measurements, mNoise, pNoise, pCount);
   // measurements = particles1(measurements, mNoise, pNoise, pCount);
    measurements = kalman(measurements, mNoise, pNoise);

    graph(measurements);
  } 
  
  
  void graph(List m) {
    List data = new List();
    List data2 = new List();
    data.add(['t', 'real', 'measured', 'kalman', 'particles']);
    data2.add(['t', 'm', 'm total', 'k', 'k total', 'p', 'p total']);
    
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

      //p1 = (m[i]['real'] - m[i]['particles1']).abs();
      //pt1 += p1;
      data2.add([i, me, met, k, kt, p, pt]);
    }

    var options = {
                   'title': 'title'
    };

    new GoogleChats(data, options, '#movec1');
    new GoogleChats(data2, options, '#movec2');

  }
    
  

  List kalman(List measurements, num mNoise, num pNoise) {
  
    KalmanModel s = new KalmanModel();
    Kalman filter = new Kalman(s);
  
    var t = 1;
    var a = 1;

    s.F = new Matrix.fromList([[1, t], [0, 1]]); //A
    s.x = new Matrix.fromList([[0], [0]]);
    s.B = new Matrix.fromList([[t*t / 2], [t]]); //B
    s.u = new Matrix.fromList([[a]]);
    s.Ex = new Matrix.fromList([[t*t*t*t / 4, t*t*t / 3], [t*t*t / 2, t*t]]) * (pNoise * pNoise);
  //  s.Ex = new Matrix.fromList([[0, 0], [0, 0]]);
    s.H = new Matrix.fromList([[1, 0]]);         //C
    s.Ez = new Matrix.fromList([[mNoise * mNoise]]); 
    s.P = new Matrix.fromList([[1000, 0], [0, 1000]]);
    s.I = new Matrix.fromList([[1, 0], [0, 1]]);
  
    for (var i = 0; i < measurements.length; i++) {
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
      var nx = p[0] + p[1] + mNoise() + aNoise() + 1;
      p[1] = nx - p[0];
      p[0] = nx;
    };    
    var generate = (List m, List o) {
      var nx = m[0] + mNoise() * 2 + aNoise();
      return [nx, nx - o[0]];
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
      return [p[0], p[1]];
    };
    ParticlesModel s = new ParticlesModel(pCount, move, generate, mean, aNoise, mNoise, weight, clone);
    Particles filter = new Particles(s);
  

    measurements[0]['particles'] = measurements[0]['measured'];
    measurements[1]['particles'] = measurements[1]['measured'];
  
    filter.generate([measurements[1]['measured']], [measurements[0]['measured']]);
  
    //run experiment
    var filtered;
    for (var i = 2; i < measurements.length; i++) {
     
      filter.move();
      filter.weight([measurements[i]['measured']]);
      filter.resample();
      filtered = filter.mean();
  
      measurements[i]['particles'] = filtered;
    }
  
    return measurements;
  
  }
  

  List particles1(List measurements, num meNoise, num peNoise, num pCount) {
  
    //define our model
    var aNoise = () {
      return Gaussian.normal(mean: 0, std: peNoise);
    };
    var mNoise = () {
      return Gaussian.normal(mean: 0, std: meNoise);
    };
  
    //define particles filter model
    var move = (List p) {
      p[0] = p[0] + mNoise();
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
      //return sum / p.length;
      //print(m);
      //print(w);
      return sum;
    };
    var clone = (List p) {
      return [p[0]];
    };
    ParticlesModel s = new ParticlesModel(pCount, move, generate, mean, aNoise, mNoise, weight, clone);
    Particles filter = new Particles(s);
  
  
    measurements[0]['particles1'] = measurements[0]['measured'];
  
    filter.generate([measurements[0]['measured']], [measurements[0]['measured']]);
  
    //run experiment
    for (var i = 1; i < measurements.length; i++) {
      var filtered;
  
      filter.move();
      filter.weight([measurements[i]['measured']]);
      filter.resample();
      filtered = filter.mean();
  
      measurements[i]['particles1'] = filtered;
    }
  
    return measurements;
  
  }

  
}