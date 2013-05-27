part of filters;

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
   * s.Ez - measurement noise
   * s.Ex - measurement noise
   */
   filter(var measurement) {
    //measurement update
    var S = s.H * s.P * s.H.transpose() + s.Ez;
    var K = s.P * s.H.transpose() * S.invert();

    var Z = new Matrix.fromList(measurement);
    var y = Z - (s.H * s.x);
    
    s.x = s.x + (K * y);
    s.out = s.x.clone();
    s.P = (s.I - (K * s.H)) * s.P;
    
    //predict
    s.x = s.F * s.x;
    s.x = s.x + s.B * s.u;
    //s.x = s.x + s.Ex;
    s.P = s.F * s.P * s.F.transpose() + s.Ex;
  }

}