// binary search tree

class BSTree {
  int _size;
  Node _root;
  ArrayList<LineSegment> _lines;
  boolean _newLine;
  
  BSTree() {
    _size = 0;
    _lines = new ArrayList();
//    _newLines = false;
  }
  
  boolean insert(LineSegment l) {
//    boolean inserted;
    _newLine = insert(l.start(), null, _root, 0); // line segment stored in end node
    _newLine = _newLine && insert(l.end(), l, _root, 0);
//    _newLine = true;
//    if (_newLine)
//      _lines.add(l);
    return _newLine;
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
//        _newLines = false;
        return false;
      }
    }
    return true;
  }
  
  float[] remove() { // get leftmost event
    Node n = _root;
    _newLine = true;
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
      
//      for (int i = 0; i < _lines.size(); i++) { // find line to remove
//        LineSegment l = _lines.get(i);
//        boolean remove;
//        float[] e = l.start();
//        if (e[0] == n.event[0] && e[1] == n.event[1])
//          remove = true;
//        e = l.end();
//        if (e[0] == n.event[0] && e[1] == n.event[1])
//          remove = true;
//        if (remove)
//          _lines.remove(i);
//      }
      
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

  ArrayList<LineSegment> getLines() { // return ArrayList of lines (used for drawing)
    if (_newLine) {
      _lines.clear();
      if (!empty())
        visitNodes(_root);
    }
    
    return _lines;
  }
  
  private void visitNodes(Node n) {
    if (n.hasLeftChild()) // left child
      visitNodes(n.left);
    
    // between left and right to keep ordered  
    if (n.isEnd)
      _lines.add(n.ls);
    
    if (n.hasRightChild()) // right child
      visitNodes(n.right);
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
