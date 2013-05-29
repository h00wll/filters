part of tests;

class KalmanTest {

  num time = 50;
  num pNoise = 0;
  num mNoise = 1;
  num Ex1 = 0;
  num Ez1 = 1;
  num Ex2 = 0;
  num Ez2 = 1;

  KalmanTest(this.time, this.mNoise, this.pNoise, this.Ex1, this.Ez1, this.Ex2, this.Ez2) {
    List measurements = new List();
    var x = 10;
    for (var i = 0; i < time; i++) {
      measurements.add({
        'real': x + Gaussian.normal(mean: 0, std: pNoise),
        'measured': x + Gaussian.normal(mean: 0, std: mNoise)
      });
    }

    measurements = kalman1(measurements, mNoise, pNoise);
    measurements = kalman2(measurements, mNoise, pNoise);

    graph(measurements);
  }


  void graph(List m) {
    List data = new List();
    List data2 = new List();
    data.add(['laikas', 'reali reikšmė', 'pamatuota', 'kalman1', 'kalman2']);
    data2.add(['laikas', 'matavimas', 'matavimo klaidos suma', 'kalman1 klaida', 'kalman1 klaidos suma', 'kalman2 klaida', 'kalman2 klaidos suma']);
    //data2.add(['laikas', 'matavimas', 'matavimo klaidos suma', 'kalman1 klaida', 'kalman1 klaidos suma']);

    var met = 0, k1t = 0, k2t = 0;
    var me, k1, k2;
    for (var i = 0; i < m.length; i++) {
      data.add([i, m[i]['real'], m[i]['measured'], m[i]['kalman1'], m[i]['kalman2']]);
      //data.add([i, m[i]['real'], m[i]['measured'], m[i]['kalman1']]);
      //data.add([i, m[i]['real'], m[i]['measured']]);
      me = (m[i]['real'] - m[i]['measured']).abs();
      met += me;

      k1 = (m[i]['real'] - m[i]['kalman1']).abs();
      k1t += k1;

      k2 = (m[i]['real'] - m[i]['kalman2']).abs();
      k2t += k2;

      data2.add([i, me, met, k1, k1t, k2, k2t]);
    }

    var options = {
                   'title': 'Kalman filter'
    };

    new GoogleChats(data, options, '#kalmanc1');
    new GoogleChats(data2, options, '#kalmanc2');

  }



  List kalman1(List measurements, num mNoise, num pNoise) {

    KalmanModel s = new KalmanModel();
    Kalman filter = new Kalman(s);

    var t = 1;

    s.x = new Matrix.fromList([[0]]);
    s.P = new Matrix.fromList([[1000000000]]);
    s.u = new Matrix.fromList([[0.0]]);
    s.B = new Matrix.fromList([[0]]);
    s.F = new Matrix.fromList([[1]]);
    s.H = new Matrix.fromList([[1]]);
    s.Ez = new Matrix.fromList([[Ez1 * Ez1]]);
    s.Ex = new Matrix.fromList([[Ex1 * Ex1]]);
    s.I = new Matrix.fromList([[1]]);

    for (var i = 0; i < measurements.length; i++) {
      filter.filter([[measurements[i]['measured']]]);
      measurements[i]['kalman1'] = s.out.m[0][0];
    }

    return measurements;

  }


  List kalman2(List measurements, num mNoise, num pNoise) {

    KalmanModel s = new KalmanModel();
    Kalman filter = new Kalman(s);

    var t = 1;

    s.x = new Matrix.fromList([[0]]);
    s.P = new Matrix.fromList([[1000000000]]);
    s.u = new Matrix.fromList([[0.0]]);
    s.B = new Matrix.fromList([[0]]);
    s.F = new Matrix.fromList([[1]]);
    s.H = new Matrix.fromList([[1]]);
    s.Ez = new Matrix.fromList([[Ez2 * Ez2]]);
    s.Ex = new Matrix.fromList([[Ex2 * Ex2]]);
    s.I = new Matrix.fromList([[1]]);

    for (var i = 0; i < measurements.length; i++) {
      filter.filter([[measurements[i]['measured']]]);
      measurements[i]['kalman2'] = s.out.m[0][0];
    }

    return measurements;

  }


}