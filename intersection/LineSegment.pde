// LineSegment class

class LineSegment {
  float[] _start = new float[2]; // coordinate of start location
  float[] _end = new float[2]; // coordinate of end location
  
  LineSegment(float x1, float y1, float x2, float y2) {
    // start point is to left of end point
    if (x1 <= x2) { // first point is to left of second point
      _start[0] = x1;
      _start[1] = y1;
      _end[0] = x2;
      _end[1] = y2;
    }
    else { // first point is to right of second point
      _start[0] = x2;
      _start[1] = y2;
      _end[0] = x1;
      _end[1] = y1;
      
    }
  }
  
  float[] start() {
    return _start;
  }
  
  float[] end() {
    return _end;
  }
  
  float slope() {
    float slope = (_start[1] - _end[1]) / (_start[0] - _end[0]);
    return slope;
  }
  
  float[] findIntersect(float x) {
    float m = slope();
    float b = _start[1] - (m * _start[0]);
    float y = (m * x) + b;
    x = (y - b) / m;
    float[] point = {x, y};
    return point;
  }
  
  boolean includes(float x, float y) {
    if ((x > _start[0] && x < _end[0] && y > _start[1] && y < _end[1])
        || (x > _start[0] && x < _end[0] && y > _end[1] && y < _start[1]))
      return true;
    return false;
  }
}
