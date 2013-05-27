part of math;

class Matrix {

  List<List<num>> m;
  int rows;
  int columns;

  Matrix(this.rows, this.columns) {
    m = new List<List<num>>(rows);
    for (var row = 0; row < rows; row++) {
      m[row] = new List<num>(columns);
    }
  }

  Matrix.fromList(List<List> values) {
    rows = values.length;
    columns = values[0].length;
    m = new List<List<num>>(rows);
    for (var row = 0; row < rows; row++) {
      m[row] = new List<num>(columns);
      for (var column = 0; column < columns; column++) {
        m[row][column] = values[row][column];
      }
    }
  }

  Matrix operator *(var m) {
    Matrix result;
    if (m is Matrix) {
      result = new Matrix(rows, m.columns);
      var sum;
      for (var row = 0; row < rows; row++) {
        for (var column = 0; column < m.columns; column++) {
          sum = 0;
          for (var i = 0; i < columns; i++) {
            sum += this.m[row][i] * m.m[i][column];
          }
          result.m[row][column] = sum;
        }
      }    
    } else {
      result = new Matrix(rows, columns);  
      for (var row = 0; row < rows; row++) {
        for (var column = 0; column < columns; column++) {         
          result.m[row][column] = this.m[row][column] * m;
        }
      }
    }
    return result;
  }

  Matrix operator /(num a) {
    Matrix result = new Matrix(rows, columns);
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        result.m[row][column] = m[row][column] / a;
      }
    }
    return result;
  }

  Matrix operator +(Matrix m) {
    Matrix result = new Matrix(rows, columns);
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        result.m[row][column] = this.m[row][column] + m.m[row][column];
      }
    }
    return result;
  }

  Matrix operator -(Matrix m) {
    Matrix result = new Matrix(rows, columns);
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        result.m[row][column] = this.m[row][column] - m.m[row][column];
      }
    }
    return result;
  }

  Matrix invert() {
    if (rows == 1) {
      return new Matrix.fromList([[1 / m[0][0]]]);
    }

    Matrix nm = new Matrix(rows, columns);
    num determinant = det();
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        nm.m[row][column] = pow(-1, row + column) * minor(row, column).det();
      }
    }
    return nm / determinant;
  }

  Matrix transpose() {
    Matrix nm = new Matrix(columns, rows);
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        nm.m[column][row] = m[row][column];
      }
    }
    return nm;
  }

  num det() {
    if (rows == 1) {
      return m[0][0];
    } else if (rows == 2) {
      return m[0][0] * m[1][1] - m[0][1] * m[1][0];
    } else {
      num determinant = 0;
      for (int c = 0; c < columns; c++) {
        determinant += pow(-1, c) * m[0][c] * minor(0, c).det();
      }
      return determinant;
    }
  }

  Matrix minor(int row, int column) {
    Matrix nm = new Matrix(rows - 1, columns - 1);
    int i = 0;
    for (int r = 0; r < rows; r++) {
      if (r != row) {
        int j = 0;
        for (int c = 0; c < columns; c++) {
          if ((r != row) && (c != column)) {
            nm.m[i][j] = m[r][c];
            j++;
          }
        }
        i++;
      }
    }
    return nm;
  }

  Matrix clone() {
    Matrix nm = new Matrix.fromList(m);
    return nm;
  }

  String toString() {
    String s = '';
    for (var row = 0; row < rows; row++) {
      s += '[';
      for (var column = 0; column < columns; column++) {
        s += m[row][column].toString() +', ';
      }
      s += ']\n';
    }
    return s;
  }

}