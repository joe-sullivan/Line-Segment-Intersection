// priority queue for storing events

class PriorityQueue {
  private ArrayList<Point> _points;
  
  PriorityQueue() {
    _points = new ArrayList();
  }
  
  void addEvent(Point p) {
    if (_points.size() > 0) {
      boolean inserted = false;
      for (int i = 0; i < _points.size(); i++) {
        if (compare(_points.get(i), p) && !inserted) {
          _points.add(i,p);
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
  
  Point removeEvent() {
    Point p = _points.get(0);
    _points.remove(0);
    return p;
  }
  
  void removeEvent(float[] p) {
    for (int i = 0; i < _points.size(); i++) {
      float[] pt = _points.get(i).getPoint();
      if (pt[0] == p[0] && pt[1] == p[1])
        _points.remove(i);
    }
  }
  
  void insert(Point p) {
    println("INSERT");
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
    for (Point p : _points) {
      println("X: " + p.getPoint()[0]);
    }
    if (!empty()) {
      Point p = _points.get(0);
//      _points.remove(0);
      swap(0,_points.size()-1);
      _points.remove(_points.size()-1);
      siftDown(0);
      return p;
    }
    else
      return null;
  }
  
  private void siftDown(int id) {
    int left, right, min;
    left = getLeft(id);
    right = getRight(id);
    if (right >= size()) {
      if (left >= size())
        return;
      else
        min = left;
    }
    else {
      if (compare(_points.get(left),_points.get(right)))
        min = left;
      else
        min = right;
    }
    if (!compare(_points.get(id),_points.get(min))) {
      swap(id, min);
      siftDown(min);
    }
  }
  
  void remove(float[] point) {
    for (int i = 0; i < _points.size(); i++) {
      float[] pt = _points.get(i).getPoint();
      if (pt[0] == point[0] && pt[1] == point[1])
//        _points.remove(i);
        swap(i,_points.size()-1);
        _points.remove(_points.size()-1);
        siftDown(i);
    }
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
    _points.remove(id+1);
    _points.add(p, tmp);
    _points.remove(p+1);
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
