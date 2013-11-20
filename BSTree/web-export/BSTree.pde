final int L = -1;
final int R = 1;

public class BSTree {
  private int _size;
  private Node _root;
  private ArrayList<LineSegment> _lines;
  private boolean _newLine;

  public BSTree() {
    _size = 0;
    _lines = new ArrayList();
  }

  boolean insert(LineSegment ls) {
    _newLine = insert(ls, _root);
    return _newLine;
  }

  private boolean insert(LineSegment ls, Node parent) {
    if (isEmpty()) {
      println("Inserting root");
      _root = new Node(ls);
      _size++; 
    }
    else {
      int comp = parent.compareH(ls);
      if (comp == R) {                         // parent should be right of new event
        if (parent.hasLeftChild()) // recurse
          insert(ls, parent.getLeftChild());
        else { // leaf
          println("Insert Left Child");
          _size++;
          Node newNode = new Node(ls);
          newNode.setParent(parent);
          parent.setLeftChild(newNode);
        }
      }
      if (comp == L) {                       // parent should be left of new event
        if (parent.hasRightChild())           // recurse
          insert(ls, parent.getRightChild());
        else { // leaf
          println("Insert Right Child");
          _size++;
          Node newNode = new Node(ls);
          newNode.setParent(parent);
          parent.setRightChild(newNode);
        }
      }
      if (comp == 0) { // event already exists in tree
        return false;
      }
    }
    return true;
  }

  public Node findNode (LineSegment ls, Node node){
    int comp = node.compareH(ls);
    if(comp == 0){
        return node;
    }
    else if(comp == R){                     //ls is less than node.getLS()             
      if(node.hasLeftChild()){
        return findNode(ls, node.getLeftChild());
      }
      else{
        return null;
      }
    }
    else{                                  //ls is greater than node.getLS();
      if(node.hasRightChild()){
        return findNode(ls, node.getRightChild());
      }
      else{
        return null;
      }
    }
  }
  
   public boolean remove(LineSegment ls) {
    if (!isEmpty()){
      _newLine = remove(ls, _root);
    }
    else{
      _newLine = false;
    }
    return _newLine;
  }

  public boolean remove(LineSegment ls, Node node) {
    if(findNode(ls, node) != null){              //this ls is in tree
      println( "Execute Removal" );
      Node toRemove = findNode(ls, node);    
      if (toRemove == node){              //then toRemove is root
        if(toRemove.hasChild()){                        //if toRemove is root has child(ren)
          if(toRemove.hasLeftChild()){                    //if toRemove has left child
            //println("Removing Root with Left Child");
            Node leftChild = toRemove.getLeftChild();      
            leftChild.setParent(null);
            //println("Replacing root");
            _root = leftChild;
            if(toRemove.hasRightChild()){                    //if toRemove has left and right child
              //println("Removing Root with Two Child");
              Node rightChild = toRemove.getRightChild();
              Node leaf = findRightExternal(leftChild);
              leaf.setRightChild(rightChild);
              rightChild.setParent(leaf);
            }
          }  
          else{                         //if toRemove has right child (only)
            //println("Removing Root with Right Child");
            Node rightChild = toRemove.getRightChild();
            rightChild.setParent(null);
            //println("Replacing root");
            _root = rightChild;
          }
        }
        else{                                        //if toRemove has no child
          //println("Removing Root with no child");
          _root = null;
        }
      }
      else{                                          //if toRemove is not the root
        Node parent = toRemove.getParent();
        //println("Removing Interior Nodes");
        int comp = toRemove.compareH(parent.getLS());
        if(toRemove.hasChild()){                      //if toRemove has child(ren)
          if(toRemove.hasLeftChild()){                 //if toRemove has left child
            //println("Removing IN with Left Child");
            Node leftChild = toRemove.getLeftChild();
            if(comp == L){   //toRemove is a left node of parent
              //println("ToRemove is a left Child");
              leftChild.setParent(parent);
              parent.setLeftChild(leftChild);
            }
            else{                                        //toRemove is a right node of parent
              //println("ToRemove is a right Child");
              leftChild.setParent(parent);
              parent.setRightChild(leftChild);
            }
            if(toRemove.hasRightChild()){              //if toRemove has left and right child
              //println("Removing IN with Two Child");
              Node rightChild = toRemove.getRightChild();
              Node leaf = findRightExternal(leftChild);
              leaf.setRightChild(rightChild);
              rightChild.setParent(leaf);
            }
          }
          else{                                         //if toRemove has right child (only)
            //println("Removing IN with Right Child");
            Node rightChild = toRemove.getRightChild();
            if(comp == L){   //toRemove is a left node of parent
              //println("ToRemove is a left Child");
              rightChild.setParent(parent);
              parent.setLeftChild(rightChild);
            }
            else{                                        //toRemove is a right node of parent
              //println("ToRemove is a right Child");
              rightChild.setParent(parent);
              parent.setRightChild(rightChild);
            }
          }
        }
        else{                                          //if toRemove has no children
          if(comp == L){
            //println("ToRemove is a left Child with no Child");
            parent.setLeftChild(null);
          }
          else{
            //println("ToRemove is a right Child with no Child");
            parent.setRightChild(null);
          }
        }      
      }
      _size--;
      return true;
    }
    else{
      //println( "Can't find node in tree" );
      return false;
    }
  }

