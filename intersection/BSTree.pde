// binary search tree to store line segments

final int L = -1;
final int R = 1;

class BSTree {
  private int _size;
  private Node _root;
  private ArrayList<LineSegment> _lines;
  private boolean _newLine;
  
  BSTree() {
    _size = 0;
    _lines = new ArrayList();
  }
  
  boolean insert(LineSegment l) {
    _newLine = insert(l, _root, 0); // insert line
    return _newLine;
  }
  
  private boolean insert(LineSegment ls, Node pn, int depth) {
    if (empty()) {
      _root = new Node(ls);
      _size++; 
    }
    else {
      int comp = pn.compareH(ls);
      if (comp == L) {
        if (pn.hasLeft()) // recurse
          insert(ls, pn.left, depth + 1);
        else { // leaf
          _size++;
          Node n = new Node(ls);
          n.parent = pn;
          pn.left = n;
        }
      }
      if (comp == R) {
        if (pn.hasRight()) // recurse
          insert(ls, pn.right, depth + 1);
        else { // leaf
          _size++;
          Node n = new Node(ls);
          n.parent = pn;
          pn.right = n;
        }
      }
      if (comp == 0) { // node already exists in tree
        // do nothing
        return false;
      }
    }
    return true;
  }
  
  boolean remove(LineSegment l) {
    if (!empty())
      _newLine = remove(l, _root);
    else
      _newLine = false;
    return _newLine;
  }
  
  private boolean remove(LineSegment l, Node n) {
      int comp = n.compareH(l);
      if (comp == L) {
        if (n.hasLeft()) // recurse
          remove(l, n.left);
        else
          return false;
      }
      if (comp == R) {
        if (n.hasRight()) // recurse
          remove(l, n.right);
        else
          return false;
      }
      if (comp == 0) { // remove
        comp = n.parent.compareH(l);
        if (comp == L) {
          if (n.hasLeft()) {
            n.parent.left =  n.left;
            n.left.parent = n.parent;
            if (n.hasRight()) {
              Node leftmost = findLeft(n.right);
              leftmost.left = n.left.right;
              n.left.parent = leftmost;
            }
            n.left.right = n.right;
            n.right.parent = n.left;
          }
          else {
            if (n.hasRight()) {
              n.parent.right = n.right;
              n.right.parent = n.parent;
            }
          }
        }
        if (comp == R) {
          if (n.hasLeft()) {
            n.parent.right =  n.left;
            n.left.parent = n.parent;
            if (n.hasRight()) {
              Node leftmost = findLeft(n.right);
              leftmost.left = n.left.right;
              n.left.parent = leftmost;
            }
            n.left.right = n.right;
            n.right.parent = n.left;
          }
          else {
            if (n.hasRight()) {
              n.parent.right = n.right;
              n.right.parent = n.parent;
            }
          }
        }
        if (comp == 0) { // root
          if (n.hasRight()) {
            Node leftmost = findLeft(n.right);
            _root = leftmost;
            _root.parent = null;
            _root.right = n.right;
            n.right.parent = _root;
            if (n.hasLeft()) {
              _root.left = n.left;
              n.left.parent = _root;
            }
          }
          else {
            if (n.hasLeft()) {
              _root = n.left;
              n.left.parent = null;
            }
          }
        }
      }
      _size--;
      return true;
  }
  
  private Node findLeft(Node n) {
    while (n.hasLeft()) {
      n = n.left;
    }
    return n;
  }
  
  int size() {
    return _size;
  }
  
  boolean empty() {
    return (_size == 0);
  }
  
  LineSegment get(int i) {
    if (_newLine)
      getLines();
    return _lines.get(i);
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
    if (n.hasLeft()) // left child
      visitNodes(n.left);
    
    // between left and right to keep ordered  
    _lines.add(n.ls);
    
    if (n.hasRight()) // right child
      visitNodes(n.right);
  }
}

private class Node {
  LineSegment ls;
  Node parent;
  Node left;
  Node right;
  
  Node(LineSegment lineSegment) {
    ls = lineSegment;
  }
  
  boolean isRoot() {
    return (parent == null);
  }
  
  boolean hasChild() {
    return (left != null || right != null);
  }
  
  boolean hasLeft() {
    return (left != null);
  }
  
  boolean hasRight() {
    return (right != null);
  }

  int compareH(LineSegment l) { // left to right
    float x = ls._start[0];
    float y = ls._start[1];

    float[] p = l._start; // parent node event
    if (x < p[0] || (x == p[0] && y < p[1]))
      return L;
    if (x > p[0] || (x == p[0] && y > p[1]))
      return R;
    return 0;
  }
  
  int compareV(LineSegment l) { // top to bottom
    float x = ls._start[0];
    float y = ls._start[1];

    float[] p = l._start; // parent node event
    if (y < p[1] || (y == p[1] && x < p[0]))
      return R;
    if (y > p[1] || (y == p[1] && x > p[0]))
      return L;
    return 0;
  }
}

