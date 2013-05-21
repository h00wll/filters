library particles;

import 'dart:math';

part 'particles_model.dart';

class Particles {

  Random r = new Random();

  ParticlesModel s;

  Particles(this.s) {

  }

  void generate(var x) {
    for (var i = 0; i < s.count; i++) {
      s.particles[i] = s.generate(x);
    }
    //print('gen');
    //print(s.particles);
  }

  void move() {
    for (var i = 0; i < s.count; i++) {
      s.particles[i] = s.move(s.particles[i]);
    }
    //print('move');
    //print(s.particles);
  }

  void weight(num measured) {
    num sum = 0;
    s.maxWeight = 0;
    for (var i = 0; i < s.count; i++) {
      s.weights[i] = s.weight(measured, s.particles[i]['x']);
      sum += s.weights[i];
    }
    for (var i = 0; i < s.count; i++) {
      s.weights[i] /= sum;
      if (s.weights[i] > s.maxWeight) {
        s.maxWeight = s.weights[i];
      }
    }
    //print('weight');
    //print(s.weights);
  }

  void resample() {
    List newParticles = new List(s.count);
    int index = r.nextInt(s.count);
    num beta = 0;
    for (var i = 0; i < s.count; i++) {
      beta = r.nextDouble() * 2 * s.maxWeight;
      while(beta > s.weights[index]) {
        beta -= s.weights[index];
        index = (index + 1) % s.count;
      }
      newParticles[i] = {'x': s.particles[index]['x'], 'v': s.particles[index]['v']};
    }
    s.particles = newParticles;
    //print('resampled');
    //print(s.particles);
  }


  mean() {
    var sum = 0;
    for (var i = 0; i < s.count; i++) {
      sum += s.particles[i]['x'];
    }
    //print(sum);
    //print(s.count);
    return sum / s.count;
  }

}