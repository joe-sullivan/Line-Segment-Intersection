// Point class

final int START = -1;
final int END = 1;
final int INTERSECTION = 0;

class Point {
  private float[] _pnt = new float[2]; // coordinate of point
  private int _type;
  private LineSegment _lineSegment;
  private LineSegment _lineSegment2;
  
  Point(float x, float y, int type, LineSegment l) {
    _pnt[0] = x;
    _pnt[1] = y;
    _type = type;
    _lineSegment = l;
  }
  
  Point(float x, float y, int type, LineSegment l1, LineSegment l2) {
    _pnt[0] = x;
    _pnt[1] = y;
    _type = type;
    _lineSegment = l1; // above
    _lineSegment2 = l2; // below
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
  
  LineSegment[] crossingLines() {
    LineSegment[] ls = {_lineSegment, _lineSegment2};
    return ls;
  }
}
