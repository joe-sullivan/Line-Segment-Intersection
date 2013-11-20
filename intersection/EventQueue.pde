// event queue (binary search tree)

class EventQueue {
  int _size;
  Node _root;
  
  EventQueue() {
    _size = 0;
  }
  
  boolean insert(LineSegment l) {
    boolean inserted;
    inserted = insert(l.start(), l, _root, 0);
    inserted = inserted && insert(l.end(), l, _root, 0);
    return inserted;
  }
  
  private boolean insert(float[] e, LineSegment ls, Node pn, int depth) {
    if (empty()) {
      _root = new Node(e, null);
      _size++; 
    }
    else {
      float x = e[0];
      float y = e[1];
      
      float[] pe = pn.event; // parent node event
      if (x < pe[0] || (x == pe[0] && y < pe[1])) { // event goes left
        if (pn.hasLeftChild()) // recurse
          insert(e, ls, pn.left, depth + 1);
        else { // leaf
          _size++;
          Node n = new Node(e, ls);
          n.setParent(pn);
          pn.setLeft(n);
        }
      }
      if (x > pe[0] || (x == pe[0] && y > pe[1])) { // event goes right
        if (pn.hasRightChild()) // recurse
          insert(e, ls, pn.right, depth + 1);
        else { // leaf
          _size++;
          Node n = new Node(e, ls);
          n.setParent(pn);
          pn.setRight(n);
        }
      }
      if ((x == pe[0]) && (y == pe[1])) { // event already exists in tree
        // do nothing
        return false;
      }
    }
    return true;
  }
  
  float[] remove() { // get leftmost event
    Node n = _root;
    if (!empty()) {
      while (n.hasLeftChild()) {
        n = n.left;
      }
      if (n.isRoot()) {
        _root = n.right; // new root
      }
      else
        n.parent.left = n.right; // update parent
      _size--;
      
      return n.event;
    }
    return null;
  }
  
  int size() {
    return _size;
  }
  
  boolean empty() {
    return (_size == 0);
  }
}

private class Node {
  boolean isEnd;
  LineSegment ls;
  float[] event = new float[2];
  Node parent;
  Node left;
  Node right;
  
  Node(float[] e, LineSegment lineSegment) {
    event[0] = e[0];
    event[1] = e[1];
    ls = lineSegment;
    isEnd = (lineSegment != null);
  }
  
  void setParent(Node n) {
    parent = n;
  }
  
  void setLeft(Node n) {
    left = n;
  }
  
  void setRight(Node n) {
    right = n;
  }
  
  boolean isRoot() {
    return (parent == null);
  }
  
  boolean hasChild() {
    return (left != null || right != null);
  }
  
  boolean hasLeftChild() {
    return (left != null);
  }
  
  boolean hasRightChild() {
    return (right != null);
  }
}
