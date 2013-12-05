final int FG_COLOR = 85;
final color RED = color(217, 107, 114);
final color BLUE = color(148, 164, 181);
final color ORANGE = color(236, 180, 76);
final color GREEN = color(208, 230, 217);

boolean _debug = true;
boolean _running = false;
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

void step() {
  // add endpoints to queue
  if (!_running) {
    _running = true;
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
    neighbors = findNeighbors(cl[0], cl[1], e.getPoint());
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
}

LineSegment[] findNeighbors(Point point) {
  float[] pt = point.getPoint();
  ArrayList<LineSegment> ls = _status.getLines();
  LineSegment[] neighbors = new LineSegment[2]; // {above, below}
  float minAbove = -1000; // arbitrary small number
  float minBelow = 1000; // arbitrary large number
  for (int i = 0; i < ls.size(); i++) {
    // find vertical distance from l.start() to ls.get(i)
    LineSegment n = ls.get(i);
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

LineSegment[] findNeighbors(LineSegment a, LineSegment b, float[] pt) {
  ArrayList<LineSegment> ls = _status.getLines();
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

void go() { // run algorithm
  // add endpoints to queue
  if (!_running) {
    _running = true;
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
  _intersectionPts.clear(); // reset
  _point[0] = -1;
  _point[1] = -1;
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
      println("NUM OF LINES: " + _lineSegs.size());
      _point[0] = -1; // waiting for new start point
    }
  }
//  if (mouseButton == RIGHT) {
//    println("START ALG");
//    // add endpoints to queue
//    if (!_running) {
//      for (int i = 0; i < _lineSegs.size(); i++) {
//        LineSegment l = _lineSegs.get(i);
//        Point startpt = new Point(l.start()[0], l.start()[1], START, l);
//        Point endpt = new Point(l.end()[0], l.end()[1], END, l);
//        _events.insert(startpt);
//        _events.insert(endpt);
//      }
//      _running = true;
//    }
//    if (!_events.empty())
//      go();
////      step();
//    else {
//      _running = false;
//      _point[0] = -1;
//      _point[1] = -1;
//    }
//  }
  if (_debug) {
    println("Size: " + _lineSegs.size());
  }
}

void keyPressed() {
  // add endpoints to queue
  if (!_running) {
    for (int i = 0; i < _lineSegs.size(); i++) {
      LineSegment l = _lineSegs.get(i);
      Point startpt = new Point(l.start()[0], l.start()[1], START, l);
      Point endpt = new Point(l.end()[0], l.end()[1], END, l);
      _events.insert(startpt);
      _events.insert(endpt);
    }
    _running = true;
  }
    if (!_events.empty())
      step();
//      go();
    else {
      _running = false;
      _point[0] = -1;
      _point[1] = -1;
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
