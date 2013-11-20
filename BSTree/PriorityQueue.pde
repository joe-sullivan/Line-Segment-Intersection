// priority queue for storing events

class PriorityQueue {
  private ArrayList<float[]> _events;
  
  PriorityQueue() {
    _events = new ArrayList();
  }
  
  void insert(float[] event) {
    _events.add(event);
    heapify(_events.size()-1);
  }
  
  private void heapify(int id) {
    while (id != 0) {
      int p = getParent(id);
      if (compare(_events.get(id), _events.get(p)))
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
    float[] tmp = _events.get(id);
    _events.add(id, _events.get(p));
    _events.add(p, tmp);
  }
  
  private boolean compare(float[] e, float[] p) {
     if (e[0] < p[0] || (e[0] == p[0] && e[1] < p[1]))
      return false;
    return true;
  }
  
  
  int size() {
    return _events.size();
  }
  
  boolean empty() {
    return (_events.size() == 0);
  }
}

