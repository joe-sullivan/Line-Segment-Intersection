// priority queue for storing events

class PriorityQueue {
  private ArrayList<float[]> _points;
  
  PriorityQueue() {
    _points = new ArrayList();
  }
  
  void insert(float[] event) {
    _points.add(event);
    heapify(_points.size()-1);
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
    float[] tmp = _points.get(id);
    _points.add(id, _points.get(p));
    _points.add(p, tmp);
  }
  
  private boolean compare(float[] e, float[] p) {
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

