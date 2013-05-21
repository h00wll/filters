library Kalman;

import "matrix.dart";

part "kalman_model.dart";

class Kalman {

  KalmanModel s;

  Kalman(this.s) {

  }

  static init(KalmanModel s) {
    print('kalman init');
  }

  /**
   * s.x - estimate
   * s.P - uncertainty covariance
   * s.F - state transition matrix
   * s.R - measurement noise
   *
   */
   filter(var measurement) {
    //measurement update
    var Z = new Matrix.fromList(measurement);
    var y = Z - (s.H * s.x);
    var S = s.H * s.P * s.H.transpose() + s.R;
    var K = s.P * s.H.transpose() * S.invert();
    s.x = s.x + (K * y);
    s.out = s.x.clone();
    s.P = (s.I - (K * s.H)) * s.P;
    //predict
    s.x = (s.F * s.x) + s.u;
    s.P = s.F * s.P * s.F.transpose();
  }

}