  public Node findLeftExternal (Node node){
    if(node.getLeftChild() != null){
      return findLeftExternal(node.getLeftChild());
    }
    else{
      return node;
    }
  }
  
  public Node findRightExternal (Node node){
    if(node.getRightChild() != null){
      return findRightExternal(node.getLeftChild());
    }
    else{
      return node;
    }
  }

  public int size() {
    return _size;
  }

  public boolean isEmpty() {
    return (_size == 0);
  }
  
  public LineSegment get(int i){
    if(_newLine){
      getLines();
    }
    return _lines.get(i);
  }
  
  public ArrayList<LineSegment> getLines() { // return ArrayList of lines (used for drawing)
    if (_newLine) {
      _lines.clear();
      if (!isEmpty())
        visitNodes(_root);
    }
   /* for(int i=0; i<_lines.size(); i++){
      print(_lines.get(i)._start+", " );
    }
    println("");*/
    return _lines;
  }
  
  private void visitNodes(Node n) {
    if (n.hasLeftChild()){ // left child
      visitNodes(n.getLeftChild());
    }
    // between left and right to keep ordered  
    _lines.add(n.ls);
    
    if (n.hasRightChild()){ // right child
      visitNodes(n.getRightChild());
    }
    //println("Visit Node: "+_size);
  }
}
  
 private class Node {
  LineSegment ls;
  Node parent;
  Node left;
  Node right;

  private Node(LineSegment lineSegment) {
    ls = lineSegment;
    parent = null;
  }
  
  private LineSegment getLS(){
    return ls;
  }

  private Node getParent(){
    return parent; 
  }

  private Node getLeftChild(){
    return left; 
  }

  private Node getRightChild(){
    return right; 
  }

  private void setParent(Node n) {
    parent = n;
  }

  private void setLeftChild(Node n) {
    left = n;
  }

  private void setRightChild(Node n) {
    right = n;
  }

  private boolean isRoot() {
    return (parent == null);
  }

  private boolean hasChild() {
    return (left != null || right != null);
  }

  private boolean hasLeftChild() {
    return (left != null);
  }

  private boolean hasRightChild() {
    return (right != null);
  }
  
  private int compareH(LineSegment ls2) { // left to right
    float x = ls._start[0];
    float y = ls._start[1];
    float[] ls2Event = ls2._start; // parent node event
    if (x < ls2Event[0] || (x == ls2Event[0] && y < ls2Event[1])){
      //println("TO THE LEFT");
      return L;
    }
    if (x > ls2Event[0] || (x == ls2Event[0] && y > ls2Event[1])){
      //println("TO THE RIGHT");
      return R;
    }
    //println("IT GETS HERE");
    return 0;
  }

  private int compareV(LineSegment ls2) { // top to bottom
    float x = ls._start[0];
    float y = ls._start[1];

    float[] ls2Event = ls2._start; // parent node event
    if (y < ls2Event[1] || (y == ls2Event[1] && x < ls2Event[0]))
      return R;
    if (y > ls2Event[1] || (y == ls2Event[1] && x > ls2Event[0]))
      return L;
    return 0;
  }
}
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
  //_status = new BSTree();
  //_events = new PriorityQueue();
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


