// priority queue for storing events

class PriorityQueue {
  private ArrayList<Point> _points;
  
  PriorityQueue() {
    _points = new ArrayList();
  }
  
  void insert(Point p) {
    _points.add(p);
    heapify(_points.size()-1);
  }
  
  Point peek() {
    if (!empty())
      return _points.get(0);
    else
      return null;
  }
  
  Point remove() {
    if (!empty()) {
      Point p = _points.get(0);
      _points.remove(0);
      return p;
    }
    else
      return null;
  }
  
  private void heapify(int id) {
    while (id != 0) {
      int p = getParent(id);
      if (compare(_points.get(id), _points.get(p)))
        break;
      swap(p, id);
      id = p;
    }
  }
  
  private int getParent(int id) {
    return (id - 1) / 2;
  }
  
  private int getLeft(int id) {
    return ((id + 1) * 2);
  }
  
  private int getRight(int id) {
    return ((id + 1) * 2) + 1;
  }
  
  private void swap(int p, int id) {
    Point tmp = _points.get(id);
    _points.add(id, _points.get(p));
    _points.add(p, tmp);
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

