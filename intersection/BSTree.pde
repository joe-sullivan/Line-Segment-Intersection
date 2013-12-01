// binary search tree to store line segments

final int L = -1;
final int R = 1;

class BSTree {
  private int _size;
  private Node _root;
  private ArrayList<LineSegment> _lines;
  private boolean _newLine;
  private boolean _isStatus;
  
  BSTree(boolean isStatus) {
    _size = 0;
    _lines = new ArrayList();
    _isStatus = isStatus;
  }

  boolean insert(LineSegment l) {
    _newLine = insert(l, _root); // insert line
    return _newLine;
  }

  private boolean insert(LineSegment ls, Node pn) {
    if (empty()) {
      _root = new Node(ls);
      _size++;
    }
    else {
      int comp;
      if (_isStatus)
        comp = pn.compareH(ls);
      else
        comp = pn.compareV(ls);
      if (comp == L) {
        if (pn.hasLeft()) // recurse
          insert(ls, pn.left);
        else { // leaf
          _size++;
          Node n = new Node(ls);
          n.parent = pn;
          pn.left = n;
        }
      }
      if (comp == R) {
        if (pn.hasRight()) // recurse
          insert(ls, pn.right);
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
    if (comp != 0) { // keep searching
      if (comp == L) {
        if (n.hasLeft()) // recurse
          return remove(l, n.left);
      }
      if (comp == R) {
        if (n.hasRight()) // recurse
          return remove(l, n.right);
      }
      return false;
    }
    else { // remove
      if (!n.isRoot())
        comp = n.parent.compareH(l);
      if (n.hasLeft() && n.hasRight()) {
        Node min = findLeft(n.right);
        n.ls = min.ls;
        min.parent.left = null;
      }
      else if (n.hasLeft()) {
        if (!n.isRoot()) {
          if (comp == L)
            n.parent.left = n.left;
          else
            n.parent.right = n.left;
          n.left.parent = n.parent;
        }
        else {
          _root = n.left;
          n.left.parent = null;
        }
      }
      else if (n.hasRight()) {
        if (!n.isRoot()) {
          if (comp == L)
            n.parent.left = n.right;
          else
            n.parent.right = n.right;
          n.right.parent = n.parent;
        }
        else {
          _root = n.right;
          n.right.parent = null;
        }
      }
      else { // leaf
        if (!n.isRoot()) {
          if (comp == L)
            n.parent.left = null;
          else
            n.parent.right = null;
        }
        else
          _root = null;
      }

      _size--;
      return true;
    }
  }

  private Node findLeft(Node n) {
    while (n.hasLeft ()) {
      n = n.left;
    }
    return n;
  }
  
  LineSegment[] findNeighbors(LineSegment l) {
    LineSegment[] ls = new LineSegment[2];
    if (!empty()) {
      ls[0] = visitNeighbors(l, ls, _root, true);
      ls[1] = visitNeighbors(l, ls, _root, false);
    }
    return ls;
  }
  
  private LineSegment visitNeighbors(LineSegment l, LineSegment[] ls, Node n, boolean left) {
    if (l.equals(n.ls)) {
      if (left && n.hasLeft())
          return n.left.ls;
      if (!left && n.hasRight())
          return n.right.ls;
    }
    else {
      if (n.hasLeft()) // left child
        visitNeighbors(l, ls, n.left, left);
      if (n.hasRight()) // right child
        visitNeighbors(l, ls, n.right, left);
    }
    return null;
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
    if (n.hasRight()) // right child
      visitNodes(n.right);

    // between left and right to keep ordered  
    _lines.add(n.ls);
    
    if (n.hasLeft()) // left child
      visitNodes(n.left);
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
