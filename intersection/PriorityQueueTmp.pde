// priority queue for storing events
// temporary (not min heap)

class PriorityQueueTmp {
  private ArrayList<Point> _points;

  PriorityQueueTmp() {
    _points = new ArrayList();
  }

  void insert(Point p) {
    if (_points.size() > 0) {
      boolean inserted = false;
      for (int i = 0; i < _points.size(); i++) {
        if (compare(_points.get(i), p) && !inserted) {
          _points.add(i, p);
          inserted = true;
          i++;
        }
      }
      if (!inserted)
        _points.add(p);
    }
    else
      _points.add(p);
  }

  Point remove() {
    Point p = _points.get(0);
    _points.remove(0);
    return p;
  }

  void remove(float[] p) {
    for (int i = 0; i < _points.size(); i++) {
      float[] pt = _points.get(i).getPoint();
      if (pt[0] == p[0] && pt[1] == p[1])
        _points.remove(i);
    }
  }

  private boolean compare(Point evt, Point pnt) {
    float[] e = evt.getPoint();
    float[] p = pnt.getPoint();
    if (e[0] < p[0] || (e[0] == p[0] && e[1] < p[1]))
      return false;
    return true;
  }

  int size() {
    return _points.size();
  }

  boolean empty() {
    return (_points.size() == 0);
  }
}
