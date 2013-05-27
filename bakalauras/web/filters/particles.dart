part of filters;

class Particles {

  Random r = new Random();

  ParticlesModel s;

  Particles(this.s) {

  }

  void generate(var m, var o) {
    for (var i = 0; i < s.count; i++) {
      s.particles[i] = s.generate(m, o);
    }
    //print('gen');
    //print(s.particles);
  }

  void move() {
    for (var i = 0; i < s.count; i++) {
      s.move(s.particles[i]);
    }
    //print('move');
    //print(s.particles);
  }

  void weight(var measured) {
    num sum = 0;
    s.maxWeight = 0;
    for (var i = 0; i < s.count; i++) {
      s.weights[i] = s.weight(measured, s.particles[i]);
      sum += s.weights[i];
    }
    
    if (sum == 0) sum = 1;
    
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
      newParticles[i] = s.clone(s.particles[index]);
    }
    s.particles = newParticles;
    //print('resampled');
    //print(s.particles);
  }


  mean() {
    //print(sum);
    //print(s.count);
    return s.mean(s.particles, s.weights);
  }

}