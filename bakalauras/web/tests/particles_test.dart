part of tests;

class ParticlesTest {
  
  num pNoise = 0;
  num mNoise = 1;
  num time = 50;
  num p1Count;
  num p2Count;
  
  ParticlesTest(this.time, this.mNoise, this.pNoise, this.p1Count, this.p2Count) {
    List measurements = new List();
    var x = 10;
    for (var i = 0; i < time; i++) {
      measurements.add({
        'real': x + Gaussian.normal(mean: 0, std: pNoise),
        'measured': x + Gaussian.normal(mean: 0, std: mNoise)
      });
    }
    measurements = particles1(measurements, mNoise, pNoise, p1Count);
    measurements = particles2(measurements, mNoise, pNoise, p2Count);

    graph(measurements);
  } 
  
  
  void graph(List m) {
    List data = new List();
    List data2 = new List();
    data.add(['time', 'real', 'measured', 'particles1', 'particles2']);
    data2.add(['time', 'measured', 'measured total', 'particles1', 'particles1 total', 'particles2', 'particles2 total']);
    
    var met = 0, pt1 = 0, pt2 = 0;
    var me, p1, p2;
    for (var i = 0; i < m.length; i++) {
      data.add([i, m[i]['real'], m[i]['measured'], m[i]['particles1'], m[i]['particles2']]);
      me = (m[i]['real'] - m[i]['measured']).abs();
      met += me;

      p1 = (m[i]['real'] - m[i]['particles1']).abs();
      pt1 += p1;
      p2 = (m[i]['real'] - m[i]['particles2']).abs();
      pt2 += p2;
      data2.add([i, me, met, p1, pt1, p2, pt2]);
    }

    var options = {
                   'title': 'Daleliu filtras'
    };

    new GoogleChats(data, options, '#particlesc1');
    new GoogleChats(data2, options, '#particlesc2');

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
      return sum;
    };
    var clone = (List p) {
      return [p[0]];
    };
    ParticlesModel s = new ParticlesModel(pCount.round(), move, generate, mean, aNoise, mNoise, weight, clone);
    Particles filter = new Particles(s);
  
  
    measurements[0]['particles1'] = measurements[0]['measured'];
  
    filter.generate([measurements[0]['measured']], [measurements[0]['measured']]);
  
    //run experiment
    var filtered;
    for (var i = 1; i < measurements.length; i++) {
     
      filter.move();
      filter.weight([measurements[i]['measured']]);
      filter.resample();
      filtered = filter.mean();
  
      measurements[i]['particles1'] = filtered;
    }
  
    return measurements;
  
  }
  

  List particles2(List measurements, num meNoise, num peNoise, num pCount) {
  
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
    ParticlesModel s = new ParticlesModel(pCount.round(), move, generate, mean, aNoise, mNoise, weight, clone);
    Particles filter = new Particles(s);
  
  
    measurements[0]['particles2'] = measurements[0]['measured'];
  
    filter.generate([measurements[0]['measured']], [measurements[0]['measured']]);
  
    //run experiment
    for (var i = 1; i < measurements.length; i++) {
      var filtered;
  
      filter.move();
      filter.weight([measurements[i]['measured']]);
      filter.resample();
      filtered = filter.mean();
  
      measurements[i]['particles2'] = filtered;
    }
  
    return measurements;
  
  }

  
}