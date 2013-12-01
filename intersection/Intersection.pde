final int FG_COLOR = 85;
final color RED = color(217, 107, 114);
final color BLUE = color(148, 164, 181);

boolean _debug = true;
BSTree _lineSegs; // holds events and line segements
BSTree _status; // lines currently intersecting sweep line
PriorityQueue _events; // current and future stopping points
LineSegment _sweep;
float[] _point = new float[2];
int _color = FG_COLOR; // line or point color
int _colorChange = 2; // amount to change each tick for pulse

void setup() {
  size(400, 400);
  background(214, 209, 203);

  fill(FG_COLOR);
  noFill();
  stroke(FG_COLOR);

  _lineSegs = new BSTree(false); // initialize
  _status = new BSTree(true);
  _events = new PriorityQueue();
  _point[0] = -1; // waiting for input for first point
  _sweep = new LineSegment(0, 0, 0, 400);
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

void step() {
  Point e = _events.remove();
  _sweep._start[0] = _sweep._end[0] = e.getPoint()[0];
  LineSegment ls = e.getLine();
  LineSegment[] neighbors = _status.findNeighbors(ls);
  LineSegment above = neighbors[0];
  LineSegment below = neighbors[1];
  if (e.type() == START) {
    _status.insert(ls);
    if (above != null && below != null) {
      float[] pt = above.findIntersect(below);
      if (above.includes(pt[0], pt[1]) && below.includes(pt[0], pt[1]))
        _events.remove(pt);
      pt = ls.findIntersect(above);
      if (ls.includes(pt[0], pt[1]) && above.includes(pt[0], pt[1]))
        _events.insert(new Point(pt[0], pt[1], INTERSECTION, null));
      pt = ls.findIntersect(below);
      if (ls.includes(pt[0], pt[1]) && below.includes(pt[0], pt[1]))
        _events.insert(new Point(pt[0], pt[1], INTERSECTION, null));
    }
  }
  if (e.type() == END) {
    _status.remove(ls);
    if (above != null && below != null) {
      float[] pt = above.findIntersect(below);
      if (above.includes(pt[0], pt[1]) && below.includes(pt[0], pt[1]))
        _events.remove(pt);
    }
  }
  if (e.type() == INTERSECTION) {
    
  }
}

void go() { // run algorithm
  while (!_events.empty()) {
    step();
  }
  _point[0] = -1;
  _point[1] = -1;
//  _lineSegs.remove(_lineSegs.get(0));
//  for (int i = 0; i < _lineSegs.size(); i++) {
//    LineSegment ls = _lineSegs.get(i);
//    _status.insert(ls);
//    handleEvent(nextEvent);
//  }
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
      _lineSegs.insert(l);
      _point[0] = -1; // waiting for new start point
    }
  }
  if (mouseButton == RIGHT) {
    // add endpoints to queue
    for (int i = 0; i < _lineSegs.size(); i++) {
      LineSegment l = _lineSegs.get(i);
      Point startpt = new Point(l.start()[0], l.start()[1], START, l);
      Point endpt = new Point(l.end()[0], l.end()[1], END, l);
      _events.insert(startpt);
      _events.insert(endpt);
    }
//    go();
    step();
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
