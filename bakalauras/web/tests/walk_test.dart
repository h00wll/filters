part of tests;

class WalkTest {
  
  WalkTest() {
    
    InputElement button = query('#submit');
    button.onClick.listen((var data) {
      FileUploadInputElement file = query('#file');
      readFile(file.files);
    });  
  }
  
  List readFile(FileList fl) {
    FileReader fr = new FileReader();
    fr.onLoadEnd.listen((var data) {
      List measurements = new List();
      String result = fr.result;
      List lines = result.split('\n');
      lines.forEach((String line) {
        if (!line.isEmpty) {          
          List args = line.split(',');
          if (args[0] == "0") {
            measurements.add({'measured': [[double.parse(args[3]) * 100000], [double.parse(args[2]) * 100000]]});
          }
        }
      });
      
      //do something
      //measurements = kalman(measurements);
      measurements = particles(measurements);
      print(measurements);
      draw(measurements);
    });
    fr.readAsText(fl.first);
  }
  
  void draw(List m) {
    GoogleMaps maps = new GoogleMaps();
    List data = new List();
    List kalman = new List();
    List particles = new List();
    m.forEach((var mes) {
      data.add([mes['measured'][0][0], mes['measured'][1][0]]);
      if (mes['kalman'] != null) {
        kalman.add([mes['kalman'][0][0], mes['kalman'][1][0]]);
      }
      if (mes['particles'] != null) {
        kalman.add([mes['particles'][0], mes['particles'][1]]);
      }
    });    
    maps.draw(data, "#ff0000");  
    /*if (kalman.length > 0) {
      print(kalman);
      maps.draw(kalman, "#00ff00");        
    }
    if (particles.length > 0) {
      print(particles);
      //maps.draw(kalman, "#0000ff");        
    }*/
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