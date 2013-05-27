part of filters;

class KalmanModel {
  //vector (aka matrix)
  Matrix x; //prediction
  Matrix z; //measurement
  Matrix u; //motion vecor
  //MATRIX
  Matrix F; //state transition
  Matrix B; //motion transition
  Matrix P; //uncertainty covariance
  Matrix H; //measurement function
  Matrix Ez; //measurement noise
  Matrix Ex; //model noise
 
  Matrix I; //identity matrix

  Matrix out;

  String toString() {
    String s = '';
    s += x.toString();
    return s;
  }

}