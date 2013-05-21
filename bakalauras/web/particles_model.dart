part of particles;

class ParticlesModel {

  int count;
  List particles;
  List weights;
  var move;
  var generate;
  var aNoise;
  var mNoise;
  var weight;
  num maxWeight;

  ParticlesModel(this.count, this.move, this.generate, this.aNoise, this.mNoise, this.weight) {
    particles = new List(count);
    weights = new List(count);
  }

}