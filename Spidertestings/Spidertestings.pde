import processing.serial.*;

Serial  myPort;
int     lf = 10;       //ASCII linefeed
String  inString;      //String for testing serial communication
StringList commands;
boolean done=true;


void setup() {
  size(410, 460);
  printArray(Serial.list());
  pixelDensity(2);
  try {
    myPort = new Serial(this, Serial.list()[5], 115200);
    myPort.clear();
    myPort.bufferUntil(lf);
  }
  catch(Exception e) {
    println("Cannot open serial port.");
  }
  commands = new StringList();
}

void draw() {
  if (done)sendFeed();
  drawBezier(width/2, height, width/2, height-200, width-200, height-200, width, height-200);
}


void drawBezier(int ax1, int ay1, int sx1, int sy1, int sx2, int sy2, int ax2, int ay2) {
  pushStyle();
  bezier(ax1, ay1, sx1, sy1, sx2, sy2, ax2, ay2);
  fill(0, 255, 0);
  noStroke();
  ellipse(sx1, sy1, 5, 5);
  ellipse(sx2, sy2, 5, 5);
  
  stroke(0, 255, 0);
  line(ax1, ay1, sx1, sy1);
  line(ax2, ay2, sx2, sy2);
  drawSegmentBezier(ax1, ay1, sx1, sy1, sx2, sy2, ax2, ay2, 10, 5);
  // segmentBezier(ax1, ay1, sx1, sy1, sx2, sy2, ax2, ay2,10);
  popStyle();
}

void drawSegmentBezier(int ax1, int ay1, int sx1, int sy1, int sx2, int sy2, int ax2, int ay2, int steps, int size) {
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    float x = bezierPoint(ax1, sx1, sx2, ax2, t);
    float y = bezierPoint( ay1, sy1, sy2, ay2, t);
    float xPos =width/2-x;
    float yPos =height-y;
    pushStyle();
    fill(255, 0, 0);
    noStroke();
    ellipse(x, y, 5, 5);
    popStyle();
  }
}

void segmentBezier(int ax1, int ay1, int sx1, int sy1, int sx2, int sy2, int ax2, int ay2, int steps) {
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    float x = bezierPoint(ax1, sx1, sx2, ax2, t);
    float y = bezierPoint( ay1, sy1, sy2, ay2, t);
    float xPos =width/2-x;
    float yPos =height-y;
    String cmd = "G1 X"+xPos+" Y"+yPos;
    commands.append(cmd);
  }
}


/*
void drawsegmentBezier(int _s) {
 int steps = _s;
 for (int i = 0; i <= steps; i++) {
 float t = i / float(steps);
 float x = bezierPoint(width/2, width/2-100, width/2, width-100, t);
 float y = bezierPoint(height, height/2+50, height/2, height/2+150, t);
 fill(255, 0, 0);
 ellipse(x, y, 5, 5);
 }
 }
 
 void segmentBezier(int _s) {
 int steps = _s;
 for (int i = 0; i <= steps; i++) {
 float t = i / float(steps);
 float x = bezierPoint(width/2-5, width/2-100, width/2, width-100, t);
 float y = bezierPoint( height-5, height/2+50, height/2, height/2+150, t);
 float xPos =width/2-x;
 float yPos =height-y;
 String cmd = "G1 X"+xPos+" Y"+yPos;
 commands.append(cmd);
 }
 }
 */




void mousePressed() {
  int xPos =width/2-mouseX;
  int yPos =height-mouseY;
  moveTo(xPos, yPos);
}


void keyPressed() {
  if (key == 'h') {
    goHome();
  }

  if (key=='p') {
    int xPos =width/2-mouseX;
    int yPos =height-mouseY;
    drawTo(xPos, yPos);
  }

  if (key=='s') {
    //segmentBezier(50);
    segmentBezier(width/2, height, width/2, height-200, width-200, height-200, width, height-200,50);
  }

  if (key=='u') {
    penUp();
  }

  if (key=='d') {
    penDown();
  }
}


void moveTo(int posX, int posY) {
  penUp();
  String cmd = "G1 X"+posX+" Y"+posY;
  commands.append(cmd);
}

void penUp() {
  String cmd = "M1 100d";
  commands.append(cmd);
}

void penDown() {
  String cmd = "M1 10d";
  commands.append(cmd);
}

void goHome() {
  penUp();
  String cmd="G28";
  commands.append(cmd);
}


void drawTo(int posX, int posY) {
  penDown();
  String cmd = "G1 X"+posX+" Y"+posY;
  commands.append(cmd);
  penUp();
}


void sendFeed() {
  if (commands.size()>0) {
    println(commands.size()+" commands in buffer");
    String cmd = commands.get(0);
    println("command " +cmd);
    cmd+='\n';
    myPort.write(cmd);
    commands.remove(0);
    done=false;
  }
}


// This is where we read
void serialEvent(Serial p) {
  inString = (myPort.readStringUntil('\n'));
  inString=inString.trim();
  println("Incoming: "+inString);
  if (inString.equals("OK") == true) {
    done=true;
  } else {
  }
}