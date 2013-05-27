part of tests;

class FlightTest {

  Map flights;

  FlightTest(var file) {
    readFile(file);
  }

  List readFile(FileList fl) {
    FileReader fr = new FileReader();
    fr.onLoadEnd.listen((var data) {
      flights = new Map();
      String result = fr.result;
      List lines = result.split('\n');
      lines.forEach((String line) {
        if (!line.isEmpty) {
          List args = line.split(',');
          if (flights[args[1]] == null) {
            flights[args[1]] = new List();
          }
          flights[args[1]].add([args[0], args[2], args[3], args[4]]);
        }
      });

      SelectElement se = new SelectElement();
      flights.forEach((var key, var value) {
       // se.options.add(new OptionElement(key, key));
      });

      //do something
      //measurements = kalman(measurements);
      //measurements = particles(measurements);
      //print(measurements);
      graph();
    });
    fr.readAsText(fl.first);
  }

  void graph() {
    List data = [];
    data.add(['x', 'y']);
    List flight = flights['SMX5292'];
    for (var i = 0; i < flight.length; i++) {
      data.add([double.parse(flight[i][1]), double.parse(flight[i][2])]);
    }

    var options = {'title': 'Kalman filter'};

    new GoogleChats(data, options, '#flightc1', type: GoogleChartType.Scatter);

  }



  List kalman(List measurements) {

    KalmanModel s = new KalmanModel();
    Kalman filter = new Kalman(s);

    var t = 1;

    s.x = new Matrix.fromList([[0], [0], [0], [0]]);
    s.P = new Matrix.fromList([[1000000000, 0, 0, 0], [0, 1000000000, 0, 0], [0, 0, 1000000000, 0], [0, 0, 0, 1000000000]]);
    s.u = new Matrix.fromList([[0.0], [0.0], [0.0], [0.0]]);
    s.B = new Matrix.fromList([[t/2], [t/2], [t], [t]]);
    s.F = new Matrix.fromList([[1, 0, t, 0], [0, 1, 0, t], [0, 0, 1, 0], [0, 0, 0, 1]]);
    s.H = new Matrix.fromList([[1, 0, 0, 0], [0, 1, 0, 0]]);
    s.Ez = new Matrix.fromList([[0.0, 0], [0, 0.0]]);
    //s.Ex = new Matrix.fromList([[t/4, 0, t/2 ,0], [0, t/4, 0 ,t/2], [t/2, 0, t/2 ,0], [0, t/2, 0 ,t/2]]);
    s.Ex = new Matrix.fromList([[0, 0, 0 ,0],[0, 0, 0 ,0],[0, 0, 0 ,0],[0, 0, 0 ,0]]);
    s.I = new Matrix.fromList([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]);

    for (var i = 0; i < measurements.length; i++) {
      filter.filter(measurements[i]['measured']);
      measurements[i]['kalman'] = s.out.m;
      //measurements[i]['kalman'] = measurements[i]['measured'];
    }

    return measurements;

  }


  List particles(List measurements) {

    //define our model
    var aNoise = () {
      return Gaussian.normal();
    };
    var mNoise = () {
      return Gaussian.normal();
    };

    //define particles filter model
    var move = (var p) {
      var nx = p[0] + p[2];
      var ny = p[1] + p[3];
      p[2] = nx - p[0];
      p[3] = ny - p[1];
      p[0] = nx;
      p[1] = ny;
      return p;
    };
    var generate = (List m, List o) {
      return [m[0][0] + mNoise(), m[1][0] + mNoise(), m[0][0] - o[0][0], m[1][0] - o[1][0]];
    };
    var weight = (List m, List p) {
      return Gaussian.gaussian(m[0][0], mean: p[0], std: 1);
    };
    var mean = (List p, List w) {
      List m = [0, 0, 0, 0];
      for (var i = 0; i < p.length; i++) {
        m[0] += p[i][0] * w[i];
        m[1] += p[i][1] * w[i];
        m[2] += p[i][2] * w[i];
        m[3] += p[i][3] * w[i];
      }
      //print(m);
      //print(w);
      return m;
    };
    var clone = (List m) {
      return [m[0], m[1], m[2], m[3]];
    };
    ParticlesModel s = new ParticlesModel(10, move, generate, mean, aNoise, mNoise, weight, clone);
    Particles filter = new Particles(s);


    measurements[0]['particles'] = [measurements[0]['measured'][0][0], measurements[0]['measured'][1][0]];
    measurements[1]['particles'] = [measurements[1]['measured'][0][0], measurements[1]['measured'][1][0]];

    filter.generate(measurements[1]['measured'], measurements[0]['measured']);

    //run experiment
    for (var i = 2; i < measurements.length; i++) {
      var filtered;

      filter.move();
     // print(s.particles);
      filter.weight(measurements[i]['measured']);
    //  print(s.weights);
      filter.resample();
    //  print(s.particles);
      filtered = filter.mean();

      measurements[i]['particles'] = filtered;
    }

    return measurements;

  }


}