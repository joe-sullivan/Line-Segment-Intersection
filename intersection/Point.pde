// Point class

final int START = -1;
final int END = 1;
final int INTERSECTION = 0;

class Point {
  private float[] _pnt = new float[2]; // coordinate of point
  private int _type;
  private LineSegment _lineSegment;
  
  Point(float x, float y, int type, LineSegment l) {
    _pnt[0] = x;
    _pnt[1] = y;
    _type = type;
    _lineSegment = l;
  }
  
  float[] getPoint() {
    return _pnt;
  }
  
  int type() {
    return _type;
  }
  
  LineSegment getLine() {
    return _lineSegment;
  }
}
