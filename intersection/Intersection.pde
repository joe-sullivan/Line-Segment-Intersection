final int FG_COLOR = 85;
final color RED = color(217,107,114);
final color BLUE = color(148,164,181);

boolean _debug = true;
BSTree _lineSegs; // holds events and line segements
BSTree _status;
PriorityQueue _events;
float[] _point = new float[2];
int _color = FG_COLOR; // line or point color
int _colorChange = 2; // amount to change each tick for pulse

void setup() {
  size(400, 400);
  background(214, 209, 203);
  
  fill(FG_COLOR);
  noFill();
  stroke(FG_COLOR);
  
  _lineSegs = new BSTree(); // initialize
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
  for (int i = 0; i < _lineSegs.size(); i++) {
    LineSegment l = _lineSegs.get(i);
    
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
      _lineSegs.insert(l);
      _point[0] = -1; // waiting for new start point
    }
  }
  if (mouseButton == RIGHT) { // run algorithm
    _point[0] = -1;
    _point[1] = -1;
    _lineSegs.remove(_lineSegs.get(0));
//    while (!_lineSegs.empty()) {
//      float[] nextEvent = _lineSegs.remove();
//      handleEvent(nextEvent);
//    }
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
