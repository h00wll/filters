part of Kalman;

class KalmanModel {
  //vector (aka matrix)
  Matrix x; //prediction
  Matrix z; //measurement
  Matrix u; //motion vecor
  //MATRIX
  Matrix F; //state transition
  Matrix P; //uncertainty covariance
  Matrix R; //measurement noise
  Matrix H; //measurement function
  Matrix I; //identity matrix

  Matrix out;

  String toString() {
    String s = '';
    s += "";
    return s;
  }

}