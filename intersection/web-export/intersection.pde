final int FG_COLOR = 85;
final color RED = color(217, 107, 114);
final color BLUE = color(148, 164, 181);
final color ORANGE = color(236, 180, 76);
final color GREEN = color(208, 230, 217);

boolean _debug = false;
boolean _running;
BSTree _lineSegs; // holds events and line segements
BSTree _status; // lines currently intersecting sweep line
PriorityQueueTmp _events; // current and future stopping points
LineSegment _sweep;
LineSegment _above;
LineSegment _below;
float[] _point = new float[2];
int _color = FG_COLOR; // line or point color
int _colorChange = 2; // amount to change each tick for pulse
ArrayList<float[]> _intersectionPts;

void setup() {
  size(400, 400);
  background(214, 209, 203);

  fill(FG_COLOR);
  noFill();
  stroke(FG_COLOR);

  _lineSegs = new BSTree(false); // initialize
  _status = new BSTree(true);
  _events = new PriorityQueueTmp();
  _point[0] = -1; // waiting for input for first point
  _sweep = new LineSegment(0, 0, 0, 400);
  _intersectionPts = new ArrayList();
  _running = false;
}

void draw() {
  // flip y axis
  scale(1, -1);
  translate(0, -height);

  background(214, 209, 203);
  stroke(FG_COLOR);

  // vertical sweep line
//  _sweep = new LineSegment(mouseX, 0, mouseX, 400);
  stroke(RED);
  float[] s = _sweep.start();
  float[] e = _sweep.end();
  line(s[0], s[1], e[0], e[1]);

  // draw line segments
  for (int i = 0; i < _lineSegs.size(); i++) { // draw all lines (blue)
    LineSegment l = _lineSegs.get(i);

    float[] start = l.start();
    float[] end = l.end();

    float[] p = l.findIntersect(_sweep);
    if (l.includes(p[0], p[1])) {
      stroke(FG_COLOR);
      ellipse(p[0], p[1], 2, 2); // intersect sweep line
    }
    stroke(BLUE);
    line(start[0], start[1], end[0], end[1]); // line segment
  }
  for (int i = 0; i < _status.size(); i++) { // draw lines in status (black)
    LineSegment l = _status.get(i);

    float[] start = l.start();
    float[] end = l.end();
    
    stroke(FG_COLOR);
    if (l.equals(_above) || l.equals(_below))
      stroke(ORANGE);
    line(start[0], start[1], end[0], end[1]); // line segment
  }
  
  stroke(RED);
  for (float[] f : _intersectionPts) {
    ellipse(f[0], f[1], 2, 2);
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

void toggleDebug() {
  _debug = !_debug;
}

String go() { // run algorithm
  // add endpoints to queue
  if (!_running) {
    _running = true;
    _intersectionPts.clear(); // reset
    for (int i = 0; i < _lineSegs.size(); i++) {
      LineSegment l = _lineSegs.get(i);
      Point startpt = new Point(l.start()[0], l.start()[1], START, l);
      Point endpt = new Point(l.end()[0], l.end()[1], END, l);
      _events.insert(startpt);
      _events.insert(endpt);
    }
    _running = true;
  }
  
  while (!_events.empty()) {
    step();
  }
  _running = false;
  _point[0] = -1;
  _point[1] = -1;
  
  String output = "";
  for (int i = 0; i < _intersectionPts.size(); i++) {
    float[] f = _intersectionPts.get(i);
    output += "(" + (int)f[0] + "," + (int)f[1] + ")";
    if (i < _intersectionPts.size() - 1)
      output += ", ";
  }
  if (_debug)
    println(output);
  return output;
}

String step() {
  // add endpoints to queue
  if (!_running) {
    _running = true;
    _intersectionPts.clear(); // reset
    for (int i = 0; i < _lineSegs.size(); i++) {
      LineSegment l = _lineSegs.get(i);
      Point startpt = new Point(l.start()[0], l.start()[1], START, l);
      Point endpt = new Point(l.end()[0], l.end()[1], END, l);
      _events.insert(startpt);
      _events.insert(endpt);
    }
    _running = true;
  }
  
  Point e = _events.remove();
  _point = e.getPoint(); // used to show point being handled
  _sweep._start[0] = _sweep._end[0] = e.getPoint()[0];
  LineSegment ls = e.getLine();
  LineSegment[] neighbors;
  LineSegment[] cl = e.crossingLines();
  if (e.type() == INTERSECTION)
    neighbors = findNeighborsCross(cl[0], cl[1], e.getPoint());
  else
    neighbors = findNeighbors(e);
  _above = neighbors[0];
  _below = neighbors[1];
  float[] pt; // event to add or remove
  if (e.type() == START) {
    _status.insert(ls);
    if (_above != null && _below != null) {
      pt = _above.findIntersect(_below);
      if (_above.includes(pt[0], pt[1]) && _below.includes(pt[0], pt[1]))
        _events.remove(pt);
    }
    if (_above != null) {
      pt = ls.findIntersect(_above);
      if (ls.includes(pt[0], pt[1]) && _above.includes(pt[0], pt[1]))
        _events.insert(new Point(pt[0], pt[1], INTERSECTION, _above, ls));
    }
    if (_below != null) {
      pt = ls.findIntersect(_below);
      if (ls.includes(pt[0], pt[1]) && _below.includes(pt[0], pt[1]))
        _events.insert(new Point(pt[0], pt[1], INTERSECTION, ls, _below));
    }
  }
  if (e.type() == END) {
    _status.remove(ls);
    if (_above != null && _below != null) {
      pt = _above.findIntersect(_below);
      if (_above.includes(pt[0], pt[1]) && _below.includes(pt[0], pt[1]))
        _events.remove(pt);
    }
  }
  if (e.type() == INTERSECTION) {
    _intersectionPts.add(e.getPoint());
    _status.swap(cl[0], cl[1]);
    if (_above != null) {
      pt = _above.findIntersect(cl[0]);
      if (cl[0].includes(pt[0], pt[1]) && _above.includes(pt[0], pt[1]) && pt[0] > _sweep.start()[0])
        _events.remove(pt);
      pt = _above.findIntersect(cl[1]);
      if (cl[1].includes(pt[0], pt[1]) && _above.includes(pt[0], pt[1]) && pt[0] > _sweep.start()[0])
        _events.insert(new Point(pt[0], pt[1], INTERSECTION, _above, cl[1]));
    }
    if (_below != null) {
      pt = _below.findIntersect(cl[1]);
      if (cl[1].includes(pt[0], pt[1]) && _below.includes(pt[0], pt[1]) && pt[0] > _sweep.start()[0])
        _events.remove(pt);
      pt = _below.findIntersect(cl[0]);
      if (cl[0].includes(pt[0], pt[1]) && _below.includes(pt[0], pt[1]) && pt[0] > _sweep.start()[0])
        _events.insert(new Point(pt[0], pt[1], INTERSECTION, cl[0], _below));
    }
  }
  
  String output = "";
  for (int i = 0; i < _intersectionPts.size(); i++) {
    float[] f = _intersectionPts.get(i);
    output += "(" + (int)f[0] + "," + (int)f[1] + ")";
    if (i < _intersectionPts.size() - 1)
      output += ", ";
  }
  if (_debug)
    println(output);
  return output;
}

LineSegment[] findNeighbors(Point point) {
  float[] pt = point.getPoint();
  ArrayList<LineSegment> l = _status.getLines();
  LineSegment[] neighbors = new LineSegment[2]; // {above, below}
  float minAbove = -1000; // arbitrary small number
  float minBelow = 1000; // arbitrary large number
  for (int i = 0; i < l.size(); i++) {
    // find vertical distance from l.start() to ls.get(i)
    LineSegment n = l.get(i);
    LineSegment vert = new LineSegment(pt[0], 0, pt[0], 400);
    float[] p = n.findIntersect(vert);
    float dist = pt[1] - p[1];
    if (dist < 0) { // above
      if (dist > minAbove) { // closer to line
        minAbove = dist;
        neighbors[0] = n;
      }
    }
    if (dist > 0) { // below
      if (dist < minBelow) {
        minBelow = dist;
        neighbors[1] = n;
      }
    }
  }
  return neighbors;
}

LineSegment[] findNeighborsCross(LineSegment a, LineSegment b, float[] pt) {
  ArrayList<LineSegment> ls = _status.getLines(); //<>//
  LineSegment[] neighbors = new LineSegment[2]; // {above, below}
  float minAbove = -1000; // arbitrary small number
  float minBelow = 1000; // arbitrary large number
  for (int i = 0; i < ls.size(); i++) {
    // find vertical distance from l.start() to ls.get(i)
    LineSegment n = ls.get(i);
    LineSegment vert = new LineSegment(pt[0], 0, pt[0], 400);
    float[] p = n.findIntersect(vert);
    float dist = pt[1] - p[1];
    if (dist < 0 && !n.equals(a) && !n.equals(b)) { // above
      if (dist > minAbove) { // closer to line
        minAbove = dist;
        neighbors[0] = n;
      }
    }
    if (dist > 0 && !n.equals(a) && !n.equals(b)) { // below
      if (dist < minBelow) {
        minBelow = dist;
        neighbors[1] = n;
      }
    }
  }
  return neighbors;
}

void mouseClicked() {
  if (mouseButton == LEFT && !_running) {
    if (_point[0] == -1) { // waiting for first point
      // store first point
      _point[0] = mouseX;
      _point[1] = 400 - mouseY;
    }
    else {
      // create a new line from start and end points
      LineSegment l = new LineSegment(_point[0], _point[1], mouseX, 400 - mouseY);
      _lineSegs.insert(l);
      _point[0] = -1; // waiting for new start point
    }
  }
  if (_debug) {
    println("Size: " + _lineSegs.size());
  }
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
  
//  LineSegment[] findNeighbors(LineSegment l) {
//    LineSegment[] ls = new LineSegment[2];
//    if (!empty()) {
//      ls[0] = visitNeighbors(l, ls, _root, true);
//      ls[1] = visitNeighbors(l, ls, _root, false);
//    }
//    return ls;
//  }
//  
//  private LineSegment visitNeighbors(LineSegment l, LineSegment[] ls, Node n, boolean left) {
//    if (l.equals(n.ls)) {
//      if (left) {
//        if (n.hasLeft())
//          return n.left.ls;
//        if (!n.isRoot()) {
//          if (n == n.parent.right)
//            return n.parent.ls;
//        }
//      }
//      else { // right
//        if (n.hasRight())
//          return n.right.ls;
//        if (!n.isRoot()) {
//          if (n == n.parent.left)
//            return n.parent.ls;
//        }
//      }
//    }
//    else {
//      if (n.hasLeft()) // left child
//        visitNeighbors(l, ls, n.left, left);
//      if (n.hasRight()) // right child
//        visitNeighbors(l, ls, n.right, left);
//    }
//    return null;
//  }

  void swap(LineSegment a, LineSegment b) {
    if (size() > 1) {
      Node n1 = findNode(a, _root);
      Node n2 = findNode(b, _root);
      if (n1 != null && n2 != null) {
        LineSegment tmp = n1.ls;
        n1.ls = n2.ls;
        n2.ls = tmp;
      }
    }
  }

  private Node findNode(LineSegment l, Node n) {
    if (l.equals(n.ls))
      return n;
    else {
      if (n.hasLeft()) // left child
        findNode(l, n.left);
      if (n.hasRight()) // right child
        findNode(l, n.right);
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
  
  float[] findVerticalIntersect(LineSegment ls) {
    float x = ls._start[0];
    float m = slope();
    float b = _start[1] - (m * _start[0]);
    float y = (m * x) + b;
    if (m != 0) // horizontal line
      x = (y - b) / m;
    float[] point = {x, y};
    return point;
  }

//  float[] findIntersect(LineSegment ls) {
//    float a1 = (ls._start[1] - _start[1]) / (ls._start[0] - _start[0]);
//    float b1 = _start[1] - a1 * _start[0];
//    float a2 = (ls._end[1] - _end[1]) / (ls._end[0] - _end[0]);
//    float b2 = _end[1] - a2 * _end[0];
//    float x = -(b1-b2)/(a1-a2);
//    float y = slope() * x + b1;
//    float[] point = {x, y};
//    return point;
//  }

//  float[] findIntersect(LineSegment ls) {
//    if ((_start[0] - _end[0]) == 0)
//      return findVerticalIntersect(this);
//    float m1 = slope();
//    float m2 = ls.slope();
//    float b1 = yIntercept();
//    float b2 = ls.yIntercept();
//    float x = _start[0];
//    if ((m2 - m1) != 0)
//      x = (b1 - b2) / (m2 - m1);
//    float y = (m1 * x) + b1;
//    float[] point = {x, y};
//    return point;
//  }

  float[] findIntersect(LineSegment ls) {
    float x1 = _start[0];
    float x2 = _end[0];
    float x3 = ls._start[0];
    float x4 = ls._end[0];
    float y1 = _start[1];
    float y2 = _end[1];
    float y3 = ls._start[1];
    float y4 = ls._end[1];
    float x = ((x1*y2 - y1*x2)*(x3-x4) - (x1-x2)*(x3*y4 - y3*x4)) / ((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4));
    float y = ((x1*y2 - y1*x2)*(y3-y4) - (y1-y2)*(x3*y4 - y3*x4)) / ((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4));
    float[] point = {x, y};
    return point;
  }
  
  private float yIntercept() {
    return _start[1] - (slope() * _start[0]);
  }
  
  boolean includes(float x, float y) {
    if ((x >= _start[0] && x <= _end[0] && y >= _start[1] && y <= _end[1])
        || (x >= _start[0] && x <= _end[0] && y >= _end[1] && y <= _start[1]))
      return true;
    return false;
  }
  
  boolean equals(LineSegment ls) {
    if (ls == null)
      return false;
    return !(_start[0] != ls.start()[0] ||
        _start[1] != ls.start()[1] ||
        _end[0] != ls.end()[0] ||
        _end[1] != ls.end()[1]);
  }
  
  void mark() {
    _marked = true;
  }
  
  boolean isMarked() {
    return _marked;
  }
}
// Point class

final int START = -1;
final int END = 1;
final int INTERSECTION = 0;

class Point {
  private float[] _pnt = new float[2]; // coordinate of point
  private int _type;
  private LineSegment _lineSegment;
  private LineSegment _lineSegment2;
  
  Point(float x, float y, int type, LineSegment l) {
    _pnt[0] = x;
    _pnt[1] = y;
    _type = type;
    _lineSegment = l;
  }
  
  Point(float x, float y, int type, LineSegment l1, LineSegment l2) {
    _pnt[0] = x;
    _pnt[1] = y;
    _type = type;
    _lineSegment = l1; // above
    _lineSegment2 = l2; // below
  }
  
  float[] getPoint() {
    return _pnt;
  }
  
  int type() {
    return _type;
  }
  
  LineSegment getLine() {
    return _lineSegment;
  }
  
  LineSegment[] crossingLines() {
    LineSegment[] ls = {_lineSegment, _lineSegment2};
    return ls;
  }
}
// priority queue for storing events
// does not work properly yet

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

