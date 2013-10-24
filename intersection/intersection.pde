ArrayList<Line> _lines; // holds set of lines
float[] _point = new float[2];
int _color = 200; // line or point color
int _colorChange = 2; // amount to change for pulse

void setup() {
  size(400, 400);
  
  noFill();
  stroke(200);
  
  _lines = new ArrayList(); // initialize
  
  // test lines
//  Line l1 = new Line(100, 100, 300, 300);
//  Line l2 = new Line(300, 150, 50, 150);
//  _lines.add(l1);
//  _lines.add(l2);
  
  _point[0] = -1; // waiting for input for first point
}

void draw() {
  // flip y axis
  scale(1, -1);
  translate(0, -height);
  
  background(100);
  stroke(200);
  
  // draw lines in _lines ArrayList
  for (int i = 0; i < _lines.size(); i++) {
    Line line = _lines.get(i);
    float[] start = line.start();
    float[] end = line.end();
    
    line(start[0], start[1], end[0], end[1]); // line segment
  }
  
  pulseColor();
  if (_point[0] != -1)
    ellipse(_point[0], _point[1], 4, 4); // first point in new line segment
    
  // text
  scale(1, -1);
  translate(0, -height);
  text("FPS: " + frameRate, 0, 12); // show fps
  text("X: " + mouseX, 0, 24);
  text("Y: " + (400 - mouseY), 0, 36);
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
      Line line = new Line(_point[0], _point[1], mouseX, 400 - mouseY);
      _lines.add(line);
      _point[0] = -1; // waiting for new start point
    }
  }
}

void pulseColor() { // increase and decrease color value
  int change = abs(_colorChange); // magnitude of change
  if (_color >= 255 - change || _color <= 145 - change)
    _colorChange = -_colorChange; // reverse
  _color += _colorChange; // change color
  stroke(_color);
}

class Line {
  float[] _start = new float[2]; // coordinate of start location
  float[] _end = new float[2]; // coordinate of end location
  
  Line(float x1, float y1, float x2, float y2) {
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
    println("Slope: " + slope);
    return slope;
  }
}
