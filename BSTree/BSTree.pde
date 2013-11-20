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
