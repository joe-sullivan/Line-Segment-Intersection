// Point class

final int START = -1;
final int END = 1;
final int INTERSECTION = 0;

class Point {
  private float[] _pnt = new float[2]; // coordinate of point
  private int _type;
  
  Point(float x, float y, int type) {
    _pnt[0] = x;
    _pnt[1] = y;
    _type = type;
  }
  
  float[] getPoint() {
    return _pnt;
  }
  
  int type() {
    return _type;
  }
}
