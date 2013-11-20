final int FG_COLOR = 85;
final color RED = color(217,107,114);
final color BLUE = color(148,164,181);

boolean _debug = true;
BSTree _lines; // holds events and line segements
BSTree _status;
PriorityQueue _events;
float[] _point = new float[2];
int _color = FG_COLOR; // line or point color
int _colorChange = 2; // amount to change each tick for pulse
float[] test = new float[2];

void setup() {
  size(400, 400);
  background(214, 209, 203);
  
  fill(FG_COLOR);
  noFill();
  stroke(FG_COLOR);
  
  _lines = new BSTree(); // initialize
  _status = new BSTree();
  _events = new PriorityQueue();
  _point[0] = -1; // waiting for input for first point
}

void draw() {
  // flip y axis
  scale(1, -1);
  translate(0, -height);
  
  background(214, 209, 203);
  stroke(FG_COLOR);
  
  // vertical sweep line
  LineSegment sweepLine = new LineSegment(mouseX, 0, mouseX, 400);
  stroke(RED);
  line(mouseX, 0, mouseX, 400);
  
  // draw line segments
  for (int i = 0; i < _lines.size(); i++) {
    LineSegment l = _lines.get(i);
    
    float[] start = l.start();
    float[] end = l.end();
    
    float[] p = l.findIntersect(sweepLine);
    if (l.includes(p[0], p[1])) {
      stroke(FG_COLOR);
      ellipse(p[0], p[1], 2, 2);
    }
    else
      stroke(BLUE);
    
    line(start[0], start[1], end[0], end[1]); // line segment
  }
  
  pulseColor();
  if (_point[0] != -1)
    ellipse(_point[0], _point[1], 4, 4); // first point in new line segment
    
  // text
  if (_debug) {
    scale(1, -1);
    translate(0, -height);
    text("FPS: " + frameRate, 0, 12); // show fps
    text("X: " + mouseX, 0, 24);
    text("Y: " + (400 - mouseY), 0, 36);
  }
}

void handleEvent(float[] event) {
  
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    if (_point[0] == -1) { // waiting for first point
      // store first point
      _point[0] = mouseX;
      _point[1] = 400 - mouseY;
    }
    else {
      // create a new line from start and end points
      LineSegment l = new LineSegment(_point[0], _point[1], mouseX, 400 - mouseY);
      
      _lines.insert(l);
      _point[0] = -1; // waiting for new start point
    }
  }
  if (mouseButton == RIGHT) { // run algorithm
    _lines.remove(_lines.get(0));
//    while (!_lines.empty()) {
//      float[] nextEvent = _lines.remove();
//      handleEvent(nextEvent);
//    }
  }
  println("Size: " + _lines.size());
}

void pulseColor() { // increase and decrease color value
  int change = abs(_colorChange); // magnitude of change
  int maxColor = min(255, FG_COLOR + 50);
  int minColor = max(0, FG_COLOR - 50);
  if (_color >= maxColor - change || _color <= minColor - change)
    _colorChange = -_colorChange; // reverse
  _color += _colorChange; // change color
  stroke(_color);
}
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

// LineSegment class

class LineSegment {
  float[] _start = new float[2]; // coordinate of start location
  float[] _end = new float[2]; // coordinate of end location
  boolean _marked = false;
  
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
  
  float[] findIntersect(LineSegment ls) {
    float x = ls._start[0];
    float m = slope();
    float b = _start[1] - (m * _start[0]);
    float y = (m * x) + b;
    if (m != 0) // horizontal line
      x = (y - b) / m;
    float[] point = {x, y};
    return point;
  }
  
  boolean includes(float x, float y) {
    if ((x >= _start[0] && x <= _end[0] && y >= _start[1] && y <= _end[1])
        || (x >= _start[0] && x <= _end[0] && y >= _end[1] && y <= _start[1]))
      return true;
    return false;
  }
  
  void mark() {
    _marked = true;
  }
  
  boolean isMarked() {
    return _marked;
  }
}
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


