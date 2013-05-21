import 'dart:html';
import 'dart:math';
import 'dart:core';

import 'matrix.dart';
import 'kalman.dart';
import 'particles.dart';
import 'gaussian.dart';
import 'google_charts.dart';
import 'google_maps.dart';


CanvasElement c = query('#graph');
CanvasRenderingContext2D crc = c.getContext('2d');

void main() {
  
  InputElement button = query('#submit');
  button.onClick.listen((var data) {
    print('click');
    FileUploadInputElement file = query('#file');
    print(file.files);
    FileList fl = file.files;

    FileReader fr = new FileReader();
    fr.onLoadEnd.listen((var data) {
      List data = new List();
      String result = fr.result;
      List lines = result.split('\n');
      lines.forEach((String line) {
        if (!line.isEmpty) {          
          List args = line.split(',');
          if (args[0] == "0") {
            data.add([args[2], args[3]]);
            print(args);
          }
        }
      });
      new GoogleMaps(data);
    });
    fr.readAsText(fl.first);
  });
  
  
  //for (var i = 0; i < 20; i++) {
    //print(Gaussian.normal());
  //}
  var measurements = new List();
  // x = x + 2;
  var x = 4;
  var v = 0;
  var a = 1;
  for (var i = 0; i < 50; i++) {
    if (i > 25) {
      a = -1;
    }
    measurements.add({
      'real': x,
      'measured': x + Gaussian.normal()
    });
    x += v;
    v = v + a;
  }
  measurements = particles(measurements);
  measurements = kalman(measurements);
  print(measurements);
  graph(measurements);

  //new GoogleMaps();


}

void graph(List m) {
  List data = new List();
  List data2 = new List();
  data.add(['t', 'real', 'measured', 'kalman', 'particles']);
  data2.add(['t', 'm', 'm total', 'k', 'k total', 'p', 'p total']);
  var met = 0, kt = 0, pt = 0;
  var me, k, p;
  for (var i = 0; i < m.length; i++) {
    data.add([i, m[i]['real'], m[i]['measured'], m[i]['kalman'], m[i]['particles']]);
    me = (m[i]['real'] - m[i]['measured']).abs();
    met += me;
    k = (m[i]['real'] - m[i]['kalman']).abs();
    kt += k;
    p = (m[i]['real'] - m[i]['particles']).abs();
    pt += p;
    data2.add([i, me, met, k, kt, p, pt]);
  }

  var options = {
    'title': 'title'
  };

  new GoogleChats(data, options, '#c1');
  new GoogleChats(data2, options, '#c2');

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
    var newX = p['x'] + p['v'] + mNoise(); 
    p['v'] = newX - p['x'];
    p['x'] = newX;
    return p;
  };
  var generate = (var m) {
    return {'x': m['x'] + mNoise(), 'v': m['v']};
  };
  var weight = (num m, num p) {
    return Gaussian.gaussian(m, mean: p, std: 1);
  };
  ParticlesModel s = new ParticlesModel(1000, move, generate, aNoise, mNoise, weight);
  Particles filter = new Particles(s);


  measurements[0]['particles'] = measurements[0]['measured'];
  measurements[1]['particles'] = measurements[1]['measured'];

  filter.generate({'x': measurements[1]['particles'], 'v': measurements[1]['particles'] - measurements[0]['particles']});

  //run experiment
  for (var i = 2; i < measurements.length; i++) {
    var filtered;

    filter.move();
    filter.weight(measurements[i]['measured']);
    filter.resample();
    filtered = filter.mean();

    measurements[i]['particles'] = filtered;
  }

  return measurements;

}

List kalman(List measurements) {

  KalmanModel s = new KalmanModel();
  Kalman filter = new Kalman(s);

  s.x = new Matrix.fromList([[0], [0]]);
  s.P = new Matrix.fromList([[1000, 0], [0, 1000]]);
  s.u = new Matrix.fromList([[0], [0]]);
  s.F = new Matrix.fromList([[1, 1], [0, 1]]);
  s.H = new Matrix.fromList([[1, 0]]);
  s.R = new Matrix.fromList([[1]]); 
  s.I = new Matrix.fromList([[1, 0], [0, 1]]);

  for (var i = 0; i < measurements.length; i++) {
    filter.filter([[measurements[i]['measured']]]);
    //measurements[i]['kalman'] = s.out.m[0][0];
    measurements[i]['kalman'] = measurements[i]['measured'];
  }

  return measurements;

}

void paint(List points, String color) {

  crc.beginPath();
  crc.lineWidth = 1;
  crc.strokeStyle = color;
  crc.moveTo(0, points[0] * 10);

  for (var i = 0; i < points.length; i++) {
    crc.lineTo(i * 10, c.height - points[i] * 40 + 300);
  }
  crc.moveTo(0, points[0] * 100);


  crc.closePath();
  crc.stroke();
}
