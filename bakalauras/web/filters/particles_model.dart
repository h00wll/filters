part of filters;

class ParticlesModel {

  int count;
  List particles;
  List weights;
  var move;
  var generate;
  var mean;
  var aNoise;
  var mNoise;
  var weight;
  var clone;
  num maxWeight;

  ParticlesModel(this.count, this.move, this.generate, this.mean, this.aNoise, this.mNoise, this.weight, this.clone) {
    particles = new List(count);
    weights = new List(count);
  }

}