final int FG_COLOR = 85;
final color RED = color(217,107,114);
final color BLUE = color(148,164,181);

boolean _debug = true;
ArrayList<LineSegment> _lines; // holds set of lines
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
  
  _lines = new ArrayList(); // initialize
  
  // test lines
  LineSegment l1 = new LineSegment(10, 100, 300, 300);
//  LineSegment l2 = new LineSegment(300, 150, 50, 150);
  _lines.add(l1);
//  _lines.add(l2);
  
  _point[0] = -1; // waiting for input for first point
}

void draw() {
  // flip y axis
  scale(1, -1);
  translate(0, -height);
  
  background(214, 209, 203);
  stroke(FG_COLOR);
  
  // draw lines in _lines ArrayList
  for (int i = 0; i < _lines.size(); i++) {
    LineSegment l = _lines.get(i);
    float[] start = l.start();
    float[] end = l.end();
    
    line(start[0], start[1], end[0], end[1]); // line segment
    
    float[] p = l.findIntersect(mouseX);
    if (l.includes(p[0], p[1]))
      ellipse(p[0], p[1], 4, 4);
  }
  
  // vertical sweep line
  stroke(RED);
  line(mouseX, 0, mouseX, 400);
  
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
      _lines.add(l);
      _point[0] = -1; // waiting for new start point
    }
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
